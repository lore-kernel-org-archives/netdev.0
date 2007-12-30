From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 2/4] [CORE]: adding memory accounting points
Date: Sun, 30 Dec 2007 03:51:44 -0500
Message-ID: <47775C20.5010004@redhat.com>
References: <47775B25.7020401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net,
	Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	vladislav.yasevich@hp.com, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988AbXL3I7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 03:59:47 -0500
In-Reply-To: <47775B25.7020401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To consolidate memory accounting functions, this patch adds memory
accounting calls to network core functions. Moreover, present
memory accounting call is renamed to new accounting call.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Cc: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/sock.h  |    3 ++-
 net/core/datagram.c |    2 ++
 net/core/sock.c     |    7 +++++++
 net/core/stream.c   |    2 +-
 4 files changed, 12 insertions(+), 2 deletions(-)

diff -pruN net-2.6.25-t12t19m-p1/include/net/sock.h net-2.6.25-t12t19m-p2/include/net/sock.h
--- net-2.6.25-t12t19m-p1/include/net/sock.h	2007-12-29 20:16:31.000000000 -0500
+++ net-2.6.25-t12t19m-p2/include/net/sock.h	2007-12-29 20:28:15.000000000 -0500
@@ -1116,7 +1116,7 @@ static inline int skb_copy_to_page(struc
 	skb->data_len	     += copy;
 	skb->truesize	     += copy;
 	sk->sk_wmem_queued   += copy;
-	sk->sk_forward_alloc -= copy;
+	sk_mem_charge(sk, copy);
 	return 0;
 }

@@ -1142,6 +1142,7 @@ static inline void skb_set_owner_r(struc
 	skb->sk = sk;
 	skb->destructor = sock_rfree;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+	sk_mem_charge(sk, skb->truesize);
 }

 extern void sk_reset_timer(struct sock *sk, struct timer_list* timer,
diff -pruN net-2.6.25-t12t19m-p1/net/core/datagram.c net-2.6.25-t12t19m-p2/net/core/datagram.c
--- net-2.6.25-t12t19m-p1/net/core/datagram.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p2/net/core/datagram.c	2007-12-29 20:28:15.000000000 -0500
@@ -209,6 +209,7 @@ struct sk_buff *skb_recv_datagram(struct
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
 {
 	kfree_skb(skb);
+	sk_mem_reclaim(sk);
 }

 /**
@@ -248,6 +249,7 @@ int skb_kill_datagram(struct sock *sk, s
 	}

 	kfree_skb(skb);
+	sk_mem_reclaim(sk);
 	return err;
 }

diff -pruN net-2.6.25-t12t19m-p1/net/core/sock.c net-2.6.25-t12t19m-p2/net/core/sock.c
--- net-2.6.25-t12t19m-p1/net/core/sock.c	2007-12-29 20:16:31.000000000 -0500
+++ net-2.6.25-t12t19m-p2/net/core/sock.c	2007-12-29 20:28:15.000000000 -0500
@@ -282,6 +282,11 @@ int sock_queue_rcv_skb(struct sock *sk,
 	if (err)
 		goto out;

+	if (!sk_rmem_schedule(sk, skb->truesize)) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
 	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);

@@ -1107,7 +1112,9 @@ void sock_rfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;

+	skb_truesize_check(skb);
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+	sk_mem_uncharge(skb->sk, skb->truesize);
 }


diff -pruN net-2.6.25-t12t19m-p1/net/core/stream.c net-2.6.25-t12t19m-p2/net/core/stream.c
--- net-2.6.25-t12t19m-p1/net/core/stream.c	2007-12-29 20:16:31.000000000 -0500
+++ net-2.6.25-t12t19m-p2/net/core/stream.c	2007-12-29 20:28:15.000000000 -0500
@@ -195,7 +195,7 @@ void sk_stream_kill_queues(struct sock *
 	BUG_TRAP(skb_queue_empty(&sk->sk_write_queue));

 	/* Account for returned memory. */
-	sk_stream_mem_reclaim(sk);
+	sk_mem_reclaim(sk);

 	BUG_TRAP(!sk->sk_wmem_queued);
 	BUG_TRAP(!sk->sk_forward_alloc);
-- 
Hitachi Computer Products (America) Inc.
