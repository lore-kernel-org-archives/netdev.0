From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/20] ixgbe: consolidate all setting of MRQC
	into one function
Date: Thu, 19 Aug 2010 16:35:41 -0700
Message-ID: <20100819233539.10335.93283.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:44340 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752423Ab0HSXgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:36:03 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change simplifies the configuration of MRQC by consolidating the
setting of it into one function. As such the register is no longer set in
multiple places which should make any future changes easier to work with.
In addition we can combine RSS related register writes into the call since
enabling all of those bits without enabling RSS itself in MRQC should have
no effect.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  100 +++++++++++++++++-----------------------
 1 files changed, 43 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 37d1f64..f5d8902 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2545,20 +2545,46 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }
 
-static u32 ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
+static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 {
-	u32 mrqc = 0;
+	struct ixgbe_hw *hw = &adapter->hw;
+	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
+	                  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
+	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
+	u32 mrqc = 0, reta = 0;
+	u32 rxcsum;
+	int i, j;
 	int mask;
 
-	if (!(adapter->hw.mac.type == ixgbe_mac_82599EB))
-		return mrqc;
+	/* Fill out hash function seeds */
+	for (i = 0; i < 10; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
+
+	/* Fill out redirection table */
+	for (i = 0, j = 0; i < 128; i++, j++) {
+		if (j == adapter->ring_feature[RING_F_RSS].indices)
+			j = 0;
+		/* reta = 4-byte sliding window of
+		 * 0x00..(indices-1)(indices-1)00..etc. */
+		reta = (reta << 8) | (j * 0x11);
+		if ((i & 3) == 3)
+			IXGBE_WRITE_REG(hw, IXGBE_RETA(i >> 2), reta);
+	}
+
+	/* Disable indicating checksum in descriptor, enables RSS hash */
+	rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
+	rxcsum |= IXGBE_RXCSUM_PCSD;
+	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
 
-	mask = adapter->flags & (IXGBE_FLAG_RSS_ENABLED
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		mask = adapter->flags & IXGBE_FLAG_RSS_ENABLED;
+	else
+		mask = adapter->flags & (IXGBE_FLAG_RSS_ENABLED
 #ifdef CONFIG_IXGBE_DCB
-				 | IXGBE_FLAG_DCB_ENABLED
+					 | IXGBE_FLAG_DCB_ENABLED
 #endif
-				 | IXGBE_FLAG_SRIOV_ENABLED
-				);
+					 | IXGBE_FLAG_SRIOV_ENABLED
+					);
 
 	switch (mask) {
 	case (IXGBE_FLAG_RSS_ENABLED):
@@ -2576,7 +2602,13 @@ static u32 ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 		break;
 	}
 
-	return mrqc;
+	/* Perform hash on these packet types */
+	mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4
+	      | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
+	      | IXGBE_MRQC_RSS_FIELD_IPV6
+	      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
+
+	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 }
 
 /**
@@ -2637,12 +2669,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i, j;
-	u32 rdlen, rxctrl, rxcsum;
-	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
-	                  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
-	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
+	u32 rdlen, rxctrl;
 	u32 fctrl, hlreg0;
-	u32 reta = 0, mrqc = 0;
 	u32 rdrxctl;
 	int rx_buf_len;
 
@@ -2774,33 +2802,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	}
 
 	/* Program MRQC for the distribution of queues */
-	mrqc = ixgbe_setup_mrqc(adapter);
-
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		/* Fill out redirection table */
-		for (i = 0, j = 0; i < 128; i++, j++) {
-			if (j == adapter->ring_feature[RING_F_RSS].indices)
-				j = 0;
-			/* reta = 4-byte sliding window of
-			 * 0x00..(indices-1)(indices-1)00..etc. */
-			reta = (reta << 8) | (j * 0x11);
-			if ((i & 3) == 3)
-				IXGBE_WRITE_REG(hw, IXGBE_RETA(i >> 2), reta);
-		}
-
-		/* Fill out hash function seeds */
-		for (i = 0; i < 10; i++)
-			IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
-
-		if (hw->mac.type == ixgbe_mac_82598EB)
-			mrqc |= IXGBE_MRQC_RSSEN;
-		    /* Perform hash on these packet types */
-		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4
-		      | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
-		      | IXGBE_MRQC_RSS_FIELD_IPV6
-		      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
-	}
-	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
+	ixgbe_setup_mrqc(adapter);
 
 	if (adapter->num_vfs) {
 		u32 reg;
@@ -2816,22 +2818,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, reg);
 	}
 
-	rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
-
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED ||
-	    adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED) {
-		/* Disable indicating checksum in descriptor, enables
-		 * RSS hash */
-		rxcsum |= IXGBE_RXCSUM_PCSD;
-	}
-	if (!(rxcsum & IXGBE_RXCSUM_PCSD)) {
-		/* Enable IPv4 payload checksum for UDP fragments
-		 * if PCSD is not set */
-		rxcsum |= IXGBE_RXCSUM_IPPCSE;
-	}
-
-	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
-
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
 		rdrxctl |= IXGBE_RDRXCTL_CRCSTRIP;

