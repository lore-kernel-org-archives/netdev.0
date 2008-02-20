From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [Patch 2.6.25 3/4]S2io: Support for vlan_rx_kill_vid entry point
Date: Wed, 20 Feb 2008 17:09:15 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10802201707530.11320-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55723 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbYBTWJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 17:09:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Resubmit #3
- Added s2io_vlan_rx_kill_vid entry point function for unregistering vlan.
- Fix to aggregate vlan packets. IP offset is incremented by
  4 bytes if the packet contains vlan header.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-18-3/drivers/net/s2io.c 2-0-26-19-1/drivers/net/s2io.c
--- 2-0-26-18-3/drivers/net/s2io.c	2008-02-15 05:18:38.000000000 +0530
+++ 2-0-26-19-1/drivers/net/s2io.c	2008-02-15 07:03:10.000000000 +0530
@@ -388,6 +388,26 @@ static void s2io_vlan_rx_register(struct
 /* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
 static int vlan_strip_flag;
 
+/* Unregister the vlan */
+static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
+{
+	int i;
+	struct s2io_nic *nic = dev->priv;
+	unsigned long flags[MAX_TX_FIFOS];
+	struct mac_info *mac_control = &nic->mac_control;
+	struct config_param *config = &nic->config;
+
+	for (i = 0; i < config->tx_fifo_num; i++)
+		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags[i]);
+
+	if (nic->vlgrp)
+		vlan_group_set_device(nic->vlgrp, vid, NULL);
+
+	for (i = config->tx_fifo_num - 1; i >= 0; i--)
+		spin_unlock_irqrestore(&mac_control->fifos[i].tx_lock,
+			flags[i]);
+}
+
 /*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
@@ -3047,7 +3067,7 @@ static void rx_intr_handler(struct ring_
 			struct lro *lro = &nic->lro0_n[i];
 			if (lro->in_use) {
 				update_L3L4_header(nic, lro);
-				queue_rx_frame(lro->parent);
+				queue_rx_frame(lro->parent, lro->vlan_tag);
 				clear_lro_session(lro);
 			}
 		}
@@ -7522,7 +7542,8 @@ static int rx_osm_handler(struct ring_in
 					{
 						lro_append_pkt(sp, lro,
 							skb, tcp_len);
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						sp->mac_control.stats_info->
 						    sw_stat.flush_max_pkts++;
@@ -7533,7 +7554,8 @@ static int rx_osm_handler(struct ring_in
 							lro->frags_len;
 						sp->mac_control.stats_info->
 						     sw_stat.sending_both++;
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						goto send_up;
 					case 0: /* sessions exceeded */
@@ -7559,31 +7581,12 @@ static int rx_osm_handler(struct ring_in
 			 */
 			skb->ip_summed = CHECKSUM_NONE;
 		}
-	} else {
+	} else
 		skb->ip_summed = CHECKSUM_NONE;
-	}
+
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
-	if (!sp->lro) {
-		skb->protocol = eth_type_trans(skb, dev);
-		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
-			vlan_strip_flag)) {
-			/* Queueing the vlan frame to the upper layer */
-			if (napi)
-				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
-					RXD_GET_VLAN_TAG(rxdp->Control_2));
-			else
-				vlan_hwaccel_rx(skb, sp->vlgrp,
-					RXD_GET_VLAN_TAG(rxdp->Control_2));
-		} else {
-			if (napi)
-				netif_receive_skb(skb);
-			else
-				netif_rx(skb);
-		}
-	} else {
 send_up:
-		queue_rx_frame(skb);
-	}
+	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
 	dev->last_rx = jiffies;
 aggregate:
 	atomic_dec(&sp->rx_bufs_left[ring_no]);
@@ -8005,6 +8008,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = s2io_vlan_rx_register;
+	dev->vlan_rx_kill_vid = (void *)s2io_vlan_rx_kill_vid;
 
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
@@ -8306,7 +8310,8 @@ module_init(s2io_starter);
 module_exit(s2io_closer);
 
 static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
-		struct tcphdr **tcp, struct RxD_t *rxdp)
+		struct tcphdr **tcp, struct RxD_t *rxdp,
+		struct s2io_nic *sp)
 {
 	int ip_off;
 	u8 l2_type = (u8)((rxdp->Control_1 >> 37) & 0x7), ip_len;
@@ -8317,19 +8322,20 @@ static int check_L2_lro_capable(u8 *buff
 		return -1;
 	}
 
-	/* TODO:
-	 * By default the VLAN field in the MAC is stripped by the card, if this
-	 * feature is turned off in rx_pa_cfg register, then the ip_off field
-	 * has to be shifted by a further 2 bytes
-	 */
-	switch (l2_type) {
-		case 0: /* DIX type */
-		case 4: /* DIX type with VLAN */
-			ip_off = HEADER_ETHERNET_II_802_3_SIZE;
-			break;
+	/* Checking for DIX type or DIX type with VLAN */
+	if ((l2_type == 0)
+		|| (l2_type == 4)) {
+		ip_off = HEADER_ETHERNET_II_802_3_SIZE;
+		/*
+		 * If vlan stripping is disabled and the frame is VLAN tagged,
+		 * shift the offset by the VLAN header size bytes.
+		 */
+		if ((!vlan_strip_flag) &&
+			(rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
+			ip_off += HEADER_VLAN_SIZE;
+	} else {
 		/* LLC, SNAP etc are considered non-mergeable */
-		default:
-			return -1;
+		return -1;
 	}
 
 	*ip = (struct iphdr *)((u8 *)buffer + ip_off);
@@ -8356,7 +8362,7 @@ static inline int get_l4_pyld_length(str
 }
 
 static void initiate_new_session(struct lro *lro, u8 *l2h,
-		     struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len)
+	struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len, u16 vlan_tag)
 {
 	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
 	lro->l2h = l2h;
@@ -8367,6 +8373,7 @@ static void initiate_new_session(struct 
 	lro->sg_num = 1;
 	lro->total_len = ntohs(ip->tot_len);
 	lro->frags_len = 0;
+	lro->vlan_tag = vlan_tag;
 	/*
 	 * check if we saw TCP timestamp. Other consistency checks have
 	 * already been done.
@@ -8498,15 +8505,16 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
 	struct iphdr *ip;
 	struct tcphdr *tcph;
 	int ret = 0, i;
+	u16 vlan_tag = 0;
 
 	if (!(ret = check_L2_lro_capable(buffer, &ip, (struct tcphdr **)tcp,
-					 rxdp))) {
+					 rxdp, sp))) {
 		DBG_PRINT(INFO_DBG,"IP Saddr: %x Daddr: %x\n",
 			  ip->saddr, ip->daddr);
-	} else {
+	} else
 		return ret;
-	}
 
+	vlan_tag = RXD_GET_VLAN_TAG(rxdp->Control_2);
 	tcph = (struct tcphdr *)*tcp;
 	*tcp_len = get_l4_pyld_length(ip, tcph);
 	for (i=0; i<MAX_LRO_SESSIONS; i++) {
@@ -8566,7 +8574,8 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
 
 	switch (ret) {
 		case 3:
-			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len);
+			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len,
+								vlan_tag);
 			break;
 		case 2:
 			update_L3L4_header(sp, *lro);
@@ -8594,15 +8603,25 @@ static void clear_lro_session(struct lro
 	memset(lro, 0, lro_struct_size);
 }
 
-static void queue_rx_frame(struct sk_buff *skb)
+static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 {
 	struct net_device *dev = skb->dev;
+	struct s2io_nic *sp = dev->priv;
 
 	skb->protocol = eth_type_trans(skb, dev);
-	if (napi)
-		netif_receive_skb(skb);
-	else
-		netif_rx(skb);
+	if (sp->vlgrp && vlan_tag
+		&& (vlan_strip_flag)) {
+		/* Queueing the vlan frame to the upper layer */
+		if (sp->config.napi)
+			vlan_hwaccel_receive_skb(skb, sp->vlgrp, vlan_tag);
+		else
+			vlan_hwaccel_rx(skb, sp->vlgrp, vlan_tag);
+	} else {
+		if (sp->config.napi)
+			netif_receive_skb(skb);
+		else
+			netif_rx(skb);
+	}
 }
 
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
diff -Nurp 2-0-26-18-3/drivers/net/s2io.h 2-0-26-19-1/drivers/net/s2io.h
--- 2-0-26-18-3/drivers/net/s2io.h	2008-02-15 05:18:47.000000000 +0530
+++ 2-0-26-19-1/drivers/net/s2io.h	2008-02-15 07:03:16.000000000 +0530
@@ -546,6 +546,7 @@ struct RxD_t {
 #define RXD_OWN_XENA            s2BIT(7)
 #define RXD_T_CODE              (s2BIT(12)|s2BIT(13)|s2BIT(14)|s2BIT(15))
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
+#define RXD_FRAME_VLAN_TAG      s2BIT(24)
 #define RXD_FRAME_PROTO_IPV4    s2BIT(27)
 #define RXD_FRAME_PROTO_IPV6    s2BIT(28)
 #define RXD_FRAME_IP_FRAG	s2BIT(29)
@@ -829,10 +830,11 @@ struct lro {
 	int		sg_num;
 	int		in_use;
 	__be16		window;
+	u16             vlan_tag;
 	u32		cur_tsval;
 	__be32		cur_tsecr;
 	u8		saw_ts;
-};
+} ____cacheline_aligned;
 
 /* These flags represent the devices temporary state */
 enum s2io_device_state_t
@@ -1129,7 +1131,7 @@ static int
 s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 		      struct RxD_t *rxdp, struct s2io_nic *sp);
 static void clear_lro_session(struct lro *lro);
-static void queue_rx_frame(struct sk_buff *skb);
+static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag);
 static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro);
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 			   struct sk_buff *skb, u32 tcp_len);

