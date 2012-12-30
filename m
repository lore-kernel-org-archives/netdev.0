From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V4 00/15] net: introduce upper device lists and remove dev->master
Date: Sun, 30 Dec 2012 12:58:07 +0100
Message-ID: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:54596 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab2L3L6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 06:58:37 -0500
Received: by mail-ea0-f175.google.com with SMTP id h11so4801761eaa.20
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 03:58:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a V4 of a repost of my previous patchset:
"[patch net-next v2 00/15] net: introduce upper device lists and remove dev->master" from Aug 14

The discussion around
"[net-next] bonding: don't allow the master to become its slave"
forced me to think about upper<->lower device connections.

This patchset adds a possibility to record upper device linkage.
All upper<->lower devices are converted to use this mechanism right after.
That leads to dev->master removal because this info becomes redundant since
"master links" have the same value.

After all changes, there is no longer possible to do things as:
"bond->someotherdevice->samebond"

Also I think that drivers like cxgb3, qlcnic, qeth would benefit by this
in future by being able to get more appropriate info about l3 addresses.

v3->v4:
- comments in __netdev_upper_dev_link() squashed into one line
- kfree_rcu used instead of call_rcu in netdev_upper_dev_unlink() 

v2->v3:
- removed recursion in __netdev_has_upper_dev()
- refreshed bits to be applicable on current net-next

v1->v2:
- s/unique/master/ better naming + stays closer to the past
- fixed vlan err goto
- original patch 15 (WARN_ON change) is squashed into the first patch

Jiri Pirko (15):
  net: introduce upper device lists
  macvlan: add link to upper device
  vlan: add link to upper device
  rtnetlink: remove usage of dev->master
  team: remove usage of netdev_set_master()
  bridge: remove usage of netdev_set_master()
  netpoll: remove usage of dev->master
  cxgb3: remove usage of dev->master
  qlcnic: guard __vlan_find_dev_deep() by rcu_read_lock
  qeth: ensure that __vlan_find_dev_deep() is called with rcu_read_lock
  vlan: remove usage of dev->master in __vlan_find_dev_deep()
  nes: remove usage of dev->master
  bonding: remove usage of dev->master
  net: remove no longer used netdev_set_bond_master() and
    netdev_set_master()
  net: kill dev->master

 drivers/infiniband/hw/nes/nes.c                    |   8 +-
 drivers/infiniband/hw/nes/nes_cm.c                 |   2 +-
 drivers/net/bonding/bond_3ad.c                     |  30 +--
 drivers/net/bonding/bond_alb.c                     |   6 +-
 drivers/net/bonding/bond_main.c                    |  94 ++++----
 drivers/net/bonding/bonding.h                      |  14 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |  11 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   2 +
 drivers/net/macvlan.c                              |   9 +-
 drivers/net/team/team.c                            |  13 +-
 drivers/s390/net/qeth_l3_main.c                    |  21 +-
 include/linux/netdevice.h                          |  22 +-
 net/8021q/vlan.c                                   |  10 +-
 net/8021q/vlan_core.c                              |  18 +-
 net/bridge/br_if.c                                 |   6 +-
 net/core/dev.c                                     | 244 +++++++++++++++++----
 net/core/netpoll.c                                 |   9 +-
 net/core/rtnetlink.c                               |  70 +++---
 18 files changed, 407 insertions(+), 182 deletions(-)

-- 
1.8.0
