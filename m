From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] bnx2x: fix rx checksum validation for IPv6
Date: Fri, 14 Sep 2012 00:59:44 +0200
Message-ID: <1347577184-8417-1-git-send-email-mschmidt@redhat.com>
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Eric Dumazet <edumazet@google.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Robert Evans <evansr@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663Ab2IMW7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 18:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d6cb3e41 "bnx2x: fix checksum validation" caused a performance
regression for IPv6. Rx checksum offload does not work. IPv6 packets
are passed to the stack with CHECKSUM_NONE.

The hardware obviously cannot perform IP checksum validation for IPv6,
because there is no checksum in the IPv6 header. This should not prevent
us from setting CHECKSUM_UNNECESSARY.

Tested on BCM57711.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index af20c6e..e8e97a7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -662,14 +662,16 @@ void bnx2x_csum_validate(struct sk_buff *skb, union eth_rx_cqe *cqe,
 				 struct bnx2x_fastpath *fp,
 				 struct bnx2x_eth_q_stats *qstats)
 {
-	/* Do nothing if no IP/L4 csum validation was done */
-
+	/* Do nothing if no L4 csum validation was done.
+	 * We do not check whether IP csum was validated. For IPv4 we assume
+	 * that if the card got as far as validating the L4 csum, it also
+	 * validated the IP csum. IPv6 has no IP csum.
+	 */
 	if (cqe->fast_path_cqe.status_flags &
-	    (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG |
-	     ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG))
+	    ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)
 		return;
 
-	/* If both IP/L4 validation were done, check if an error was found. */
+	/* If L4 validation was done, check if an error was found. */
 
 	if (cqe->fast_path_cqe.type_error_flags &
 	    (ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG |
-- 
1.7.11.4
