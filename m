From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/6] bpf, ixgbe: add meta data support
Date: Mon, 25 Sep 2017 02:25:55 +0200
Message-ID: <111d95035f7cee64abab545c98e56c3013cb4979.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37246 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933078AbdIYA1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 20:27:08 -0400
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement support for transferring XDP meta data into skb for
ixgbe driver; before calling into the program, xdp.data_meta points
to xdp.data, where on program return with pass verdict, we call
into skb_metadata_set().

We implement this for the default ixgbe_build_skb() variant. For the
ixgbe_construct_skb() that is used when legacy-rx buffer mananagement
mode is turned on via ethtool, I found that XDP gets 0 headroom, so
neither xdp_adjust_head() nor xdp_adjust_meta() can be used with this.
Just add a comment with explanation for this operating mode.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 30 +++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 04bb03b..3942c62 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2133,6 +2133,21 @@ static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 #if L1_CACHE_BYTES < 128
 	prefetch(xdp->data + L1_CACHE_BYTES);
 #endif
+	/* Note, we get here by enabling legacy-rx via:
+	 *
+	 *    ethtool --set-priv-flags <dev> legacy-rx on
+	 *
+	 * In this mode, we currently get 0 extra XDP headroom as
+	 * opposed to having legacy-rx off, where we process XDP
+	 * packets going to stack via ixgbe_build_skb(). The latter
+	 * provides us currently with 192 bytes of headroom.
+	 *
+	 * For ixgbe_construct_skb() mode it means that the
+	 * xdp->data_meta will always point to xdp->data, since
+	 * the helper cannot expand the head. Should this ever
+	 * change in future for legacy-rx mode on, then lets also
+	 * add xdp->data_meta handling here.
+	 */
 
 	/* allocate a skb to store the frags */
 	skb = napi_alloc_skb(&rx_ring->q_vector->napi, IXGBE_RX_HDR_SIZE);
@@ -2165,6 +2180,7 @@ static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
 				       struct xdp_buff *xdp,
 				       union ixgbe_adv_rx_desc *rx_desc)
 {
+	unsigned int metasize = xdp->data - xdp->data_meta;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
@@ -2174,10 +2190,14 @@ static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
 #endif
 	struct sk_buff *skb;
 
-	/* prefetch first cache line of first page */
-	prefetch(xdp->data);
+	/* Prefetch first cache line of first page. If xdp->data_meta
+	 * is unused, this points extactly as xdp->data, otherwise we
+	 * likely have a consumer accessing first few bytes of meta
+	 * data, and then actual data.
+	 */
+	prefetch(xdp->data_meta);
 #if L1_CACHE_BYTES < 128
-	prefetch(xdp->data + L1_CACHE_BYTES);
+	prefetch(xdp->data_meta + L1_CACHE_BYTES);
 #endif
 
 	/* build an skb to around the page buffer */
@@ -2188,6 +2208,8 @@ static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
 	/* update pointers within the skb to store the data */
 	skb_reserve(skb, xdp->data - xdp->data_hard_start);
 	__skb_put(skb, xdp->data_end - xdp->data);
+	if (metasize)
+		skb_metadata_set(skb, metasize);
 
 	/* record DMA address if this is the start of a chain of buffers */
 	if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
@@ -2326,7 +2348,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (!skb) {
 			xdp.data = page_address(rx_buffer->page) +
 				   rx_buffer->page_offset;
-			xdp_set_data_meta_invalid(&xdp);
+			xdp.data_meta = xdp.data;
 			xdp.data_hard_start = xdp.data -
 					      ixgbe_rx_offset(rx_ring);
 			xdp.data_end = xdp.data + size;
-- 
1.9.3
