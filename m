From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH 2/3] pch_gbe: don't re-set RX_FIFO_ERR flag in napi_poll
Date: Mon, 22 Oct 2012 16:43:24 +0200
Message-ID: <1350917005-26350-3-git-send-email-vfalico@redhat.com>
References: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com, agospoda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755081Ab2JVOnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 10:43:39 -0400
In-Reply-To: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we were in RX_FIFO_ERR state and entered pch_gbe_napi_poll(), we'll
anyway clean some rx space and thus can continue to receive more packets.
Currently, we re-set the RX_FIFO_ERR in situations when we've exhausted our
budget for RX cleaning or cleaned some TX packets. Removing it gives us
+20%-40% speed increase and a lot less of RX_FIFO_ERRors reported.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index d5190bf..4ffad78 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2419,7 +2419,6 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 	int work_done = 0;
 	bool poll_end_flag = false;
 	bool cleaned = false;
-	u32 int_en;
 
 	pr_debug("budget : %d\n", budget);
 
@@ -2436,19 +2435,13 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 
 	if (poll_end_flag) {
 		napi_complete(napi);
-		if (adapter->rx_stop_flag) {
-			adapter->rx_stop_flag = false;
-			pch_gbe_start_receive(&adapter->hw);
-		}
 		pch_gbe_irq_enable(adapter);
-	} else
-		if (adapter->rx_stop_flag) {
-			adapter->rx_stop_flag = false;
-			pch_gbe_start_receive(&adapter->hw);
-			int_en = ioread32(&adapter->hw.reg->INT_EN);
-			iowrite32((int_en | PCH_GBE_INT_RX_FIFO_ERR),
-				&adapter->hw.reg->INT_EN);
-		}
+	}
+
+	if (adapter->rx_stop_flag) {
+		adapter->rx_stop_flag = false;
+		pch_gbe_start_receive(&adapter->hw);
+	}
 
 	pr_debug("poll_end_flag : %d  work_done : %d  budget : %d\n",
 		 poll_end_flag, work_done, budget);
-- 
1.7.1
