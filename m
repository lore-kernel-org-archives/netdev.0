From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/12] nfp: don't reuse pointers in ring dumping
Date: Fri, 18 Aug 2017 15:48:22 -0700
Message-ID: <20170818224822.8409-13-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32840 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdHRWte (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:34 -0400
Received: by mail-pg0-f50.google.com with SMTP id t3so44445964pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:34 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were reusing skb pointer when reading page frag, since ring
entries contain a union of a skb and frag pointer.  This can
be confusing to people reading the code.  Refactor the code
to read frag pointer directly.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 40217ece5fcb..cf81cf95d1d8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -125,7 +125,6 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 	struct nfp_net_tx_ring *tx_ring;
 	struct nfp_net_tx_desc *txd;
 	int d_rd_p, d_wr_p, txd_cnt;
-	struct sk_buff *skb;
 	struct nfp_net *nn;
 	int i;
 
@@ -158,13 +157,15 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 			   txd->vals[0], txd->vals[1],
 			   txd->vals[2], txd->vals[3]);
 
-		skb = READ_ONCE(tx_ring->txbufs[i].skb);
-		if (skb) {
-			if (tx_ring == r_vec->tx_ring)
+		if (tx_ring == r_vec->tx_ring) {
+			struct sk_buff *skb = READ_ONCE(tx_ring->txbufs[i].skb);
+
+			if (skb)
 				seq_printf(file, " skb->head=%p skb->data=%p",
 					   skb->head, skb->data);
-			else
-				seq_printf(file, " frag=%p", skb);
+		} else {
+			seq_printf(file, " frag=%p",
+				   READ_ONCE(tx_ring->txbufs[i].frag));
 		}
 
 		if (tx_ring->txbufs[i].dma_addr)
-- 
2.11.0
