From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: hns: avoid uninitialized variable warning:
Date: Fri, 01 Jan 2016 23:27:57 +0100
Message-ID: <6649249.INrAY8KJG0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yisen Zhuang <yisen.zhuang@huawei.com>, yankejian@huawei.com,
	lisheng011@huawei.com, huangdaode@hisilicon.com,
	salil.mehta@huawei.com, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc fails to see that the use of the 'last_offset' variable
in hns_nic_reuse_page() is used correctly and issues a bogus
warning:

drivers/net/ethernet/hisilicon/hns/hns_enet.c: In function 'hns_nic_reuse_page':
drivers/net/ethernet/hisilicon/hns/hns_enet.c:541:6: warning: 'last_offset' may be used uninitialized in this function [-Wmaybe-uninitialized]

This simplifies the function to make it more obvious what is
going on to both readers and compilers, which makes the warning
go away.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Compile-tested only, and complex enough that this requires a proper
review and testing before it gets apply. Please have a look at this.

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 5a81dafd725e..0e30846a24f8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -499,50 +499,47 @@ static void hns_nic_reuse_page(struct sk_buff *skb, int i,
 	struct hnae_desc *desc;
 	int truesize, size;
 	int last_offset;
+	bool twobufs;
+
+	twobufs = ((PAGE_SIZE < 8192) && hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048);
 
 	desc = &ring->desc[ring->next_to_clean];
 	size = le16_to_cpu(desc->rx.size);
 
-#if (PAGE_SIZE < 8192)
-	if (hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048) {
+	if (twobufs) {
 		truesize = hnae_buf_size(ring);
 	} else {
 		truesize = ALIGN(size, L1_CACHE_BYTES);
 		last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
 	}
 
-#else
-	truesize = ALIGN(size, L1_CACHE_BYTES);
-	last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
-#endif
-
 	skb_add_rx_frag(skb, i, desc_cb->priv, desc_cb->page_offset + pull_len,
 			size - pull_len, truesize - pull_len);
 
 	 /* avoid re-using remote pages,flag default unreuse */
-	if (likely(page_to_nid(desc_cb->priv) == numa_node_id())) {
-#if (PAGE_SIZE < 8192)
-		if (hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048) {
-			/* if we are only owner of page we can reuse it */
-			if (likely(page_count(desc_cb->priv) == 1)) {
-				/* flip page offset to other buffer */
-				desc_cb->page_offset ^= truesize;
-
-				desc_cb->reuse_flag = 1;
-				/* bump ref count on page before it is given*/
-				get_page(desc_cb->priv);
-			}
-			return;
-		}
-#endif
-		/* move offset up to the next cache line */
-		desc_cb->page_offset += truesize;
+	if (unlikely(page_to_nid(desc_cb->priv) != numa_node_id()))
+		return;
+
+	if (twobufs) {
+		/* if we are only owner of page we can reuse it */
+		if (likely(page_count(desc_cb->priv) == 1)) {
+			/* flip page offset to other buffer */
+			desc_cb->page_offset ^= truesize;
 
-		if (desc_cb->page_offset <= last_offset) {
 			desc_cb->reuse_flag = 1;
 			/* bump ref count on page before it is given*/
 			get_page(desc_cb->priv);
 		}
+		return;
+	}
+
+	/* move offset up to the next cache line */
+	desc_cb->page_offset += truesize;
+
+	if (desc_cb->page_offset <= last_offset) {
+		desc_cb->reuse_flag = 1;
+		/* bump ref count on page before it is given*/
+		get_page(desc_cb->priv);
 	}
 }
 
