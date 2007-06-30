From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Fix secondary unicast/multicast address count maintenance
Date: Sat, 30 Jun 2007 18:46:29 +0200
Message-ID: <468688E5.20106@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070503000605080308020601"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38545 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755581AbXF3Qsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 12:48:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070503000605080308020601
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Fix a bug introduced by the secondary unicast address patches.




--------------070503000605080308020601
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Fix secondary unicast/multicast address count maintenance

When a reference to an existing address is increased or decreased without
hitting zero, the address count is incorrectly adjusted.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 84de3fc644b2a98be30519225b088fa8856a8ce4
tree 1ae3a42ed15d68ec21707f72b42a406dad8ee606
parent e1749582c9c230fb2cc0292cf824b30b04f80ee6
author Patrick McHardy <kaber@trash.net> Sat, 30 Jun 2007 17:23:23 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 30 Jun 2007 17:23:23 +0200

 include/linux/netdevice.h |    4 ++--
 net/core/dev.c            |   21 ++++++++++-----------
 net/core/dev_mcast.c      |   11 ++++-------
 3 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2c0cc19..296a59b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1021,8 +1021,8 @@ extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern void		dev_mc_discard(struct net_device *dev);
-extern int 		__dev_addr_delete(struct dev_addr_list **list, void *addr, int alen, int all);
-extern int		__dev_addr_add(struct dev_addr_list **list, void *addr, int alen, int newonly);
+extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
+extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
 extern void		__dev_addr_discard(struct dev_addr_list **list);
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
diff --git a/net/core/dev.c b/net/core/dev.c
index f453127..2ce5546 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2602,8 +2602,8 @@ void dev_set_rx_mode(struct net_device *dev)
 	netif_tx_unlock_bh(dev);
 }
 
-int __dev_addr_delete(struct dev_addr_list **list, void *addr, int alen,
-		      int glbl)
+int __dev_addr_delete(struct dev_addr_list **list, int *count,
+		      void *addr, int alen, int glbl)
 {
 	struct dev_addr_list *da;
 
@@ -2621,13 +2621,15 @@ int __dev_addr_delete(struct dev_addr_list **list, void *addr, int alen,
 
 			*list = da->next;
 			kfree(da);
+			(*count)--;
 			return 0;
 		}
 	}
 	return -ENOENT;
 }
 
-int __dev_addr_add(struct dev_addr_list **list, void *addr, int alen, int glbl)
+int __dev_addr_add(struct dev_addr_list **list, int *count,
+		   void *addr, int alen, int glbl)
 {
 	struct dev_addr_list *da;
 
@@ -2654,6 +2656,7 @@ int __dev_addr_add(struct dev_addr_list **list, void *addr, int alen, int glbl)
 	da->da_gusers = glbl ? 1 : 0;
 	da->next = *list;
 	*list = da;
+	(*count)++;
 	return 0;
 }
 
@@ -2687,11 +2690,9 @@ int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
 	ASSERT_RTNL();
 
 	netif_tx_lock_bh(dev);
-	err = __dev_addr_delete(&dev->uc_list, addr, alen, 0);
-	if (!err) {
-		dev->uc_count--;
+	err = __dev_addr_delete(&dev->uc_list, &dev->uc_count, addr, alen, 0);
+	if (!err)
 		__dev_set_rx_mode(dev);
-	}
 	netif_tx_unlock_bh(dev);
 	return err;
 }
@@ -2713,11 +2714,9 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 	ASSERT_RTNL();
 
 	netif_tx_lock_bh(dev);
-	err = __dev_addr_add(&dev->uc_list, addr, alen, 0);
-	if (!err) {
-		dev->uc_count++;
+	err = __dev_addr_add(&dev->uc_list, &dev->uc_count, addr, alen, 0);
+	if (!err)
 		__dev_set_rx_mode(dev);
-	}
 	netif_tx_unlock_bh(dev);
 	return err;
 }
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 5cc9b44..aa38100 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -72,10 +72,9 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 	int err;
 
 	netif_tx_lock_bh(dev);
-	err = __dev_addr_delete(&dev->mc_list, addr, alen, glbl);
+	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
+				addr, alen, glbl);
 	if (!err) {
-		dev->mc_count--;
-
 		/*
 		 *	We have altered the list, so the card
 		 *	loaded filter is now wrong. Fix it
@@ -96,11 +95,9 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 	int err;
 
 	netif_tx_lock_bh(dev);
-	err = __dev_addr_add(&dev->mc_list, addr, alen, glbl);
-	if (!err) {
-		dev->mc_count++;
+	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
+	if (!err)
 		__dev_set_rx_mode(dev);
-	}
 	netif_tx_unlock_bh(dev);
 	return err;
 }

--------------070503000605080308020601--
