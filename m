From: Tony Prisk <linux@prisktech.co.nz>
Subject: [PATCHv8 1/3] net: velocity: Rename vptr->dev to vptr->netdev
Date: Sat, 18 May 2013 16:59:45 +1200
Message-ID: <1368853187-17823-2-git-send-email-linux@prisktech.co.nz>
References: <1368853187-17823-1-git-send-email-linux@prisktech.co.nz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, romieu@fr.zoreil.com,
	Tony Prisk <linux@prisktech.co.nz>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368853187-17823-1-git-send-email-linux@prisktech.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve the clarity of the code in preparation for converting the
dma functions to generic versions, which require a struct device *.

This makes it possible to store a 'struct device *dev' in the
velocity_info structure.

Signed-off-by: Tony Prisk <linux@prisktech.co.nz>
---
 drivers/net/ethernet/via/via-velocity.c |   66 +++++++++++++++----------------
 drivers/net/ethernet/via/via-velocity.h |    4 +-
 2 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index fb62489..187eef3 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -998,9 +998,9 @@ static void velocity_print_link_status(struct velocity_info *vptr)
 {
 
 	if (vptr->mii_status & VELOCITY_LINK_FAIL) {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: failed to detect cable link\n", vptr->dev->name);
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: failed to detect cable link\n", vptr->netdev->name);
 	} else if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link auto-negotiation", vptr->dev->name);
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link auto-negotiation", vptr->netdev->name);
 
 		if (vptr->mii_status & VELOCITY_SPEED_1000)
 			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 1000M bps");
@@ -1014,7 +1014,7 @@ static void velocity_print_link_status(struct velocity_info *vptr)
 		else
 			VELOCITY_PRT(MSG_LEVEL_INFO, " half duplex\n");
 	} else {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link forced", vptr->dev->name);
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link forced", vptr->netdev->name);
 		switch (vptr->options.spd_dpx) {
 		case SPD_DPX_1000_FULL:
 			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 1000M bps full duplex\n");
@@ -1319,7 +1319,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 	case VELOCITY_INIT_RESET:
 	case VELOCITY_INIT_WOL:
 
-		netif_stop_queue(vptr->dev);
+		netif_stop_queue(vptr->netdev);
 
 		/*
 		 *	Reset RX to prevent RX pointer not on the 4X location
@@ -1332,7 +1332,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		if (velocity_set_media_mode(vptr, mii_status) != VELOCITY_LINK_CHANGE) {
 			velocity_print_link_status(vptr);
 			if (!(vptr->mii_status & VELOCITY_LINK_FAIL))
-				netif_wake_queue(vptr->dev);
+				netif_wake_queue(vptr->netdev);
 		}
 
 		enable_flow_control_ability(vptr);
@@ -1354,7 +1354,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 
 		mac_eeprom_reload(regs);
 		for (i = 0; i < 6; i++)
-			writeb(vptr->dev->dev_addr[i], &(regs->PAR[i]));
+			writeb(vptr->netdev->dev_addr[i], &(regs->PAR[i]));
 
 		/*
 		 *	clear Pre_ACPI bit.
@@ -1377,7 +1377,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		/*
 		 *	Set packet filter: Receive directed and broadcast address
 		 */
-		velocity_set_multi(vptr->dev);
+		velocity_set_multi(vptr->netdev);
 
 		/*
 		 *	Enable MII auto-polling
@@ -1404,14 +1404,14 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		writel((CR0_DPOLL | CR0_TXON | CR0_RXON | CR0_STRT), &regs->CR0Set);
 
 		mii_status = velocity_get_opt_media_mode(vptr);
-		netif_stop_queue(vptr->dev);
+		netif_stop_queue(vptr->netdev);
 
 		mii_init(vptr, mii_status);
 
 		if (velocity_set_media_mode(vptr, mii_status) != VELOCITY_LINK_CHANGE) {
 			velocity_print_link_status(vptr);
 			if (!(vptr->mii_status & VELOCITY_LINK_FAIL))
-				netif_wake_queue(vptr->dev);
+				netif_wake_queue(vptr->netdev);
 		}
 
 		enable_flow_control_ability(vptr);
@@ -1474,7 +1474,7 @@ static int velocity_init_dma_rings(struct velocity_info *vptr)
 				    rx_ring_size, &pool_dma);
 	if (!pool) {
 		dev_err(&pdev->dev, "%s : DMA memory allocation failed.\n",
-			vptr->dev->name);
+			vptr->netdev->name);
 		return -ENOMEM;
 	}
 
@@ -1514,7 +1514,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	struct rx_desc *rd = &(vptr->rx.ring[idx]);
 	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 
-	rd_info->skb = netdev_alloc_skb(vptr->dev, vptr->rx.buf_sz + 64);
+	rd_info->skb = netdev_alloc_skb(vptr->netdev, vptr->rx.buf_sz + 64);
 	if (rd_info->skb == NULL)
 		return -ENOMEM;
 
@@ -1620,7 +1620,7 @@ static int velocity_init_rd_ring(struct velocity_info *vptr)
 
 	if (velocity_rx_refill(vptr) != vptr->options.numrx) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
-			"%s: failed to allocate RX buffer.\n", vptr->dev->name);
+			"%s: failed to allocate RX buffer.\n", vptr->netdev->name);
 		velocity_free_rd_ring(vptr);
 		goto out;
 	}
@@ -1809,7 +1809,7 @@ static void velocity_error(struct velocity_info *vptr, int status)
 		printk(KERN_ERR "TD structure error TDindex=%hx\n", readw(&regs->TDIdx[0]));
 		BYTE_REG_BITS_ON(TXESR_TDSTR, &regs->TXESR);
 		writew(TRDCSR_RUN, &regs->TDCSRClr);
-		netif_stop_queue(vptr->dev);
+		netif_stop_queue(vptr->netdev);
 
 		/* FIXME: port over the pci_device_failed code and use it
 		   here */
@@ -1850,10 +1850,10 @@ static void velocity_error(struct velocity_info *vptr, int status)
 
 		if (linked) {
 			vptr->mii_status &= ~VELOCITY_LINK_FAIL;
-			netif_carrier_on(vptr->dev);
+			netif_carrier_on(vptr->netdev);
 		} else {
 			vptr->mii_status |= VELOCITY_LINK_FAIL;
-			netif_carrier_off(vptr->dev);
+			netif_carrier_off(vptr->netdev);
 		}
 
 		velocity_print_link_status(vptr);
@@ -1867,9 +1867,9 @@ static void velocity_error(struct velocity_info *vptr, int status)
 		enable_mii_autopoll(regs);
 
 		if (vptr->mii_status & VELOCITY_LINK_FAIL)
-			netif_stop_queue(vptr->dev);
+			netif_stop_queue(vptr->netdev);
 		else
-			netif_wake_queue(vptr->dev);
+			netif_wake_queue(vptr->netdev);
 
 	}
 	if (status & ISR_MIBFI)
@@ -1894,7 +1894,7 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 	int idx;
 	int works = 0;
 	struct velocity_td_info *tdinfo;
-	struct net_device_stats *stats = &vptr->dev->stats;
+	struct net_device_stats *stats = &vptr->netdev->stats;
 
 	for (qnum = 0; qnum < vptr->tx.numq; qnum++) {
 		for (idx = vptr->tx.tail[qnum]; vptr->tx.used[qnum] > 0;
@@ -1939,9 +1939,9 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 	 *	Look to see if we should kick the transmit network
 	 *	layer for more work.
 	 */
-	if (netif_queue_stopped(vptr->dev) && (full == 0) &&
+	if (netif_queue_stopped(vptr->netdev) && (full == 0) &&
 	    (!(vptr->mii_status & VELOCITY_LINK_FAIL))) {
-		netif_wake_queue(vptr->dev);
+		netif_wake_queue(vptr->netdev);
 	}
 	return works;
 }
@@ -1989,7 +1989,7 @@ static int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *new_skb;
 
-		new_skb = netdev_alloc_skb_ip_align(vptr->dev, pkt_size);
+		new_skb = netdev_alloc_skb_ip_align(vptr->netdev, pkt_size);
 		if (new_skb) {
 			new_skb->ip_summed = rx_skb[0]->ip_summed;
 			skb_copy_from_linear_data(*rx_skb, new_skb->data, pkt_size);
@@ -2030,14 +2030,14 @@ static inline void velocity_iph_realign(struct velocity_info *vptr,
 static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 {
 	void (*pci_action)(struct pci_dev *, dma_addr_t, size_t, int);
-	struct net_device_stats *stats = &vptr->dev->stats;
+	struct net_device_stats *stats = &vptr->netdev->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 	struct rx_desc *rd = &(vptr->rx.ring[idx]);
 	int pkt_len = le16_to_cpu(rd->rdesc0.len) & 0x3fff;
 	struct sk_buff *skb;
 
 	if (rd->rdesc0.RSR & (RSR_STP | RSR_EDP)) {
-		VELOCITY_PRT(MSG_LEVEL_VERBOSE, KERN_ERR " %s : the received frame span multple RDs.\n", vptr->dev->name);
+		VELOCITY_PRT(MSG_LEVEL_VERBOSE, KERN_ERR " %s : the received frame span multple RDs.\n", vptr->netdev->name);
 		stats->rx_length_errors++;
 		return -EINVAL;
 	}
@@ -2075,7 +2075,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 		   PCI_DMA_FROMDEVICE);
 
 	skb_put(skb, pkt_len - 4);
-	skb->protocol = eth_type_trans(skb, vptr->dev);
+	skb->protocol = eth_type_trans(skb, vptr->netdev);
 
 	if (rd->rdesc0.RSR & RSR_DETAG) {
 		u16 vid = swab16(le16_to_cpu(rd->rdesc1.PQTAG));
@@ -2100,7 +2100,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
  */
 static int velocity_rx_srv(struct velocity_info *vptr, int budget_left)
 {
-	struct net_device_stats *stats = &vptr->dev->stats;
+	struct net_device_stats *stats = &vptr->netdev->stats;
 	int rd_curr = vptr->rx.curr;
 	int works = 0;
 
@@ -2292,7 +2292,7 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 
 	if ((new_mtu < VELOCITY_MIN_MTU) || new_mtu > (VELOCITY_MAX_MTU)) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_NOTICE "%s: Invalid MTU.\n",
-				vptr->dev->name);
+				vptr->netdev->name);
 		ret = -EINVAL;
 		goto out_0;
 	}
@@ -2314,7 +2314,7 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 			goto out_0;
 		}
 
-		tmp_vptr->dev = dev;
+		tmp_vptr->netdev = dev;
 		tmp_vptr->pdev = vptr->pdev;
 		tmp_vptr->options = vptr->options;
 		tmp_vptr->tx.numq = vptr->tx.numq;
@@ -2692,7 +2692,7 @@ static int velocity_get_pci_info(struct velocity_info *vptr,
  */
 static void velocity_print_info(struct velocity_info *vptr)
 {
-	struct net_device *dev = vptr->dev;
+	struct net_device *dev = vptr->netdev;
 
 	printk(KERN_INFO "%s: %s\n", dev->name, get_chip_name(vptr->chip_id));
 	printk(KERN_INFO "%s: Ethernet Address: %pM\n",
@@ -2755,7 +2755,7 @@ static int velocity_found1(struct pci_dev *pdev,
 
 	velocity_init_info(pdev, vptr, info);
 
-	vptr->dev = dev;
+	vptr->netdev = dev;
 
 	ret = pci_enable_device(pdev);
 	if (ret < 0)
@@ -3010,10 +3010,10 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct velocity_info *vptr = netdev_priv(dev);
 	unsigned long flags;
 
-	if (!netif_running(vptr->dev))
+	if (!netif_running(vptr->netdev))
 		return 0;
 
-	netif_device_detach(vptr->dev);
+	netif_device_detach(vptr->netdev);
 
 	spin_lock_irqsave(&vptr->lock, flags);
 	pci_save_state(pdev);
@@ -3078,7 +3078,7 @@ static int velocity_resume(struct pci_dev *pdev)
 	unsigned long flags;
 	int i;
 
-	if (!netif_running(vptr->dev))
+	if (!netif_running(vptr->netdev))
 		return 0;
 
 	pci_set_power_state(pdev, PCI_D0);
@@ -3101,7 +3101,7 @@ static int velocity_resume(struct pci_dev *pdev)
 
 	mac_enable_int(vptr->mac_regs);
 	spin_unlock_irqrestore(&vptr->lock, flags);
-	netif_device_attach(vptr->dev);
+	netif_device_attach(vptr->netdev);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/via/via-velocity.h b/drivers/net/ethernet/via/via-velocity.h
index 4cb9f13..ff8d7828 100644
--- a/drivers/net/ethernet/via/via-velocity.h
+++ b/drivers/net/ethernet/via/via-velocity.h
@@ -1435,7 +1435,7 @@ struct velocity_opt {
 
 struct velocity_info {
 	struct pci_dev *pdev;
-	struct net_device *dev;
+	struct net_device *netdev;
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 ip_addr[4];
@@ -1514,7 +1514,7 @@ static inline int velocity_get_ip(struct velocity_info *vptr)
 	int res = -ENOENT;
 
 	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(vptr->dev);
+	in_dev = __in_dev_get_rcu(vptr->netdev);
 	if (in_dev != NULL) {
 		ifa = (struct in_ifaddr *) in_dev->ifa_list;
 		if (ifa != NULL) {
-- 
1.7.9.5
