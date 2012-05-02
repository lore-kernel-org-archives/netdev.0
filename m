From: Jason Wang <jasowang@redhat.com>
Subject: [V2 PATCH 2/9] macvtap: zerocopy: fix truesize underestimation
Date: Wed, 02 May 2012 11:41:44 +0800
Message-ID: <20120502034144.11782.88947.stgit@amd-6168-8-1.englab.nay.redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the skb fragment were pinned/built from user pages, we should
account the page instead of length for truesize.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index bd4a70d..7cb2684 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -519,6 +519,7 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		struct page *page[MAX_SKB_FRAGS];
 		int num_pages;
 		unsigned long base;
+		unsigned long truesize;
 
 		len = from->iov_len - offset;
 		if (!len) {
@@ -533,10 +534,11 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
 			/* put_page is in skb free */
 			return -EFAULT;
+		truesize = size * PAGE_SIZE;
 		skb->data_len += len;
 		skb->len += len;
-		skb->truesize += len;
-		atomic_add(len, &skb->sk->sk_wmem_alloc);
+		skb->truesize += truesize;
+		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
 		while (len) {
 			int off = base & ~PAGE_MASK;
 			int size = min_t(int, len, PAGE_SIZE - off);
