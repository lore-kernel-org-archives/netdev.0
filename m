From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 1/2]S2io: Strip the vlan tag if the vlan group is
	not NULL
Date: 19 Nov 2007 14:00:37 -0800
Message-ID: <1195509636.1995.39.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:50610 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbXKSUiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 15:38:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Updated the vlan tag stripping code as per Dave Johnson's patch
  <djohnson@sw.starentnetworks.com>
  Below is the driver behaviour for vlan_tag_strip loadable paramter,
	vlan_tag_strip - 0: Don't strip the vlan tag
	vlan_tag_strip - 1: Always strip the vlan tag
	vlan_tag_strip - 2 (default): strip the vlan tag if the 
	  vlan group is not NULL.

Signed-off-by: Santoshkumar Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.6/drivers/net/s2io.c 2.0.26.8P1/drivers/net/s2io.c
--- 2.0.26.6/drivers/net/s2io.c	2007-11-15 18:19:42.000000000 -0800
+++ 2.0.26.8P1/drivers/net/s2io.c	2007-11-15 18:15:00.000000000 -0800
@@ -46,10 +46,10 @@
  *     Possible values '1' for enable and '0' for disable. Default is '1'
  * ufo: This parameter used to enable/disable UDP Fragmentation Offload(UFO)
  *      Possible values '1' for enable and '0' for disable. Default is '0'
- * vlan_tag_strip: This can be used to enable or disable vlan stripping.
- *                 Possible values '1' for enable , '0' for disable.
- *                 Default is '2' - which means disable in promisc mode
- *                 and enable in non-promiscuous mode.
+ * vlan_tag_strip: This can be used to enable or disable vlan tag stripping.
+ *      Possible values '2' for driver default, '1' for enable and
+ *      '0' for disable
+ *      Default is '2' - VLAN tag stripping enabled if vlan group present
  ************************************************************************/
 
 #include <linux/module.h>
@@ -365,20 +365,57 @@ static void do_s2io_copy_mac_addr(struct
 	sp->def_mac_addr[offset].mac_addr[1] = (u8) (mac_addr >> 32);
 	sp->def_mac_addr[offset].mac_addr[0] = (u8) (mac_addr >> 40);
 }
+
+/* Progran the hardware to Enable/Disable vlan tag strippng dynamically */
+static void s2io_handle_vlan_tag_strip(struct s2io_nic *nic, int flag)
+{
+	struct XENA_dev_config __iomem *bar0 = nic->bar0;
+	u64 val64;
+
+	val64 = readq(&bar0->rx_pa_cfg);
+	if (flag == S2IO_DO_NOT_STRIP_VLAN_TAG)
+		val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
+	else
+		val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
+
+	writeq(val64, &bar0->rx_pa_cfg);
+}
+
 /* Add the vlan */
 static void s2io_vlan_rx_register(struct net_device *dev,
 					struct vlan_group *grp)
 {
 	struct s2io_nic *nic = dev->priv;
 	unsigned long flags;
+	struct config_param *config = &nic->config;
 
 	spin_lock_irqsave(&nic->tx_lock, flags);
 	nic->vlgrp = grp;
+
+	/* if vlgrp is NULL disable VLAN stripping */
+	if (config->vlan_tag_strip == S2IO_DEFAULT_STRIP_MODE_VLAN_TAG) {
+		if (!grp)
+			nic->vlan_strip_flag = S2IO_DO_NOT_STRIP_VLAN_TAG;
+		else
+			nic->vlan_strip_flag = S2IO_STRIP_VLAN_TAG;
+	}
+
+	s2io_handle_vlan_tag_strip(nic, nic->vlan_strip_flag);
 	spin_unlock_irqrestore(&nic->tx_lock, flags);
 }
 
-/* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
-static int vlan_strip_flag;
+/* Unregister the vlan */
+static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
+{
+	unsigned long flags;
+	struct s2io_nic *nic = dev->priv;
+
+	spin_lock_irqsave(&nic->tx_lock, flags);
+	if (nic->vlgrp)
+		vlan_group_set_device(nic->vlgrp, vid, NULL);
+
+	spin_unlock_irqrestore(&nic->tx_lock, flags);
+}
 
 /*
  * Constants to be programmed into the Xena's registers, to configure
@@ -479,7 +516,7 @@ S2IO_PARM_INT(indicate_max_pkts, 0);
 
 S2IO_PARM_INT(napi, 1);
 S2IO_PARM_INT(ufo, 0);
-S2IO_PARM_INT(vlan_tag_strip, NO_STRIP_IN_PROMISC);
+S2IO_PARM_INT(vlan_tag_strip, S2IO_DEFAULT_STRIP_MODE_VLAN_TAG);
 
 static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
     {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
@@ -2147,12 +2184,7 @@ static int start_nic(struct s2io_nic *ni
 		writeq(val64, &bar0->rx_pa_cfg);
 	}
 
-	if (vlan_tag_strip == 0) {
-		val64 = readq(&bar0->rx_pa_cfg);
-		val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
-		writeq(val64, &bar0->rx_pa_cfg);
-		vlan_strip_flag = 0;
-	}
+	s2io_handle_vlan_tag_strip(nic, nic->vlan_strip_flag);
 
 	/*
 	 * Enabling MC-RLDRAM. After enabling the device, we timeout
@@ -4766,13 +4798,6 @@ static void s2io_set_multicast(struct ne
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
 		writel((u32) (val64 >> 32), (add + 4));
 
-		if (vlan_tag_strip != 1) {
-			val64 = readq(&bar0->rx_pa_cfg);
-			val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
-			writeq(val64, &bar0->rx_pa_cfg);
-			vlan_strip_flag = 0;
-		}
-
 		val64 = readq(&bar0->mac_cfg);
 		sp->promisc_flg = 1;
 		DBG_PRINT(INFO_DBG, "%s: entered promiscuous mode\n",
@@ -4788,13 +4813,6 @@ static void s2io_set_multicast(struct ne
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
 		writel((u32) (val64 >> 32), (add + 4));
 
-		if (vlan_tag_strip != 0) {
-			val64 = readq(&bar0->rx_pa_cfg);
-			val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
-			writeq(val64, &bar0->rx_pa_cfg);
-			vlan_strip_flag = 1;
-		}
-
 		val64 = readq(&bar0->mac_cfg);
 		sp->promisc_flg = 0;
 		DBG_PRINT(INFO_DBG, "%s: left promiscuous mode\n",
@@ -7188,8 +7206,8 @@ static int rx_osm_handler(struct ring_in
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 	if (!sp->lro) {
 		skb->protocol = eth_type_trans(skb, dev);
-		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
-			vlan_strip_flag)) {
+		if ((sp->vlan_strip_flag == S2IO_STRIP_VLAN_TAG) &&
+			RXD_GET_VLAN_TAG(rxdp->Control_2)) {
 			/* Queueing the vlan frame to the upper layer */
 			if (napi)
 				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
@@ -7295,6 +7313,16 @@ static int s2io_verify_parm(struct pci_d
 		DBG_PRINT(ERR_DBG, "s2io: Default to 8 Rx rings\n");
 		rx_ring_num = 8;
 	}
+
+	if (vlan_tag_strip) {
+		if (vlan_tag_strip > S2IO_DEFAULT_STRIP_MODE_VLAN_TAG) {
+			DBG_PRINT(ERR_DBG, "s2io: Unsupported vlan tag "
+				"sripping option. Enabling vlan tag "
+				"stripping if vlan group present\n");
+			vlan_tag_strip = S2IO_DEFAULT_STRIP_MODE_VLAN_TAG;
+		}
+	}
+
 	if (*dev_intr_type != INTA)
 		napi = 0;
 
@@ -7463,6 +7491,11 @@ s2io_init_nic(struct pci_dev *pdev, cons
 
 	config->napi = napi;
 
+	config->vlan_tag_strip = vlan_tag_strip;
+	sp->vlan_strip_flag = config->vlan_tag_strip;
+	if (sp->vlan_strip_flag == S2IO_DEFAULT_STRIP_MODE_VLAN_TAG)
+		sp->vlan_strip_flag = S2IO_DO_NOT_STRIP_VLAN_TAG;
+
 	/* Tx side parameters. */
 	config->tx_fifo_num = tx_fifo_num;
 	for (i = 0; i < MAX_TX_FIFOS; i++) {
@@ -7557,6 +7590,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = s2io_vlan_rx_register;
+	dev->vlan_rx_kill_vid = (void *)s2io_vlan_rx_kill_vid;
 
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
@@ -7725,6 +7759,14 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	if (ufo)
 		DBG_PRINT(ERR_DBG, "%s: UDP Fragmentation Offload(UFO)"
 					" enabled\n", dev->name);
+
+	if (vlan_tag_strip == S2IO_STRIP_VLAN_TAG) {
+		DBG_PRINT(ERR_DBG, "%s: Vlan tag stripping enabled\n",
+			dev->name);
+	} else if (vlan_tag_strip == S2IO_DO_NOT_STRIP_VLAN_TAG)
+		DBG_PRINT(ERR_DBG, "%s: Vlan tag stripping disabled\n",
+			dev->name);
+
 	/* Initialize device name */
 	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
 
diff -Nurp 2.0.26.6/drivers/net/s2io.h 2.0.26.8P1/drivers/net/s2io.h
--- 2.0.26.6/drivers/net/s2io.h	2007-11-15 18:19:42.000000000 -0800
+++ 2.0.26.8P1/drivers/net/s2io.h	2007-11-15 18:15:00.000000000 -0800
@@ -348,8 +348,10 @@ struct stat_block {
 	struct xpakStat xpak_stat;
 };
 
-/* Default value for 'vlan_strip_tag' configuration parameter */
-#define NO_STRIP_IN_PROMISC 2
+/* Macros for vlan tag handling */
+#define S2IO_DO_NOT_STRIP_VLAN_TAG 0
+#define S2IO_STRIP_VLAN_TAG 1
+#define S2IO_DEFAULT_STRIP_MODE_VLAN_TAG 2
 
 /*
  * Structures representing different init time configuration
@@ -458,6 +460,7 @@ struct config_param {
 #define MAX_MTU_JUMBO               (MAX_PYLD_JUMBO+18)
 #define MAX_MTU_JUMBO_VLAN          (MAX_PYLD_JUMBO+22)
 	u16 bus_speed;
+	u8 vlan_tag_strip;
 };
 
 /* Structure representing MAC Addrs */
@@ -915,6 +918,7 @@ struct s2io_nic {
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
 	u8  serial_num[VPD_STRING_LEN];
+	u8  vlan_strip_flag;
 };
 
 #define RESET_ERROR 1;



