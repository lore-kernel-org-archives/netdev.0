From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 2/2]S2io: Fix to aggregate vlan tagged packets
Date: 19 Nov 2007 14:06:19 -0800
Message-ID: <1195509978.1995.46.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:50550 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbXKSUbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 15:31:09 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Fix to aggregate vlan packets. IP offset is incremented by 
  4 bytes if the packet contains vlan header.

Signed-off-by: Santoshkumar Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.8P1/drivers/net/s2io.c 2.0.26.8P2/drivers/net/s2io.c
--- 2.0.26.8P1/drivers/net/s2io.c	2007-11-15 18:15:00.000000000 -0800
+++ 2.0.26.8P2/drivers/net/s2io.c	2007-11-15 18:17:41.000000000 -0800
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.6"
+#define DRV_VERSION "2.0.26.8"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -2926,7 +2926,7 @@ static void rx_intr_handler(struct ring_
 			struct lro *lro = &nic->lro0_n[i];
 			if (lro->in_use) {
 				update_L3L4_header(nic, lro);
-				queue_rx_frame(lro->parent);
+				queue_rx_frame(lro->parent, lro->vlan_tag);
 				clear_lro_session(lro);
 			}
 		}
@@ -7163,7 +7163,8 @@ static int rx_osm_handler(struct ring_in
 					{
 						lro_append_pkt(sp, lro,
 							skb, tcp_len);
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						sp->mac_control.stats_info->
 						    sw_stat.flush_max_pkts++;
@@ -7174,7 +7175,8 @@ static int rx_osm_handler(struct ring_in
 							lro->frags_len;
 						sp->mac_control.stats_info->
 						     sw_stat.sending_both++;
-						queue_rx_frame(lro->parent);
+						queue_rx_frame(lro->parent,
+							lro->vlan_tag);
 						clear_lro_session(lro);
 						goto send_up;
 					case 0: /* sessions exceeded */
@@ -7204,27 +7206,8 @@ static int rx_osm_handler(struct ring_in
 		skb->ip_summed = CHECKSUM_NONE;
 	}
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
-	if (!sp->lro) {
-		skb->protocol = eth_type_trans(skb, dev);
-		if ((sp->vlan_strip_flag == S2IO_STRIP_VLAN_TAG) &&
-			RXD_GET_VLAN_TAG(rxdp->Control_2)) {
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
@@ -7855,7 +7838,8 @@ module_init(s2io_starter);
 module_exit(s2io_closer);
 
 static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
-		struct tcphdr **tcp, struct RxD_t *rxdp)
+		struct tcphdr **tcp, struct RxD_t *rxdp,
+		struct s2io_nic *sp)
 {
 	int ip_off;
 	u8 l2_type = (u8)((rxdp->Control_1 >> 37) & 0x7), ip_len;
@@ -7866,19 +7850,19 @@ static int check_L2_lro_capable(u8 *buff
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
+	if ((l2_type == 0) ||	 /* DIX type */
+		(l2_type == 4)) {	 /* DIX type with VLAN */
+		ip_off = HEADER_ETHERNET_II_802_3_SIZE;
+		/*
+		* If vlan stripping is disabled and the frame is VLAN tagged,
+		* shift the offset by the VLAN header size bytes.
+		*/
+		if ((sp->vlan_strip_flag == S2IO_DO_NOT_STRIP_VLAN_TAG) &&
+			(rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
+			ip_off += HEADER_VLAN_SIZE;
+	} else {
 		/* LLC, SNAP etc are considered non-mergeable */
-		default:
-			return -1;
+		return -1;
 	}
 
 	*ip = (struct iphdr *)((u8 *)buffer + ip_off);
@@ -7905,7 +7889,8 @@ static inline int get_l4_pyld_length(str
 }
 
 static void initiate_new_session(struct lro *lro, u8 *l2h,
-		     struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len)
+		struct iphdr *ip, struct tcphdr *tcp,
+		u32 tcp_pyld_len, u16 vlan_tag)
 {
 	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
 	lro->l2h = l2h;
@@ -7916,6 +7901,7 @@ static void initiate_new_session(struct 
 	lro->sg_num = 1;
 	lro->total_len = ntohs(ip->tot_len);
 	lro->frags_len = 0;
+	lro->vlan_tag = vlan_tag;
 	/*
 	 * check if we saw TCP timestamp. Other consistency checks have
 	 * already been done.
@@ -8047,15 +8033,17 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
 	struct iphdr *ip;
 	struct tcphdr *tcph;
 	int ret = 0, i;
+	u16 vlan_tag = 0;
 
 	if (!(ret = check_L2_lro_capable(buffer, &ip, (struct tcphdr **)tcp,
-					 rxdp))) {
+					 rxdp, sp))) {
 		DBG_PRINT(INFO_DBG,"IP Saddr: %x Daddr: %x\n",
 			  ip->saddr, ip->daddr);
 	} else {
 		return ret;
 	}
 
+	vlan_tag = RXD_GET_VLAN_TAG(rxdp->Control_2);
 	tcph = (struct tcphdr *)*tcp;
 	*tcp_len = get_l4_pyld_length(ip, tcph);
 	for (i=0; i<MAX_LRO_SESSIONS; i++) {
@@ -8115,7 +8103,8 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
 
 	switch (ret) {
 		case 3:
-			initiate_new_session(*lro, buffer, ip, tcph, *tcp_len);
+			initiate_new_session(*lro, buffer, ip, tcph,
+					*tcp_len, vlan_tag);
 			break;
 		case 2:
 			update_L3L4_header(sp, *lro);
@@ -8143,15 +8132,24 @@ static void clear_lro_session(struct lro
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
+	if (vlan_tag && (sp->vlan_strip_flag == S2IO_STRIP_VLAN_TAG)) {
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
diff -Nurp 2.0.26.8P1/drivers/net/s2io.h 2.0.26.8P2/drivers/net/s2io.h
--- 2.0.26.8P1/drivers/net/s2io.h	2007-11-15 18:15:00.000000000 -0800
+++ 2.0.26.8P2/drivers/net/s2io.h	2007-11-15 18:17:41.000000000 -0800
@@ -531,6 +531,7 @@ struct RxD_t {
 #define RXD_OWN_XENA            s2BIT(7)
 #define RXD_T_CODE              (s2BIT(12)|s2BIT(13)|s2BIT(14)|s2BIT(15))
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
+#define RXD_FRAME_VLAN_TAG      s2BIT(24)
 #define RXD_FRAME_PROTO_IPV4    s2BIT(27)
 #define RXD_FRAME_PROTO_IPV6    s2BIT(28)
 #define RXD_FRAME_IP_FRAG	s2BIT(29)
@@ -799,6 +800,7 @@ struct lro {
 	int		sg_num;
 	int		in_use;
 	__be16		window;
+	u16		vlan_tag;
 	u32		cur_tsval;
 	u32		cur_tsecr;
 	u8		saw_ts;
@@ -1075,7 +1077,7 @@ static int
 s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 		      struct RxD_t *rxdp, struct s2io_nic *sp);
 static void clear_lro_session(struct lro *lro);
-static void queue_rx_frame(struct sk_buff *skb);
+static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag);
 static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro);
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 			   struct sk_buff *skb, u32 tcp_len);



