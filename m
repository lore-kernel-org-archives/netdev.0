From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.24-rc4-mm1
Date: Mon, 10 Dec 2007 14:24:31 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712101136190.18529@kivilampi-30.cs.helsinki.fi>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
 <47579DD9.9030909@reub.net> <20071205233504.67366c5b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1118666943-1197288931=:18529"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Reuben Farrelly <reuben-linuxkernel@reub.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50569 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbXLJMYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 07:24:34 -0500
In-Reply-To: <20071205233504.67366c5b.akpm@linux-foundation.org>
Content-ID: <Pine.LNX.4.64.0712101424090.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1118666943-1197288931=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712101424091.18529@kivilampi-30.cs.helsinki.fi>

On Wed, 5 Dec 2007, Andrew Morton wrote:

> On Thu, 06 Dec 2007 17:59:37 +1100 Reuben Farrelly <reuben-linuxkernel@reub.net> wrote:
> 
> > This non fatal oops which I have just noticed may be related to this change then 
> > - certainly looks networking related.
> 
> yep, but it isn't e1000.  It's core TCP.
> 
> > WARNING: at net/ipv4/tcp_input.c:2518 tcp_fastretrans_alert()
> > Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #1
> 
> Ilpo, Reuben's kernel is talking to you ;)

...Please try the patch below. Andrew, this probably fixes your problem 
(the packets <= tp->packets_out) as well.

Dave, please include this one to net-2.6.25.


-- 
 i.

--
[PATCH] [TCP]: Fix fack_count miscountings (multiple places)

1) Fack_count is set incorrectly if the highest sent skb is
already sacked (the skb->prev won't return it because it's on
the other list already). These manifest as fackets_out counting
error later on, the second-order effects are very hard to track,
so it may fix all out-standing TCP bug reports.

2) Prev == NULL check was wrong way around

3) Last skb's fack count was incorrectly skipped while() {} loop

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9dbed0b..11a7e3e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1337,10 +1337,20 @@ static inline struct sk_buff *tcp_send_head(struct sock *sk)
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
 	struct sk_buff *prev = tcp_write_queue_prev(sk, skb);
+	unsigned int fc = 0;
+
+	if (prev == (struct sk_buff *)&sk->sk_write_queue)
+		prev = NULL;
+	else if (!tcp_skb_adjacent(sk, prev, skb))
+		prev = NULL;
 
-	if (prev != (struct sk_buff *)&sk->sk_write_queue)
-		TCP_SKB_CB(skb)->fack_count = TCP_SKB_CB(prev)->fack_count +
-					      tcp_skb_pcount(prev);
+	if ((prev == NULL) && !__tcp_write_queue_empty(sk, TCP_WQ_SACKED))
+		prev = __tcp_write_queue_tail(sk, TCP_WQ_SACKED);
+
+	if (prev != NULL)
+		fc = TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
+
+	TCP_SKB_CB(skb)->fack_count = fc;
 
 	sk->sk_send_head = tcp_write_queue_next(sk, skb);
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
@@ -1464,7 +1474,7 @@ static inline struct sk_buff *__tcp_reset_fack_counts(struct sock *sk,
 {
 	unsigned int fc = 0;
 
-	if (prev == NULL)
+	if (prev != NULL)
 		fc = TCP_SKB_CB(*prev)->fack_count + tcp_skb_pcount(*prev);
 
 	BUG_ON((*prev != NULL) && !tcp_skb_adjacent(sk, *prev, skb));
@@ -1521,7 +1531,7 @@ static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *inskb)
 		skb[otherq] = prev->next;
 	}
 
-	while (skb[queue] != __tcp_write_queue_tail(sk, queue)) {
+	do {
 		/* Lazy find for the other queue */
 		if (skb[queue] == NULL) {
 			skb[queue] = tcp_write_queue_find(sk, TCP_SKB_CB(prev)->seq,
@@ -1535,7 +1545,7 @@ static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *inskb)
 			break;
 
 		queue ^= TCP_WQ_SACKED;
-	}
+	} while (skb[queue] != __tcp_write_queue_tail(sk, queue));
 }
 
 static inline void __tcp_insert_write_queue_after(struct sk_buff *skb,
-- 
1.5.0.6
---696243703-1118666943-1197288931=:18529--
