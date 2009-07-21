From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 4/10] bnx2x: Adding some mmiowb
Date: Tue, 21 Jul 2009 18:47:33 +0300
Message-ID: <1248191253.18195.47.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Vlad Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2395 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753469AbZGUPrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:47:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vlad Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d946c9e..f20df6d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -652,6 +652,11 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 	   val, port, addr, (msix ? "MSI-X" : (msi ? "MSI" : "INTx")));
 
 	REG_WR(bp, addr, val);
+	/*
+	 * Ensure that HC_CONFIG is written before leading/trailing edge config
+	 */
+	mmiowb();
+	barrier();
 
 	if (CHIP_IS_E1H(bp)) {
 		/* init leading/trailing edge */
@@ -666,6 +671,9 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 		REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
 		REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
 	}
+
+	/* Make sure that interrupts are indeed enabled from here on */
+	mmiowb();
 }
 
 static void bnx2x_int_disable(struct bnx2x *bp)
@@ -739,6 +747,10 @@ static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 	DP(BNX2X_MSG_OFF, "write 0x%08x to HC addr 0x%x\n",
 	   (*(u32 *)&igu_ack), hc_addr);
 	REG_WR(bp, hc_addr, (*(u32 *)&igu_ack));
+
+	/* Make sure that ACK is written */
+	mmiowb();
+	barrier();
 }
 
 static inline u16 bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
@@ -2429,9 +2441,14 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		bp->spq_prod_idx++;
 	}
 
+	/* Make sure that BD data is updated before writing the producer */
+	wmb();
+
 	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
 	       bp->spq_prod_idx);
 
+	mmiowb();
+
 	spin_unlock_bh(&bp->spq_lock);
 	return 0;
 }
-- 
1.5.4.3




