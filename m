From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/macb: fix race with RX interrupt while doing NAPI
Date: Tue, 12 Feb 2013 11:08:48 +0100
Message-ID: <1360663728-10296-1-git-send-email-nicolas.ferre@atmel.com>
References: <50D2D7BD.3030801@erwinrol.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	<mailinglists@erwinrol.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50D2D7BD.3030801@erwinrol.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When interrupts are disabled, an RX condition can occur but
it is not reported when enabling interrupts again. We need to check
RSR and use napi_reschedule() if condition is met.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a9b0830..b9d4bb9 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -693,6 +693,11 @@ static int macb_poll(struct napi_struct *napi, int budget)
 		 * get notified when new packets arrive.
 		 */
 		macb_writel(bp, IER, MACB_RX_INT_FLAGS);
+
+		/* Packets received while interrupts were disabled */
+		status = macb_readl(bp, RSR);
+		if (unlikely(status))
+			napi_reschedule(napi);
 	}
 
 	/* TODO: Handle errors */
-- 
1.8.0
