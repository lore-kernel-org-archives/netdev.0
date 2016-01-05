From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv2 net-next 4/4] nfp: fix RX buffer length validation
Date: Tue,  5 Jan 2016 11:57:31 +0000
Message-ID: <1451995051-21920-5-git-send-email-jakub.kicinski@netronome.com>
References: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34990 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbcAEL5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 06:57:41 -0500
Received: by mail-wm0-f48.google.com with SMTP id f206so20033131wmf.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 03:57:40 -0800 (PST)
In-Reply-To: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meaning of data_len and meta_len RX WB descriptor fields depend
slightly on whether rx_offset is dynamic or not.  For dynamic
offsets data_len includes mata_len.  This makes the code harder
to follow, in fact our RX buffer length check is incorrect -
we are comparing allocation length to data_len while we should
also account for meta_len.

Let's adjust the values of data_len and meta_len to their natural
meaning and simplify the logic.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 553ae64e2f7f..070645f9bc21 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1259,22 +1259,19 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		meta_len = rxd->rxd.meta_len_dd & PCIE_DESC_RX_META_LEN_MASK;
 		data_len = le16_to_cpu(rxd->rxd.data_len);
+		/* For dynamic offset data_len includes meta_len, adjust */
+		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
+			data_len -= meta_len;
+		else
+			meta_len = nn->rx_offset;
 
-		if (WARN_ON_ONCE(data_len > nn->fl_bufsz)) {
+		if (WARN_ON_ONCE(meta_len + data_len > nn->fl_bufsz)) {
 			dev_kfree_skb_any(skb);
 			continue;
 		}
 
-		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC) {
-			/* The packet data starts after the metadata */
-			skb_reserve(skb, meta_len);
-		} else {
-			/* The packet data starts at a fixed offset */
-			skb_reserve(skb, nn->rx_offset);
-		}
-
-		/* Adjust the SKB for the dynamic meta data pre-pended */
-		skb_put(skb, data_len - meta_len);
+		skb_reserve(skb, meta_len);
+		skb_put(skb, data_len);
 
 		nfp_net_set_hash(nn->netdev, skb, rxd);
 
-- 
1.9.1
