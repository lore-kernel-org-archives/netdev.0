From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/6] nfp: avoid reading TX queue indexes from the device
Date: Thu, 27 Apr 2017 21:06:18 -0700
Message-ID: <20170428040620.8256-5-jakub.kicinski@netronome.com>
References: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35636 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751285AbdD1EHB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 00:07:01 -0400
Received: by mail-pg0-f50.google.com with SMTP id o3so3018199pgn.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 21:07:01 -0700 (PDT)
In-Reply-To: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading TX queue indexes from the device memory on each interrupt
is expensive.  It's doubly expensive with XDP running since we have
two TX rings to check there.  If the software indexes indicate that
the TX queue is completely empty, however, we don't need to look at
the device completion index at all.

The queuing CPU is doing a wmb() before kicking the device TX so
we should be safe to assume on the CPU handling the completions will
never see old value of the software copy of the index.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 4fbda0eb4776..c763a5b3bd6b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -927,6 +927,9 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 	int fidx;
 	int idx;
 
+	if (tx_ring->wr_p == tx_ring->rd_p)
+		return;
+
 	/* Work out how many descriptors have been transmitted */
 	qcp_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
 
@@ -1001,6 +1004,9 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 	int idx, todo;
 	u32 qcp_rd_p;
 
+	if (tx_ring->wr_p == tx_ring->rd_p)
+		return;
+
 	/* Work out how many descriptors have been transmitted */
 	qcp_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
 
-- 
2.11.0
