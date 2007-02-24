From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 3/6] S2IO: Added a loadable parameter to enable or disable
 vlan stripping in frame.
Date: Sat, 24 Feb 2007 01:59:39 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10702240158160.3434-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, sreenivasa.honnur@neterion.com,
	ramkrishna.vepa@neterion.com, santosh.rastapur@neterion.com,
	alicia.pena@neterion.com, sriram.rapuru@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:45759 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933400AbXBXG7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 01:59:41 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added code to not to strip vlan tag when driver is in promiscuous mode
- Added module loadable parameter 'vlan_tag_strip" through which user can
  enable or disable vlan stripping irrespective of mode
  ( promiscuous or non-promiscuous ). 

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch2/drivers/net/s2io.c patch3/drivers/net/s2io.c
--- patch2/drivers/net/s2io.c	2007-02-21 15:21:14.000000000 +0530
+++ patch3/drivers/net/s2io.c	2007-02-24 11:42:48.000000000 +0530
@@ -42,6 +42,14 @@
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can be
  *     aggregated as a single large packet
+ * napi: This parameter used to enable/disable NAPI (polling Rx)
+ *     Possible values '1' for enable and '0' for disable. Default is '1'
+ * ufo: This parameter used to enable/disable UDP Fragmentation Offload(UFO)
+ *      Possible values '1' for enable and '0' for disable. Default is '0'
+ * vlan_tag_strip: This can be used to enable or disable vlan stripping.
+ *                 Possible values '1' for enable , '0' for disable.
+ *                 Default is '2' - which means disable in promisc mode
+ *                 and enable in non-promiscuous mode.
  ************************************************************************/
 
 #include <linux/module.h>
@@ -293,6 +301,9 @@ static void s2io_vlan_rx_register(struct
 	spin_unlock_irqrestore(&nic->tx_lock, flags);
 }
 
+/* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
+int vlan_strip_flag;
+
 /* Unregister the vlan */
 static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
 {
@@ -404,6 +415,7 @@ S2IO_PARM_INT(indicate_max_pkts, 0);
 
 S2IO_PARM_INT(napi, 1);
 S2IO_PARM_INT(ufo, 0);
+S2IO_PARM_INT(vlan_tag_strip, NO_STRIP_IN_PROMISC);
 
 static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
     {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
@@ -1371,7 +1383,7 @@ static int init_nic(struct s2io_nic *nic
 				&bar0->rts_frm_len_n[i]);
 		}
 	}
-
+	
 	/* Disable differentiated services steering logic */
 	for (i = 0; i < 64; i++) {
 		if (rts_ds_steer(nic, i, 0) == FAILURE) {
@@ -1953,6 +1965,13 @@ static int start_nic(struct s2io_nic *ni
 		writeq(val64, &bar0->rx_pa_cfg);
 	}
 
+	if (vlan_tag_strip == 0) {
+		val64 = readq(&bar0->rx_pa_cfg);
+		val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
+		writeq(val64, &bar0->rx_pa_cfg);
+		vlan_strip_flag = 0;
+	}
+
 	/*
 	 * Enabling MC-RLDRAM. After enabling the device, we timeout
 	 * for around 100ms, which is approximately the time required
@@ -4352,6 +4371,13 @@ static void s2io_set_multicast(struct ne
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
 		writel((u32) (val64 >> 32), (add + 4));
 
+		if (vlan_tag_strip != 1) {
+			val64 = readq(&bar0->rx_pa_cfg);
+			val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
+			writeq(val64, &bar0->rx_pa_cfg);
+			vlan_strip_flag = 0;
+		}
+
 		val64 = readq(&bar0->mac_cfg);
 		sp->promisc_flg = 1;
 		DBG_PRINT(INFO_DBG, "%s: entered promiscuous mode\n",
@@ -4367,6 +4393,13 @@ static void s2io_set_multicast(struct ne
 		writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);
 		writel((u32) (val64 >> 32), (add + 4));
 
+		if (vlan_tag_strip != 0) {
+			val64 = readq(&bar0->rx_pa_cfg);
+			val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
+			writeq(val64, &bar0->rx_pa_cfg);
+			vlan_strip_flag = 1;
+		}
+
 		val64 = readq(&bar0->mac_cfg);
 		sp->promisc_flg = 0;
 		DBG_PRINT(INFO_DBG, "%s: left promiscuous mode\n",
@@ -6614,7 +6647,8 @@ static int rx_osm_handler(struct ring_in
 
 	if (!sp->lro) {
 		skb->protocol = eth_type_trans(skb, dev);
-		if (sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2)) {
+		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
+			vlan_strip_flag)) {
 			/* Queueing the vlan frame to the upper layer */
 			if (napi)
 				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
diff -urpN patch2/drivers/net/s2io.h patch3/drivers/net/s2io.h
--- patch2/drivers/net/s2io.h	2007-02-20 14:47:46.000000000 +0530
+++ patch3/drivers/net/s2io.h	2007-02-21 14:54:19.000000000 +0530
@@ -297,6 +297,9 @@ struct stat_block {
 	struct xpakStat xpak_stat;
 };
 
+/* Default value for 'vlan_strip_tag' configuration parameter */
+#define NO_STRIP_IN_PROMISC 2
+
 /*
  * Structures representing different init time configuration
  * parameters of the NIC.
diff -urpN patch2/drivers/net/s2io-regs.h patch3/drivers/net/s2io-regs.h
--- patch2/drivers/net/s2io-regs.h	2007-02-15 14:49:42.000000000 +0530
+++ patch3/drivers/net/s2io-regs.h	2007-02-16 11:03:55.000000000 +0530
@@ -430,6 +430,7 @@ struct XENA_dev_config {
 #define TX_PA_CFG_IGNORE_SNAP_OUI          BIT(2)
 #define TX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)
 #define	TX_PA_CFG_IGNORE_L2_ERR			   BIT(6)
+#define RX_PA_CFG_STRIP_VLAN_TAG		BIT(15)
 
 /* Recent add, used only debug purposes. */
 	u64 pcc_enable;

