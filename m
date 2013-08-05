From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next,1/3] bonding: fix vlan 0 addition and removal
Date: Mon, 5 Aug 2013 23:51:26 +0200
Message-ID: <20130805215126.GB3859@redhat.com>
References: <1375709304-16778-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, kaber@trash.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506Ab3HEVvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:51:40 -0400
Content-Disposition: inline
In-Reply-To: <1375709304-16778-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 03:28:22PM +0200, nikolay@redhat.com wrote:
...snip...
>This is fixed by forbidding the addition/removal of vlan 0 through the
>bond's ndo_vlan_rx_add/kill_vid functions, and adding/removing it only when
>vlan 0 is in fact being created (or destroyed) on top of a bond interface
>in the bond's netdev handling function.

Isn't that a bit too intrusive/hacky? I don't think we should treat vlan id
0 somehow differently in terms of adding/removing, though I might be
wrong...

Maybe we should just fix the bond_vlan_used() function? Something like
this (I've done only basic testing, can do more thorough if needed), though
it's also not a really clean fix:

>From 1c89abefebe90568ed52d2df59fcfdd650bc4696 Mon Sep 17 00:00:00 2001
From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon, 5 Aug 2013 23:29:12 +0200
Subject: [PATCH] bonding: add vlan_uses_dev_rcu() and make bond_vlan_used() use it

Currently, bond_vlan_used() looks for any vlan, including the pseudo-vlan
id 0, and always returns true if 8021q is loaded. This creates several bad
situations - some warnings in __bond_release_one() because it thinks that
we still have vlans while removing, sending LB packets with vlan id 0 and,
possibly, other caused by vlan id 0.

Fix it by adding a new call, vlan_uses_dev_rcu(), which is the same as
vlan_uses_dev(), but uses rcu_dereference() instead of rtnl, and thus we
can use it in bond_vlan_used() wrapped in rcu_read_lock().

Also, use the pure vlan_uses_dev() in __bond_release_one() cause the rtnl
lock is held there.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Patrick McHardy <kaber@trash.net>
CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
  drivers/net/bonding/bond_alb.c  |  1 -
  drivers/net/bonding/bond_main.c |  3 +--
  drivers/net/bonding/bonding.h   | 10 +++++++++-
  include/linux/if_vlan.h         |  6 ++++++
  net/8021q/vlan_core.c           | 11 +++++++++++
  5 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 3a5db7b..2684329 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -34,7 +34,6 @@
  #include <linux/if_arp.h>
  #include <linux/if_ether.h>
  #include <linux/if_bonding.h>
-#include <linux/if_vlan.h>
  #include <linux/in.h>
  #include <net/ipx.h>
  #include <net/arp.h>
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5697043..b8c36ac 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -69,7 +69,6 @@
  #include <net/arp.h>
  #include <linux/mii.h>
  #include <linux/ethtool.h>
-#include <linux/if_vlan.h>
  #include <linux/if_bonding.h>
  #include <linux/jiffies.h>
  #include <linux/preempt.h>
@@ -1976,7 +1975,7 @@ static int __bond_release_one(struct net_device *bond_dev,
  		bond_set_carrier(bond);
  		eth_hw_addr_random(bond_dev);
  
-		if (bond_vlan_used(bond)) {
+		if (vlan_uses_dev(bond_dev)) {
  			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
  				   bond_dev->name, bond_dev->name);
  			pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4bf52d5..cb49313 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -23,6 +23,7 @@
  #include <linux/netpoll.h>
  #include <linux/inetdevice.h>
  #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
  #include "bond_3ad.h"
  #include "bond_alb.h"
  
@@ -267,9 +268,16 @@ struct bonding {
  #endif /* CONFIG_DEBUG_FS */
  };
  
+/* use vlan_uses_dev() if under rtnl */
  static inline bool bond_vlan_used(struct bonding *bond)
  {
-	return !list_empty(&bond->vlan_list);
+	bool ret;
+
+	rcu_read_lock();
+	ret = vlan_uses_dev_rcu(bond->dev);
+	rcu_read_unlock();
+
+	return ret;
  }
  
  #define bond_slave_get_rcu(dev) \
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 715c343..1fcea36 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -101,6 +101,7 @@ extern void vlan_vids_del_by_dev(struct net_device *dev,
  				 const struct net_device *by_dev);
  
  extern bool vlan_uses_dev(const struct net_device *dev);
+extern bool vlan_uses_dev_rcu(const struct net_device *dev);
  #else
  static inline struct net_device *
  __vlan_find_dev_deep(struct net_device *real_dev,
@@ -155,6 +156,11 @@ static inline bool vlan_uses_dev(const struct net_device *dev)
  {
  	return false;
  }
+
+static inline bool vlan_uses_dev_rcu(const struct net_device *dev)
+{
+	return false;
+}
  #endif
  
  static inline bool vlan_hw_offload_capable(netdev_features_t features,
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 4a78c4d..52e3fb3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -399,3 +399,14 @@ bool vlan_uses_dev(const struct net_device *dev)
  	return vlan_info->grp.nr_vlan_devs ? true : false;
  }
  EXPORT_SYMBOL(vlan_uses_dev);
+
+bool vlan_uses_dev_rcu(const struct net_device *dev)
+{
+	struct vlan_info *vlan_info;
+
+	vlan_info = rcu_dereference(dev->vlan_info);
+	if (!vlan_info)
+		return false;
+	return vlan_info->grp.nr_vlan_devs ? true : false;
+}
+EXPORT_SYMBOL(vlan_uses_dev_rcu);
-- 
1.8.1.4
