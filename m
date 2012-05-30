From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] net: sock: validate data_len before allocating skb in
 sock_alloc_send_pskb()
Date: Wed, 30 May 2012 13:47:02 +0800
Message-ID: <20120530054702.6146.8503.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, mst@redhat.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754718Ab2E3Fwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 01:52:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to validate the number of pages consumed by data_len, otherwise frags
array could be overflowed by userspace. So this patch validate data_len and
return -EMSGSIZE when data_len may occupies more frags than MAX_SKB_FRAGS.

Cc: stable@vger.kernel.org [2.6.27+]
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/core/sock.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 653f8c0..4ad5fa5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1599,6 +1599,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 
 	timeo = sock_sndtimeo(sk, noblock);
 	while (1) {
+		int npages;
 		err = sock_error(sk);
 		if (err != 0)
 			goto failure;
@@ -1607,17 +1608,20 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		if (sk->sk_shutdown & SEND_SHUTDOWN)
 			goto failure;
 
+		err = -EMSGSIZE;
+		npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
+		if (npages > MAX_SKB_FRAGS)
+			goto failure;
+
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
