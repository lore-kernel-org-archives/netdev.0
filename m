From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-18
Date: Tue, 26 Aug 2008 22:19:30 +0800
Message-ID: <48B410F2.7000005@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55955 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757243AbYHZOV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:56 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index a86c022..b3cd541 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -167,7 +167,7 @@ static void znet_tx_timeout (struct net_device *dev);
 /* Request needed resources */
 static int znet_request_resources (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 
 	if (request_irq (dev->irq, &znet_interrupt, 0, "ZNet", dev))
@@ -201,7 +201,7 @@ static int znet_request_resources (struct net_device *dev)
 
 static void znet_release_resources (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 
 	release_region (znet->sia_base, znet->sia_size);
@@ -216,7 +216,7 @@ static void znet_release_resources (struct net_device *dev)
 /* Keep the magical SIA stuff in a single function... */
 static void znet_transceiver_power (struct net_device *dev, int on)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned char v;
 
 	/* Turn on/off the 82501 SIA, using zenith-specific magic. */
@@ -235,7 +235,7 @@ static void znet_transceiver_power (struct net_device *dev, int on)
    Also used from hardware_init. */
 static void znet_set_multicast_list (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	struct i82593_conf_block *cfblk = &znet->i593_init;
 
@@ -387,7 +387,7 @@ static int __init znet_probe (void)
 	if (!dev)
 		return -ENOMEM;
 
-	znet = dev->priv;
+	znet = netdev_priv(dev);
 
 	netinfo = (struct netidblk *)p;
 	dev->base_addr = netinfo->iobase1;
@@ -531,7 +531,7 @@ static void znet_tx_timeout (struct net_device *dev)
 static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 	short length = skb->len;
 
@@ -601,7 +601,7 @@ static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 static irqreturn_t znet_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	int ioaddr;
 	int boguscnt = 20;
 	int handled = 0;
@@ -679,7 +679,7 @@ static irqreturn_t znet_interrupt(int irq, void *dev_id)
 
 static void znet_rx(struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = 1;
 	short next_frame_end_offset = 0; 		/* Offset of next frame start. */
@@ -829,7 +829,7 @@ static void show_dma(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
 	unsigned char stat = inb (ioaddr);
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 	short dma_port = ((znet->tx_dma&3)<<2) + IO_DMA2_BASE;
 	unsigned addr = inb(dma_port);
@@ -852,7 +852,7 @@ static void hardware_init(struct net_device *dev)
 {
 	unsigned long flags;
 	short ioaddr = dev->base_addr;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 
 	znet->rx_cur = znet->rx_start;
 	znet->tx_cur = znet->tx_start;
@@ -914,7 +914,7 @@ static void update_stop_hit(short ioaddr, unsigned short rx_stop_offset)
 static __exit void znet_cleanup (void)
 {
 	if (znet_dev) {
-		struct znet_private *znet = znet_dev->priv;
+		struct znet_private *znet = netdev_priv(znet_dev);
 
 		unregister_netdev (znet_dev);
 		kfree (znet->rx_start);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 0c85042..287a3df 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1284,7 +1284,7 @@ static int handle_ip_over_ddp(struct sk_buff *skb)
 	skb->dev   = dev;
 	skb_reset_transport_header(skb);
 
-	stats = dev->priv;
+	stats = netdev_priv(dev);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len + 13;
 	netif_rx(skb);  /* Send the SKB up to a higher place. */
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 8d9a6f1..bdb1013 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -101,7 +101,7 @@ static LIST_HEAD(br2684_devs);
 
 static inline struct br2684_dev *BRPRIV(const struct net_device *net_dev)
 {
-	return (struct br2684_dev *)net_dev->priv;
+	return (struct br2684_dev *)netdev_priv(net_dev);
 }
 
 static inline struct net_device *list_entry_brdev(const struct list_head *le)
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 5799fb5..1053471 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -152,7 +152,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		buff += 4;
 		mesg->content.normal.flag = *buff & 0x01;	/* 0x01 is topology change */
 
-		priv = (struct lec_priv *)dev->priv;
+		priv = netdev_priv(dev);
 		atm_force_charge(priv->lecd, skb2->truesize);
 		sk = sk_atm(priv->lecd);
 		skb_queue_tail(&sk->sk_receive_queue, skb2);
@@ -218,7 +218,7 @@ static unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
 
 static int lec_open(struct net_device *dev)
 {
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 	netif_start_queue(dev);
 	memset(&priv->stats, 0, sizeof(struct net_device_stats));
@@ -252,7 +252,7 @@ static void lec_tx_timeout(struct net_device *dev)
 static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *skb2;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 	struct lecdatahdr_8023 *lec_h;
 	struct atm_vcc *vcc;
 	struct lec_arp_table *entry;
@@ -442,14 +442,14 @@ static int lec_close(struct net_device *dev)
  */
 static struct net_device_stats *lec_get_stats(struct net_device *dev)
 {
-	return &((struct lec_priv *)dev->priv)->stats;
+	return &((struct lec_priv *)netdev_priv(dev))->stats;
 }
 
 static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 	struct atmlec_msg *mesg;
 	struct lec_arp_table *entry;
 	int i;
@@ -596,7 +596,7 @@ static void lec_atm_close(struct atm_vcc *vcc)
 {
 	struct sk_buff *skb;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 	priv->lecd = NULL;
 	/* Do something needful? */
@@ -727,7 +727,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 #if DUMP_PACKETS >0
 	int i = 0;
@@ -874,7 +874,7 @@ static int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 	vpriv->old_pop = vcc->pop;
 	vcc->user_back = vpriv;
 	vcc->pop = lec_pop;
-	lec_vcc_added(dev_lec[ioc_data.dev_num]->priv,
+	lec_vcc_added(netdev_priv(dev_lec[ioc_data.dev_num]),
 		      &ioc_data, vcc, vcc->push);
 	vcc->proto_data = dev_lec[ioc_data.dev_num];
 	vcc->push = lec_push;
@@ -886,7 +886,8 @@ static int lec_mcast_attach(struct atm_vcc *vcc, int arg)
 	if (arg < 0 || arg >= MAX_LEC_ITF || !dev_lec[arg])
 		return -EINVAL;
 	vcc->proto_data = dev_lec[arg];
-	return (lec_mcast_make((struct lec_priv *)dev_lec[arg]->priv, vcc));
+	return lec_mcast_make((struct lec_priv *)netdev_priv(dev_lec[arg]),
+				vcc);
 }
 
 /* Initialize device. */
@@ -928,11 +929,11 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 			return -EINVAL;
 		}
 
-		priv = dev_lec[i]->priv;
+		priv = netdev_priv(dev_lec[i]);
 		priv->is_trdev = is_trdev;
 		lec_init(dev_lec[i]);
 	} else {
-		priv = dev_lec[i]->priv;
+		priv = netdev_priv(dev_lec[i]);
 		if (priv->lecd)
 			return -EADDRINUSE;
 	}
@@ -1093,7 +1094,8 @@ static void *lec_itf_walk(struct lec_state *state, loff_t *l)
 	void *v;
 
 	dev = state->dev ? state->dev : dev_lec[state->itf];
-	v = (dev && dev->priv) ? lec_priv_walk(state, l, dev->priv) : NULL;
+	v = (dev && netdev_priv(dev)) ?
+		lec_priv_walk(state, l, netdev_priv(dev)) : NULL;
 	if (!v && dev) {
 		dev_put(dev);
 		/* Partial state reset for the next time we get called */
@@ -1255,7 +1257,7 @@ static void __exit lane_module_cleanup(void)
 
 	for (i = 0; i < MAX_LEC_ITF; i++) {
 		if (dev_lec[i] != NULL) {
-			priv = (struct lec_priv *)dev_lec[i]->priv;
+			priv = netdev_priv(dev_lec[i]);
 			unregister_netdev(dev_lec[i]);
 			free_netdev(dev_lec[i]);
 			dev_lec[i] = NULL;
@@ -1279,7 +1281,7 @@ static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 			 u8 **tlvs, u32 *sizeoftlvs)
 {
 	unsigned long flags;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 	struct lec_arp_table *table;
 	struct sk_buff *skb;
 	int retval;
@@ -1326,7 +1328,7 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 {
 	int retval;
 	struct sk_buff *skb;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 
 	if (compare_ether_addr(lan_dst, dev->dev_addr))
 		return (0);	/* not our mac address */
@@ -1363,7 +1365,7 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 #if 0
 	int i = 0;
 #endif
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = netdev_priv(dev);
 #if 0				/*
 				 * Why have the TLVs in LE_ARP entries
 				 * since we do not use them? When you
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 11b16d1..236f416 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -785,7 +785,7 @@ static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 	}
 
 	if (mpc->dev) { /* check if the lec is LANE2 capable */
-		priv = (struct lec_priv *)mpc->dev->priv;
+		priv = netdev_priv(mpc->dev);
 		if (priv->lane_version < 2) {
 			dev_put(mpc->dev);
 			mpc->dev = NULL;
@@ -845,7 +845,7 @@ static void mpoad_close(struct atm_vcc *vcc)
 
 	mpc->mpoad_vcc = NULL;
 	if (mpc->dev) {
-		struct lec_priv *priv = (struct lec_priv *)mpc->dev->priv;
+		struct lec_priv *priv = netdev_priv(mpc->dev);
 		priv->lane2_ops->associate_indicator = NULL;
 		stop_mpc(mpc);
 		dev_put(mpc->dev);
@@ -976,7 +976,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 
 	switch (event) {
 	case NETDEV_REGISTER:       /* a new lec device was allocated */
-		priv = (struct lec_priv *)dev->priv;
+		priv = netdev_priv(dev);
 		if (priv->lane_version < 2)
 			break;
 		priv->lane2_ops->associate_indicator = lane2_assoc_ind;
@@ -1322,7 +1322,7 @@ static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg, struct mpoa_client *m
 	dprintk("\n");
 
 	if (mpc->dev) {
-		priv = (struct lec_priv *)mpc->dev->priv;
+		priv = netdev_priv(mpc->dev);
 		retval = priv->lane2_ops->associate_req(mpc->dev, mpc->dev->dev_addr, tlv, sizeof(tlv));
 		if (retval == 0)
 			printk("mpoa: (%s) MPOA device type TLV association failed\n", mpc->dev->name);
@@ -1472,7 +1472,7 @@ static void __exit atm_mpoa_cleanup(void)
 		tmp = mpc->next;
 		if (mpc->dev != NULL) {
 			stop_mpc(mpc);
-			priv = (struct lec_priv *)mpc->dev->priv;
+			priv = netdev_priv(mpc->dev);
 			if (priv->lane2_ops != NULL)
 				priv->lane2_ops->associate_indicator = NULL;
 		}
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 80ba30c..9c617f3 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -566,7 +566,7 @@ int bnep_add_connection(struct bnep_connadd_req *req, struct socket *sock)
 		goto failed;
 	}
 
-	s = dev->priv;
+	s = netdev_priv(dev);
 
 	/* This is rx header therefore addresses are swapped.
 	 * ie eh.h_dest is our local address. */
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index d9fa0ab..47e179f 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -62,14 +62,14 @@ static int bnep_net_close(struct net_device *dev)
 
 static struct net_device_stats *bnep_net_get_stats(struct net_device *dev)
 {
-	struct bnep_session *s = dev->priv;
+	struct bnep_session *s = netdev_priv(dev);
 	return &s->stats;
 }
 
 static void bnep_net_set_mc_list(struct net_device *dev)
 {
 #ifdef CONFIG_BT_BNEP_MC_FILTER
-	struct bnep_session *s = dev->priv;
+	struct bnep_session *s = netdev_priv(dev);
 	struct sock *sk = s->sock->sk;
 	struct bnep_set_filter_req *r;
 	struct sk_buff *skb;
@@ -183,7 +183,7 @@ static inline int bnep_net_proto_filter(struct sk_buff *skb, struct bnep_session
 
 static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct bnep_session *s = dev->priv;
+	struct bnep_session *s = netdev_priv(dev);
 	struct sock *sk = s->sock->sk;
 
 	BT_DBG("skb %p, dev %p", skb, dev);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 63c18aa..bd1bc78 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -453,7 +453,7 @@ void __exit br_cleanup_bridges(void)
 restart:
 	for_each_netdev(&init_net, dev) {
 		if (dev->priv_flags & IFF_EBRIDGE) {
-			del_br(dev->priv);
+			del_br(netdev_priv(dev));
 			goto restart;
 		}
 	}
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 27d6a51..3d6d0d4 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -22,7 +22,7 @@
 #include "br_private.h"
 
 #define to_dev(obj)	container_of(obj, struct device, kobj)
-#define to_bridge(cd)	((struct net_bridge *)(to_net_dev(cd)->priv))
+#define to_bridge(cd)	((struct net_bridge *)netdev_priv(to_net_dev(cd)))
 
 /*
  * Common code for storing bridge parameters.
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 9a1cd87..774d73a 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -207,7 +207,7 @@ static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
 	if (!dev)
 		return NULL;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->dev = dev;
 
 	/*
-- 


