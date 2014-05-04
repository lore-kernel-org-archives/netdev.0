From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH 3/5] net: macb: Re-enable RX interrupt only when RX is done
Date: Sun,  4 May 2014 15:43:00 -0700
Message-ID: <1399243382-12528-4-git-send-email-soren.brinkmann@xilinx.com>
References: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Cc: =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	git@xilinx.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When data is received during the driver processing received data the
NAPI is re-scheduled. In that case the RX interrupt should not be
re-enabled.

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e38fe39d9589..3f4b8ee0b0e7 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -891,16 +891,15 @@ static int macb_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		napi_complete(napi);
 
-		/*
-		 * We've done what we can to clean the buffers. Make sure we
-		 * get notified when new packets arrive.
-		 */
-		macb_writel(bp, IER, MACB_RX_INT_FLAGS);
-
 		/* Packets received while interrupts were disabled */
 		status = macb_readl(bp, RSR);
-		if (unlikely(status))
+		if (unlikely(status)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				macb_writel(bp, ISR, MACB_BIT(RCOMP));
 			napi_reschedule(napi);
+		} else {
+			macb_writel(bp, IER, MACB_RX_INT_FLAGS);
+		}
 	}
 
 	/* TODO: Handle errors */
-- 
1.9.2.1.g06c4abd
