From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 00/27] bonding: use neighbours instead of own lists
Date: Tue, 17 Sep 2013 02:46:25 +0200
Message-ID: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Dimitris Michailidis <dm@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903Ab3IQAq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:46:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduces all the needed infrastructure, on top of current
adjacent lists, to be able to remove bond's slave_list/slave->list. The
overhead in memory/CPU is minimal, and after the patchset bonding can rely
on its slave-related functions, given the proper locking. I've done some
netperf benchmarks on a vm, and the delta was about 0.1gbps for 35gbps as a
whole, so no speed fluctuations.

It also automatically creates lower/upper and master symlinks in dev's
sysfs directory.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Dimitris Michailidis <dm@chelsio.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Patrick McHardy <kaber@trash.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
v2  -> v3:
Fix the commit subject for patch 08 - forgot the _continue in
bond_for_each_slave_continue_reverse(), suggested by Cong Wang.
This version is already ready for the inclusion, hopefully.
Moved the changelog in cover letter to the bottom and cleaned it
up a bit.

v1  -> v2:
Fix a bug when we could remove try to remove a neighbour twice - it was
possible if we've had this neighbour already and added another devices
which had this neighbour in its lists. Fix it by following the rule - there
can be only one neighbour link, so add also _remove_neighbour() functions
to the generic _remove()s to handle the neighbour only removing, and fix
its refcounting while adding (all in patch 01).
Also, fix a vlan bug when it called unregister netdevice before unlinking -
it could possibly lead to a subte race condition - cause it was
unregistered but still in global-accessible list.
Rearrange sysfs/vlan patches so that first we fix vlan and only after we
add sysfs stuff.

RFC -> v1:
I've added proper, consistent naming for all variables/functions, uninlined
some helpers to get better backtraces, just in case (overhead is minimal,
no hot paths), rearranged patches for better review, dropped bondings
->prev and bond_for_each_slave_continue() functionality - to be able to
RCUify it easier, and renamed slave_* sysfs links to lower_* sysfs links to
maintain upper/lower naming. I've also dropped, thanks to bonding cleanup,
some heavy and ugly/intrusive patches.


 drivers/net/bonding/bond_3ad.c                  |  54 +--
 drivers/net/bonding/bond_alb.c                  |  81 ++--
 drivers/net/bonding/bond_alb.h                  |   4 +-
 drivers/net/bonding/bond_main.c                 | 296 ++++++++-------
 drivers/net/bonding/bond_procfs.c               |   5 +-
 drivers/net/bonding/bond_sysfs.c                |  62 +--
 drivers/net/bonding/bonding.h                   |  74 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   3 +-
 include/linux/netdevice.h                       |  57 ++-
 net/8021q/vlan.c                                |  18 +-
 net/core/dev.c                                  | 482 +++++++++++++++++++-----
 11 files changed, 724 insertions(+), 412 deletions(-)
