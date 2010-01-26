From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/21] net/atm/mpc.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:09 -0800
Message-ID: <1fbe5c552df39789d6df62e381fe4cac63630808.1264541549.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1485 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753923Ab0AZVkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:24 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert #include <asm... to #include <linux...
Add printk argument verification to dprintk and ddprintk
Spacing cleanups
Mostly 80 column wrapped.
printk->pr_info and pr_cont
Moved labels to column 1
Move trailing statements to new lines
switch/case cleanups
	remove unnecessary breaks after returns
Remove unnecessary braces around single line statements

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/mpc.c |  445 ++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 252 insertions(+), 193 deletions(-)

diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 3c45aef..55dba22 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -15,8 +15,8 @@
 #include <net/sock.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
+#include <linux/uaccess.h>
 #include <asm/byteorder.h>
-#include <asm/uaccess.h>
 #include <net/checksum.h>   /* for ip_fast_csum() */
 #include <net/arp.h>
 #include <net/dst.h>
@@ -38,15 +38,17 @@
  */
 
 #if 0
-#define dprintk printk   /* debug */
+#define dprintk(format, args...) printk(KERN_DEBUG format, ##args)   /* debug */
 #else
-#define dprintk(format,args...)
+#define dprintk(format, args...)			\
+	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
 #endif
 
 #if 0
-#define ddprintk printk  /* more debug */
+#define ddprintk printk(KERN_DEBUG format, ##args)  /* more debug */
 #else
-#define ddprintk(format,args...)
+#define ddprintk(format, args...)			\
+	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
 #endif
 
 
@@ -54,15 +56,19 @@
 #define MPOA_TAG_LEN 4
 
 /* mpc_daemon -> kernel */
-static void MPOA_trigger_rcvd (struct k_message *msg, struct mpoa_client *mpc);
+static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc);
 static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc);
 static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc);
 static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc);
 static void mps_death(struct k_message *msg, struct mpoa_client *mpc);
-static void clean_up(struct k_message *msg, struct mpoa_client *mpc, int action);
-static void MPOA_cache_impos_rcvd(struct k_message *msg, struct mpoa_client *mpc);
-static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg, struct mpoa_client *mpc);
-static void set_mps_mac_addr_rcvd(struct k_message *mesg, struct mpoa_client *mpc);
+static void clean_up(struct k_message *msg, struct mpoa_client *mpc,
+		     int action);
+static void MPOA_cache_impos_rcvd(struct k_message *msg,
+				  struct mpoa_client *mpc);
+static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg,
+				   struct mpoa_client *mpc);
+static void set_mps_mac_addr_rcvd(struct k_message *mesg,
+				  struct mpoa_client *mpc);
 
 static const uint8_t *copy_macs(struct mpoa_client *mpc,
 				const uint8_t *router_mac,
@@ -76,10 +82,11 @@ static int msg_from_mpoad(struct atm_vcc *vcc, struct sk_buff *skb);
 
 static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb);
 static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
-					 struct net_device *dev);
-static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned long event, void *dev);
+				   struct net_device *dev);
+static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
+			       unsigned long event, void *dev);
 static void mpc_timer_refresh(void);
-static void mpc_cache_check( unsigned long checking_time  );
+static void mpc_cache_check(unsigned long checking_time);
 
 static struct llc_snap_hdr llc_snap_mpoa_ctrl = {
 	0xaa, 0xaa, 0x03,
@@ -169,7 +176,7 @@ struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos)
 
 	entry = kmalloc(sizeof(struct atm_mpoa_qos), GFP_KERNEL);
 	if (entry == NULL) {
-		printk("mpoa: atm_mpoa_add_qos: out of memory\n");
+		pr_info("mpoa: out of memory\n");
 		return entry;
 	}
 
@@ -187,10 +194,9 @@ struct atm_mpoa_qos *atm_mpoa_search_qos(__be32 dst_ip)
 	struct atm_mpoa_qos *qos;
 
 	qos = qos_head;
-	while( qos != NULL ){
-		if(qos->ipaddr == dst_ip) {
+	while (qos) {
+		if (qos->ipaddr == dst_ip)
 			break;
-		}
 		qos = qos->next;
 	}
 
@@ -202,10 +208,10 @@ struct atm_mpoa_qos *atm_mpoa_search_qos(__be32 dst_ip)
  */
 int atm_mpoa_delete_qos(struct atm_mpoa_qos *entry)
 {
-
 	struct atm_mpoa_qos *curr;
 
-	if (entry == NULL) return 0;
+	if (entry == NULL)
+		return 0;
 	if (entry == qos_head) {
 		qos_head = qos_head->next;
 		kfree(entry);
@@ -236,9 +242,17 @@ void atm_mpoa_disp_qos(struct seq_file *m)
 
 	while (qos != NULL) {
 		seq_printf(m, "%pI4\n     %-7d %-7d %-7d %-7d %-7d\n     %-7d %-7d %-7d %-7d %-7d\n",
-				&qos->ipaddr,
-				qos->qos.txtp.max_pcr, qos->qos.txtp.pcr, qos->qos.txtp.min_pcr, qos->qos.txtp.max_cdv, qos->qos.txtp.max_sdu,
-				qos->qos.rxtp.max_pcr, qos->qos.rxtp.pcr, qos->qos.rxtp.min_pcr, qos->qos.rxtp.max_cdv, qos->qos.rxtp.max_sdu);
+			   &qos->ipaddr,
+			   qos->qos.txtp.max_pcr,
+			   qos->qos.txtp.pcr,
+			   qos->qos.txtp.min_pcr,
+			   qos->qos.txtp.max_cdv,
+			   qos->qos.txtp.max_sdu,
+			   qos->qos.rxtp.max_pcr,
+			   qos->qos.rxtp.pcr,
+			   qos->qos.rxtp.min_pcr,
+			   qos->qos.rxtp.max_cdv,
+			   qos->qos.rxtp.max_sdu);
 		qos = qos->next;
 	}
 }
@@ -258,7 +272,7 @@ static struct mpoa_client *alloc_mpc(void)
 {
 	struct mpoa_client *mpc;
 
-	mpc = kzalloc(sizeof (struct mpoa_client), GFP_KERNEL);
+	mpc = kzalloc(sizeof(struct mpoa_client), GFP_KERNEL);
 	if (mpc == NULL)
 		return NULL;
 	rwlock_init(&mpc->ingress_lock);
@@ -268,7 +282,7 @@ static struct mpoa_client *alloc_mpc(void)
 
 	mpc->parameters.mpc_p1 = MPC_P1;
 	mpc->parameters.mpc_p2 = MPC_P2;
-	memset(mpc->parameters.mpc_p3,0,sizeof(mpc->parameters.mpc_p3));
+	memset(mpc->parameters.mpc_p3, 0, sizeof(mpc->parameters.mpc_p3));
 	mpc->parameters.mpc_p4 = MPC_P4;
 	mpc->parameters.mpc_p5 = MPC_P5;
 	mpc->parameters.mpc_p6 = MPC_P6;
@@ -290,7 +304,7 @@ static void start_mpc(struct mpoa_client *mpc, struct net_device *dev)
 
 	dprintk("mpoa: (%s) start_mpc:\n", mpc->dev->name);
 	if (!dev->netdev_ops)
-		printk("mpoa: (%s) start_mpc  not starting\n", dev->name);
+		pr_info("(%s) not starting\n", dev->name);
 	else {
 		mpc->old_ops = dev->netdev_ops;
 		mpc->new_ops = *mpc->old_ops;
@@ -321,25 +335,18 @@ static const char *mpoa_device_type_string(char type) __attribute__ ((unused));
 
 static const char *mpoa_device_type_string(char type)
 {
-	switch(type) {
+	switch (type) {
 	case NON_MPOA:
 		return "non-MPOA device";
-		break;
 	case MPS:
 		return "MPS";
-		break;
 	case MPC:
 		return "MPC";
-		break;
 	case MPS_AND_MPC:
 		return "both MPS and MPC";
-		break;
-	default:
-		return "unspecified (non-MPOA) device";
-		break;
 	}
 
-	return ""; /* not reached */
+	return "unspecified (non-MPOA) device";
 }
 
 /*
@@ -368,22 +375,24 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 	dprintk("total length of all TLVs %d\n", sizeoftlvs);
 	mpc = find_mpc_by_lec(dev); /* Sampo-Fix: moved here from below */
 	if (mpc == NULL) {
-		printk("mpoa: (%s) lane2_assoc_ind: no mpc\n", dev->name);
+		pr_info("(%s) no mpc\n", dev->name);
 		return;
 	}
 	end_of_tlvs = tlvs + sizeoftlvs;
 	while (end_of_tlvs - tlvs >= 5) {
-		type = (tlvs[0] << 24) | (tlvs[1] << 16) | (tlvs[2] << 8) | tlvs[3];
+		type = ((tlvs[0] << 24) | (tlvs[1] << 16) |
+			(tlvs[2] << 8) | tlvs[3]);
 		length = tlvs[4];
 		tlvs += 5;
 		dprintk("    type 0x%x length %02x\n", type, length);
 		if (tlvs + length > end_of_tlvs) {
-			printk("TLV value extends past its buffer, aborting parse\n");
+			pr_info("TLV value extends past its buffer, aborting parse\n");
 			return;
 		}
 
 		if (type == 0) {
-			printk("mpoa: (%s) lane2_assoc_ind: TLV type was 0, returning\n", dev->name);
+			pr_info("mpoa: (%s) TLV type was 0, returning\n",
+				dev->name);
 			return;
 		}
 
@@ -393,39 +402,47 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 		}
 		mpoa_device_type = *tlvs++;
 		number_of_mps_macs = *tlvs++;
-		dprintk("mpoa: (%s) MPOA device type '%s', ", dev->name, mpoa_device_type_string(mpoa_device_type));
+		dprintk("mpoa: (%s) MPOA device type '%s', ",
+			dev->name, mpoa_device_type_string(mpoa_device_type));
 		if (mpoa_device_type == MPS_AND_MPC &&
 		    length < (42 + number_of_mps_macs*ETH_ALEN)) { /* :) */
-			printk("\nmpoa: (%s) lane2_assoc_ind: short MPOA Device Type TLV\n",
-			       dev->name);
+			pr_info("(%s) short MPOA Device Type TLV\n",
+				dev->name);
 			continue;
 		}
-		if ((mpoa_device_type == MPS || mpoa_device_type == MPC)
-		    && length < 22 + number_of_mps_macs*ETH_ALEN) {
-			printk("\nmpoa: (%s) lane2_assoc_ind: short MPOA Device Type TLV\n",
-				dev->name);
+		if ((mpoa_device_type == MPS || mpoa_device_type == MPC) &&
+		    length < 22 + number_of_mps_macs*ETH_ALEN) {
+			pr_info("(%s) short MPOA Device Type TLV\n", dev->name);
 			continue;
 		}
-		if (mpoa_device_type != MPS && mpoa_device_type != MPS_AND_MPC) {
+		if (mpoa_device_type != MPS &&
+		    mpoa_device_type != MPS_AND_MPC) {
 			dprintk("ignoring non-MPS device\n");
-			if (mpoa_device_type == MPC) tlvs += 20;
+			if (mpoa_device_type == MPC)
+				tlvs += 20;
 			continue;  /* we are only interested in MPSs */
 		}
-		if (number_of_mps_macs == 0 && mpoa_device_type == MPS_AND_MPC) {
-			printk("\nmpoa: (%s) lane2_assoc_ind: MPS_AND_MPC has zero MACs\n", dev->name);
+		if (number_of_mps_macs == 0 &&
+		    mpoa_device_type == MPS_AND_MPC) {
+			pr_info("(%s) MPS_AND_MPC has zero MACs\n", dev->name);
 			continue;  /* someone should read the spec */
 		}
 		dprintk("this MPS has %d MAC addresses\n", number_of_mps_macs);
 
-		/* ok, now we can go and tell our daemon the control address of MPS */
+		/*
+		 * ok, now we can go and tell our daemon
+		 * the control address of MPS
+		 */
 		send_set_mps_ctrl_addr(tlvs, mpc);
 
-		tlvs = copy_macs(mpc, mac_addr, tlvs, number_of_mps_macs, mpoa_device_type);
-		if (tlvs == NULL) return;
+		tlvs = copy_macs(mpc, mac_addr, tlvs,
+				 number_of_mps_macs, mpoa_device_type);
+		if (tlvs == NULL)
+			return;
 	}
 	if (end_of_tlvs - tlvs != 0)
-		printk("mpoa: (%s) lane2_assoc_ind: ignoring %Zd bytes of trailing TLV carbage\n",
-		       dev->name, end_of_tlvs - tlvs);
+		pr_info("(%s) ignoring %Zd bytes of trailing TLV garbage\n",
+			dev->name, end_of_tlvs - tlvs);
 	return;
 }
 
@@ -443,11 +460,12 @@ static const uint8_t *copy_macs(struct mpoa_client *mpc,
 	num_macs = (mps_macs > 1) ? mps_macs : 1;
 
 	if (mpc->number_of_mps_macs != num_macs) { /* need to reallocate? */
-		if (mpc->number_of_mps_macs != 0) kfree(mpc->mps_macs);
+		if (mpc->number_of_mps_macs != 0)
+			kfree(mpc->mps_macs);
 		mpc->number_of_mps_macs = 0;
-		mpc->mps_macs = kmalloc(num_macs*ETH_ALEN, GFP_KERNEL);
+		mpc->mps_macs = kmalloc(num_macs * ETH_ALEN, GFP_KERNEL);
 		if (mpc->mps_macs == NULL) {
-			printk("mpoa: (%s) copy_macs: out of mem\n", mpc->dev->name);
+			pr_info("(%s) out of mem\n", mpc->dev->name);
 			return NULL;
 		}
 	}
@@ -480,24 +498,30 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 	iph = (struct iphdr *)buff;
 	ipaddr = iph->daddr;
 
-	ddprintk("mpoa: (%s) send_via_shortcut: ipaddr 0x%x\n", mpc->dev->name, ipaddr);
+	ddprintk("mpoa: (%s) send_via_shortcut: ipaddr 0x%x\n",
+		 mpc->dev->name, ipaddr);
 
 	entry = mpc->in_ops->get(ipaddr, mpc);
 	if (entry == NULL) {
 		entry = mpc->in_ops->add_entry(ipaddr, mpc);
-		if (entry != NULL) mpc->in_ops->put(entry);
+		if (entry != NULL)
+			mpc->in_ops->put(entry);
 		return 1;
 	}
-	if (mpc->in_ops->cache_hit(entry, mpc) != OPEN){   /* threshold not exceeded or VCC not ready */
-		ddprintk("mpoa: (%s) send_via_shortcut: cache_hit: returns != OPEN\n", mpc->dev->name);
+	/* threshold not exceeded or VCC not ready */
+	if (mpc->in_ops->cache_hit(entry, mpc) != OPEN) {
+		ddprintk("mpoa: (%s) send_via_shortcut: cache_hit: returns != OPEN\n",
+			 mpc->dev->name);
 		mpc->in_ops->put(entry);
 		return 1;
 	}
 
-	ddprintk("mpoa: (%s) send_via_shortcut: using shortcut\n", mpc->dev->name);
+	ddprintk("mpoa: (%s) send_via_shortcut: using shortcut\n",
+		 mpc->dev->name);
 	/* MPOA spec A.1.4, MPOA client must decrement IP ttl at least by one */
 	if (iph->ttl <= 1) {
-		ddprintk("mpoa: (%s) send_via_shortcut: IP ttl = %u, using LANE\n", mpc->dev->name, iph->ttl);
+		ddprintk("mpoa: (%s) send_via_shortcut: IP ttl = %u, using LANE\n",
+			 mpc->dev->name, iph->ttl);
 		mpc->in_ops->put(entry);
 		return 1;
 	}
@@ -506,15 +530,18 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
 	if (entry->ctrl_info.tag != 0) {
-		ddprintk("mpoa: (%s) send_via_shortcut: adding tag 0x%x\n", mpc->dev->name, entry->ctrl_info.tag);
+		ddprintk("mpoa: (%s) send_via_shortcut: adding tag 0x%x\n",
+			 mpc->dev->name, entry->ctrl_info.tag);
 		tagged_llc_snap_hdr.tag = entry->ctrl_info.tag;
-		skb_pull(skb, ETH_HLEN);                       /* get rid of Eth header */
-		skb_push(skb, sizeof(tagged_llc_snap_hdr));    /* add LLC/SNAP header   */
+		skb_pull(skb, ETH_HLEN);	/* get rid of Eth header */
+		skb_push(skb, sizeof(tagged_llc_snap_hdr));
+						/* add LLC/SNAP header   */
 		skb_copy_to_linear_data(skb, &tagged_llc_snap_hdr,
 					sizeof(tagged_llc_snap_hdr));
 	} else {
-		skb_pull(skb, ETH_HLEN);                        /* get rid of Eth header */
-		skb_push(skb, sizeof(struct llc_snap_hdr));     /* add LLC/SNAP header + tag  */
+		skb_pull(skb, ETH_HLEN);	/* get rid of Eth header */
+		skb_push(skb, sizeof(struct llc_snap_hdr));
+						/* add LLC/SNAP header + tag  */
 		skb_copy_to_linear_data(skb, &llc_snap_mpoa_data,
 					sizeof(struct llc_snap_hdr));
 	}
@@ -539,8 +566,8 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 	int i = 0;
 
 	mpc = find_mpc_by_lec(dev); /* this should NEVER fail */
-	if(mpc == NULL) {
-		printk("mpoa: (%s) mpc_send_packet: no MPC found\n", dev->name);
+	if (mpc == NULL) {
+		pr_info("(%s) no MPC found\n", dev->name);
 		goto non_ip;
 	}
 
@@ -556,14 +583,15 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 		goto non_ip;
 
 	while (i < mpc->number_of_mps_macs) {
-		if (!compare_ether_addr(eth->h_dest, (mpc->mps_macs + i*ETH_ALEN)))
-			if ( send_via_shortcut(skb, mpc) == 0 )           /* try shortcut */
-				return NETDEV_TX_OK;                      /* success!     */
+		if (!compare_ether_addr(eth->h_dest,
+					(mpc->mps_macs + i*ETH_ALEN)))
+			if (send_via_shortcut(skb, mpc) == 0) /* try shortcut */
+				return NETDEV_TX_OK;
 		i++;
 	}
 
- non_ip:
-	return mpc->old_ops->ndo_start_xmit(skb,dev);
+non_ip:
+	return mpc->old_ops->ndo_start_xmit(skb, dev);
 }
 
 static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
@@ -576,7 +604,8 @@ static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 
 	bytes_left = copy_from_user(&ioc_data, arg, sizeof(struct atmmpc_ioc));
 	if (bytes_left != 0) {
-		printk("mpoa: mpc_vcc_attach: Short read (missed %d bytes) from userland\n", bytes_left);
+		pr_info("mpoa:Short read (missed %d bytes) from userland\n",
+			bytes_left);
 		return -EFAULT;
 	}
 	ipaddr = ioc_data.ipaddr;
@@ -589,18 +618,20 @@ static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 
 	if (ioc_data.type == MPC_SOCKET_INGRESS) {
 		in_entry = mpc->in_ops->get(ipaddr, mpc);
-		if (in_entry == NULL || in_entry->entry_state < INGRESS_RESOLVED) {
-			printk("mpoa: (%s) mpc_vcc_attach: did not find RESOLVED entry from ingress cache\n",
+		if (in_entry == NULL ||
+		    in_entry->entry_state < INGRESS_RESOLVED) {
+			pr_info("(%s) did not find RESOLVED entry from ingress cache\n",
 				mpc->dev->name);
-			if (in_entry != NULL) mpc->in_ops->put(in_entry);
+			if (in_entry != NULL)
+				mpc->in_ops->put(in_entry);
 			return -EINVAL;
 		}
-		printk("mpoa: (%s) mpc_vcc_attach: attaching ingress SVC, entry = %pI4\n",
-		       mpc->dev->name, &in_entry->ctrl_info.in_dst_ip);
+		pr_info("(%s) attaching ingress SVC, entry = %pI4\n",
+			mpc->dev->name, &in_entry->ctrl_info.in_dst_ip);
 		in_entry->shortcut = vcc;
 		mpc->in_ops->put(in_entry);
 	} else {
-		printk("mpoa: (%s) mpc_vcc_attach: attaching egress SVC\n", mpc->dev->name);
+		pr_info("(%s) attaching egress SVC\n", mpc->dev->name);
 	}
 
 	vcc->proto_data = mpc->dev;
@@ -620,7 +651,7 @@ static void mpc_vcc_close(struct atm_vcc *vcc, struct net_device *dev)
 
 	mpc = find_mpc_by_lec(dev);
 	if (mpc == NULL) {
-		printk("mpoa: (%s) mpc_vcc_close: close for unknown MPC\n", dev->name);
+		pr_info("(%s) close for unknown MPC\n", dev->name);
 		return;
 	}
 
@@ -628,19 +659,21 @@ static void mpc_vcc_close(struct atm_vcc *vcc, struct net_device *dev)
 	in_entry = mpc->in_ops->get_by_vcc(vcc, mpc);
 	if (in_entry) {
 		dprintk("mpoa: (%s) mpc_vcc_close: ingress SVC closed ip = %pI4\n",
-		       mpc->dev->name, &in_entry->ctrl_info.in_dst_ip);
+			mpc->dev->name, &in_entry->ctrl_info.in_dst_ip);
 		in_entry->shortcut = NULL;
 		mpc->in_ops->put(in_entry);
 	}
 	eg_entry = mpc->eg_ops->get_by_vcc(vcc, mpc);
 	if (eg_entry) {
-		dprintk("mpoa: (%s) mpc_vcc_close: egress SVC closed\n", mpc->dev->name);
+		dprintk("mpoa: (%s) mpc_vcc_close: egress SVC closed\n",
+			mpc->dev->name);
 		eg_entry->shortcut = NULL;
 		mpc->eg_ops->put(eg_entry);
 	}
 
 	if (in_entry == NULL && eg_entry == NULL)
-		dprintk("mpoa: (%s) mpc_vcc_close:  unused vcc closed\n", dev->name);
+		dprintk("mpoa: (%s) mpc_vcc_close:  unused vcc closed\n",
+			dev->name);
 
 	return;
 }
@@ -656,16 +689,19 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	ddprintk("mpoa: (%s) mpc_push:\n", dev->name);
 	if (skb == NULL) {
-		dprintk("mpoa: (%s) mpc_push: null skb, closing VCC\n", dev->name);
+		dprintk("mpoa: (%s) mpc_push: null skb, closing VCC\n",
+			dev->name);
 		mpc_vcc_close(vcc, dev);
 		return;
 	}
 
 	skb->dev = dev;
-	if (memcmp(skb->data, &llc_snap_mpoa_ctrl, sizeof(struct llc_snap_hdr)) == 0) {
+	if (memcmp(skb->data, &llc_snap_mpoa_ctrl,
+		   sizeof(struct llc_snap_hdr)) == 0) {
 		struct sock *sk = sk_atm(vcc);
 
-		dprintk("mpoa: (%s) mpc_push: control packet arrived\n", dev->name);
+		dprintk("mpoa: (%s) mpc_push: control packet arrived\n",
+			dev->name);
 		/* Pass control packets to daemon */
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);
@@ -677,20 +713,23 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	mpc = find_mpc_by_lec(dev);
 	if (mpc == NULL) {
-		printk("mpoa: (%s) mpc_push: unknown MPC\n", dev->name);
+		pr_info("(%s) unknown MPC\n", dev->name);
 		return;
 	}
 
-	if (memcmp(skb->data, &llc_snap_mpoa_data_tagged, sizeof(struct llc_snap_hdr)) == 0) { /* MPOA tagged data */
-		ddprintk("mpoa: (%s) mpc_push: tagged data packet arrived\n", dev->name);
+	if (memcmp(skb->data, &llc_snap_mpoa_data_tagged,
+		   sizeof(struct llc_snap_hdr)) == 0) { /* MPOA tagged data */
+		ddprintk("mpoa: (%s) mpc_push: tagged data packet arrived\n",
+			 dev->name);
 
-	} else if (memcmp(skb->data, &llc_snap_mpoa_data, sizeof(struct llc_snap_hdr)) == 0) { /* MPOA data */
-		printk("mpoa: (%s) mpc_push: non-tagged data packet arrived\n", dev->name);
-		printk("           mpc_push: non-tagged data unsupported, purging\n");
+	} else if (memcmp(skb->data, &llc_snap_mpoa_data,
+			  sizeof(struct llc_snap_hdr)) == 0) { /* MPOA data */
+		pr_info("(%s) Unsupported non-tagged data packet arrived.  Purging\n",
+			dev->name);
 		dev_kfree_skb_any(skb);
 		return;
 	} else {
-		printk("mpoa: (%s) mpc_push: garbage arrived, purging\n", dev->name);
+		pr_info("(%s) garbage arrived, purging\n", dev->name);
 		dev_kfree_skb_any(skb);
 		return;
 	}
@@ -700,8 +739,8 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	eg = mpc->eg_ops->get_by_tag(tag, mpc);
 	if (eg == NULL) {
-		printk("mpoa: (%s) mpc_push: Didn't find egress cache entry, tag = %u\n",
-		       dev->name,tag);
+		pr_info("mpoa: (%s) Didn't find egress cache entry, tag = %u\n",
+			dev->name, tag);
 		purge_egress_shortcut(vcc, NULL);
 		dev_kfree_skb_any(skb);
 		return;
@@ -713,13 +752,15 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	 */
 	if (eg->shortcut == NULL) {
 		eg->shortcut = vcc;
-		printk("mpoa: (%s) mpc_push: egress SVC in use\n", dev->name);
+		pr_info("(%s) egress SVC in use\n", dev->name);
 	}
 
-	skb_pull(skb, sizeof(struct llc_snap_hdr) + sizeof(tag)); /* get rid of LLC/SNAP header */
-	new_skb = skb_realloc_headroom(skb, eg->ctrl_info.DH_length); /* LLC/SNAP is shorter than MAC header :( */
+	skb_pull(skb, sizeof(struct llc_snap_hdr) + sizeof(tag));
+					/* get rid of LLC/SNAP header */
+	new_skb = skb_realloc_headroom(skb, eg->ctrl_info.DH_length);
+					/* LLC/SNAP is shorter than MAC header :( */
 	dev_kfree_skb_any(skb);
-	if (new_skb == NULL){
+	if (new_skb == NULL) {
 		mpc->eg_ops->put(eg);
 		return;
 	}
@@ -752,7 +793,7 @@ static struct atm_dev mpc_dev = {
 	/* members not explicitly initialised will be 0 */
 };
 
-static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
+static int atm_mpoa_mpoad_attach(struct atm_vcc *vcc, int arg)
 {
 	struct mpoa_client *mpc;
 	struct lec_priv *priv;
@@ -772,15 +813,17 @@ static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 
 	mpc = find_mpc_by_itfnum(arg);
 	if (mpc == NULL) {
-		dprintk("mpoa: mpoad_attach: allocating new mpc for itf %d\n", arg);
+		dprintk("mpoa: mpoad_attach: allocating new mpc for itf %d\n",
+			arg);
 		mpc = alloc_mpc();
 		if (mpc == NULL)
 			return -ENOMEM;
 		mpc->dev_num = arg;
-		mpc->dev = find_lec_by_itfnum(arg); /* NULL if there was no lec */
+		mpc->dev = find_lec_by_itfnum(arg);
+					/* NULL if there was no lec */
 	}
 	if (mpc->mpoad_vcc) {
-		printk("mpoa: mpoad_attach: mpoad is already present for itf %d\n", arg);
+		pr_info("mpoad is already present for itf %d\n", arg);
 		return -EADDRINUSE;
 	}
 
@@ -796,8 +839,8 @@ static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 	mpc->mpoad_vcc = vcc;
 	vcc->dev = &mpc_dev;
 	vcc_insert_socket(sk_atm(vcc));
-	set_bit(ATM_VF_META,&vcc->flags);
-	set_bit(ATM_VF_READY,&vcc->flags);
+	set_bit(ATM_VF_META, &vcc->flags);
+	set_bit(ATM_VF_READY, &vcc->flags);
 
 	if (mpc->dev) {
 		char empty[ATM_ESA_LEN];
@@ -807,7 +850,7 @@ static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 		/* set address if mpcd e.g. gets killed and restarted.
 		 * If we do not do it now we have to wait for the next LE_ARP
 		 */
-		if ( memcmp(mpc->mps_ctrl_addr, empty, ATM_ESA_LEN) != 0 )
+		if (memcmp(mpc->mps_ctrl_addr, empty, ATM_ESA_LEN) != 0)
 			send_set_mps_ctrl_addr(mpc->mps_ctrl_addr, mpc);
 	}
 
@@ -819,7 +862,7 @@ static void send_set_mps_ctrl_addr(const char *addr, struct mpoa_client *mpc)
 {
 	struct k_message mesg;
 
-	memcpy (mpc->mps_ctrl_addr, addr, ATM_ESA_LEN);
+	memcpy(mpc->mps_ctrl_addr, addr, ATM_ESA_LEN);
 
 	mesg.type = SET_MPS_CTRL_ADDR;
 	memcpy(mesg.MPS_ctrl, addr, ATM_ESA_LEN);
@@ -835,11 +878,11 @@ static void mpoad_close(struct atm_vcc *vcc)
 
 	mpc = find_mpc_by_vcc(vcc);
 	if (mpc == NULL) {
-		printk("mpoa: mpoad_close: did not find MPC\n");
+		pr_info("did not find MPC\n");
 		return;
 	}
 	if (!mpc->mpoad_vcc) {
-		printk("mpoa: mpoad_close: close for non-present mpoad\n");
+		pr_info("close for non-present mpoad\n");
 		return;
 	}
 
@@ -859,7 +902,7 @@ static void mpoad_close(struct atm_vcc *vcc)
 		kfree_skb(skb);
 	}
 
-	printk("mpoa: (%s) going down\n",
+	pr_info("(%s) going down\n",
 		(mpc->dev) ? mpc->dev->name : "<unknown>");
 	module_put(THIS_MODULE);
 
@@ -873,15 +916,16 @@ static int msg_from_mpoad(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 
 	struct mpoa_client *mpc = find_mpc_by_vcc(vcc);
-	struct k_message *mesg = (struct k_message*)skb->data;
+	struct k_message *mesg = (struct k_message *)skb->data;
 	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 
 	if (mpc == NULL) {
-		printk("mpoa: msg_from_mpoad: no mpc found\n");
+		pr_info("no mpc found\n");
 		return 0;
 	}
-	dprintk("mpoa: (%s) msg_from_mpoad:", (mpc->dev) ? mpc->dev->name : "<unknown>");
-	switch(mesg->type) {
+	dprintk("mpoa: (%s) msg_from_mpoad:",
+		(mpc->dev) ? mpc->dev->name : "<unknown>");
+	switch (mesg->type) {
 	case MPOA_RES_REPLY_RCVD:
 		dprintk(" mpoa_res_reply_rcvd\n");
 		MPOA_res_reply_rcvd(mesg, mpc);
@@ -942,7 +986,7 @@ int msg_to_mpoad(struct k_message *mesg, struct mpoa_client *mpc)
 	struct sock *sk;
 
 	if (mpc == NULL || !mpc->mpoad_vcc) {
-		printk("mpoa: msg_to_mpoad: mesg %d to a non-existent mpoad\n", mesg->type);
+		pr_info("mesg %d to a non-existent mpoad\n", mesg->type);
 		return -ENXIO;
 	}
 
@@ -960,7 +1004,8 @@ int msg_to_mpoad(struct k_message *mesg, struct mpoa_client *mpc)
 	return 0;
 }
 
-static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned long event, void *dev_ptr)
+static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
+			       unsigned long event, void *dev_ptr)
 {
 	struct net_device *dev;
 	struct mpoa_client *mpc;
@@ -983,10 +1028,10 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 		mpc = find_mpc_by_itfnum(priv->itfnum);
 		if (mpc == NULL) {
 			dprintk("mpoa: mpoa_event_listener: allocating new mpc for %s\n",
-			       dev->name);
+				dev->name);
 			mpc = alloc_mpc();
 			if (mpc == NULL) {
-				printk("mpoa: mpoa_event_listener: no new mpc");
+				pr_info("no new mpc");
 				break;
 			}
 		}
@@ -1010,9 +1055,8 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 		mpc = find_mpc_by_lec(dev);
 		if (mpc == NULL)
 			break;
-		if (mpc->mpoad_vcc != NULL) {
+		if (mpc->mpoad_vcc != NULL)
 			start_mpc(mpc, dev);
-		}
 		break;
 	case NETDEV_DOWN:
 		/* the dev was ifconfig'ed down */
@@ -1022,9 +1066,8 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 		mpc = find_mpc_by_lec(dev);
 		if (mpc == NULL)
 			break;
-		if (mpc->mpoad_vcc != NULL) {
+		if (mpc->mpoad_vcc != NULL)
 			stop_mpc(mpc);
-		}
 		break;
 	case NETDEV_REBOOT:
 	case NETDEV_CHANGE:
@@ -1051,7 +1094,7 @@ static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	in_cache_entry *entry;
 
 	entry = mpc->in_ops->get(dst_ip, mpc);
-	if(entry == NULL){
+	if (entry == NULL) {
 		entry = mpc->in_ops->add_entry(dst_ip, mpc);
 		entry->entry_state = INGRESS_RESOLVING;
 		msg->type = SND_MPOA_RES_RQST;
@@ -1062,7 +1105,7 @@ static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 		return;
 	}
 
-	if(entry->entry_state == INGRESS_INVALID){
+	if (entry->entry_state == INGRESS_INVALID) {
 		entry->entry_state = INGRESS_RESOLVING;
 		msg->type = SND_MPOA_RES_RQST;
 		msg->content.in_info = entry->ctrl_info;
@@ -1072,7 +1115,7 @@ static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 		return;
 	}
 
-	printk("mpoa: (%s) MPOA_trigger_rcvd: entry already in resolving state\n",
+	pr_info("(%s) entry already in resolving state\n",
 		(mpc->dev) ? mpc->dev->name : "<unknown>");
 	mpc->in_ops->put(entry);
 	return;
@@ -1082,22 +1125,24 @@ static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc)
  * Things get complicated because we have to check if there's an egress
  * shortcut with suitable traffic parameters we could use.
  */
-static void check_qos_and_open_shortcut(struct k_message *msg, struct mpoa_client *client, in_cache_entry *entry)
+static void check_qos_and_open_shortcut(struct k_message *msg,
+					struct mpoa_client *client,
+					in_cache_entry *entry)
 {
 	__be32 dst_ip = msg->content.in_info.in_dst_ip;
 	struct atm_mpoa_qos *qos = atm_mpoa_search_qos(dst_ip);
 	eg_cache_entry *eg_entry = client->eg_ops->get_by_src_ip(dst_ip, client);
 
-	if(eg_entry && eg_entry->shortcut){
-		if(eg_entry->shortcut->qos.txtp.traffic_class &
-		   msg->qos.txtp.traffic_class &
-		   (qos ? qos->qos.txtp.traffic_class : ATM_UBR | ATM_CBR)){
-			    if(eg_entry->shortcut->qos.txtp.traffic_class == ATM_UBR)
-				    entry->shortcut = eg_entry->shortcut;
-			    else if(eg_entry->shortcut->qos.txtp.max_pcr > 0)
-				    entry->shortcut = eg_entry->shortcut;
+	if (eg_entry && eg_entry->shortcut) {
+		if (eg_entry->shortcut->qos.txtp.traffic_class &
+		    msg->qos.txtp.traffic_class &
+		    (qos ? qos->qos.txtp.traffic_class : ATM_UBR | ATM_CBR)) {
+			if (eg_entry->shortcut->qos.txtp.traffic_class == ATM_UBR)
+				entry->shortcut = eg_entry->shortcut;
+			else if (eg_entry->shortcut->qos.txtp.max_pcr > 0)
+				entry->shortcut = eg_entry->shortcut;
 		}
-		if(entry->shortcut){
+		if (entry->shortcut) {
 			dprintk("mpoa: (%s) using egress SVC to reach %pI4\n",
 				client->dev->name, &dst_ip);
 			client->eg_ops->put(eg_entry);
@@ -1109,12 +1154,13 @@ static void check_qos_and_open_shortcut(struct k_message *msg, struct mpoa_clien
 
 	/* No luck in the egress cache we must open an ingress SVC */
 	msg->type = OPEN_INGRESS_SVC;
-	if (qos && (qos->qos.txtp.traffic_class == msg->qos.txtp.traffic_class))
-	{
+	if (qos &&
+	    (qos->qos.txtp.traffic_class == msg->qos.txtp.traffic_class)) {
 		msg->qos = qos->qos;
-		printk("mpoa: (%s) trying to get a CBR shortcut\n",client->dev->name);
-	}
-	else memset(&msg->qos,0,sizeof(struct atm_qos));
+		pr_info("(%s) trying to get a CBR shortcut\n",
+			client->dev->name);
+	} else
+		memset(&msg->qos, 0, sizeof(struct atm_qos));
 	msg_to_mpoad(msg, client);
 	return;
 }
@@ -1126,15 +1172,17 @@ static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 
 	dprintk("mpoa: (%s) MPOA_res_reply_rcvd: ip %pI4\n",
 		mpc->dev->name, &dst_ip);
-	ddprintk("mpoa: (%s) MPOA_res_reply_rcvd() entry = %p", mpc->dev->name, entry);
-	if(entry == NULL){
-		printk("\nmpoa: (%s) ARGH, received res. reply for an entry that doesn't exist.\n", mpc->dev->name);
+	ddprintk("mpoa: (%s) MPOA_res_reply_rcvd() entry = %p",
+		 mpc->dev->name, entry);
+	if (entry == NULL) {
+		pr_info("(%s) ARGH, received res. reply for an entry that doesn't exist.\n",
+			mpc->dev->name);
 		return;
 	}
 	ddprintk(" entry_state = %d ", entry->entry_state);
 
 	if (entry->entry_state == INGRESS_RESOLVED) {
-		printk("\nmpoa: (%s) MPOA_res_reply_rcvd for RESOLVED entry!\n", mpc->dev->name);
+		pr_info("(%s) RESOLVED entry!\n", mpc->dev->name);
 		mpc->in_ops->put(entry);
 		return;
 	}
@@ -1145,15 +1193,16 @@ static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	entry->refresh_time = 0;
 	ddprintk("entry->shortcut = %p\n", entry->shortcut);
 
-	if(entry->entry_state == INGRESS_RESOLVING && entry->shortcut != NULL){
+	if (entry->entry_state == INGRESS_RESOLVING &&
+	    entry->shortcut != NULL) {
 		entry->entry_state = INGRESS_RESOLVED;
 		mpc->in_ops->put(entry);
 		return; /* Shortcut already open... */
 	}
 
 	if (entry->shortcut != NULL) {
-		printk("mpoa: (%s) MPOA_res_reply_rcvd: entry->shortcut != NULL, impossible!\n",
-		       mpc->dev->name);
+		pr_info("(%s) entry->shortcut != NULL, impossible!\n",
+			mpc->dev->name);
 		mpc->in_ops->put(entry);
 		return;
 	}
@@ -1172,9 +1221,9 @@ static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	__be32 mask = msg->ip_mask;
 	in_cache_entry *entry = mpc->in_ops->get_with_mask(dst_ip, mpc, mask);
 
-	if(entry == NULL){
-		printk("mpoa: (%s) ingress_purge_rcvd: purge for a non-existing entry, ip = %pI4\n",
-		       mpc->dev->name, &dst_ip);
+	if (entry == NULL) {
+		pr_info("(%s) purge for a non-existing entry, ip = %pI4\n",
+			mpc->dev->name, &dst_ip);
 		return;
 	}
 
@@ -1197,7 +1246,8 @@ static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	eg_cache_entry *entry = mpc->eg_ops->get_by_cache_id(cache_id, mpc);
 
 	if (entry == NULL) {
-		dprintk("mpoa: (%s) egress_purge_rcvd: purge for a non-existing entry\n", mpc->dev->name);
+		dprintk("mpoa: (%s) egress_purge_rcvd: purge for a non-existing entry\n",
+			mpc->dev->name);
 		return;
 	}
 
@@ -1218,13 +1268,13 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 
 	dprintk("mpoa: purge_egress_shortcut: entering\n");
 	if (vcc == NULL) {
-		printk("mpoa: purge_egress_shortcut: vcc == NULL\n");
+		pr_info("vcc == NULL\n");
 		return;
 	}
 
 	skb = alloc_skb(sizeof(struct k_message), GFP_ATOMIC);
 	if (skb == NULL) {
-		 printk("mpoa: purge_egress_shortcut: out of memory\n");
+		pr_info("out of memory\n");
 		return;
 	}
 
@@ -1249,14 +1299,14 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
  * Our MPS died. Tell our daemon to send NHRP data plane purge to each
  * of the egress shortcuts we have.
  */
-static void mps_death( struct k_message * msg, struct mpoa_client * mpc )
+static void mps_death(struct k_message *msg, struct mpoa_client *mpc)
 {
 	eg_cache_entry *entry;
 
 	dprintk("mpoa: (%s) mps_death:\n", mpc->dev->name);
 
-	if(memcmp(msg->MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN)){
-		printk("mpoa: (%s) mps_death: wrong MPS\n", mpc->dev->name);
+	if (memcmp(msg->MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN)) {
+		pr_info("(%s) wrong MPS\n", mpc->dev->name);
 		return;
 	}
 
@@ -1275,20 +1325,21 @@ static void mps_death( struct k_message * msg, struct mpoa_client * mpc )
 	return;
 }
 
-static void MPOA_cache_impos_rcvd( struct k_message * msg, struct mpoa_client * mpc)
+static void MPOA_cache_impos_rcvd(struct k_message *msg,
+				  struct mpoa_client *mpc)
 {
 	uint16_t holding_time;
 	eg_cache_entry *entry = mpc->eg_ops->get_by_cache_id(msg->content.eg_info.cache_id, mpc);
 
 	holding_time = msg->content.eg_info.holding_time;
 	dprintk("mpoa: (%s) MPOA_cache_impos_rcvd: entry = %p, holding_time = %u\n",
-	       mpc->dev->name, entry, holding_time);
-	if(entry == NULL && holding_time) {
+		mpc->dev->name, entry, holding_time);
+	if (entry == NULL && holding_time) {
 		entry = mpc->eg_ops->add_entry(msg, mpc);
 		mpc->eg_ops->put(entry);
 		return;
 	}
-	if(holding_time){
+	if (holding_time) {
 		mpc->eg_ops->update(entry, holding_time);
 		return;
 	}
@@ -1302,7 +1353,8 @@ static void MPOA_cache_impos_rcvd( struct k_message * msg, struct mpoa_client *
 	return;
 }
 
-static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg, struct mpoa_client *mpc)
+static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg,
+				   struct mpoa_client *mpc)
 {
 	struct lec_priv *priv;
 	int i, retval ;
@@ -1318,33 +1370,38 @@ static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg, struct mpoa_client *m
 	memcpy(mpc->our_ctrl_addr, mesg->MPS_ctrl, ATM_ESA_LEN);
 
 	dprintk("mpoa: (%s) setting MPC ctrl ATM address to ",
-	       (mpc->dev) ? mpc->dev->name : "<unknown>");
+		(mpc->dev) ? mpc->dev->name : "<unknown>");
 	for (i = 7; i < sizeof(tlv); i++)
 		dprintk("%02x ", tlv[i]);
 	dprintk("\n");
 
 	if (mpc->dev) {
 		priv = netdev_priv(mpc->dev);
-		retval = priv->lane2_ops->associate_req(mpc->dev, mpc->dev->dev_addr, tlv, sizeof(tlv));
+		retval = priv->lane2_ops->associate_req(mpc->dev,
+							mpc->dev->dev_addr,
+							tlv, sizeof(tlv));
 		if (retval == 0)
-			printk("mpoa: (%s) MPOA device type TLV association failed\n", mpc->dev->name);
+			pr_info("(%s) MPOA device type TLV association failed\n",
+				mpc->dev->name);
 		retval = priv->lane2_ops->resolve(mpc->dev, NULL, 1, NULL, NULL);
 		if (retval < 0)
-			printk("mpoa: (%s) targetless LE_ARP request failed\n", mpc->dev->name);
+			pr_info("(%s) targetless LE_ARP request failed\n",
+				mpc->dev->name);
 	}
 
 	return;
 }
 
-static void set_mps_mac_addr_rcvd(struct k_message *msg, struct mpoa_client *client)
+static void set_mps_mac_addr_rcvd(struct k_message *msg,
+				  struct mpoa_client *client)
 {
 
-	if(client->number_of_mps_macs)
+	if (client->number_of_mps_macs)
 		kfree(client->mps_macs);
 	client->number_of_mps_macs = 0;
 	client->mps_macs = kmemdup(msg->MPS_ctrl, ETH_ALEN, GFP_KERNEL);
 	if (client->mps_macs == NULL) {
-		printk("mpoa: set_mps_mac_addr_rcvd: out of memory\n");
+		pr_info("out of memory\n");
 		return;
 	}
 	client->number_of_mps_macs = 1;
@@ -1365,11 +1422,11 @@ static void clean_up(struct k_message *msg, struct mpoa_client *mpc, int action)
 	/* FIXME: This knows too much of the cache structure */
 	read_lock_irq(&mpc->egress_lock);
 	entry = mpc->eg_cache;
-	while (entry != NULL){
-		    msg->content.eg_info = entry->ctrl_info;
-		    dprintk("mpoa: cache_id %u\n", entry->ctrl_info.cache_id);
-		    msg_to_mpoad(msg, mpc);
-		    entry = entry->next;
+	while (entry != NULL) {
+		msg->content.eg_info = entry->ctrl_info;
+		dprintk("mpoa: cache_id %u\n", entry->ctrl_info.cache_id);
+		msg_to_mpoad(msg, mpc);
+		entry = entry->next;
 	}
 	read_unlock_irq(&mpc->egress_lock);
 
@@ -1388,20 +1445,22 @@ static void mpc_timer_refresh(void)
 	return;
 }
 
-static void mpc_cache_check( unsigned long checking_time  )
+static void mpc_cache_check(unsigned long checking_time)
 {
 	struct mpoa_client *mpc = mpcs;
 	static unsigned long previous_resolving_check_time;
 	static unsigned long previous_refresh_time;
 
-	while( mpc != NULL ){
+	while (mpc != NULL) {
 		mpc->in_ops->clear_count(mpc);
 		mpc->eg_ops->clear_expired(mpc);
-		if(checking_time - previous_resolving_check_time > mpc->parameters.mpc_p4 * HZ ){
+		if (checking_time - previous_resolving_check_time >
+		    mpc->parameters.mpc_p4 * HZ) {
 			mpc->in_ops->check_resolving(mpc);
 			previous_resolving_check_time = checking_time;
 		}
-		if(checking_time - previous_refresh_time > mpc->parameters.mpc_p5 * HZ ){
+		if (checking_time - previous_refresh_time >
+		    mpc->parameters.mpc_p5 * HZ) {
 			mpc->in_ops->refresh(mpc);
 			previous_refresh_time = checking_time;
 		}
@@ -1412,7 +1471,8 @@ static void mpc_cache_check( unsigned long checking_time  )
 	return;
 }
 
-static int atm_mpoa_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+static int atm_mpoa_ioctl(struct socket *sock, unsigned int cmd,
+			  unsigned long arg)
 {
 	int err = 0;
 	struct atm_vcc *vcc = ATM_SD(sock);
@@ -1424,21 +1484,20 @@ static int atm_mpoa_ioctl(struct socket *sock, unsigned int cmd, unsigned long a
 		return -EPERM;
 
 	switch (cmd) {
-		case ATMMPC_CTRL:
-			err = atm_mpoa_mpoad_attach(vcc, (int)arg);
-			if (err >= 0)
-				sock->state = SS_CONNECTED;
-			break;
-		case ATMMPC_DATA:
-			err = atm_mpoa_vcc_attach(vcc, (void __user *)arg);
-			break;
-		default:
-			break;
+	case ATMMPC_CTRL:
+		err = atm_mpoa_mpoad_attach(vcc, (int)arg);
+		if (err >= 0)
+			sock->state = SS_CONNECTED;
+		break;
+	case ATMMPC_DATA:
+		err = atm_mpoa_vcc_attach(vcc, (void __user *)arg);
+		break;
+	default:
+		break;
 	}
 	return err;
 }
 
-
 static struct atm_ioctl atm_ioctl_ops = {
 	.owner	= THIS_MODULE,
 	.ioctl	= atm_mpoa_ioctl,
@@ -1451,7 +1510,7 @@ static __init int atm_mpoa_init(void)
 	if (mpc_proc_init() != 0)
 		pr_info("failed to initialize /proc/mpoa\n");
 
-	printk("mpc.c: " __DATE__ " " __TIME__ " initialized\n");
+	pr_info("mpc.c: " __DATE__ " " __TIME__ " initialized\n");
 
 	return 0;
 }
-- 
1.6.6.rc0.57.gad7a

