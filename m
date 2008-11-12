From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/5] bnx2: Set rx buffer water marks based on
 MTU.
Date: Wed, 12 Nov 2008 15:10:02 -0800
Message-ID: <1226531404-26118-3-git-send-email-mchan@broadcom.com>
References: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4068 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753391AbYKLXDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 18:03:49 -0500
In-Reply-To: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default rx buffer water marks for XOFF/XON are for 1500 MTU.  At
larger MTUs, these water marks need to be adjusted for effective
flow control.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   12 ++++++++++--
 drivers/net/bnx2.h |   21 +++++++++++++++++++++
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d28cbce..a52ffdc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4473,7 +4473,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 static int
 bnx2_init_chip(struct bnx2 *bp)
 {
-	u32 val;
+	u32 val, mtu;
 	int rc, i;
 
 	/* Make sure the interrupt is not active. */
@@ -4565,11 +4565,19 @@ bnx2_init_chip(struct bnx2 *bp)
 	REG_WR(bp, BNX2_EMAC_BACKOFF_SEED, val);
 
 	/* Program the MTU.  Also include 4 bytes for CRC32. */
-	val = bp->dev->mtu + ETH_HLEN + 4;
+	mtu = bp->dev->mtu;
+	val = mtu + ETH_HLEN + ETH_FCS_LEN;
 	if (val > (MAX_ETHERNET_PACKET_SIZE + 4))
 		val |= BNX2_EMAC_RX_MTU_SIZE_JUMBO_ENA;
 	REG_WR(bp, BNX2_EMAC_RX_MTU_SIZE, val);
 
+	if (mtu < 1500)
+		mtu = 1500;
+
+	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG, BNX2_RBUF_CONFIG_VAL(mtu));
+	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG2, BNX2_RBUF_CONFIG2_VAL(mtu));
+	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG3, BNX2_RBUF_CONFIG3_VAL(mtu));
+
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
 		bp->bnx2_napi[i].last_status_idx = 0;
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 617d953..2b9649a 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -4199,7 +4199,14 @@ struct l2_fhdr {
 
 #define BNX2_RBUF_CONFIG				0x0020000c
 #define BNX2_RBUF_CONFIG_XOFF_TRIP			 (0x3ffL<<0)
+#define BNX2_RBUF_CONFIG_XOFF_TRIP_VAL(mtu)		 \
+	((((mtu) - 1500) * 31 / 1000) + 54)
 #define BNX2_RBUF_CONFIG_XON_TRIP			 (0x3ffL<<16)
+#define BNX2_RBUF_CONFIG_XON_TRIP_VAL(mtu)		 \
+	((((mtu) - 1500) * 39 / 1000) + 66)
+#define BNX2_RBUF_CONFIG_VAL(mtu)			 \
+	(BNX2_RBUF_CONFIG_XOFF_TRIP_VAL(mtu) |		 \
+	(BNX2_RBUF_CONFIG_XON_TRIP_VAL(mtu) << 16))
 
 #define BNX2_RBUF_FW_BUF_ALLOC				0x00200010
 #define BNX2_RBUF_FW_BUF_ALLOC_VALUE			 (0x1ffL<<7)
@@ -4221,11 +4228,25 @@ struct l2_fhdr {
 
 #define BNX2_RBUF_CONFIG2				0x0020001c
 #define BNX2_RBUF_CONFIG2_MAC_DROP_TRIP			 (0x3ffL<<0)
+#define BNX2_RBUF_CONFIG2_MAC_DROP_TRIP_VAL(mtu)	 \
+	((((mtu) - 1500) * 4 / 1000) + 5)
 #define BNX2_RBUF_CONFIG2_MAC_KEEP_TRIP			 (0x3ffL<<16)
+#define BNX2_RBUF_CONFIG2_MAC_KEEP_TRIP_VAL(mtu)	 \
+	((((mtu) - 1500) * 2 / 100) + 30)
+#define BNX2_RBUF_CONFIG2_VAL(mtu)			 \
+	(BNX2_RBUF_CONFIG2_MAC_DROP_TRIP_VAL(mtu) |	 \
+	(BNX2_RBUF_CONFIG2_MAC_KEEP_TRIP_VAL(mtu) << 16))
 
 #define BNX2_RBUF_CONFIG3				0x00200020
 #define BNX2_RBUF_CONFIG3_CU_DROP_TRIP			 (0x3ffL<<0)
+#define BNX2_RBUF_CONFIG3_CU_DROP_TRIP_VAL(mtu)		 \
+	((((mtu) - 1500) * 12 / 1000) + 18)
 #define BNX2_RBUF_CONFIG3_CU_KEEP_TRIP			 (0x3ffL<<16)
+#define BNX2_RBUF_CONFIG3_CU_KEEP_TRIP_VAL(mtu)		 \
+	((((mtu) - 1500) * 2 / 100) + 30)
+#define BNX2_RBUF_CONFIG3_VAL(mtu)			 \
+	(BNX2_RBUF_CONFIG3_CU_DROP_TRIP_VAL(mtu) |	 \
+	(BNX2_RBUF_CONFIG3_CU_KEEP_TRIP_VAL(mtu) << 16))
 
 #define BNX2_RBUF_PKT_DATA				0x00208000
 #define BNX2_RBUF_CLIST_DATA				0x00210000
-- 
1.5.6.GIT


