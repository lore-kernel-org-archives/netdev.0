From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH 4/5] net: macb: Remove 'unlikely' optimization
Date: Sun,  4 May 2014 15:43:01 -0700
Message-ID: <1399243382-12528-5-git-send-email-soren.brinkmann@xilinx.com>
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

Coverage data suggests that the unlikely case of receiving data while
the receive handler is running may not be that unlikely.
Coverage data after running iperf for a while:
    91320:  891:	work_done = bp->macbgem_ops.mog_rx(bp, budget);
    91320:  892:	if (work_done < budget) {
     2362:  893:		napi_complete(napi);
        -:  894:
        -:  895:		/* Packets received while interrupts were disabled */
     4724:  896:		status = macb_readl(bp, RSR);
     2362:  897:		if (unlikely(status)) {
      762:  898:			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
      762:  899:				macb_writel(bp, ISR, MACB_BIT(RCOMP));
        -:  900:			napi_reschedule(napi);
        -:  901:		} else {
     1600:  902:			macb_writel(bp, IER, MACB_RX_INT_FLAGS);
        -:  903:		}
        -:  904:	}

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 3f4b8ee0b0e7..3e13aa31548a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -893,7 +893,7 @@ static int macb_poll(struct napi_struct *napi, int budget)
 
 		/* Packets received while interrupts were disabled */
 		status = macb_readl(bp, RSR);
-		if (unlikely(status)) {
+		if (status) {
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
 				macb_writel(bp, ISR, MACB_BIT(RCOMP));
 			napi_reschedule(napi);
-- 
1.9.2.1.g06c4abd
