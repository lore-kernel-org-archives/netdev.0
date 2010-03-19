From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] bonding: flush unicast and multicast lists when
 changing type
Date: Fri, 19 Mar 2010 15:00:23 +0100
Message-ID: <20100319140023.GC2811@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab0CSOAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 10:00:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the type change, addresses in unicast and multicast lists wouldn't make
sense, not to mention possible different lenghts. So flush both lists here.

Note "dev_addr_discard" will be very soon replaced by "dev_mc_flush" (once
mc_list conversion will be done).

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    4 ++++
 include/linux/netdevice.h       |    2 ++
 net/core/dev.c                  |    6 ++++--
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index cbe9e35..c2aceaa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1490,6 +1490,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 				goto err_undo_flags;
 			}
 
+			/* Flush unicast and multicast addresses */
+			dev_unicast_flush(bond_dev);
+			dev_addr_discard(bond_dev);
+
 			if (slave_dev->type != ARPHRD_ETHER)
 				bond_setup_by_slave(bond_dev, slave_dev);
 			else
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 813bed7..3cff4ba 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1994,10 +1994,12 @@ extern int		dev_unicast_delete(struct net_device *dev, void *addr);
 extern int		dev_unicast_add(struct net_device *dev, void *addr);
 extern int		dev_unicast_sync(struct net_device *to, struct net_device *from);
 extern void		dev_unicast_unsync(struct net_device *to, struct net_device *from);
+extern void		dev_unicast_flush(struct net_device *dev);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
 extern void		dev_mc_unsync(struct net_device *to, struct net_device *from);
+extern void		dev_addr_discard(struct net_device *dev);
 extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
 extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
 extern int		__dev_addr_sync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
diff --git a/net/core/dev.c b/net/core/dev.c
index d1f027c..80a0608 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4455,12 +4455,13 @@ void dev_unicast_unsync(struct net_device *to, struct net_device *from)
 }
 EXPORT_SYMBOL(dev_unicast_unsync);
 
-static void dev_unicast_flush(struct net_device *dev)
+void dev_unicast_flush(struct net_device *dev)
 {
 	netif_addr_lock_bh(dev);
 	__hw_addr_flush(&dev->uc);
 	netif_addr_unlock_bh(dev);
 }
+EXPORT_SYMBOL(dev_unicast_flush);
 
 static void dev_unicast_init(struct net_device *dev)
 {
@@ -4482,7 +4483,7 @@ static void __dev_addr_discard(struct dev_addr_list **list)
 	}
 }
 
-static void dev_addr_discard(struct net_device *dev)
+void dev_addr_discard(struct net_device *dev)
 {
 	netif_addr_lock_bh(dev);
 
@@ -4491,6 +4492,7 @@ static void dev_addr_discard(struct net_device *dev)
 
 	netif_addr_unlock_bh(dev);
 }
+EXPORT_SYMBOL(dev_addr_discard);
 
 /**
  *	dev_get_flags - get flags reported to userspace
-- 
1.6.6.1

