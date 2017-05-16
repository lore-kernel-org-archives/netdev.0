From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 9/9] nfp: eliminate an if statement in calculation of completed frames
Date: Mon, 15 May 2017 17:55:23 -0700
Message-ID: <20170516005523.26124-10-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35781 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdEPA4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:30 -0400
Received: by mail-pf0-f181.google.com with SMTP id n23so66333489pfb.2
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:30 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given that our rings are always a power of 2, we can simplify the
calculation of number of completed TX descriptors by using masking
instead of if statement based on whether the index have wrapped
or not.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c64514f8ee65..da83e17b8b20 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -940,10 +940,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 	if (qcp_rd_p == tx_ring->qcp_rd_p)
 		return;
 
-	if (qcp_rd_p > tx_ring->qcp_rd_p)
-		todo = qcp_rd_p - tx_ring->qcp_rd_p;
-	else
-		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
+	todo = D_IDX(tx_ring, qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p);
 
 	while (todo--) {
 		idx = D_IDX(tx_ring, tx_ring->rd_p++);
@@ -1014,10 +1011,7 @@ static bool nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 	if (qcp_rd_p == tx_ring->qcp_rd_p)
 		return true;
 
-	if (qcp_rd_p > tx_ring->qcp_rd_p)
-		todo = qcp_rd_p - tx_ring->qcp_rd_p;
-	else
-		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
+	todo = D_IDX(tx_ring, qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p);
 
 	done_all = todo <= NFP_NET_XDP_MAX_COMPLETE;
 	todo = min(todo, NFP_NET_XDP_MAX_COMPLETE);
-- 
2.11.0
