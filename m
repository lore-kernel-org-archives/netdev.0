From: roy.qing.li@gmail.com
Subject: [PATCH net-next] cxgb3: Correct comparisons and calculations using skb->tail and skb-transport_header
Date: Tue,  4 Jun 2013 16:11:16 +0800
Message-ID: <1370333476-17699-1-git-send-email-roy.qing.li@gmail.com>
Cc: horms@verge.net.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36742 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab3FDILX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 04:11:23 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so811883pdj.0
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 01:11:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case skb->tail will be a pointer whereas skb->transport_header
will be an offset from head. This is corrected by using wrappers that
ensure that comparisons and calculations are always made using pointers.

Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 46d1efc..687ec4a 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1583,7 +1583,7 @@ static void deferred_unmap_destructor(struct sk_buff *skb)
 	dui = (struct deferred_unmap_info *)skb->head;
 	p = dui->addr;
 
-	if (skb->tail - skb->transport_header)
+	if (skb_tail_pointer(skb) - skb_transport_header(skb))
 		pci_unmap_single(dui->pdev, *p++, skb_tail_pointer(skb) -
 				 skb_transport_header(skb), PCI_DMA_TODEVICE);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 2bfbb20..ac311f5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1294,7 +1294,7 @@ static inline unsigned int calc_tx_flits_ofld(const struct sk_buff *skb)
 
 	flits = skb_transport_offset(skb) / 8U;   /* headers */
 	cnt = skb_shinfo(skb)->nr_frags;
-	if (skb->tail != skb->transport_header)
+	if (skb_tail_pointer(skb) != skb_transport_header(skb))
 		cnt++;
 	return flits + sgl_len(cnt);
 }
-- 
1.7.10.4
