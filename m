From: Joe Perches <joe@perches.com>
Subject: [PATCH 21/21] net/atm: Cleanup dprint/ddprintk #defines and uses
Date: Tue, 26 Jan 2010 13:40:20 -0800
Message-ID: <2328bd8fd64efda09cb0ec8390eb40599c9a3e46.1264541550.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1491 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015Ab0AZVkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:25 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move "mpoa:%s: ", __func__/__FILE__ to #defines
Remove mpoa __func__/__FILE__ from dprintk uses
Add and use #define dprint_cont where appropriate

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/mpc.c         |  153 +++++++++++++++++++++++++------------------------
 net/atm/mpoa_caches.c |   50 +++++++++-------
 net/atm/mpoa_proc.c   |   28 ++++++---
 3 files changed, 124 insertions(+), 107 deletions(-)

diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 55dba22..a6521c8 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -38,21 +38,31 @@
  */
 
 #if 0
-#define dprintk(format, args...) printk(KERN_DEBUG format, ##args)   /* debug */
+#define dprintk(format, args...) \
+	printk(KERN_DEBUG "mpoa:%s: " format, __func__, ##args)
+#define dprintk_cont(format, args...) printk(KERN_CONT format, ##args)
 #else
-#define dprintk(format, args...)			\
-	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
+#define dprintk(format, args...)					\
+	do { if (0)							\
+		printk(KERN_DEBUG "mpoa:%s: " format, __func__, ##args);\
+	} while (0)
+#define dprintk_cont(format, args...)			\
+	do { if (0) printk(KERN_CONT format, ##args); } while (0)
 #endif
 
 #if 0
-#define ddprintk printk(KERN_DEBUG format, ##args)  /* more debug */
+#define ddprintk(format, args...) \
+	printk(KERN_DEBUG "mpoa:%s: " format, __func__, ##args)
+#define ddprintk_cont(format, args...) printk(KERN_CONT format, ##args)
 #else
-#define ddprintk(format, args...)			\
-	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
+#define ddprintk(format, args...)					\
+	do { if (0)							\
+		printk(KERN_DEBUG "mpoa:%s: " format, __func__, ##args);\
+	} while (0)
+#define ddprintk_cont(format, args...)			\
+	do { if (0) printk(KERN_CONT format, ##args); } while (0)
 #endif
 
-
-
 #define MPOA_TAG_LEN 4
 
 /* mpc_daemon -> kernel */
@@ -302,7 +312,7 @@ static struct mpoa_client *alloc_mpc(void)
 static void start_mpc(struct mpoa_client *mpc, struct net_device *dev)
 {
 
-	dprintk("mpoa: (%s) start_mpc:\n", mpc->dev->name);
+	dprintk("(%s)\n", mpc->dev->name);
 	if (!dev->netdev_ops)
 		pr_info("(%s) not starting\n", dev->name);
 	else {
@@ -316,14 +326,14 @@ static void start_mpc(struct mpoa_client *mpc, struct net_device *dev)
 static void stop_mpc(struct mpoa_client *mpc)
 {
 	struct net_device *dev = mpc->dev;
-	dprintk("mpoa: (%s) stop_mpc:", mpc->dev->name);
+	dprintk("(%s)", mpc->dev->name);
 
 	/* Lets not nullify lec device's dev->hard_start_xmit */
 	if (dev->netdev_ops != &mpc->new_ops) {
-		dprintk(" mpc already stopped, not fatal\n");
+		dprintk_cont(" mpc already stopped, not fatal\n");
 		return;
 	}
-	dprintk("\n");
+	dprintk_cont("\n");
 
 	dev->netdev_ops = mpc->old_ops;
 	mpc->old_ops = NULL;
@@ -371,7 +381,7 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 	struct mpoa_client *mpc;
 
 	mpoa_device_type = number_of_mps_macs = 0; /* silence gcc */
-	dprintk("mpoa: (%s) lane2_assoc_ind: received TLV(s), ", dev->name);
+	dprintk("(%s) received TLV(s), ", dev->name);
 	dprintk("total length of all TLVs %d\n", sizeoftlvs);
 	mpc = find_mpc_by_lec(dev); /* Sampo-Fix: moved here from below */
 	if (mpc == NULL) {
@@ -402,7 +412,7 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 		}
 		mpoa_device_type = *tlvs++;
 		number_of_mps_macs = *tlvs++;
-		dprintk("mpoa: (%s) MPOA device type '%s', ",
+		dprintk("(%s) MPOA device type '%s', ",
 			dev->name, mpoa_device_type_string(mpoa_device_type));
 		if (mpoa_device_type == MPS_AND_MPC &&
 		    length < (42 + number_of_mps_macs*ETH_ALEN)) { /* :) */
@@ -417,7 +427,7 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 		}
 		if (mpoa_device_type != MPS &&
 		    mpoa_device_type != MPS_AND_MPC) {
-			dprintk("ignoring non-MPS device\n");
+			dprintk("ignoring non-MPS device ");
 			if (mpoa_device_type == MPC)
 				tlvs += 20;
 			continue;  /* we are only interested in MPSs */
@@ -427,7 +437,8 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 			pr_info("(%s) MPS_AND_MPC has zero MACs\n", dev->name);
 			continue;  /* someone should read the spec */
 		}
-		dprintk("this MPS has %d MAC addresses\n", number_of_mps_macs);
+		dprintk_cont("this MPS has %d MAC addresses\n",
+			     number_of_mps_macs);
 
 		/*
 		 * ok, now we can go and tell our daemon
@@ -498,7 +509,7 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 	iph = (struct iphdr *)buff;
 	ipaddr = iph->daddr;
 
-	ddprintk("mpoa: (%s) send_via_shortcut: ipaddr 0x%x\n",
+	ddprintk("(%s) ipaddr 0x%x\n",
 		 mpc->dev->name, ipaddr);
 
 	entry = mpc->in_ops->get(ipaddr, mpc);
@@ -510,17 +521,17 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 	}
 	/* threshold not exceeded or VCC not ready */
 	if (mpc->in_ops->cache_hit(entry, mpc) != OPEN) {
-		ddprintk("mpoa: (%s) send_via_shortcut: cache_hit: returns != OPEN\n",
+		ddprintk("(%s) cache_hit: returns != OPEN\n",
 			 mpc->dev->name);
 		mpc->in_ops->put(entry);
 		return 1;
 	}
 
-	ddprintk("mpoa: (%s) send_via_shortcut: using shortcut\n",
+	ddprintk("(%s) using shortcut\n",
 		 mpc->dev->name);
 	/* MPOA spec A.1.4, MPOA client must decrement IP ttl at least by one */
 	if (iph->ttl <= 1) {
-		ddprintk("mpoa: (%s) send_via_shortcut: IP ttl = %u, using LANE\n",
+		ddprintk("(%s) IP ttl = %u, using LANE\n",
 			 mpc->dev->name, iph->ttl);
 		mpc->in_ops->put(entry);
 		return 1;
@@ -530,7 +541,7 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 
 	if (entry->ctrl_info.tag != 0) {
-		ddprintk("mpoa: (%s) send_via_shortcut: adding tag 0x%x\n",
+		ddprintk("(%s) adding tag 0x%x\n",
 			 mpc->dev->name, entry->ctrl_info.tag);
 		tagged_llc_snap_hdr.tag = entry->ctrl_info.tag;
 		skb_pull(skb, ETH_HLEN);	/* get rid of Eth header */
@@ -655,25 +666,23 @@ static void mpc_vcc_close(struct atm_vcc *vcc, struct net_device *dev)
 		return;
 	}
 
-	dprintk("mpoa: (%s) mpc_vcc_close:\n", dev->name);
+	dprintk("(%s)\n", dev->name);
 	in_entry = mpc->in_ops->get_by_vcc(vcc, mpc);
 	if (in_entry) {
-		dprintk("mpoa: (%s) mpc_vcc_close: ingress SVC closed ip = %pI4\n",
+		dprintk("(%s) ingress SVC closed ip = %pI4\n",
 			mpc->dev->name, &in_entry->ctrl_info.in_dst_ip);
 		in_entry->shortcut = NULL;
 		mpc->in_ops->put(in_entry);
 	}
 	eg_entry = mpc->eg_ops->get_by_vcc(vcc, mpc);
 	if (eg_entry) {
-		dprintk("mpoa: (%s) mpc_vcc_close: egress SVC closed\n",
-			mpc->dev->name);
+		dprintk("(%s) egress SVC closed\n", mpc->dev->name);
 		eg_entry->shortcut = NULL;
 		mpc->eg_ops->put(eg_entry);
 	}
 
 	if (in_entry == NULL && eg_entry == NULL)
-		dprintk("mpoa: (%s) mpc_vcc_close:  unused vcc closed\n",
-			dev->name);
+		dprintk("(%s) unused vcc closed\n", dev->name);
 
 	return;
 }
@@ -687,10 +696,9 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	__be32 tag;
 	char *tmp;
 
-	ddprintk("mpoa: (%s) mpc_push:\n", dev->name);
+	ddprintk("(%s)\n", dev->name);
 	if (skb == NULL) {
-		dprintk("mpoa: (%s) mpc_push: null skb, closing VCC\n",
-			dev->name);
+		dprintk("(%s) null skb, closing VCC\n", dev->name);
 		mpc_vcc_close(vcc, dev);
 		return;
 	}
@@ -700,8 +708,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 		   sizeof(struct llc_snap_hdr)) == 0) {
 		struct sock *sk = sk_atm(vcc);
 
-		dprintk("mpoa: (%s) mpc_push: control packet arrived\n",
-			dev->name);
+		dprintk("(%s) control packet arrived\n", dev->name);
 		/* Pass control packets to daemon */
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);
@@ -719,8 +726,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	if (memcmp(skb->data, &llc_snap_mpoa_data_tagged,
 		   sizeof(struct llc_snap_hdr)) == 0) { /* MPOA tagged data */
-		ddprintk("mpoa: (%s) mpc_push: tagged data packet arrived\n",
-			 dev->name);
+		ddprintk("(%s) tagged data packet arrived\n", dev->name);
 
 	} else if (memcmp(skb->data, &llc_snap_mpoa_data,
 			  sizeof(struct llc_snap_hdr)) == 0) { /* MPOA data */
@@ -813,8 +819,7 @@ static int atm_mpoa_mpoad_attach(struct atm_vcc *vcc, int arg)
 
 	mpc = find_mpc_by_itfnum(arg);
 	if (mpc == NULL) {
-		dprintk("mpoa: mpoad_attach: allocating new mpc for itf %d\n",
-			arg);
+		dprintk("allocating new mpc for itf %d\n", arg);
 		mpc = alloc_mpc();
 		if (mpc == NULL)
 			return -ENOMEM;
@@ -923,55 +928,54 @@ static int msg_from_mpoad(struct atm_vcc *vcc, struct sk_buff *skb)
 		pr_info("no mpc found\n");
 		return 0;
 	}
-	dprintk("mpoa: (%s) msg_from_mpoad:",
-		(mpc->dev) ? mpc->dev->name : "<unknown>");
+	dprintk("(%s)", mpc->dev ? mpc->dev->name : "<unknown>");
 	switch (mesg->type) {
 	case MPOA_RES_REPLY_RCVD:
-		dprintk(" mpoa_res_reply_rcvd\n");
+		dprintk_cont("mpoa_res_reply_rcvd\n");
 		MPOA_res_reply_rcvd(mesg, mpc);
 		break;
 	case MPOA_TRIGGER_RCVD:
-		dprintk(" mpoa_trigger_rcvd\n");
+		dprintk_cont("mpoa_trigger_rcvd\n");
 		MPOA_trigger_rcvd(mesg, mpc);
 		break;
 	case INGRESS_PURGE_RCVD:
-		dprintk(" nhrp_purge_rcvd\n");
+		dprintk_cont("nhrp_purge_rcvd\n");
 		ingress_purge_rcvd(mesg, mpc);
 		break;
 	case EGRESS_PURGE_RCVD:
-		dprintk(" egress_purge_reply_rcvd\n");
+		dprintk_cont("egress_purge_reply_rcvd\n");
 		egress_purge_rcvd(mesg, mpc);
 		break;
 	case MPS_DEATH:
-		dprintk(" mps_death\n");
+		dprintk_cont("mps_death\n");
 		mps_death(mesg, mpc);
 		break;
 	case CACHE_IMPOS_RCVD:
-		dprintk(" cache_impos_rcvd\n");
+		dprintk_cont("cache_impos_rcvd\n");
 		MPOA_cache_impos_rcvd(mesg, mpc);
 		break;
 	case SET_MPC_CTRL_ADDR:
-		dprintk(" set_mpc_ctrl_addr\n");
+		dprintk_cont("set_mpc_ctrl_addr\n");
 		set_mpc_ctrl_addr_rcvd(mesg, mpc);
 		break;
 	case SET_MPS_MAC_ADDR:
-		dprintk(" set_mps_mac_addr\n");
+		dprintk_cont("set_mps_mac_addr\n");
 		set_mps_mac_addr_rcvd(mesg, mpc);
 		break;
 	case CLEAN_UP_AND_EXIT:
-		dprintk(" clean_up_and_exit\n");
+		dprintk_cont("clean_up_and_exit\n");
 		clean_up(mesg, mpc, DIE);
 		break;
 	case RELOAD:
-		dprintk(" reload\n");
+		dprintk_cont("reload\n");
 		clean_up(mesg, mpc, RELOAD);
 		break;
 	case SET_MPC_PARAMS:
-		dprintk(" set_mpc_params\n");
+		dprintk_cont("set_mpc_params\n");
 		mpc->parameters = mesg->content.params;
 		break;
 	default:
-		dprintk(" unknown message %d\n", mesg->type);
+		dprintk_cont("unknown message %d\n", mesg->type);
 		break;
 	}
 	kfree_skb(skb);
@@ -1027,8 +1031,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 		priv->lane2_ops->associate_indicator = lane2_assoc_ind;
 		mpc = find_mpc_by_itfnum(priv->itfnum);
 		if (mpc == NULL) {
-			dprintk("mpoa: mpoa_event_listener: allocating new mpc for %s\n",
-				dev->name);
+			dprintk("allocating new mpc for %s\n", dev->name);
 			mpc = alloc_mpc();
 			if (mpc == NULL) {
 				pr_info("no new mpc");
@@ -1038,14 +1041,14 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 		mpc->dev_num = priv->itfnum;
 		mpc->dev = dev;
 		dev_hold(dev);
-		dprintk("mpoa: (%s) was initialized\n", dev->name);
+		dprintk("(%s) was initialized\n", dev->name);
 		break;
 	case NETDEV_UNREGISTER:
 		/* the lec device was deallocated */
 		mpc = find_mpc_by_lec(dev);
 		if (mpc == NULL)
 			break;
-		dprintk("mpoa: device (%s) was deallocated\n", dev->name);
+		dprintk("device (%s) was deallocated\n", dev->name);
 		stop_mpc(mpc);
 		dev_put(mpc->dev);
 		mpc->dev = NULL;
@@ -1143,7 +1146,7 @@ static void check_qos_and_open_shortcut(struct k_message *msg,
 				entry->shortcut = eg_entry->shortcut;
 		}
 		if (entry->shortcut) {
-			dprintk("mpoa: (%s) using egress SVC to reach %pI4\n",
+			dprintk("(%s) using egress SVC to reach %pI4\n",
 				client->dev->name, &dst_ip);
 			client->eg_ops->put(eg_entry);
 			return;
@@ -1170,16 +1173,16 @@ static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	__be32 dst_ip = msg->content.in_info.in_dst_ip;
 	in_cache_entry *entry = mpc->in_ops->get(dst_ip, mpc);
 
-	dprintk("mpoa: (%s) MPOA_res_reply_rcvd: ip %pI4\n",
+	dprintk("(%s) ip %pI4\n",
 		mpc->dev->name, &dst_ip);
-	ddprintk("mpoa: (%s) MPOA_res_reply_rcvd() entry = %p",
+	ddprintk("(%s) entry = %p",
 		 mpc->dev->name, entry);
 	if (entry == NULL) {
 		pr_info("(%s) ARGH, received res. reply for an entry that doesn't exist.\n",
 			mpc->dev->name);
 		return;
 	}
-	ddprintk(" entry_state = %d ", entry->entry_state);
+	ddprintk_cont(" entry_state = %d ", entry->entry_state);
 
 	if (entry->entry_state == INGRESS_RESOLVED) {
 		pr_info("(%s) RESOLVED entry!\n", mpc->dev->name);
@@ -1191,7 +1194,7 @@ static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	do_gettimeofday(&(entry->tv));
 	do_gettimeofday(&(entry->reply_wait)); /* Used in refreshing func from now on */
 	entry->refresh_time = 0;
-	ddprintk("entry->shortcut = %p\n", entry->shortcut);
+	ddprintk_cont("entry->shortcut = %p\n", entry->shortcut);
 
 	if (entry->entry_state == INGRESS_RESOLVING &&
 	    entry->shortcut != NULL) {
@@ -1228,7 +1231,7 @@ static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	}
 
 	do {
-		dprintk("mpoa: (%s) ingress_purge_rcvd: removing an ingress entry, ip = %pI4\n",
+		dprintk("(%s) removing an ingress entry, ip = %pI4\n",
 			mpc->dev->name, &dst_ip);
 		write_lock_bh(&mpc->ingress_lock);
 		mpc->in_ops->remove_entry(entry, mpc);
@@ -1246,7 +1249,7 @@ static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	eg_cache_entry *entry = mpc->eg_ops->get_by_cache_id(cache_id, mpc);
 
 	if (entry == NULL) {
-		dprintk("mpoa: (%s) egress_purge_rcvd: purge for a non-existing entry\n",
+		dprintk("(%s) purge for a non-existing entry\n",
 			mpc->dev->name);
 		return;
 	}
@@ -1266,7 +1269,7 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 	struct k_message *purge_msg;
 	struct sk_buff *skb;
 
-	dprintk("mpoa: purge_egress_shortcut: entering\n");
+	dprintk("entering\n");
 	if (vcc == NULL) {
 		pr_info("vcc == NULL\n");
 		return;
@@ -1290,7 +1293,7 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 	sk = sk_atm(vcc);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk, skb->len);
-	dprintk("mpoa: purge_egress_shortcut: exiting:\n");
+	dprintk("exiting\n");
 
 	return;
 }
@@ -1303,7 +1306,7 @@ static void mps_death(struct k_message *msg, struct mpoa_client *mpc)
 {
 	eg_cache_entry *entry;
 
-	dprintk("mpoa: (%s) mps_death:\n", mpc->dev->name);
+	dprintk("(%s)\n", mpc->dev->name);
 
 	if (memcmp(msg->MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN)) {
 		pr_info("(%s) wrong MPS\n", mpc->dev->name);
@@ -1332,7 +1335,7 @@ static void MPOA_cache_impos_rcvd(struct k_message *msg,
 	eg_cache_entry *entry = mpc->eg_ops->get_by_cache_id(msg->content.eg_info.cache_id, mpc);
 
 	holding_time = msg->content.eg_info.holding_time;
-	dprintk("mpoa: (%s) MPOA_cache_impos_rcvd: entry = %p, holding_time = %u\n",
+	dprintk("(%s) entry = %p, holding_time = %u\n",
 		mpc->dev->name, entry, holding_time);
 	if (entry == NULL && holding_time) {
 		entry = mpc->eg_ops->add_entry(msg, mpc);
@@ -1369,11 +1372,11 @@ static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg,
 	memcpy(&tlv[7], mesg->MPS_ctrl, ATM_ESA_LEN); /* MPC ctrl ATM addr */
 	memcpy(mpc->our_ctrl_addr, mesg->MPS_ctrl, ATM_ESA_LEN);
 
-	dprintk("mpoa: (%s) setting MPC ctrl ATM address to ",
-		(mpc->dev) ? mpc->dev->name : "<unknown>");
+	dprintk("(%s) setting MPC ctrl ATM address to",
+		mpc->dev ? mpc->dev->name : "<unknown>");
 	for (i = 7; i < sizeof(tlv); i++)
-		dprintk("%02x ", tlv[i]);
-	dprintk("\n");
+		dprintk_cont(" %02x", tlv[i]);
+	dprintk_cont("\n");
 
 	if (mpc->dev) {
 		priv = netdev_priv(mpc->dev);
@@ -1424,7 +1427,7 @@ static void clean_up(struct k_message *msg, struct mpoa_client *mpc, int action)
 	entry = mpc->eg_cache;
 	while (entry != NULL) {
 		msg->content.eg_info = entry->ctrl_info;
-		dprintk("mpoa: cache_id %u\n", entry->ctrl_info.cache_id);
+		dprintk("cache_id %u\n", entry->ctrl_info.cache_id);
 		msg_to_mpoad(msg, mpc);
 		entry = entry->next;
 	}
@@ -1537,15 +1540,15 @@ static void __exit atm_mpoa_cleanup(void)
 			if (priv->lane2_ops != NULL)
 				priv->lane2_ops->associate_indicator = NULL;
 		}
-		ddprintk("mpoa: cleanup_module: about to clear caches\n");
+		ddprintk("about to clear caches\n");
 		mpc->in_ops->destroy_cache(mpc);
 		mpc->eg_ops->destroy_cache(mpc);
-		ddprintk("mpoa: cleanup_module: caches cleared\n");
+		ddprintk("caches cleared\n");
 		kfree(mpc->mps_macs);
 		memset(mpc, 0, sizeof(struct mpoa_client));
-		ddprintk("mpoa: cleanup_module: about to kfree %p\n", mpc);
+		ddprintk("about to kfree %p\n", mpc);
 		kfree(mpc);
-		ddprintk("mpoa: cleanup_module: next mpc is at %p\n", tmp);
+		ddprintk("next mpc is at %p\n", tmp);
 		mpc = tmp;
 	}
 
@@ -1553,7 +1556,7 @@ static void __exit atm_mpoa_cleanup(void)
 	qos_head = NULL;
 	while (qos != NULL) {
 		nextqos = qos->next;
-		dprintk("mpoa: cleanup_module: freeing qos entry %p\n", qos);
+		dprintk("freeing qos entry %p\n", qos);
 		kfree(qos);
 		qos = nextqos;
 	}
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index de21cc6..4c14181 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -11,17 +11,23 @@
  */
 
 #if 0
-#define dprintk(format, args...) printk(KERN_DEBUG format, ##args)  /* debug */
+#define dprintk(format, args...)					\
+	printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args)  /* debug */
 #else
-#define dprintk(format, args...)			\
-	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
+#define dprintk(format, args...)					\
+	do { if (0)							\
+		printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args);\
+	} while (0)
 #endif
 
 #if 0
-#define ddprintk printk(KERN_DEBUG format, ##args)  /* more debug */
+#define ddprintk(format, args...)					\
+	printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args)  /* debug */
 #else
-#define ddprintk(format, args...)			\
-	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
+#define ddprintk(format, args...)					\
+	do { if (0)							\
+		printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args);\
+	} while (0)
 #endif
 
 static in_cache_entry *in_cache_get(__be32 dst_ip,
@@ -96,11 +102,10 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 		return NULL;
 	}
 
-	dprintk("mpoa: mpoa_caches.c: adding an ingress entry, ip = %pI4\n",
-		&dst_ip);
+	dprintk("adding an ingress entry, ip = %pI4\n", &dst_ip);
 
 	atomic_set(&entry->use, 1);
-	dprintk("mpoa: mpoa_caches.c: new_in_cache_entry: about to lock\n");
+	dprintk("new_in_cache_entry: about to lock\n");
 	write_lock_bh(&client->ingress_lock);
 	entry->next = client->in_cache;
 	entry->prev = NULL;
@@ -118,7 +123,7 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 	atomic_inc(&entry->use);
 
 	write_unlock_bh(&client->ingress_lock);
-	dprintk("mpoa: mpoa_caches.c: new_in_cache_entry: unlocked\n");
+	dprintk("new_in_cache_entry: unlocked\n");
 
 	return entry;
 }
@@ -154,7 +159,7 @@ static int cache_hit(in_cache_entry *entry, struct mpoa_client *mpc)
 
 	if (entry->count > mpc->parameters.mpc_p1 &&
 	    entry->entry_state == INGRESS_INVALID) {
-		dprintk("mpoa: (%s) mpoa_caches.c: threshold exceeded for ip %pI4, sending MPOA res req\n",
+		dprintk("(%s) threshold exceeded for ip %pI4, sending MPOA res req\n",
 			mpc->dev->name, &entry->ctrl_info.in_dst_ip);
 		entry->entry_state = INGRESS_RESOLVING;
 		msg.type = SND_MPOA_RES_RQST;
@@ -190,7 +195,7 @@ static void in_cache_remove_entry(in_cache_entry *entry,
 	struct k_message msg;
 
 	vcc = entry->shortcut;
-	dprintk("mpoa: mpoa_caches.c: removing an ingress entry, ip = %pI4\n",
+	dprintk("removing an ingress entry, ip = %pI4\n",
 		&entry->ctrl_info.in_dst_ip);
 
 	if (entry->prev != NULL)
@@ -235,7 +240,7 @@ static void clear_count_and_expired(struct mpoa_client *client)
 		next_entry = entry->next;
 		if ((now.tv_sec - entry->tv.tv_sec)
 		   > entry->ctrl_info.holding_time) {
-			dprintk("mpoa: mpoa_caches.c: holding time expired, ip = %pI4\n",
+			dprintk("holding time expired, ip = %pI4\n",
 				&entry->ctrl_info.in_dst_ip);
 			client->in_ops->remove_entry(entry, client);
 		}
@@ -302,7 +307,7 @@ static void refresh_entries(struct mpoa_client *client)
 	struct timeval now;
 	struct in_cache_entry *entry = client->in_cache;
 
-	ddprintk("mpoa: mpoa_caches.c: refresh_entries\n");
+	ddprintk("refresh_entries\n");
 	do_gettimeofday(&now);
 
 	read_lock_bh(&client->ingress_lock);
@@ -312,7 +317,7 @@ static void refresh_entries(struct mpoa_client *client)
 				entry->refresh_time = (2 * (entry->ctrl_info.holding_time))/3;
 			if ((now.tv_sec - entry->reply_wait.tv_sec) >
 			    entry->refresh_time) {
-				dprintk("mpoa: mpoa_caches.c: refreshing an entry.\n");
+				dprintk("refreshing an entry.\n");
 				entry->entry_state = INGRESS_REFRESHING;
 
 			}
@@ -435,7 +440,7 @@ static void eg_cache_remove_entry(eg_cache_entry *entry,
 	struct k_message msg;
 
 	vcc = entry->shortcut;
-	dprintk("mpoa: mpoa_caches.c: removing an egress entry.\n");
+	dprintk("removing an egress entry.\n");
 	if (entry->prev != NULL)
 		entry->prev->next = entry->next;
 	else
@@ -471,11 +476,11 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 		return NULL;
 	}
 
-	dprintk("mpoa: mpoa_caches.c: adding an egress entry, ip = %pI4, this should be our IP\n",
+	dprintk("adding an egress entry, ip = %pI4, this should be our IP\n",
 		&msg->content.eg_info.eg_dst_ip);
 
 	atomic_set(&entry->use, 1);
-	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry: about to lock\n");
+	dprintk("new_eg_cache_entry: about to lock\n");
 	write_lock_irq(&client->egress_lock);
 	entry->next = client->eg_cache;
 	entry->prev = NULL;
@@ -487,14 +492,13 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 	entry->ctrl_info = msg->content.eg_info;
 	do_gettimeofday(&(entry->tv));
 	entry->entry_state = EGRESS_RESOLVED;
-	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry cache_id %u\n",
+	dprintk("new_eg_cache_entry cache_id %u\n",
 		ntohl(entry->ctrl_info.cache_id));
-	dprintk("mpoa: mpoa_caches.c: mps_ip = %pI4\n",
-		&entry->ctrl_info.mps_ip);
+	dprintk("mps_ip = %pI4\n", &entry->ctrl_info.mps_ip);
 	atomic_inc(&entry->use);
 
 	write_unlock_irq(&client->egress_lock);
-	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry: unlocked\n");
+	dprintk("new_eg_cache_entry: unlocked\n");
 
 	return entry;
 }
@@ -524,7 +528,7 @@ static void clear_expired(struct mpoa_client *client)
 		   > entry->ctrl_info.holding_time) {
 			msg.type = SND_EGRESS_PURGE;
 			msg.content.eg_info = entry->ctrl_info;
-			dprintk("mpoa: mpoa_caches.c: egress_cache: holding time expired, cache_id = %u.\n",
+			dprintk("egress_cache: holding time expired, cache_id = %u.\n",
 				ntohl(entry->ctrl_info.cache_id));
 			msg_to_mpoad(&msg, client);
 			client->eg_ops->remove_entry(entry, client);
diff --git a/net/atm/mpoa_proc.c b/net/atm/mpoa_proc.c
index aae4a87..b9bdb98 100644
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -21,10 +21,23 @@
  */
 
 #if 1
-#define dprintk(format, args...) printk(KERN_DEBUG format, ##args)   /* debug */
+#define dprintk(format, args...)					\
+	printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args)  /* debug */
 #else
-#define dprintk(format, args...)			\
-	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
+#define dprintk(format, args...)					\
+	do { if (0)							\
+		printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args);\
+	} while (0)
+#endif
+
+#if 0
+#define ddprintk(format, args...)					\
+	printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args)  /* debug */
+#else
+#define ddprintk(format, args...)					\
+	do { if (0)							\
+		printk(KERN_DEBUG "mpoa:%s: " format, __FILE__, ##args);\
+	} while (0)
 #endif
 
 #define STAT_FILE_NAME "mpc"     /* Our statistic file's name */
@@ -258,12 +271,9 @@ static int parse_qos(const char *buff)
 	qos.rxtp.max_pcr = rx_pcr;
 	qos.rxtp.max_sdu = rx_sdu;
 	qos.aal = ATM_AAL5;
-	dprintk("mpoa: mpoa_proc.c: parse_qos(): setting qos paramameters to tx=%d,%d rx=%d,%d\n",
-		qos.txtp.max_pcr,
-		qos.txtp.max_sdu,
-		qos.rxtp.max_pcr,
-		qos.rxtp.max_sdu
-		);
+	dprintk("parse_qos(): setting qos paramameters to tx=%d,%d rx=%d,%d\n",
+		qos.txtp.max_pcr, qos.txtp.max_sdu,
+		qos.rxtp.max_pcr, qos.rxtp.max_sdu);
 
 	atm_mpoa_add_qos(ipaddr, &qos);
 	return 1;
-- 
1.6.6.rc0.57.gad7a

