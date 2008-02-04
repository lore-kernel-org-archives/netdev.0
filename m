From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/5] forcedeth: restart tx/rx
Date: Mon, 04 Feb 2008 15:13:59 -0500
Message-ID: <47A77207.1080206@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030205080404030703050503"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:17911 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758502AbYBEVtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 16:49:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030205080404030703050503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the issue where the transmitter and receiver must be 
restarted when applying new changes to certain registers.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030205080404030703050503
Content-Type: text/plain;
 name="patch-forcedeth-restart-txrx"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-restart-txrx"

--- old/drivers/net/forcedeth.c	2008-01-15 17:41:00.000000000 -0500
+++ new/drivers/net/forcedeth.c	2008-01-15 17:41:02.000000000 -0500
@@ -624,6 +624,9 @@
 #define NV_MSI_X_VECTOR_TX    0x1
 #define NV_MSI_X_VECTOR_OTHER 0x2
 
+#define NV_RESTART_TX         0x1
+#define NV_RESTART_RX         0x2
+
 /* statistics */
 struct nv_ethtool_str {
 	char name[ETH_GSTRING_LEN];
@@ -2767,6 +2770,7 @@
 	int mii_status;
 	int retval = 0;
 	u32 control_1000, status_1000, phyreg, pause_flags, txreg;
+	u32 txrxFlags = 0;
 
 	/* BMSR_LSTATUS is latched, read it twice:
 	 * we want the current value.
@@ -2862,6 +2866,16 @@
 	np->duplex = newdup;
 	np->linkspeed = newls;
 
+	/* The transmitter and receiver must be restarted for safe update */
+	if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_START) {
+		txrxFlags |= NV_RESTART_TX;
+		nv_stop_tx(dev);
+	}
+	if (readl(base + NvRegReceiverControl) & NVREG_RCVCTL_START) {
+		txrxFlags |= NV_RESTART_RX;
+		nv_stop_rx(dev);
+	}
+
 	if (np->gigabit == PHY_GIGABIT) {
 		phyreg = readl(base + NvRegRandomSeed);
 		phyreg &= ~(0x3FF00);
@@ -2950,6 +2964,11 @@
 	}
 	nv_update_pause(dev, pause_flags);
 
+	if (txrxFlags & NV_RESTART_TX)
+		nv_start_tx(dev);
+	if (txrxFlags & NV_RESTART_RX)
+		nv_start_rx(dev);
+
 	return retval;
 }
 

--------------030205080404030703050503--
