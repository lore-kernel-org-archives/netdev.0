From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 0/21] bonding: use neighbours instead of own lists
Date: Mon,  2 Sep 2013 23:39:04 +0200
Message-ID: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932326Ab3IBVkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:40:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(on top of "net: correctly interlink lower/upper devices" - the fix is
vital)

Hi,

I'm sending it as early as possible, because it's quite a big patchset and
some of the approaches I've chosen are not really easy/straightforward. It
will require a lot of work, obviously, before I can send it as a proper
patchset ready to be considered for inclusion, even though it works now.

I'm sending it to gather any feedback possible.

This patchset introduces all the needed infrastructure, on top of current
adjacent lists, to be able to remove bond's slave_list/slave->list. The
overhead in memory/CPU is minimal, and after the patchset bonding can rely
on its slave-related functions, given the proper locking.

It also automatically creates slave/upper and master symlinks in dev's
sysfs directory.

The current version works ok, as first tests have shown. I'm testing it
further.

Here is a short description of each:

net: add neighbour_dev_list to save only neighbours
	Adding two new lists, each for the device neighbours only - it's
	done for speed when going through slaves.
net: add RCU variant to search for netdev_adjacent link
net: add netdev_adjacent->private and allow to use it
	These two patches add infrastructure for the netdev_adjacent new
	member - private, which contains master's private info for the
	slave - in case of bonding it's struct slave *.
net: expose the master link to sysfs, and remove it from bond
	Create sysfs link for master devices.
vlan: link the upper neighbour only after registering
	vlan linked itself before registering, which ends badly if we'll
	have a user before it registers, and is not ready for sysfs
	operations.
net: create sysfs symlinks for neighbour devices
	Create sysfs links to slave/upper devices.
bonding: add bond_has_slaves() and use it
	It'll be easier for modification in the future.
bonding: convert bond_has_slaves() to use the neighbour list
	First usage of the neighbour_dev_list.lower - bonding's lower
	devices are *always* slaves, so we can verify if it's empty or not.
bonding: populate neighbour's private on enslave
	Attach struct slave * to each lower link.
bonding: modify bond_get_slave_by_dev() to use neighbours
	We can search already for ->private here.
bonding: remove bond_for_each_slave_reverse()
	It's useless and hard to read sometimes.
net: add for_each iterators through neighbour lower link's private
bonding: make bond_for_each_slave() use lower neighbour's private
	These two patches convert bond_for_each_slave() to use neighbours
	lower list.
net: add netdev_for_each_lower_neigh_private_continue()
bonding: use neighbour list for bond_for_each_slave_continue()
	These two - bond_for_each_slave_continue().
net: add a possibility to get private from netdev_adjacent->list
bonding: convert first/last slave logic to use neighbours
	Convert those little helpers without huge functions - just use the
	list's next/prev.
net: add a function to get the next/prev private
bonding: use neighbours for bond_next/prev_slave()
	Same.
bonding: use bond_for_each_slave() in bond_uninit()
	We can safely use it - we're using the ->next field.
bonding: remove slave lists
	Finally.

I'll update if anything comes up.

Thanks in advance.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
CC: Patrick McHardy <kaber@trash.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_3ad.c    |  13 +-
 drivers/net/bonding/bond_alb.c    |  42 ++--
 drivers/net/bonding/bond_main.c   | 204 +++++++++-------
 drivers/net/bonding/bond_procfs.c |   5 +-
 drivers/net/bonding/bond_sysfs.c  |  62 ++---
 drivers/net/bonding/bonding.h     |  65 ++---
 include/linux/netdevice.h         |  67 +++++-
 net/8021q/vlan.c                  |  14 +-
 net/core/dev.c                    | 483 +++++++++++++++++++++++++++++++++-----
 9 files changed, 686 insertions(+), 269 deletions(-)
