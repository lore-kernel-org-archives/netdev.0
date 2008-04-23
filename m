From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 3/5]S2io: Enabling Multi ring support
Date: Wed, 23 Apr 2008 13:32:48 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804231331360.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39471 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961AbYDWRcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:32:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable multi ring support:
	- Seperate ring specific data
	- Initialize all configured rings with equal priority.
	- Updated boundary check for number of Rings.
	- Updated per ring statistics of rx_bytes and rx_packets.
	- Moved lro struct from struct s2io_nic to struct ring_info.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-21-2/drivers/net/s2io.c 2-0-26-21-3/drivers/net/s2io.c
--- 2-0-26-21-2/drivers/net/s2io.c	2008-04-09 21:08:07.000000000 +0530
+++ 2-0-26-21-3/drivers/net/s2io.c	2008-04-09 21:08:42.000000000 +0530
@@ -809,6 +809,7 @@ static int init_shared_mem(struct s2io_n
 		    config->rx_cfg[i].num_rxd - 1;
 		mac_control->rings[i].nic = nic;
 		mac_control->rings[i].ring_no = i;
+		mac_control->rings[i].lro = lro_enable;
 
 		blk_cnt = config->rx_cfg[i].num_rxd /
 				(rxd_count[nic->rxd_mode] + 1);
@@ -1560,113 +1561,112 @@ static int init_nic(struct s2io_nic *nic
 	writeq(val64, &bar0->tx_fifo_partition_0);
 
 	/* Filling the Rx round robin registers as per the
-	 * number of Rings and steering based on QoS.
-         */
+	 * number of Rings and steering based on QoS with
+	 * equal priority.
+	 */
 	switch (config->rx_ring_num) {
 	case 1:
+		val64 = 0x0;
+		writeq(val64, &bar0->rx_w_round_robin_0);
+		writeq(val64, &bar0->rx_w_round_robin_1);
+		writeq(val64, &bar0->rx_w_round_robin_2);
+		writeq(val64, &bar0->rx_w_round_robin_3);
+		writeq(val64, &bar0->rx_w_round_robin_4);
+
 		val64 = 0x8080808080808080ULL;
 		writeq(val64, &bar0->rts_qos_steering);
 		break;
 	case 2:
-		val64 = 0x0000010000010000ULL;
+		val64 = 0x0001000100010001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_0);
-		val64 = 0x0100000100000100ULL;
 		writeq(val64, &bar0->rx_w_round_robin_1);
-		val64 = 0x0001000001000001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_2);
-		val64 = 0x0000010000010000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_3);
-		val64 = 0x0100000000000000ULL;
+		val64 = 0x0001000100000000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_4);
 
 		val64 = 0x8080808040404040ULL;
 		writeq(val64, &bar0->rts_qos_steering);
 		break;
 	case 3:
-		val64 = 0x0001000102000001ULL;
+		val64 = 0x0001020001020001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_0);
-		val64 = 0x0001020000010001ULL;
+		val64 = 0x0200010200010200ULL;
 		writeq(val64, &bar0->rx_w_round_robin_1);
-		val64 = 0x0200000100010200ULL;
+		val64 = 0x0102000102000102ULL;
 		writeq(val64, &bar0->rx_w_round_robin_2);
-		val64 = 0x0001000102000001ULL;
+		val64 = 0x0001020001020001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_3);
-		val64 = 0x0001020000000000ULL;
+		val64 = 0x0200010200000000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_4);
 
 		val64 = 0x8080804040402020ULL;
 		writeq(val64, &bar0->rts_qos_steering);
 		break;
 	case 4:
-		val64 = 0x0001020300010200ULL;
+		val64 = 0x0001020300010203ULL;
 		writeq(val64, &bar0->rx_w_round_robin_0);
-		val64 = 0x0100000102030001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_1);
-		val64 = 0x0200010000010203ULL;
 		writeq(val64, &bar0->rx_w_round_robin_2);
-		val64 = 0x0001020001000001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_3);
-		val64 = 0x0203000100000000ULL;
+		val64 = 0x0001020300000000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_4);
 
 		val64 = 0x8080404020201010ULL;
 		writeq(val64, &bar0->rts_qos_steering);
 		break;
 	case 5:
-		val64 = 0x0001000203000102ULL;
+		val64 = 0x0001020304000102ULL;
 		writeq(val64, &bar0->rx_w_round_robin_0);
-		val64 = 0x0001020001030004ULL;
+		val64 = 0x0304000102030400ULL;
 		writeq(val64, &bar0->rx_w_round_robin_1);
-		val64 = 0x0001000203000102ULL;
+		val64 = 0x0102030400010203ULL;
 		writeq(val64, &bar0->rx_w_round_robin_2);
-		val64 = 0x0001020001030004ULL;
+		val64 = 0x0400010203040001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_3);
-		val64 = 0x0001000000000000ULL;
+		val64 = 0x0203040000000000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_4);
 
 		val64 = 0x8080404020201008ULL;
 		writeq(val64, &bar0->rts_qos_steering);
 		break;
 	case 6:
-		val64 = 0x0001020304000102ULL;
+		val64 = 0x0001020304050001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_0);
-		val64 = 0x0304050001020001ULL;
+		val64 = 0x0203040500010203ULL;
 		writeq(val64, &bar0->rx_w_round_robin_1);
-		val64 = 0x0203000100000102ULL;
+		val64 = 0x0405000102030405ULL;
 		writeq(val64, &bar0->rx_w_round_robin_2);
-		val64 = 0x0304000102030405ULL;
+		val64 = 0x0001020304050001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_3);
-		val64 = 0x0001000200000000ULL;
+		val64 = 0x0203040500000000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_4);
 
 		val64 = 0x8080404020100804ULL;
 		writeq(val64, &bar0->rts_qos_steering);
 		break;
 	case 7:
-		val64 = 0x0001020001020300ULL;
+		val64 = 0x0001020304050600ULL;
 		writeq(val64, &bar0->rx_w_round_robin_0);
-		val64 = 0x0102030400010203ULL;
+		val64 = 0x0102030405060001ULL;
 		writeq(val64, &bar0->rx_w_round_robin_1);
-		val64 = 0x0405060001020001ULL;
+		val64 = 0x0203040506000102ULL;
 		writeq(val64, &bar0->rx_w_round_robin_2);
-		val64 = 0x0304050000010200ULL;
+		val64 = 0x0304050600010203ULL;
 		writeq(val64, &bar0->rx_w_round_robin_3);
-		val64 = 0x0102030000000000ULL;
+		val64 = 0x0405060000000000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_4);
 
 		val64 = 0x8080402010080402ULL;
 		writeq(val64, &bar0->rts_qos_steering);
 		break;
 	case 8:
-		val64 = 0x0001020300040105ULL;
+		val64 = 0x0001020304050607ULL;
 		writeq(val64, &bar0->rx_w_round_robin_0);
-		val64 = 0x0200030106000204ULL;
 		writeq(val64, &bar0->rx_w_round_robin_1);
-		val64 = 0x0103000502010007ULL;
 		writeq(val64, &bar0->rx_w_round_robin_2);
-		val64 = 0x0304010002060500ULL;
 		writeq(val64, &bar0->rx_w_round_robin_3);
-		val64 = 0x0103020400000000ULL;
+		val64 = 0x0001020300000000ULL;
 		writeq(val64, &bar0->rx_w_round_robin_4);
 
 		val64 = 0x8040201008040201ULL;
@@ -3029,10 +3029,10 @@ static void rx_intr_handler(struct ring_
 		if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))
 			break;
 	}
-	if (nic->lro) {
+	if (ring_data->lro) {
 		/* Clear all LRO sessions before exiting */
 		for (i=0; i<MAX_LRO_SESSIONS; i++) {
-			struct lro *lro = &nic->lro0_n[i];
+			struct lro *lro = &ring_data->lro0_n[i];
 			if (lro->in_use) {
 				update_L3L4_header(nic, lro);
 				queue_rx_frame(lro->parent, lro->vlan_tag);
@@ -4866,6 +4866,7 @@ static struct net_device_stats *s2io_get
 	struct s2io_nic *sp = dev->priv;
 	struct mac_info *mac_control;
 	struct config_param *config;
+	int i;
 
 
 	mac_control = &sp->mac_control;
@@ -4885,6 +4886,13 @@ static struct net_device_stats *s2io_get
 	sp->stats.rx_length_errors =
 		le64_to_cpu(mac_control->stats_info->rmac_long_frms);
 
+	/* collect per-ring rx_packets and rx_bytes */
+	sp->stats.rx_packets = sp->stats.rx_bytes = 0;
+	for (i = 0; i < config->rx_ring_num; i++) {
+		sp->stats.rx_packets += mac_control->rings[i].rx_packets;
+		sp->stats.rx_bytes += mac_control->rings[i].rx_bytes;
+	}
+
 	return (&sp->stats);
 }
 
@@ -7384,12 +7392,12 @@ static int rx_osm_handler(struct ring_in
 	}
 
 	/* Updating statistics */
-	sp->stats.rx_packets++;
+	ring_data->rx_packets++;
 	rxdp->Host_Control = 0;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
 
-		sp->stats.rx_bytes += len;
+		ring_data->rx_bytes += len;
 		skb_put(skb, len);
 
 	} else if (sp->rxd_mode == RXD_MODE_3B) {
@@ -7400,13 +7408,13 @@ static int rx_osm_handler(struct ring_in
 		unsigned char *buff = skb_push(skb, buf0_len);
 
 		struct buffAdd *ba = &ring_data->ba[get_block][get_off];
-		sp->stats.rx_bytes += buf0_len + buf2_len;
+		ring_data->rx_bytes += buf0_len + buf2_len;
 		memcpy(buff, ba->ba_0, buf0_len);
 		skb_put(skb, buf2_len);
 	}
 
-	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && ((!sp->lro) ||
-	    (sp->lro && (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG)))) &&
+	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && ((!ring_data->lro) ||
+	    (ring_data->lro && (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG)))) &&
 	    (sp->rx_csum)) {
 		l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
 		l4_csum = RXD_GET_L4_CKSUM(rxdp->Control_1);
@@ -7417,14 +7425,14 @@ static int rx_osm_handler(struct ring_in
 			 * a flag in the RxD.
 			 */
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			if (sp->lro) {
+			if (ring_data->lro) {
 				u32 tcp_len;
 				u8 *tcp;
 				int ret = 0;
 
-				ret = s2io_club_tcp_session(skb->data, &tcp,
-							    &tcp_len, &lro,
-							    rxdp, sp);
+				ret = s2io_club_tcp_session(ring_data,
+					skb->data, &tcp, &tcp_len, &lro,
+					rxdp, sp);
 				switch (ret) {
 					case 3: /* Begin anew */
 						lro->parent = skb;
@@ -7603,12 +7611,14 @@ static int s2io_verify_parm(struct pci_d
 		tx_steering_type = NO_STEERING;
 	}
 
-	if ( rx_ring_num > 8) {
-		DBG_PRINT(ERR_DBG, "s2io: Requested number of Rx rings not "
+	if (rx_ring_num > MAX_RX_RINGS) {
+		DBG_PRINT(ERR_DBG, "s2io: Requested number of rx rings not "
 			 "supported\n");
-		DBG_PRINT(ERR_DBG, "s2io: Default to 8 Rx rings\n");
-		rx_ring_num = 8;
+		DBG_PRINT(ERR_DBG, "s2io: Default to %d rx rings\n",
+			MAX_RX_RINGS);
+		rx_ring_num = MAX_RX_RINGS;
 	}
+
 	if (*dev_intr_type != INTA)
 		napi = 0;
 
@@ -8077,6 +8087,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	DBG_PRINT(ERR_DBG, "%s: Using %d Tx fifo(s)\n", dev->name,
 		sp->config.tx_fifo_num);
 
+	DBG_PRINT(ERR_DBG, "%s: Using %d Rx ring(s)\n", dev->name,
+		  sp->config.rx_ring_num);
+
 	switch(sp->config.intr_type) {
 		case INTA:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
@@ -8391,8 +8404,9 @@ static int verify_l3_l4_lro_capable(stru
 }
 
 static int
-s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
-		      struct RxD_t *rxdp, struct s2io_nic *sp)
+s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer, u8 **tcp,
+	u32 *tcp_len, struct lro **lro, struct RxD_t *rxdp,
+	struct s2io_nic *sp)
 {
 	struct iphdr *ip;
 	struct tcphdr *tcph;
@@ -8410,7 +8424,7 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
 	tcph = (struct tcphdr *)*tcp;
 	*tcp_len = get_l4_pyld_length(ip, tcph);
 	for (i=0; i<MAX_LRO_SESSIONS; i++) {
-		struct lro *l_lro = &sp->lro0_n[i];
+		struct lro *l_lro = &ring_data->lro0_n[i];
 		if (l_lro->in_use) {
 			if (check_for_socket_match(l_lro, ip, tcph))
 				continue;
@@ -8448,7 +8462,7 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
 		}
 
 		for (i=0; i<MAX_LRO_SESSIONS; i++) {
-			struct lro *l_lro = &sp->lro0_n[i];
+			struct lro *l_lro = &ring_data->lro0_n[i];
 			if (!(l_lro->in_use)) {
 				*lro = l_lro;
 				ret = 3; /* Begin anew */
diff -Nurp 2-0-26-21-2/drivers/net/s2io.h 2-0-26-21-3/drivers/net/s2io.h
--- 2-0-26-21-2/drivers/net/s2io.h	2008-04-09 21:08:17.000000000 +0530
+++ 2-0-26-21-3/drivers/net/s2io.h	2008-04-09 21:08:49.000000000 +0530
@@ -678,11 +678,35 @@ struct rx_block_info {
 	struct rxd_info *rxds;
 };
 
+/* Data structure to represent a LRO session */
+struct lro {
+	struct sk_buff	*parent;
+	struct sk_buff  *last_frag;
+	u8		*l2h;
+	struct iphdr	*iph;
+	struct tcphdr	*tcph;
+	u32		tcp_next_seq;
+	__be32		tcp_ack;
+	int		total_len;
+	int		frags_len;
+	int		sg_num;
+	int		in_use;
+	__be16		window;
+	u16             vlan_tag;
+	u32		cur_tsval;
+	__be32		cur_tsecr;
+	u8		saw_ts;
+} ____cacheline_aligned;
+
 /* Ring specific structure */
 struct ring_info {
 	/* The ring number */
 	int ring_no;
 
+#define MAX_LRO_SESSIONS	32
+	struct lro lro0_n[MAX_LRO_SESSIONS];
+	u8		lro;
+
 	/*
 	 *  Place holders for the virtual and physical addresses of
 	 *  all the Rx Blocks
@@ -706,7 +730,11 @@ struct ring_info {
 	/* Buffer Address store. */
 	struct buffAdd **ba;
 	struct s2io_nic *nic;
-};
+
+	/* per-Ring statistics */
+	unsigned long rx_packets;
+	unsigned long rx_bytes;
+} ____cacheline_aligned;
 
 /* Fifo specific structure */
 struct fifo_info {
@@ -813,26 +841,6 @@ struct msix_info_st {
 	u64 data;
 };
 
-/* Data structure to represent a LRO session */
-struct lro {
-	struct sk_buff	*parent;
-	struct sk_buff  *last_frag;
-	u8		*l2h;
-	struct iphdr	*iph;
-	struct tcphdr	*tcph;
-	u32		tcp_next_seq;
-	__be32		tcp_ack;
-	int		total_len;
-	int		frags_len;
-	int		sg_num;
-	int		in_use;
-	__be16		window;
-	u16             vlan_tag;
-	u32		cur_tsval;
-	__be32		cur_tsecr;
-	u8		saw_ts;
-} ____cacheline_aligned;
-
 /* These flags represent the devices temporary state */
 enum s2io_device_state_t
 {
@@ -950,8 +958,6 @@ struct s2io_nic {
 #define XFRAME_II_DEVICE	2
 	u8 device_type;
 
-#define MAX_LRO_SESSIONS	32
-	struct lro lro0_n[MAX_LRO_SESSIONS];
 	unsigned long	clubbed_frms_cnt;
 	unsigned long	sending_both;
 	u8		lro;
@@ -1118,9 +1124,9 @@ static int do_s2io_add_mc(struct s2io_ni
 static int do_s2io_add_mac(struct s2io_nic *sp, u64 addr, int offset);
 static int do_s2io_delete_unicast_mc(struct s2io_nic *sp, u64 addr);
 
-static int
-s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
-		      struct RxD_t *rxdp, struct s2io_nic *sp);
+static int s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer,
+	u8 **tcp, u32 *tcp_len, struct lro **lro, struct RxD_t *rxdp,
+	struct s2io_nic *sp);
 static void clear_lro_session(struct lro *lro);
 static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag);
 static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro);

