From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/9] nfp: rename l4_offset in struct nfp_net_tx_desc to lso_hdrlen
Date: Mon, 15 May 2017 17:55:16 -0700
Message-ID: <20170516005523.26124-3-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, Edwin Peer <edwin.peer@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33645 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbdEPA4T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:19 -0400
Received: by mail-pf0-f175.google.com with SMTP id e193so71263351pfh.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:19 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edwin Peer <edwin.peer@netronome.com>

The l4_offset field referred to by NFD is confusingly named. It is not the
offset of the L4 transport header, but rather the L4 payload.

The LSO2 capability supported by alternative device firmware requires
the actual L4 offset, thus the rename seems prudent.

Signed-off-by: Edwin Peer <edwin.peer@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index fcf81b3be830..6bad11e5b845 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -153,7 +153,7 @@ struct nfp_net_tx_desc {
 			__le32 dma_addr_lo; /* Low 32bit of host buf addr */
 
 			__le16 mss;	/* MSS to be used for LSO */
-			u8 l4_offset;	/* LSO, where the L4 data starts */
+			u8 lso_hdrlen;	/* LSO, TCP payload offset */
 			u8 flags;	/* TX Flags, see @PCIE_DESC_TX_* */
 
 			__le16 vlan;	/* VLAN tag to add if indicated */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 76251a09a1f3..0cebe9098451 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -677,7 +677,7 @@ static void nfp_net_tx_tso(struct nfp_net_r_vector *r_vec,
 	txbuf->real_len += hdrlen * (txbuf->pkt_cnt - 1);
 
 	mss = skb_shinfo(skb)->gso_size & PCIE_DESC_TX_MSS_MASK;
-	txd->l4_offset = hdrlen;
+	txd->lso_hdrlen = hdrlen;
 	txd->mss = cpu_to_le16(mss);
 	txd->flags |= PCIE_DESC_TX_LSO;
 
@@ -823,7 +823,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 
 	txd->flags = 0;
 	txd->mss = 0;
-	txd->l4_offset = 0;
+	txd->lso_hdrlen = 0;
 
 	nfp_net_tx_tso(r_vec, txbuf, txd, skb);
 
@@ -1515,7 +1515,7 @@ nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 
 	txd->flags = 0;
 	txd->mss = 0;
-	txd->l4_offset = 0;
+	txd->lso_hdrlen = 0;
 
 	tx_ring->wr_p++;
 	tx_ring->wr_ptr_add++;
-- 
2.11.0
