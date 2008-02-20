From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support - FIFO
 selection based on L4 ports
Date: Wed, 20 Feb 2008 17:07:51 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10802201644130.11320-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55695 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbYBTWH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 17:07:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Resubmit #2
- Transmit fifo selection based on TCP/UDP ports.
- Added tx_steering_type loadable parameter for transmit fifo selection.
  0x0 NO_STEERING: Default FIFO is selected.
  0x1 TX_PRIORITY_STEERING: FIFO is selected based on skb->priority.
  0x2 TX_DEFAULT_STEERING: FIFO is selected based on L4 Ports.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-18-1/drivers/net/s2io.c 2-0-26-18-2/drivers/net/s2io.c
--- 2-0-26-18-1/drivers/net/s2io.c	2008-02-15 05:15:41.000000000 +0530
+++ 2-0-26-18-2/drivers/net/s2io.c	2008-02-15 05:16:36.000000000 +0530
@@ -458,7 +458,7 @@ MODULE_VERSION(DRV_VERSION);
 
 
 /* Module Loadable parameters. */
-S2IO_PARM_INT(tx_fifo_num, 1);
+S2IO_PARM_INT(tx_fifo_num, FIFO_DEFAULT_NUM);
 S2IO_PARM_INT(rx_ring_num, 1);
 S2IO_PARM_INT(multiq, 0);
 S2IO_PARM_INT(rx_ring_mode, 1);
@@ -470,6 +470,8 @@ S2IO_PARM_INT(shared_splits, 0);
 S2IO_PARM_INT(tmac_util_period, 5);
 S2IO_PARM_INT(rmac_util_period, 5);
 S2IO_PARM_INT(l3l4hdr_size, 128);
+/* 0 is no steering, 1 is Priority steering, 2 is Default steering */
+S2IO_PARM_INT(tx_steering_type, TX_DEFAULT_STEERING);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
@@ -4114,7 +4116,9 @@ static int s2io_xmit(struct sk_buff *skb
 	struct fifo_info *fifo = NULL;
 	struct mac_info *mac_control;
 	struct config_param *config;
+	int do_spin_lock = 1;
 	int offload_type;
+	int enable_per_list_interrupt = 0;
 	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
 	mac_control = &sp->mac_control;
@@ -4136,15 +4140,52 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 
 	queue = 0;
-	/* Get Fifo number to Transmit based on vlan priority */
 	if (sp->vlgrp && vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
+	if (sp->config.tx_steering_type == TX_DEFAULT_STEERING) {
+		if (skb->protocol == htons(ETH_P_IP)) {
+			struct iphdr *ip;
+			struct tcphdr *th;
+			ip = ip_hdr(skb);
+
+			if ((ip->frag_off & htons(IP_OFFSET|IP_MF)) == 0) {
+				th = (struct tcphdr *)(((unsigned char *)ip) +
+						ip->ihl*4);
+
+				if (ip->protocol == IPPROTO_TCP) {
+					queue_len = sp->total_tcp_fifos;
+					queue = (ntohs(th->source) +
+							ntohs(th->dest)) &
+					    sp->fifo_selector[queue_len - 1];
+					if (queue >= queue_len)
+						queue = queue_len - 1;
+				} else if (ip->protocol == IPPROTO_UDP) {
+					queue_len = sp->total_udp_fifos;
+					queue = (ntohs(th->source) +
+							ntohs(th->dest)) &
+					    sp->fifo_selector[queue_len - 1];
+					if (queue >= queue_len)
+						queue = queue_len - 1;
+					queue += sp->udp_fifo_idx;
+					if (skb->len > 1024)
+						enable_per_list_interrupt = 1;
+					do_spin_lock = 0;
+				}
+			}
+		}
+	} else if (sp->config.tx_steering_type == TX_PRIORITY_STEERING)
+		/* get fifo number based on skb->priority value */
+		queue = config->fifo_mapping
+					[skb->priority & (MAX_TX_FIFOS - 1)];
+	fifo = &mac_control->fifos[queue];
 
-	/* get fifo number based on skb->priority value */
-	queue = config->fifo_mapping[skb->priority & (MAX_TX_FIFOS - 1)];
+	if (do_spin_lock)
+		spin_lock_irqsave(&fifo->tx_lock, flags);
+	else {
+		if (unlikely(!spin_trylock_irqsave(&fifo->tx_lock, flags)))
+			return NETDEV_TX_LOCKED;
+	}
 
-	fifo = &mac_control->fifos[queue];
-	spin_lock_irqsave(&fifo->tx_lock, flags);
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (sp->config.multiq) {
 		if (__netif_subqueue_stopped(dev, fifo->fifo_no)) {
@@ -4188,7 +4229,9 @@ static int s2io_xmit(struct sk_buff *skb
 	txdp->Control_1 |= TXD_GATHER_CODE_FIRST;
 	txdp->Control_1 |= TXD_LIST_OWN_XENA;
 	txdp->Control_2 |= TXD_INT_NUMBER(fifo->fifo_no);
-
+	if (enable_per_list_interrupt)
+		if (put_off & (queue_len >> 5))
+			txdp->Control_2 |= TXD_INT_TYPE_PER_LIST;
 	if (vlan_tag) {
 		txdp->Control_2 |= TXD_VLAN_ENABLE;
 		txdp->Control_2 |= TXD_VLAN_TAG(vlan_tag);
@@ -7622,13 +7665,15 @@ static int s2io_verify_parm(struct pci_d
 	u8 *dev_multiq)
 {
 	if ((tx_fifo_num > MAX_TX_FIFOS) ||
-		(tx_fifo_num < FIFO_DEFAULT_NUM)) {
+		(tx_fifo_num < 1)) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested number of tx fifos "
 			"(%d) not supported\n", tx_fifo_num);
-		tx_fifo_num =
-			((tx_fifo_num > MAX_TX_FIFOS)? MAX_TX_FIFOS :
-			((tx_fifo_num < FIFO_DEFAULT_NUM) ? FIFO_DEFAULT_NUM :
-			tx_fifo_num));
+
+		if (tx_fifo_num < 1)
+			tx_fifo_num = 1;
+		else
+			tx_fifo_num = MAX_TX_FIFOS;
+
 		DBG_PRINT(ERR_DBG, "s2io: Default to %d ", tx_fifo_num);
 		DBG_PRINT(ERR_DBG, "tx fifos\n");
 	}
@@ -7639,10 +7684,23 @@ static int s2io_verify_parm(struct pci_d
 		multiq = 0;
 	}
 #endif
-	/* if multiqueue is enabled configure all fifos */
-	if (multiq) {
-		tx_fifo_num = MAX_TX_FIFOS;
+	if (multiq)
 		*dev_multiq = multiq;
+
+	if (tx_steering_type && (1 == tx_fifo_num)) {
+		if (tx_steering_type != TX_DEFAULT_STEERING)
+			DBG_PRINT(ERR_DBG,
+				"s2io: Tx steering is not supported with "
+				"one fifo. Disabling Tx steering.\n");
+		tx_steering_type = NO_STEERING;
+	}
+
+	if ((tx_steering_type < NO_STEERING) ||
+		(tx_steering_type > TX_DEFAULT_STEERING)) {
+		DBG_PRINT(ERR_DBG, "s2io: Requested transmit steering not "
+			 "supported\n");
+		DBG_PRINT(ERR_DBG, "s2io: Disabling transmit steering\n");
+		tx_steering_type = NO_STEERING;
 	}
 
 	if ( rx_ring_num > 8) {
@@ -7773,7 +7831,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	}
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	if (dev_multiq)
-		dev = alloc_etherdev_mq(sizeof(struct s2io_nic), MAX_TX_FIFOS);
+		dev = alloc_etherdev_mq(sizeof(struct s2io_nic), tx_fifo_num);
 	else
 #endif
 	dev = alloc_etherdev(sizeof(struct s2io_nic));
@@ -7824,11 +7882,33 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	config = &sp->config;
 
 	config->napi = napi;
+	config->tx_steering_type = tx_steering_type;
 
 	/* Tx side parameters. */
-	config->tx_fifo_num = tx_fifo_num;
+	if (config->tx_steering_type == TX_PRIORITY_STEERING)
+		config->tx_fifo_num = MAX_TX_FIFOS;
+	else
+		config->tx_fifo_num = tx_fifo_num;
+
+	/* Initialize the fifos used for tx steering */
+	if (config->tx_fifo_num < 5) {
+			if (config->tx_fifo_num  == 1)
+				sp->total_tcp_fifos = 1;
+			else
+				sp->total_tcp_fifos = config->tx_fifo_num - 1;
+			sp->udp_fifo_idx = config->tx_fifo_num - 1;
+			sp->total_udp_fifos = 1;
+			sp->other_fifo_idx = sp->total_tcp_fifos - 1;
+	} else {
+		sp->total_tcp_fifos = (tx_fifo_num - FIFO_UDP_MAX_NUM -
+						FIFO_OTHER_MAX_NUM);
+		sp->udp_fifo_idx = sp->total_tcp_fifos;
+		sp->total_udp_fifos = FIFO_UDP_MAX_NUM;
+		sp->other_fifo_idx = sp->udp_fifo_idx + FIFO_UDP_MAX_NUM;
+	}
+
 	config->multiq = dev_multiq;
-	for (i = 0; i < MAX_TX_FIFOS; i++) {
+	for (i = 0; i < config->tx_fifo_num; i++) {
 		config->tx_cfg[i].fifo_len = tx_fifo_len[i];
 		config->tx_cfg[i].fifo_priority = i;
 	}
@@ -7837,6 +7917,11 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	for (i = 0; i < MAX_TX_FIFOS; i++)
 		config->fifo_mapping[i] = fifo_map[config->tx_fifo_num - 1][i];
 
+	/* map the hashing selector table to the configured fifos */
+	for (i = 0; i < config->tx_fifo_num; i++)
+		sp->fifo_selector[i] = fifo_selector[i];
+
+
 	config->tx_intr_type = TXD_INT_TYPE_UTILZ;
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		config->tx_cfg[i].f_no_snoop =
@@ -8113,6 +8198,20 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		DBG_PRINT(ERR_DBG, "%s: Multiqueue support disabled\n",
 			dev->name);
 
+	switch (sp->config.tx_steering_type) {
+	case NO_STEERING:
+		DBG_PRINT(ERR_DBG, "%s: No steering enabled for"
+			" transmit\n", dev->name);
+			break;
+	case TX_PRIORITY_STEERING:
+		DBG_PRINT(ERR_DBG, "%s: Priority steering enabled for"
+			" transmit\n", dev->name);
+		break;
+	case TX_DEFAULT_STEERING:
+		DBG_PRINT(ERR_DBG, "%s: Default steering enabled for"
+			" transmit\n", dev->name);
+	}
+
 	if (sp->lro)
 		DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
 			  dev->name);
diff -Nurp 2-0-26-18-1/drivers/net/s2io.h 2-0-26-18-2/drivers/net/s2io.h
--- 2-0-26-18-1/drivers/net/s2io.h	2008-02-15 05:15:49.000000000 +0530
+++ 2-0-26-18-2/drivers/net/s2io.h	2008-02-15 05:16:45.000000000 +0530
@@ -360,7 +360,10 @@ struct stat_block {
 #define MAX_TX_FIFOS 8
 #define MAX_RX_RINGS 8
 
-#define FIFO_DEFAULT_NUM	1
+#define FIFO_DEFAULT_NUM	5
+#define FIFO_UDP_MAX_NUM			2 /* 0 - even, 1 -odd ports */
+#define FIFO_OTHER_MAX_NUM			1
+
 
 #define MAX_RX_DESC_1  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 127 )
 #define MAX_RX_DESC_2  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
@@ -379,6 +382,8 @@ static int fifo_map[][MAX_TX_FIFOS] = {
 	{0, 1, 2, 3, 4, 5, 6, 7},
 };
 
+static u16 fifo_selector[MAX_TX_FIFOS] = {0, 1, 3, 3, 7, 7, 7, 7};
+
 /* Maintains Per FIFO related information. */
 struct tx_fifo_config {
 #define	MAX_AVAILABLE_TXDS	8192
@@ -431,6 +436,12 @@ struct config_param {
 /* Tx Side */
 	u32 tx_fifo_num;	/*Number of Tx FIFOs */
 
+	/* 0-No steering, 1-Priority steering, 2-Default fifo map */
+#define	NO_STEERING				0
+#define	TX_PRIORITY_STEERING			0x1
+#define TX_DEFAULT_STEERING 			0x2
+	u8 tx_steering_type;
+
 	u8 fifo_mapping[MAX_TX_FIFOS];
 	struct tx_fifo_config tx_cfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */
 	u32 max_txds;		/*Max no. of Tx buffer descriptor per TxDL */
@@ -895,6 +906,27 @@ struct s2io_nic {
 	 */
 	int rx_csum;
 
+	/* Below variables are used for fifo selection to transmit a packet */
+	u16 fifo_selector[MAX_TX_FIFOS];
+
+	/* Total fifos for tcp packets */
+	u8 total_tcp_fifos;
+
+	/*
+	* Beginning index of udp for udp packets
+	* Value will be equal to
+	* (tx_fifo_num - FIFO_UDP_MAX_NUM - FIFO_OTHER_MAX_NUM)
+	*/
+	u8 udp_fifo_idx;
+
+	u8 total_udp_fifos;
+
+	/*
+	 * Beginning index of fifo for all other packets
+	 * Value will be equal to (tx_fifo_num - FIFO_OTHER_MAX_NUM)
+	*/
+	u8 other_fifo_idx;
+
 	/*  after blink, the adapter must be restored with original
 	 *  values.
 	 */

