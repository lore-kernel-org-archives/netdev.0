From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v4 0/13] bonding: remove vlan special handling
Date: Wed, 28 Aug 2013 23:25:03 +0200
Message-ID: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122Ab3H1VZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 17:25:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1: Per Jiri's advice, remove the exported netdev_upper struct to keep it
    inside dev.c only, and instead implement a macro to iterate over the
    list and return only net_device *.
v2: Jiri noted that we need to see every upper device, but not only the
    first level. Modify the netdev_upper logic to include a list of lower
    devices and for both upper/lower lists every device would see both its
    first-level devices and every other devices that is lower/upper of it.
    Also, convert some annoying spamming warnings to pr_debug in
    bond_arp_send_all.
v3: move renaming part completely to patch 1 (did I forget to git add
    before commiting?) and address Jiri's input about comments/style of
    patch 2.
v4: as Vlad found spotted, bond_arp_send_all() won't work in a config where
    we have a device with ip on top of our upper vlan. It fails to send
    packets because we don't tag the packet, while the device on top of
    vlan will emit tagged packets through this vlan. Fix this by first
    searching for all upper vlans, and for each vlan - for the devs on top
    of it. If we find the dev - then tag the packet with the underling's
    vlan_id, otherwise just search the old way - for all devices on top of
    bonding. Also, move the version changes under "---" so they won't get
    into the commit message, if/when applied.

The aim of this patchset is to remove bondings' own vlan handling as much
as possible and replace it with the netdev upper device functionality.

The upper device functionality is extended to include also lower devices
and to have, for each device, a full view of every lower and upper device,
but not only the first-level ones. This might permit in the future to
avoid, for any grouping/teaming/upper/lower devices, to maintain its own
lists of slaves/vlans/etc.

This is achieved by adding a helper function to upper dev list handling -
netdev_upper_get_next_dev(dev, iter), which returns the next device after
the list_head **iter, and sets *iter to the next list_head *. This patchset
also adds netdev_for_each_upper_dev(dev, upper, iter), which iterates
through the whole dev->upper_dev_list, setting upper to the net_device.
The only special treatment of vlans remains in rlb code.

This patchset solves several issues with bonding, simplifies it overall,
RCUify further and exports upper list functions for any other users which
might also want to get rid of its own vlan_lists or slaves.

I'm testing it continuously currently, no issues found, will update on
anything.

CC: Vlad Yasevich <vyasevic@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_alb.c  |  75 +++++----
 drivers/net/bonding/bond_alb.h  |   2 -
 drivers/net/bonding/bond_main.c | 272 +++++++++----------------------
 drivers/net/bonding/bonding.h   |  21 ++-
 include/linux/netdevice.h       |  11 ++
 net/core/dev.c                  | 345 ++++++++++++++++++++++++++++++++--------
 6 files changed, 416 insertions(+), 310 deletions(-)
