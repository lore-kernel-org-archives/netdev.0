From: Patrick McHardy <kaber@trash.net>
Subject: [NET 03/05]: dev_mcast: switch to generic net_device address lists
Date: Fri, 22 Jun 2007 14:24:10 +0200 (MEST)
Message-ID: <20070622122335.15215.27024.sendpatchset@localhost.localdomain>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62396 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbXFVMYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 08:24:11 -0400
In-Reply-To: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: dev_mcast: switch to generic net_device address lists

Use generic net_device address lists for multicast list handling.
Some defines are used to keep drivers working.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 02536a101d6fd8b1924b1e05c44409c7b4568335
tree 6624b4f7f6fb0b10bac091ca43b733dfd1609afc
parent 6d8fd140951de7cc8faab4922dba74dd1db3cae5
author Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 03:25:28 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 03:25:28 +0200

 include/linux/netdevice.h |   17 +++-----
 net/core/dev_mcast.c      |   96 +++++++--------------------------------------
 2 files changed, 22 insertions(+), 91 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3785a8a..b2db124 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -189,15 +189,12 @@ struct dev_addr_list
 /*
  *	We tag multicasts with these structures.
  */
- 
-struct dev_mc_list
-{	
-	struct dev_mc_list	*next;
-	__u8			dmi_addr[MAX_ADDR_LEN];
-	unsigned char		dmi_addrlen;
-	int			dmi_users;
-	int			dmi_gusers;
-};
+
+#define dev_mc_list	dev_addr_list
+#define dmi_addr	da_addr
+#define dmi_addrlen	da_addrlen
+#define dmi_users	da_users
+#define dmi_gusers	da_gusers
 
 struct hh_cache
 {
@@ -396,7 +393,7 @@ struct net_device
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */
 
-	struct dev_mc_list	*mc_list;	/* Multicast mac addresses	*/
+	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
 	int			mc_count;	/* Number of installed mcasts	*/
 	int			promiscuity;
 	int			allmulti;
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 80bb2e3..7029074 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -102,47 +102,20 @@ void dev_mc_upload(struct net_device *dev)
 
 int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 {
-	int err = 0;
-	struct dev_mc_list *dmi, **dmip;
+	int err;
 
 	netif_tx_lock_bh(dev);
+	err = __dev_addr_delete(&dev->mc_list, addr, alen, glbl);
+	if (!err) {
+		dev->mc_count--;
 
-	for (dmip = &dev->mc_list; (dmi = *dmip) != NULL; dmip = &dmi->next) {
 		/*
-		 *	Find the entry we want to delete. The device could
-		 *	have variable length entries so check these too.
+		 *	We have altered the list, so the card
+		 *	loaded filter is now wrong. Fix it
 		 */
-		if (memcmp(dmi->dmi_addr, addr, dmi->dmi_addrlen) == 0 &&
-		    alen == dmi->dmi_addrlen) {
-			if (glbl) {
-				int old_glbl = dmi->dmi_gusers;
-				dmi->dmi_gusers = 0;
-				if (old_glbl == 0)
-					break;
-			}
-			if (--dmi->dmi_users)
-				goto done;
-
-			/*
-			 *	Last user. So delete the entry.
-			 */
-			*dmip = dmi->next;
-			dev->mc_count--;
-
-			kfree(dmi);
-
-			/*
-			 *	We have altered the list, so the card
-			 *	loaded filter is now wrong. Fix it
-			 */
-			__dev_mc_upload(dev);
-
-			netif_tx_unlock_bh(dev);
-			return 0;
-		}
+
+		__dev_mc_upload(dev);
 	}
-	err = -ENOENT;
-done:
 	netif_tx_unlock_bh(dev);
 	return err;
 }
@@ -153,46 +126,15 @@ done:
 
 int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 {
-	int err = 0;
-	struct dev_mc_list *dmi, *dmi1;
-
-	dmi1 = kmalloc(sizeof(*dmi), GFP_ATOMIC);
+	int err;
 
 	netif_tx_lock_bh(dev);
-	for (dmi = dev->mc_list; dmi != NULL; dmi = dmi->next) {
-		if (memcmp(dmi->dmi_addr, addr, dmi->dmi_addrlen) == 0 &&
-		    dmi->dmi_addrlen == alen) {
-			if (glbl) {
-				int old_glbl = dmi->dmi_gusers;
-				dmi->dmi_gusers = 1;
-				if (old_glbl)
-					goto done;
-			}
-			dmi->dmi_users++;
-			goto done;
-		}
-	}
-
-	if ((dmi = dmi1) == NULL) {
-		netif_tx_unlock_bh(dev);
-		return -ENOMEM;
+	err = __dev_addr_add(&dev->mc_list, addr, alen, glbl);
+	if (!err) {
+		dev->mc_count++;
+		__dev_mc_upload(dev);
 	}
-	memcpy(dmi->dmi_addr, addr, alen);
-	dmi->dmi_addrlen = alen;
-	dmi->next = dev->mc_list;
-	dmi->dmi_users = 1;
-	dmi->dmi_gusers = glbl ? 1 : 0;
-	dev->mc_list = dmi;
-	dev->mc_count++;
-
-	__dev_mc_upload(dev);
-
 	netif_tx_unlock_bh(dev);
-	return 0;
-
-done:
-	netif_tx_unlock_bh(dev);
-	kfree(dmi1);
 	return err;
 }
 
@@ -203,16 +145,8 @@ done:
 void dev_mc_discard(struct net_device *dev)
 {
 	netif_tx_lock_bh(dev);
-
-	while (dev->mc_list != NULL) {
-		struct dev_mc_list *tmp = dev->mc_list;
-		dev->mc_list = tmp->next;
-		if (tmp->dmi_users > tmp->dmi_gusers)
-			printk("dev_mc_discard: multicast leakage! dmi_users=%d\n", tmp->dmi_users);
-		kfree(tmp);
-	}
+	__dev_addr_discard(&dev->mc_list);
 	dev->mc_count = 0;
-
 	netif_tx_unlock_bh(dev);
 }
 
@@ -244,7 +178,7 @@ static void dev_mc_seq_stop(struct seq_file *seq, void *v)
 
 static int dev_mc_seq_show(struct seq_file *seq, void *v)
 {
-	struct dev_mc_list *m;
+	struct dev_addr_list *m;
 	struct net_device *dev = v;
 
 	netif_tx_lock_bh(dev);
