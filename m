From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3 net-next] tg3: Fix jumbo loopback test on 5719
Date: Sun, 4 Mar 2012 16:48:13 -0800
Message-ID: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1876 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754964Ab2CEApa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 19:45:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Loopback on 9K packet fails because the chip has a DMA limit of 4K.  The
loopback test logic uses a single BD for simplicity.  Fix it by reducing
the jumbo packet size to the DMA limit.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 76f33d5..4b3243b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11727,6 +11727,10 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 	} else {
 		num_pkts = 1;
 		data_off = ETH_HLEN;
+
+		if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
+		    tx_len > VLAN_ETH_FRAME_LEN)
+			base_flags |= TXD_FLAG_JMB_PKT;
 	}
 
 	for (i = data_off; i < tx_len; i++)
@@ -11857,6 +11861,10 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 {
 	int err = -EIO;
 	u32 eee_cap;
+	u32 jmb_pkt_sz = 9000;
+
+	if (tp->dma_limit)
+		jmb_pkt_sz = tp->dma_limit - ETH_HLEN;
 
 	eee_cap = tp->phy_flags & TG3_PHYFLG_EEE_CAP;
 	tp->phy_flags &= ~TG3_PHYFLG_EEE_CAP;
@@ -11900,7 +11908,7 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 			data[0] |= TG3_STD_LOOPBACK_FAILED;
 
 		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
-		    tg3_run_loopback(tp, 9000 + ETH_HLEN, false))
+		    tg3_run_loopback(tp, jmb_pkt_sz + ETH_HLEN, false))
 			data[0] |= TG3_JMB_LOOPBACK_FAILED;
 
 		tg3_mac_loopback(tp, false);
@@ -11925,7 +11933,7 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 		    tg3_run_loopback(tp, ETH_FRAME_LEN, true))
 			data[1] |= TG3_TSO_LOOPBACK_FAILED;
 		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
-		    tg3_run_loopback(tp, 9000 + ETH_HLEN, false))
+		    tg3_run_loopback(tp, jmb_pkt_sz + ETH_HLEN, false))
 			data[1] |= TG3_JMB_LOOPBACK_FAILED;
 
 		if (do_extlpbk) {
@@ -11943,7 +11951,7 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 			    tg3_run_loopback(tp, ETH_FRAME_LEN, true))
 				data[2] |= TG3_TSO_LOOPBACK_FAILED;
 			if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
-			    tg3_run_loopback(tp, 9000 + ETH_HLEN, false))
+			    tg3_run_loopback(tp, jmb_pkt_sz + ETH_HLEN, false))
 				data[2] |= TG3_JMB_LOOPBACK_FAILED;
 		}
 
-- 
1.7.1
