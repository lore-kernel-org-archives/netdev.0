From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 1/9] amd-xgbe: Disable VLAN filtering when in
 promiscuous mode
Date: Wed, 17 Feb 2016 11:48:08 -0600
Message-ID: <20160217174808.26246.84867.stgit@tlendack-t1.amdoffice.net>
References: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0068.outbound.protection.outlook.com ([157.56.110.68]:26592
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964878AbcBQRsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:48:17 -0500
In-Reply-To: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the hardware is placed in promiscuous mode it will still perform
VLAN filtering and therefore may not pass all packets to the driver.

Disable all VLAN filtering when entering promiscuous mode and restore
VLAN filtering upon exit from promiscuous mode. In order to avoid adding
forward declarations, move the VLAN related functions earlier in the
file.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |  229 +++++++++++++++---------------
 1 file changed, 117 insertions(+), 112 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index f6a7161..931e374 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -6,7 +6,7 @@
  *
  * License 1: GPLv2
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  *
  * This file is free software; you may copy, redistribute and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,7 +56,7 @@
  *
  * License 2: Modified BSD
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -702,6 +702,113 @@ static int xgbe_set_xgmii_speed(struct xgbe_prv_data *pdata)
 	return 0;
 }
 
+static int xgbe_enable_rx_vlan_stripping(struct xgbe_prv_data *pdata)
+{
+	/* Put the VLAN tag in the Rx descriptor */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLRXS, 1);
+
+	/* Don't check the VLAN type */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, DOVLTC, 1);
+
+	/* Check only C-TAG (0x8100) packets */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ERSVLM, 0);
+
+	/* Don't consider an S-TAG (0x88A8) packet as a VLAN packet */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ESVL, 0);
+
+	/* Enable VLAN tag stripping */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0x3);
+
+	return 0;
+}
+
+static int xgbe_disable_rx_vlan_stripping(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0);
+
+	return 0;
+}
+
+static int xgbe_enable_rx_vlan_filtering(struct xgbe_prv_data *pdata)
+{
+	/* Enable VLAN filtering */
+	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, VTFE, 1);
+
+	/* Enable VLAN Hash Table filtering */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, VTHM, 1);
+
+	/* Disable VLAN tag inverse matching */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, VTIM, 0);
+
+	/* Only filter on the lower 12-bits of the VLAN tag */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ETV, 1);
+
+	/* In order for the VLAN Hash Table filtering to be effective,
+	 * the VLAN tag identifier in the VLAN Tag Register must not
+	 * be zero.  Set the VLAN tag identifier to "1" to enable the
+	 * VLAN Hash Table filtering.  This implies that a VLAN tag of
+	 * 1 will always pass filtering.
+	 */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, VL, 1);
+
+	return 0;
+}
+
+static int xgbe_disable_rx_vlan_filtering(struct xgbe_prv_data *pdata)
+{
+	/* Disable VLAN filtering */
+	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, VTFE, 0);
+
+	return 0;
+}
+
+static u32 xgbe_vid_crc32_le(__le16 vid_le)
+{
+	u32 poly = 0xedb88320;	/* CRCPOLY_LE */
+	u32 crc = ~0;
+	u32 temp = 0;
+	unsigned char *data = (unsigned char *)&vid_le;
+	unsigned char data_byte = 0;
+	int i, bits;
+
+	bits = get_bitmask_order(VLAN_VID_MASK);
+	for (i = 0; i < bits; i++) {
+		if ((i % 8) == 0)
+			data_byte = data[i / 8];
+
+		temp = ((crc & 1) ^ data_byte) & 1;
+		crc >>= 1;
+		data_byte >>= 1;
+
+		if (temp)
+			crc ^= poly;
+	}
+
+	return crc;
+}
+
+static int xgbe_update_vlan_hash_table(struct xgbe_prv_data *pdata)
+{
+	u32 crc;
+	u16 vid;
+	__le16 vid_le;
+	u16 vlan_hash_table = 0;
+
+	/* Generate the VLAN Hash Table value */
+	for_each_set_bit(vid, pdata->active_vlans, VLAN_N_VID) {
+		/* Get the CRC32 value of the VLAN ID */
+		vid_le = cpu_to_le16(vid);
+		crc = bitrev32(~xgbe_vid_crc32_le(vid_le)) >> 28;
+
+		vlan_hash_table |= (1 << crc);
+	}
+
+	/* Set the VLAN Hash Table filtering register */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANHTR, VLHT, vlan_hash_table);
+
+	return 0;
+}
+
 static int xgbe_set_promiscuous_mode(struct xgbe_prv_data *pdata,
 				     unsigned int enable)
 {
@@ -714,6 +821,14 @@ static int xgbe_set_promiscuous_mode(struct xgbe_prv_data *pdata,
 		  enable ? "entering" : "leaving");
 	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, PR, val);
 
+	/* Hardware will still perform VLAN filtering in promiscuous mode */
+	if (enable) {
+		xgbe_disable_rx_vlan_filtering(pdata);
+	} else {
+		if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+			xgbe_enable_rx_vlan_filtering(pdata);
+	}
+
 	return 0;
 }
 
@@ -944,116 +1059,6 @@ static int xgbe_enable_rx_csum(struct xgbe_prv_data *pdata)
 	return 0;
 }
 
-static int xgbe_enable_rx_vlan_stripping(struct xgbe_prv_data *pdata)
-{
-	/* Put the VLAN tag in the Rx descriptor */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLRXS, 1);
-
-	/* Don't check the VLAN type */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, DOVLTC, 1);
-
-	/* Check only C-TAG (0x8100) packets */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ERSVLM, 0);
-
-	/* Don't consider an S-TAG (0x88A8) packet as a VLAN packet */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ESVL, 0);
-
-	/* Enable VLAN tag stripping */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0x3);
-
-	return 0;
-}
-
-static int xgbe_disable_rx_vlan_stripping(struct xgbe_prv_data *pdata)
-{
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0);
-
-	return 0;
-}
-
-static int xgbe_enable_rx_vlan_filtering(struct xgbe_prv_data *pdata)
-{
-	/* Enable VLAN filtering */
-	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, VTFE, 1);
-
-	/* Enable VLAN Hash Table filtering */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, VTHM, 1);
-
-	/* Disable VLAN tag inverse matching */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, VTIM, 0);
-
-	/* Only filter on the lower 12-bits of the VLAN tag */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ETV, 1);
-
-	/* In order for the VLAN Hash Table filtering to be effective,
-	 * the VLAN tag identifier in the VLAN Tag Register must not
-	 * be zero.  Set the VLAN tag identifier to "1" to enable the
-	 * VLAN Hash Table filtering.  This implies that a VLAN tag of
-	 * 1 will always pass filtering.
-	 */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, VL, 1);
-
-	return 0;
-}
-
-static int xgbe_disable_rx_vlan_filtering(struct xgbe_prv_data *pdata)
-{
-	/* Disable VLAN filtering */
-	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, VTFE, 0);
-
-	return 0;
-}
-
-#ifndef CRCPOLY_LE
-#define CRCPOLY_LE 0xedb88320
-#endif
-static u32 xgbe_vid_crc32_le(__le16 vid_le)
-{
-	u32 poly = CRCPOLY_LE;
-	u32 crc = ~0;
-	u32 temp = 0;
-	unsigned char *data = (unsigned char *)&vid_le;
-	unsigned char data_byte = 0;
-	int i, bits;
-
-	bits = get_bitmask_order(VLAN_VID_MASK);
-	for (i = 0; i < bits; i++) {
-		if ((i % 8) == 0)
-			data_byte = data[i / 8];
-
-		temp = ((crc & 1) ^ data_byte) & 1;
-		crc >>= 1;
-		data_byte >>= 1;
-
-		if (temp)
-			crc ^= poly;
-	}
-
-	return crc;
-}
-
-static int xgbe_update_vlan_hash_table(struct xgbe_prv_data *pdata)
-{
-	u32 crc;
-	u16 vid;
-	__le16 vid_le;
-	u16 vlan_hash_table = 0;
-
-	/* Generate the VLAN Hash Table value */
-	for_each_set_bit(vid, pdata->active_vlans, VLAN_N_VID) {
-		/* Get the CRC32 value of the VLAN ID */
-		vid_le = cpu_to_le16(vid);
-		crc = bitrev32(~xgbe_vid_crc32_le(vid_le)) >> 28;
-
-		vlan_hash_table |= (1 << crc);
-	}
-
-	/* Set the VLAN Hash Table filtering register */
-	XGMAC_IOWRITE_BITS(pdata, MAC_VLANHTR, VLHT, vlan_hash_table);
-
-	return 0;
-}
-
 static void xgbe_tx_desc_reset(struct xgbe_ring_data *rdata)
 {
 	struct xgbe_ring_desc *rdesc = rdata->rdesc;
