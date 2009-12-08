From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/20] net/atm/lec.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:05 -0800
Message-ID: <6b7d2866d4d992d1019c7f227576f086ad017607.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1055 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932406AbZLHF5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:14 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/lec.c |  286 +++++++++++++++++++++++++++------------------------------
 1 files changed, 137 insertions(+), 149 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 31eab00..92f536c 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -18,7 +18,7 @@
 #include <linux/skbuff.h>
 #include <linux/ip.h>
 #include <asm/byteorder.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <net/arp.h>
 #include <net/dst.h>
 #include <linux/proc_fs.h>
@@ -88,17 +88,19 @@ static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
 				       int is_rdesc,
 				       struct lec_arp_table **ret_entry);
 static void lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
-			   const unsigned char *atm_addr, unsigned long remoteflag,
+			   const unsigned char *atm_addr,
+			   unsigned long remoteflag,
 			   unsigned int targetless_le_arp);
 static void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id);
 static int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc);
 static void lec_set_flush_tran_id(struct lec_priv *priv,
 				  const unsigned char *atm_addr,
 				  unsigned long tran_id);
-static void lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
+static void lec_vcc_added(struct lec_priv *priv,
+			  const struct atmlec_ioc *ioc_data,
 			  struct atm_vcc *vcc,
-			  void (*old_push) (struct atm_vcc *vcc,
-					    struct sk_buff *skb));
+			  void (*old_push)(struct atm_vcc *vcc,
+					   struct sk_buff *skb));
 static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc);
 
 /* must be done under lec_arp_lock */
@@ -113,7 +115,6 @@ static inline void lec_arp_put(struct lec_arp_table *entry)
 		kfree(entry);
 }
 
-
 static struct lane2_ops lane2_ops = {
 	lane2_resolve,		/* resolve,             spec 3.1.3 */
 	lane2_associate_req,	/* associate_req,       spec 3.1.4 */
@@ -151,7 +152,8 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		mesg = (struct atmlec_msg *)skb2->data;
 		mesg->type = l_topology_change;
 		buff += 4;
-		mesg->content.normal.flag = *buff & 0x01;	/* 0x01 is topology change */
+		mesg->content.normal.flag = *buff & 0x01;
+					/* 0x01 is topology change */
 
 		priv = netdev_priv(dev);
 		atm_force_charge(priv->lecd, skb2->truesize);
@@ -264,14 +266,10 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	unsigned char rdesc[ETH_ALEN];	/* Token Ring route descriptor */
 #endif
 	int is_rdesc;
-#if DUMP_PACKETS > 0
-	char buf[300];
-	int i = 0;
-#endif /* DUMP_PACKETS >0 */
 
 	pr_debug("called\n");
 	if (!priv->lecd) {
-		printk("%s:No lecd attached\n", dev->name);
+		pr_info("%s:No lecd attached\n", dev->name);
 		dev->stats.tx_errors++;
 		netif_stop_queue(dev);
 		kfree_skb(skb);
@@ -316,23 +314,17 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	}
 #endif
 
-#if DUMP_PACKETS > 0
-	printk("%s: send datalen:%ld lecid:%4.4x\n", dev->name,
-	       skb->len, priv->lecid);
 #if DUMP_PACKETS >= 2
-	for (i = 0; i < skb->len && i < 99; i++) {
-		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
-	}
+#define MAX_DUMP_SKB 99
 #elif DUMP_PACKETS >= 1
-	for (i = 0; i < skb->len && i < 30; i++) {
-		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
-	}
+#define MAX_DUMP_SKB 30
+#endif
+#if DUMP_PACKETS >= 1
+	printk(KERN_DEBUG "%s: send datalen:%ld lecid:%4.4x\n", dev->name,
+	       skb->len, priv->lecid);
+	print_hex_dump(KERN_DEBUG, "", DUMP_OFFSET, 16, 1,
+		       skb->data, min(skb->len, MAX_DUMP_SKB), true);
 #endif /* DUMP_PACKETS >= 1 */
-	if (i == skb->len)
-		printk("%s\n", buf);
-	else
-		printk("%s...\n", buf);
-#endif /* DUMP_PACKETS > 0 */
 
 	/* Minimum ethernet-frame size */
 #ifdef CONFIG_TR
@@ -386,7 +378,8 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 		goto out;
 	}
 #if DUMP_PACKETS > 0
-	printk("%s:sending to vpi:%d vci:%d\n", dev->name, vcc->vpi, vcc->vci);
+	printk(KERN_DEBUG "%s:sending to vpi:%d vci:%d\n",
+	       dev->name, vcc->vpi, vcc->vci);
 #endif /* DUMP_PACKETS > 0 */
 
 	while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
@@ -443,14 +436,12 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 	pr_debug("%s: msg from zeppelin:%d\n", dev->name, mesg->type);
 	switch (mesg->type) {
 	case l_set_mac_addr:
-		for (i = 0; i < 6; i++) {
+		for (i = 0; i < 6; i++)
 			dev->dev_addr[i] = mesg->content.normal.mac_addr[i];
-		}
 		break;
 	case l_del_mac_addr:
-		for (i = 0; i < 6; i++) {
+		for (i = 0; i < 6; i++)
 			dev->dev_addr[i] = 0;
-		}
 		break;
 	case l_addr_delete:
 		lec_addr_delete(priv, mesg->content.normal.atm_addr,
@@ -498,13 +489,14 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 		priv->flush_timeout = (mesg->content.config.flush_timeout * HZ);
 		priv->path_switching_delay =
 		    (mesg->content.config.path_switching_delay * HZ);
-		priv->lane_version = mesg->content.config.lane_version;	/* LANE2 */
+		priv->lane_version = mesg->content.config.lane_version;
+					/* LANE2 */
 		priv->lane2_ops = NULL;
 		if (priv->lane_version > 1)
 			priv->lane2_ops = &lane2_ops;
 		if (dev_set_mtu(dev, mesg->content.config.mtu))
-			printk("%s: change_mtu to %d failed\n", dev->name,
-			       mesg->content.config.mtu);
+			pr_info("%s: change_mtu to %d failed\n",
+				dev->name, mesg->content.config.mtu);
 		priv->is_proxy = mesg->content.config.is_proxy;
 		break;
 	case l_flush_tran_id:
@@ -525,16 +517,15 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 				break;
 
 			if (br_fdb_test_addr_hook(dev,
-					mesg->content.proxy.mac_addr)) {
+						  mesg->content.proxy.mac_addr)) {
 				/* hit from bridge table, send LE_ARP_RESPONSE */
 				struct sk_buff *skb2;
 				struct sock *sk;
 
 				pr_debug("%s: entry found, responding to zeppelin\n",
 					 dev->name);
-				skb2 =
-				    alloc_skb(sizeof(struct atmlec_msg),
-					      GFP_ATOMIC);
+				skb2 = alloc_skb(sizeof(struct atmlec_msg),
+						 GFP_ATOMIC);
 				if (skb2 == NULL)
 					break;
 				skb2->len = sizeof(struct atmlec_msg);
@@ -549,7 +540,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
 		break;
 	default:
-		printk("%s: Unknown message type %d\n", dev->name, mesg->type);
+		pr_info("%s: Unknown message type %d\n", dev->name, mesg->type);
 		dev_kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -570,14 +561,13 @@ static void lec_atm_close(struct atm_vcc *vcc)
 	lec_arp_destroy(priv);
 
 	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
-		printk("%s lec_atm_close: closing with messages pending\n",
-		       dev->name);
+		pr_info("%s closing with messages pending\n", dev->name);
 	while ((skb = skb_dequeue(&sk_atm(vcc)->sk_receive_queue)) != NULL) {
 		atm_return(vcc, skb->truesize);
 		dev_kfree_skb(skb);
 	}
 
-	printk("%s: Shut down!\n", dev->name);
+	pr_info("%s: Shut down!\n", dev->name);
 	module_put(THIS_MODULE);
 }
 
@@ -606,9 +596,8 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	struct sk_buff *skb;
 	struct atmlec_msg *mesg;
 
-	if (!priv || !priv->lecd) {
+	if (!priv || !priv->lecd)
 		return -1;
-	}
 	skb = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
 	if (!skb)
 		return -1;
@@ -671,7 +660,7 @@ static const struct net_device_ops lec_netdev_ops = {
 static void lec_init(struct net_device *dev)
 {
 	dev->netdev_ops = &lec_netdev_ops;
-	printk("%s: Initialized!\n", dev->name);
+	pr_info("%s: Initialized!\n", dev->name);
 }
 
 static const unsigned char lec_ctrl_magic[] = {
@@ -696,7 +685,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
 	struct lec_priv *priv = netdev_priv(dev);
 
-#if DUMP_PACKETS >0
+#if DUMP_PACKETS > 0
 	printk(KERN_DEBUG "%s: vcc vpi:%d vci:%d\n",
 	       dev->name, vcc->vpi, vcc->vci);
 #endif
@@ -775,9 +764,8 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 			dev_kfree_skb(skb);
 			return;
 		}
-		if (!hlist_empty(&priv->lec_arp_empty_ones)) {
+		if (!hlist_empty(&priv->lec_arp_empty_ones))
 			lec_arp_check_empties(priv, vcc, skb);
-		}
 		skb_pull(skb, 2);	/* skip lec_id */
 #ifdef CONFIG_TR
 		if (priv->is_trdev)
@@ -824,7 +812,8 @@ static int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 	if (ioc_data.dev_num < 0 || ioc_data.dev_num >= MAX_LEC_ITF ||
 	    !dev_lec[ioc_data.dev_num])
 		return -EINVAL;
-	if (!(vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL)))
+	vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL);
+	if (!vpriv)
 		return -ENOMEM;
 	vpriv->xoff = 0;
 	vpriv->old_pop = vcc->pop;
@@ -915,9 +904,8 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 	priv->flush_timeout = (4 * HZ);
 	priv->path_switching_delay = (6 * HZ);
 
-	if (dev_lec[i]->flags & IFF_UP) {
+	if (dev_lec[i]->flags & IFF_UP)
 		netif_start_queue(dev_lec[i]);
-	}
 	__module_get(THIS_MODULE);
 	return i;
 }
@@ -1119,7 +1107,9 @@ static int lec_seq_show(struct seq_file *seq, void *v)
 	else {
 		struct lec_state *state = seq->private;
 		struct net_device *dev = state->dev;
-		struct lec_arp_table *entry = hlist_entry(state->node, struct lec_arp_table, next);
+		struct lec_arp_table *entry = hlist_entry(state->node,
+							  struct lec_arp_table,
+							  next);
 
 		seq_printf(seq, "%s ", dev->name);
 		lec_info(seq, entry);
@@ -1199,7 +1189,7 @@ static int __init lane_module_init(void)
 #endif
 
 	register_atm_ioctl(&lane_ioctl_ops);
-	printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
+	pr_info("lec.c: " __DATE__ " " __TIME__ " initialized\n");
 	return 0;
 }
 
@@ -1288,13 +1278,13 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 	struct lec_priv *priv = netdev_priv(dev);
 
 	if (compare_ether_addr(lan_dst, dev->dev_addr))
-		return (0);	/* not our mac address */
+		return 0;	/* not our mac address */
 
 	kfree(priv->tlvs);	/* NULL if there was no previous association */
 
 	priv->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
 	if (priv->tlvs == NULL)
-		return (0);
+		return 0;
 	priv->sizeoftlvs = sizeoftlvs;
 
 	skb = alloc_skb(sizeoftlvs, GFP_ATOMIC);
@@ -1304,12 +1294,12 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 	skb_copy_to_linear_data(skb, tlvs, sizeoftlvs);
 	retval = send_to_lecd(priv, l_associate_req, NULL, NULL, skb);
 	if (retval != 0)
-		printk("lec.c: lane2_associate_req() failed\n");
+		pr_info("lec.c: lane2_associate_req() failed\n");
 	/*
 	 * If the previous association has changed we must
 	 * somehow notify other LANE entities about the change
 	 */
-	return (1);
+	return 1;
 }
 
 /*
@@ -1342,12 +1332,12 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 	entry->sizeoftlvs = sizeoftlvs;
 #endif
 #if 0
-	printk("lec.c: lane2_associate_ind()\n");
-	printk("dump of tlvs, sizeoftlvs=%d\n", sizeoftlvs);
+	pr_info("\n");
+	pr_info("dump of tlvs, sizeoftlvs=%d\n", sizeoftlvs);
 	while (i < sizeoftlvs)
-		printk("%02x ", tlvs[i++]);
+		pr_cont("%02x ", tlvs[i++]);
 
-	printk("\n");
+	pr_cont("\n");
 #endif
 
 	/* tell MPOA about the TLVs we saw */
@@ -1367,13 +1357,13 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 
 #include <linux/types.h>
 #include <linux/timer.h>
-#include <asm/param.h>
+#include <linux/param.h>
 #include <asm/atomic.h>
 #include <linux/inetdevice.h>
 #include <net/route.h>
 
 #if 0
-#define pr_debug(format,args...)
+#define pr_debug(format, args...)
 /*
   #define pr_debug printk
 */
@@ -1389,7 +1379,7 @@ static void lec_arp_expire_arp(unsigned long data);
  * Arp table funcs
  */
 
-#define HASH(ch) (ch & (LEC_ARP_TABLE_SIZE -1))
+#define HASH(ch) (ch & (LEC_ARP_TABLE_SIZE - 1))
 
 /*
  * Initialization of arp-cache
@@ -1398,9 +1388,8 @@ static void lec_arp_init(struct lec_priv *priv)
 {
 	unsigned short i;
 
-	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++)
 		INIT_HLIST_HEAD(&priv->lec_arp_tables[i]);
-	}
 	INIT_HLIST_HEAD(&priv->lec_arp_empty_ones);
 	INIT_HLIST_HEAD(&priv->lec_no_forward);
 	INIT_HLIST_HEAD(&priv->mcast_fwds);
@@ -1457,20 +1446,23 @@ lec_arp_remove(struct lec_priv *priv, struct lec_arp_table *to_remove)
 	struct lec_arp_table *entry;
 	int i, remove_vcc = 1;
 
-	if (!to_remove) {
+	if (!to_remove)
 		return -1;
-	}
 
 	hlist_del(&to_remove->next);
 	del_timer(&to_remove->timer);
 
-	/* If this is the only MAC connected to this VCC, also tear down the VCC */
+	/*
+	 * If this is the only MAC connected to this VCC,
+	 * also tear down the VCC
+	 */
 	if (to_remove->status >= ESI_FLUSH_PENDING) {
 		/*
 		 * ESI_FLUSH_PENDING, ESI_FORWARD_DIRECT
 		 */
 		for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-			hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
+			hlist_for_each_entry(entry, node,
+					     &priv->lec_arp_tables[i], next) {
 				if (memcmp(to_remove->atm_addr,
 					   entry->atm_addr, ATM_ESA_LEN) == 0) {
 					remove_vcc = 0;
@@ -1501,9 +1493,8 @@ static const char *get_status_string(unsigned char st)
 		return "ESI_FLUSH_PENDING";
 	case ESI_FORWARD_DIRECT:
 		return "ESI_FORWARD_DIRECT";
-	default:
-		return "<UNKNOWN>";
 	}
+	return "<UNKNOWN>";
 }
 
 static void dump_arp_table(struct lec_priv *priv)
@@ -1513,18 +1504,15 @@ static void dump_arp_table(struct lec_priv *priv)
 	char buf[256];
 	int i, j, offset;
 
-	printk("Dump %p:\n", priv);
+	pr_info("Dump %p:\n", priv);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry(rulla, node, &priv->lec_arp_tables[i], next) {
+		hlist_for_each_entry(rulla, node,
+				     &priv->lec_arp_tables[i], next) {
 			offset = 0;
 			offset += sprintf(buf, "%d: %p\n", i, rulla);
-			offset += sprintf(buf + offset, "Mac:");
-			for (j = 0; j < ETH_ALEN; j++) {
-				offset += sprintf(buf + offset,
-						  "%2.2x ",
-						  rulla->mac_addr[j] & 0xff);
-			}
-			offset += sprintf(buf + offset, "Atm:");
+			offset += sprintf(buf + offset, "Mac: %pM",
+					  rulla->mac_addr);
+			offset += sprintf(buf + offset, " Atm:");
 			for (j = 0; j < ATM_ESA_LEN; j++) {
 				offset += sprintf(buf + offset,
 						  "%2.2x ",
@@ -1544,20 +1532,16 @@ static void dump_arp_table(struct lec_priv *priv)
 				    "Flags:%x, Packets_flooded:%x, Status: %s ",
 				    rulla->flags, rulla->packets_flooded,
 				    get_status_string(rulla->status));
-			printk("%s\n", buf);
+			pr_info("%s\n", buf);
 		}
 	}
 
 	if (!hlist_empty(&priv->lec_no_forward))
-		printk("No forward\n");
+		pr_info("No forward\n");
 	hlist_for_each_entry(rulla, node, &priv->lec_no_forward, next) {
 		offset = 0;
-		offset += sprintf(buf + offset, "Mac:");
-		for (j = 0; j < ETH_ALEN; j++) {
-			offset += sprintf(buf + offset, "%2.2x ",
-					  rulla->mac_addr[j] & 0xff);
-		}
-		offset += sprintf(buf + offset, "Atm:");
+		offset += sprintf(buf + offset, "Mac: %pM", rulla->mac_addr);
+		offset += sprintf(buf + offset, " Atm:");
 		for (j = 0; j < ATM_ESA_LEN; j++) {
 			offset += sprintf(buf + offset, "%2.2x ",
 					  rulla->atm_addr[j] & 0xff);
@@ -1574,19 +1558,15 @@ static void dump_arp_table(struct lec_priv *priv)
 				  "Flags:%x, Packets_flooded:%x, Status: %s ",
 				  rulla->flags, rulla->packets_flooded,
 				  get_status_string(rulla->status));
-		printk("%s\n", buf);
+		pr_info("%s\n", buf);
 	}
 
 	if (!hlist_empty(&priv->lec_arp_empty_ones))
-		printk("Empty ones\n");
+		pr_info("Empty ones\n");
 	hlist_for_each_entry(rulla, node, &priv->lec_arp_empty_ones, next) {
 		offset = 0;
-		offset += sprintf(buf + offset, "Mac:");
-		for (j = 0; j < ETH_ALEN; j++) {
-			offset += sprintf(buf + offset, "%2.2x ",
-					  rulla->mac_addr[j] & 0xff);
-		}
-		offset += sprintf(buf + offset, "Atm:");
+		offset += sprintf(buf + offset, "Mac: %pM", rulla->mac_addr);
+		offset += sprintf(buf + offset, " Atm:");
 		for (j = 0; j < ATM_ESA_LEN; j++) {
 			offset += sprintf(buf + offset, "%2.2x ",
 					  rulla->atm_addr[j] & 0xff);
@@ -1603,19 +1583,15 @@ static void dump_arp_table(struct lec_priv *priv)
 				  "Flags:%x, Packets_flooded:%x, Status: %s ",
 				  rulla->flags, rulla->packets_flooded,
 				  get_status_string(rulla->status));
-		printk("%s", buf);
+		pr_info("%s", buf);
 	}
 
 	if (!hlist_empty(&priv->mcast_fwds))
-		printk("Multicast Forward VCCs\n");
+		pr_info("Multicast Forward VCCs\n");
 	hlist_for_each_entry(rulla, node, &priv->mcast_fwds, next) {
 		offset = 0;
-		offset += sprintf(buf + offset, "Mac:");
-		for (j = 0; j < ETH_ALEN; j++) {
-			offset += sprintf(buf + offset, "%2.2x ",
-					  rulla->mac_addr[j] & 0xff);
-		}
-		offset += sprintf(buf + offset, "Atm:");
+		offset += sprintf(buf + offset, "Mac: %pM", rulla->mac_addr);
+		offset += sprintf(buf + offset, " Atm:");
 		for (j = 0; j < ATM_ESA_LEN; j++) {
 			offset += sprintf(buf + offset, "%2.2x ",
 					  rulla->atm_addr[j] & 0xff);
@@ -1632,7 +1608,7 @@ static void dump_arp_table(struct lec_priv *priv)
 				  "Flags:%x, Packets_flooded:%x, Status: %s ",
 				  rulla->flags, rulla->packets_flooded,
 				  get_status_string(rulla->status));
-		printk("%s\n", buf);
+		pr_info("%s\n", buf);
 	}
 
 }
@@ -1658,14 +1634,16 @@ static void lec_arp_destroy(struct lec_priv *priv)
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
+		hlist_for_each_entry_safe(entry, node, next,
+					  &priv->lec_arp_tables[i], next) {
 			lec_arp_remove(priv, entry);
 			lec_arp_put(entry);
 		}
 		INIT_HLIST_HEAD(&priv->lec_arp_tables[i]);
 	}
 
-	hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
+	hlist_for_each_entry_safe(entry, node, next,
+				  &priv->lec_arp_empty_ones, next) {
 		del_timer_sync(&entry->timer);
 		lec_arp_clear_vccs(entry);
 		hlist_del(&entry->next);
@@ -1673,7 +1651,8 @@ static void lec_arp_destroy(struct lec_priv *priv)
 	}
 	INIT_HLIST_HEAD(&priv->lec_arp_empty_ones);
 
-	hlist_for_each_entry_safe(entry, node, next, &priv->lec_no_forward, next) {
+	hlist_for_each_entry_safe(entry, node, next,
+				  &priv->lec_no_forward, next) {
 		del_timer_sync(&entry->timer);
 		lec_arp_clear_vccs(entry);
 		hlist_del(&entry->next);
@@ -1706,9 +1685,8 @@ static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
 
 	head = &priv->lec_arp_tables[HASH(mac_addr[ETH_ALEN - 1])];
 	hlist_for_each_entry(entry, node, head, next) {
-		if (!compare_ether_addr(mac_addr, entry->mac_addr)) {
+		if (!compare_ether_addr(mac_addr, entry->mac_addr))
 			return entry;
-		}
 	}
 	return NULL;
 }
@@ -1720,7 +1698,7 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 
 	to_return = kzalloc(sizeof(struct lec_arp_table), GFP_ATOMIC);
 	if (!to_return) {
-		printk("LEC: Arp entry kmalloc failed\n");
+		pr_info("LEC: Arp entry kmalloc failed\n");
 		return NULL;
 	}
 	memcpy(to_return->mac_addr, mac_addr, ETH_ALEN);
@@ -1810,7 +1788,8 @@ static void lec_arp_check_expire(struct work_struct *work)
 restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
+		hlist_for_each_entry_safe(entry, node, next,
+					  &priv->lec_arp_tables[i], next) {
 			if ((entry->flags) & LEC_REMOTE_FLAG &&
 			    priv->topology_change)
 				time_to_check = priv->forward_delay_time;
@@ -1819,9 +1798,9 @@ restart:
 
 			pr_debug("About to expire: %lx - %lx > %lx\n",
 				 now, entry->last_used, time_to_check);
-			if (time_after(now, entry->last_used + time_to_check)
-			    && !(entry->flags & LEC_PERMANENT_FLAG)
-			    && !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
+			if (time_after(now, entry->last_used + time_to_check) &&
+			    !(entry->flags & LEC_PERMANENT_FLAG) &&
+			    !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
 				/* Remove entry */
 				pr_debug("Entry timed out\n");
 				lec_arp_remove(priv, entry);
@@ -1829,11 +1808,10 @@ restart:
 			} else {
 				/* Something else */
 				if ((entry->status == ESI_VC_PENDING ||
-				     entry->status == ESI_ARP_PENDING)
-				    && time_after_eq(now,
-						     entry->timestamp +
-						     priv->
-						     max_unknown_frame_time)) {
+				     entry->status == ESI_ARP_PENDING) &&
+				    time_after_eq(now,
+						  entry->timestamp +
+						  priv->max_unknown_frame_time)) {
 					entry->timestamp = jiffies;
 					entry->packets_flooded = 0;
 					if (entry->status == ESI_VC_PENDING)
@@ -1842,8 +1820,7 @@ restart:
 							     entry->atm_addr,
 							     NULL);
 				}
-				if (entry->status == ESI_FLUSH_PENDING
-				    &&
+				if (entry->status == ESI_FLUSH_PENDING &&
 				    time_after_eq(now, entry->timestamp +
 						  priv->path_switching_delay)) {
 					struct sk_buff *skb;
@@ -1871,7 +1848,8 @@ restart:
  *
  */
 static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
-				       const unsigned char *mac_to_find, int is_rdesc,
+				       const unsigned char *mac_to_find,
+				       int is_rdesc,
 				       struct lec_arp_table **ret_entry)
 {
 	unsigned long flags;
@@ -1907,9 +1885,8 @@ static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
 		 * If the LE_ARP cache entry is still pending, reset count to 0
 		 * so another LE_ARP request can be made for this frame.
 		 */
-		if (entry->status == ESI_ARP_PENDING) {
+		if (entry->status == ESI_ARP_PENDING)
 			entry->no_tries = 0;
-		}
 		/*
 		 * Data direct VC not yet set up, check to see if the unknown
 		 * frame count is greater than the limit. If the limit has
@@ -1977,10 +1954,11 @@ lec_addr_delete(struct lec_priv *priv, const unsigned char *atm_addr,
 	pr_debug("\n");
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
-			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)
-			    && (permanent ||
-				!(entry->flags & LEC_PERMANENT_FLAG))) {
+		hlist_for_each_entry_safe(entry, node, next,
+					  &priv->lec_arp_tables[i], next) {
+			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN) &&
+			    (permanent ||
+			     !(entry->flags & LEC_PERMANENT_FLAG))) {
 				lec_arp_remove(priv, entry);
 				lec_arp_put(entry);
 			}
@@ -2016,7 +1994,8 @@ lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
 				 * we have no entry in the cache. 7.1.30
 				 */
 	if (!hlist_empty(&priv->lec_arp_empty_ones)) {
-		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
+		hlist_for_each_entry_safe(entry, node, next,
+					  &priv->lec_arp_empty_ones, next) {
 			if (memcmp(entry->atm_addr, atm_addr, ATM_ESA_LEN) == 0) {
 				hlist_del(&entry->next);
 				del_timer(&entry->timer);
@@ -2060,7 +2039,8 @@ lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
 	memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
 	del_timer(&entry->timer);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry(tmp, node, &priv->lec_arp_tables[i], next) {
+		hlist_for_each_entry(tmp, node,
+				     &priv->lec_arp_tables[i], next) {
 			if (entry != tmp &&
 			    !memcmp(tmp->atm_addr, atm_addr, ATM_ESA_LEN)) {
 				/* Vcc to this host exists */
@@ -2105,14 +2085,13 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 	int i, found_entry = 0;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+	/* Vcc for Multicast Forward. No timer, LANEv2 7.1.20 and 2.3.5.3 */
 	if (ioc_data->receive == 2) {
-		/* Vcc for Multicast Forward. No timer, LANEv2 7.1.20 and 2.3.5.3 */
-
 		pr_debug("LEC_ARP: Attaching mcast forward\n");
 #if 0
 		entry = lec_arp_find(priv, bus_mac);
 		if (!entry) {
-			printk("LEC_ARP: Multicast entry not found!\n");
+			pr_info("LEC_ARP: Multicast entry not found!\n");
 			goto out;
 		}
 		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
@@ -2171,7 +2150,8 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 		 ioc_data->atm_addr[16], ioc_data->atm_addr[17],
 		 ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
+		hlist_for_each_entry(entry, node,
+				     &priv->lec_arp_tables[i], next) {
 			if (memcmp
 			    (ioc_data->atm_addr, entry->atm_addr,
 			     ATM_ESA_LEN) == 0) {
@@ -2255,14 +2235,16 @@ static void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id)
 restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
-			if (entry->flush_tran_id == tran_id
-			    && entry->status == ESI_FLUSH_PENDING) {
+		hlist_for_each_entry(entry, node,
+				     &priv->lec_arp_tables[i], next) {
+			if (entry->flush_tran_id == tran_id &&
+			    entry->status == ESI_FLUSH_PENDING) {
 				struct sk_buff *skb;
 				struct atm_vcc *vcc = entry->vcc;
 
 				lec_arp_hold(entry);
-				spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
+				spin_unlock_irqrestore(&priv->lec_arp_lock,
+						       flags);
 				while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
 					lec_send(vcc, skb);
 				entry->last_used = jiffies;
@@ -2288,7 +2270,8 @@ lec_set_flush_tran_id(struct lec_priv *priv,
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++)
-		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
+		hlist_for_each_entry(entry, node,
+				     &priv->lec_arp_tables[i], next) {
 			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)) {
 				entry->flush_tran_id = tran_id;
 				pr_debug("Set flush transaction id to %lx for %p\n",
@@ -2308,7 +2291,8 @@ static int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc)
 	struct lec_vcc_priv *vpriv;
 	int err = 0;
 
-	if (!(vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL)))
+	vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL);
+	if (!vpriv)
 		return -ENOMEM;
 	vpriv->xoff = 0;
 	vpriv->old_pop = vcc->pop;
@@ -2348,18 +2332,19 @@ static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc)
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
+		hlist_for_each_entry_safe(entry, node, next,
+					  &priv->lec_arp_tables[i], next) {
 			if (vcc == entry->vcc) {
 				lec_arp_remove(priv, entry);
 				lec_arp_put(entry);
-				if (priv->mcast_vcc == vcc) {
+				if (priv->mcast_vcc == vcc)
 					priv->mcast_vcc = NULL;
-				}
 			}
 		}
 	}
 
-	hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
+	hlist_for_each_entry_safe(entry, node, next,
+				  &priv->lec_arp_empty_ones, next) {
 		if (entry->vcc == vcc) {
 			lec_arp_clear_vccs(entry);
 			del_timer(&entry->timer);
@@ -2368,7 +2353,8 @@ static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc)
 		}
 	}
 
-	hlist_for_each_entry_safe(entry, node, next, &priv->lec_no_forward, next) {
+	hlist_for_each_entry_safe(entry, node, next,
+				  &priv->lec_no_forward, next) {
 		if (entry->recv_vcc == vcc) {
 			lec_arp_clear_vccs(entry);
 			del_timer(&entry->timer);
@@ -2409,14 +2395,16 @@ lec_arp_check_empties(struct lec_priv *priv,
 		src = hdr->h_source;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-	hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
+	hlist_for_each_entry_safe(entry, node, next,
+				  &priv->lec_arp_empty_ones, next) {
 		if (vcc == entry->vcc) {
 			del_timer(&entry->timer);
 			memcpy(entry->mac_addr, src, ETH_ALEN);
 			entry->status = ESI_FORWARD_DIRECT;
 			entry->last_used = jiffies;
 			/* We might have got an entry */
-			if ((tmp = lec_arp_find(priv, src))) {
+			tmp = lec_arp_find(priv, src);
+			if (tmp) {
 				lec_arp_remove(priv, tmp);
 				lec_arp_put(tmp);
 			}
-- 
1.6.6.rc0.57.gad7a

