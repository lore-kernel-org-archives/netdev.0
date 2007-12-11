From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [TCP]: fack_counts more fixes (the previous ones were incomplete)
Date: Tue, 11 Dec 2007 13:43:24 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712111339340.22872@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-829499223-1197373404=:22872"
Cc: Netdev <netdev@vger.kernel.org>,
	Reuben Farrelly <reuben-linuxkernel@reub.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55264 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbXLKLn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:43:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-829499223-1197373404=:22872
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Noticed later on that the things are still somewhat broken. Here's yet 
another fix to that same function. In addition, I'll do later on a patch 
to remove the __-version altogether.

-- 
 i.

--
[PATCH] [TCP]: fack_counts more fixes (the previous ones were incomplete)

1) Prev NULL check should also dereference

2) The loop reorganization did make things only slightly better,
   just changing the same not-updated problem to occur in
   another scenario. And I also noticed that in worst case it
   would be an infinite loop (could do that also before the
   change), but it required losses in the same window when TCP
   runs out new data. Now check really against the list heads
   rather than a valid skb which should still be processed.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 11a7e3e..2d9949e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1474,7 +1474,7 @@ static inline struct sk_buff *__tcp_reset_fack_counts(struct sock *sk,
 {
 	unsigned int fc = 0;
 
-	if (prev != NULL)
+	if (*prev != NULL)
 		fc = TCP_SKB_CB(*prev)->fack_count + tcp_skb_pcount(*prev);
 
 	BUG_ON((*prev != NULL) && !tcp_skb_adjacent(sk, *prev, skb));
@@ -1531,7 +1531,7 @@ static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *inskb)
 		skb[otherq] = prev->next;
 	}
 
-	do {
+	while (skb[queue] != (struct sk_buff *)__tcp_list_select(sk, queue)) {
 		/* Lazy find for the other queue */
 		if (skb[queue] == NULL) {
 			skb[queue] = tcp_write_queue_find(sk, TCP_SKB_CB(prev)->seq,
@@ -1545,7 +1545,7 @@ static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *inskb)
 			break;
 
 		queue ^= TCP_WQ_SACKED;
-	} while (skb[queue] != __tcp_write_queue_tail(sk, queue));
+	}
 }
 
 static inline void __tcp_insert_write_queue_after(struct sk_buff *skb,
-- 
1.5.0.6

---696243703-829499223-1197373404=:22872--
