From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] iwlwifi: fix skb truesize underestimation
Date: Fri, 23 Mar 2012 17:05:47 -0700
Message-ID: <1332547547.2516.132.camel@edumazet-glaptop>
References: <1332507112.4858.12.camel@edumazet-laptop>
	 <20120323.143826.1042705555491529895.davem@davemloft.net>
	 <1332528919.2516.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wey-yi.w.guy@intel.com,
	Neal Cardwell <ncardwell@google.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57548 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480Ab2CXAFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 20:05:50 -0400
Received: by iagz16 with SMTP id z16so5335720iag.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 17:05:50 -0700 (PDT)
In-Reply-To: <1332528919.2516.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, iwlwifi uses order-1 pages (8 KB) to store incoming frames,
but doesnt say so in skb->truesize.

This makes very possible to exhaust kernel memory since these skb evade
normal socket memory accounting.

As struct ieee80211_hdr is going to be pulled before calling IP stack,
there is no need to use dev_alloc_skb() to reserve NET_SKB_PAD bytes.
alloc_skb() is ok in this driver, allowing more tailroom.

Pull beginning of frame in skb header, in the hope we can reuse order-1
pages in the driver immediately for small frames and reduce their
truesize to the minimum (linear skbs)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
Depends on the "net: add a truesize parameter to skb_add_rx_frag()"
prior patch.

 drivers/net/wireless/iwlwifi/iwl-agn-rx.c        |   25 ++++++++-----
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c |    3 +
 drivers/net/wireless/iwlwifi/iwl-trans.h         |    1 
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
index f4b84d1..9ecd768f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
@@ -773,8 +773,7 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 	struct sk_buff *skb;
 	__le16 fc = hdr->frame_control;
 	struct iwl_rxon_context *ctx;
-	struct page *p;
-	int offset;
+	unsigned int hdrlen;
 
 	/* We only process data packets if the interface is open */
 	if (unlikely(!priv->is_open)) {
@@ -788,16 +787,24 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 	    iwlagn_set_decrypted_flag(priv, hdr, ampdu_status, stats))
 		return;
 
-	skb = dev_alloc_skb(128);
+	/* Dont use dev_alloc_skb(), we'll have enough headroom once
+	 * ieee80211_hdr pulled.
+	 */
+	skb = alloc_skb(128);
 	if (!skb) {
-		IWL_ERR(priv, "dev_alloc_skb failed\n");
+		IWL_ERR(priv, "alloc_skb failed\n");
 		return;
 	}
-
-	offset = (void *)hdr - rxb_addr(rxb);
-	p = rxb_steal_page(rxb);
-	skb_add_rx_frag(skb, 0, p, offset, len, len);
-
+	hdrlen = min_t(unsigned int, len, skb_tailroom(skb));
+	memcpy(skb_put(skb, hdrlen), hdr, hdrlen);
+	len -= hdrlen;
+
+	if (len) {
+		int offset = (void *)hdr + hdrlen - rxb_addr(rxb);
+ 
+		skb_add_rx_frag(skb, 0, rxb_steal_page(rxb), offset,
+				len, rxb->truesize);
+	}
 	iwl_update_stats(priv, false, fc, len);
 
 	/*
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
index 8b1a798..aa7aea1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
@@ -374,8 +374,9 @@ static void iwl_rx_handle_rxbuf(struct iwl_trans *trans,
 	if (WARN_ON(!rxb))
 		return;
 
+	rxcb.truesize = PAGE_SIZE << hw_params(trans).rx_page_order;
 	dma_unmap_page(trans->dev, rxb->page_dma,
-		       PAGE_SIZE << hw_params(trans).rx_page_order,
+		       rxcb.truesize,
 		       DMA_FROM_DEVICE);
 
 	rxcb._page = rxb->page;
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.h b/drivers/net/wireless/iwlwifi/iwl-trans.h
index 0c81cba..fdf9788 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@ -260,6 +260,7 @@ static inline void iwl_free_resp(struct iwl_host_cmd *cmd)
 
 struct iwl_rx_cmd_buffer {
 	struct page *_page;
+	unsigned int truesize;
 };
 
 static inline void *rxb_addr(struct iwl_rx_cmd_buffer *r)
