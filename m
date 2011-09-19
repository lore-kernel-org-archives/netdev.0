From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] macvtap: fix the uninitialized var using in
	macvtap_alloc_skb()
Date: Mon, 19 Sep 2011 17:48:31 +0800
Message-ID: <20110919094830.6272.40503.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, mst@redhat.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit d1b08284 use new frag API but would leave f to be used
uninitialized, this patch fix it.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7c3f84a..3da5578 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -453,7 +453,6 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 	int copy = skb_headlen(skb);
 	int size, offset1 = 0;
 	int i = 0;
-	skb_frag_t *f;
 
 	/* Skip over from offset */
 	while (count && (offset >= from->iov_len)) {
@@ -503,14 +502,13 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		skb->truesize += len;
 		atomic_add(len, &skb->sk->sk_wmem_alloc);
 		while (len) {
-			__skb_fill_page_desc(
-				skb, i, page[i],
-				base & ~PAGE_MASK,
-				min_t(int, len, PAGE_SIZE - f->page_offset));
+			int off = base & ~PAGE_MASK;
+			int size = min_t(int, len, PAGE_SIZE - off);
+			__skb_fill_page_desc(skb, i, page[i], off, size);
 			skb_shinfo(skb)->nr_frags++;
 			/* increase sk_wmem_alloc */
-			base += f->size;
-			len -= f->size;
+			base += size;
+			len -= size;
 			i++;
 		}
 		offset1 = 0;
