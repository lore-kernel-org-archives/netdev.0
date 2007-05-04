From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/40] netvm: prevent a TCP specific deadlock
Date: Fri, 04 May 2007 12:27:09 +0200
Message-ID: <20070504103159.616506817@chello.nl>
References: <20070504102651.923946304@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:31145 "EHLO
	amsfep13-int.chello.nl" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S2993226AbXEDKe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 06:34:59 -0400
Content-Disposition: inline; filename=netvm-tcp-deadlock.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It could happen that all !SOCK_VMIO sockets have buffered so much data
that we're over the global rmem limit. This will prevent SOCK_VMIO buffers
from receiving data, which will prevent userspace from running, which is needed
to reduce the buffered data.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h  |    7 ++++---
 net/core/stream.c   |    5 +++--
 net/ipv4/tcp_ipv4.c |    8 ++++++++
 net/ipv6/tcp_ipv6.c |    8 ++++++++
 4 files changed, 23 insertions(+), 5 deletions(-)

Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h	2007-02-14 12:09:05.000000000 +0100
+++ linux-2.6-git/include/net/sock.h	2007-02-14 12:09:21.000000000 +0100
@@ -730,7 +730,8 @@ static inline struct inode *SOCK_INODE(s
 }
 
 extern void __sk_stream_mem_reclaim(struct sock *sk);
-extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
+extern int sk_stream_mem_schedule(struct sock *sk, struct sk_buff *skb,
+		int size, int kind);
 
 #define SK_STREAM_MEM_QUANTUM ((int)PAGE_SIZE)
 
@@ -757,13 +758,13 @@ static inline void sk_stream_writequeue_
 static inline int sk_stream_rmem_schedule(struct sock *sk, struct sk_buff *skb)
 {
 	return (int)skb->truesize <= sk->sk_forward_alloc ||
-		sk_stream_mem_schedule(sk, skb->truesize, 1);
+		sk_stream_mem_schedule(sk, skb, skb->truesize, 1);
 }
 
 static inline int sk_stream_wmem_schedule(struct sock *sk, int size)
 {
 	return size <= sk->sk_forward_alloc ||
-	       sk_stream_mem_schedule(sk, size, 0);
+	       sk_stream_mem_schedule(sk, NULL, size, 0);
 }
 
 /* Used by processes to "lock" a socket state, so that
Index: linux-2.6-git/net/core/stream.c
===================================================================
--- linux-2.6-git.orig/net/core/stream.c	2007-02-14 12:09:05.000000000 +0100
+++ linux-2.6-git/net/core/stream.c	2007-02-14 12:09:21.000000000 +0100
@@ -207,7 +207,7 @@ void __sk_stream_mem_reclaim(struct sock
 
 EXPORT_SYMBOL(__sk_stream_mem_reclaim);
 
-int sk_stream_mem_schedule(struct sock *sk, int size, int kind)
+int sk_stream_mem_schedule(struct sock *sk, struct sk_buff *skb, int size, int kind)
 {
 	int amt = sk_stream_pages(size);
 
@@ -224,7 +224,8 @@ int sk_stream_mem_schedule(struct sock *
 	/* Over hard limit. */
 	if (atomic_read(sk->sk_prot->memory_allocated) > sk->sk_prot->sysctl_mem[2]) {
 		sk->sk_prot->enter_memory_pressure();
-		goto suppress_allocation;
+		if (!skb || (skb && !skb_emergency(skb)))
+			goto suppress_allocation;
 	}
 
 	/* Under pressure. */

--

