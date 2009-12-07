From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC, PATCH] net: sock_queue_err_skb() and sk_forward_alloc corruption
Date: Mon, 07 Dec 2009 23:32:16 +0100
Message-ID: <4B1D8270.20308@gmail.com>
References: <20091207090154.6bbfe8e2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42799 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935606AbZLGWcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 17:32:13 -0500
In-Reply-To: <20091207090154.6bbfe8e2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While investigating on sk_forward_alloc corruptions, I found two problems :

1) skb_tstamp_tx() is calling sock_queue_err_skb().

This is not good as is, because we need sock lock
before calling sock_queue_err_skb().

Problem is skb_tstamp_rx() wont be able to lock sock...

skb_tstamp_rx() ->
	sock_queue_err_skb() ->
		sk_mem_charge(sk, skb->truesize) -> // PROBLEM :
			sk->sk_forward_alloc -= size; // MUST BE PROTECTED


2) UDP (again) sk_forward_alloc corruption 

__udp4_lib_err ->
	if (inet->recverr)
		ip_icmp_error() ->
			sock_queue_err_skb() // PROBLEM


Oh well...

I wonder if we could use a special version of skb_set_owner_r()/sock_rfree()
*without* sk_mem_charge()/sk_mem_uncharge() calls for this error queue.

(We dont call sk_rmem_schedule() anyway, so I guess current usage is not correct,
even with sock locked ?)

Something like this (untested but compiled) patch ?

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |   11 ++++++++++-
 net/core/sock.c    |    8 ++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3f1a480..76277ce 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -961,6 +961,7 @@ extern struct sk_buff		*sock_rmalloc(struct sock *sk,
 					      gfp_t priority);
 extern void			sock_wfree(struct sk_buff *skb);
 extern void			sock_rfree(struct sk_buff *skb);
+extern void			sock_nocharge_rfree(struct sk_buff *skb);
 
 extern int			sock_setsockopt(struct socket *sock, int level,
 						int op, char __user *optval,
@@ -1383,6 +1384,14 @@ static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	sk_mem_charge(sk, skb->truesize);
 }
 
+static inline void skb_set_owner_nocharge_r(struct sk_buff *skb, struct sock *sk)
+{
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = sock_nocharge_rfree;
+	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+}
+
 extern void sk_reset_timer(struct sock *sk, struct timer_list* timer,
 			   unsigned long expires);
 
@@ -1398,7 +1407,7 @@ static inline int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 	    (unsigned)sk->sk_rcvbuf)
 		return -ENOMEM;
-	skb_set_owner_r(skb, sk);
+	skb_set_owner_nocharge_r(skb, sk);
 	skb_queue_tail(&sk->sk_error_queue, skb);
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, skb->len);
diff --git a/net/core/sock.c b/net/core/sock.c
index 76ff58d..181a39a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1284,6 +1284,14 @@ void sock_rfree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_rfree);
 
+void sock_nocharge_rfree(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+}
+EXPORT_SYMBOL(sock_nocharge_rfree);
+
 
 int sock_i_uid(struct sock *sk)
 {
