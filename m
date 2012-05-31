From: Jason Wang <jasowang@redhat.com>
Subject: [V2 PATCH] net: sock: validate data_len before allocating skb in
 sock_alloc_send_pskb()
Date: Thu, 31 May 2012 15:18:10 +0800
Message-ID: <20120531071809.6392.26677.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org
To: netdev@vger.kernel.org, edumazet@google.com, mst@redhat.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to validate the number of pages consumed by data_len, otherwise frags
array could be overflowed by userspace. So this patch validate data_len and
return -EMSGSIZE when data_len may occupies more frags than MAX_SKB_FRAGS.

Cc: stable@vger.kernel.org [2.6.27+]
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/core/sock.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 653f8c0..9e5b71f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1592,6 +1592,11 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 	gfp_t gfp_mask;
 	long timeo;
 	int err;
+	int npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
+
+	err = -EMSGSIZE;
+	if (npages > MAX_SKB_FRAGS)
+		goto failure;
 
 	gfp_mask = sk->sk_allocation;
 	if (gfp_mask & __GFP_WAIT)
@@ -1610,14 +1615,12 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf) {
 			skb = alloc_skb(header_len, gfp_mask);
 			if (skb) {
-				int npages;
 				int i;
 
 				/* No pages, we're done... */
 				if (!data_len)
 					break;
 
-				npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
 				skb->truesize += data_len;
 				skb_shinfo(skb)->nr_frags = npages;
 				for (i = 0; i < npages; i++) {
