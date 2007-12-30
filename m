From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 1/4] [CORE]: introducing new memory accounting interface
Date: Sun, 30 Dec 2007 03:51:06 -0500
Message-ID: <47775BFA.9090100@redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:34992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbXL3I7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 03:59:51 -0500
In-Reply-To: <47775B25.7020401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces new memory accounting functions for each network
protocol. Most of them are renamed from memory accounting functions
for stream protocols. At the same time, some stream memory accounting
functions are removed since other functions do same thing.

Renaming:
	sk_stream_free_skb()		->	sk_wmem_free_skb()
	__sk_stream_mem_reclaim()	->	__sk_mem_reclaim()
	sk_stream_mem_reclaim()		->	sk_mem_reclaim()
	sk_stream_mem_schedule 		->    	__sk_mem_schedule()
	sk_stream_pages()      		->	sk_mem_pages()
	sk_stream_rmem_schedule()	->	sk_rmem_schedule()
	sk_stream_wmem_schedule()	->	sk_wmem_schedule()
	sk_charge_skb()			->	sk_mem_charge()

Removeing
	sk_stream_rfree():	consolidates into sock_rfree()
	sk_stream_set_owner_r(): consolidates into skb_set_owner_r()
	sk_stream_mem_schedule()

The following functions are added.
    	sk_has_account(): check if the protocol supports accounting
	sk_mem_uncharge(): do the opposite of sk_mem_charge()

In addition, to achieve consolidation, updating sk_wmem_queued is
removed from sk_mem_charge().

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Cc: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/sock.h |   95 ++++++++++++++++++++++++++++++---------------------
 net/core/sock.c    |   97 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/stream.c  |   82 --------------------------------------------
 3 files changed, 152 insertions(+), 122 deletions(-)

diff -pruN net-2.6.25/include/net/sock.h net-2.6.25-t12t19m-p1/include/net/sock.h
--- net-2.6.25/include/net/sock.h	2007-12-27 10:18:58.000000000 -0500
+++ net-2.6.25-t12t19m-p1/include/net/sock.h	2007-12-29 20:16:31.000000000 -0500
@@ -460,25 +460,6 @@ static inline int sk_stream_memory_free(
 	return sk->sk_wmem_queued < sk->sk_sndbuf;
 }

-extern void sk_stream_rfree(struct sk_buff *skb);
-
-static inline void sk_stream_set_owner_r(struct sk_buff *skb, struct sock *sk)
-{
-	skb->sk = sk;
-	skb->destructor = sk_stream_rfree;
-	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
-	sk->sk_forward_alloc -= skb->truesize;
-}
-
-static inline void sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
-{
-	skb_truesize_check(skb);
-	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
-	sk->sk_wmem_queued   -= skb->truesize;
-	sk->sk_forward_alloc += skb->truesize;
-	__kfree_skb(skb);
-}
-
 /* The per-socket spinlock must be held here. */
 static inline void sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
@@ -576,7 +557,7 @@ struct proto {
 	/*
 	 * Pressure flag: try to collapse.
 	 * Technical note: it is used by multiple contexts non atomically.
-	 * All the sk_stream_mem_schedule() is of this nature: accounting
+	 * All the __sk_mem_schedule() is of this nature: accounting
 	 * is strict, actions are advisory and have some latency.
 	 */
 	int			*memory_pressure;
@@ -712,33 +693,73 @@ static inline struct inode *SOCK_INODE(s
 	return &container_of(socket, struct socket_alloc, socket)->vfs_inode;
 }

-extern void __sk_stream_mem_reclaim(struct sock *sk);
-extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
+/*
+ * Functions for memory accounting
+ */
+extern int __sk_mem_schedule(struct sock *sk, int size, int kind);
+extern void __sk_mem_reclaim(struct sock *sk);

-#define SK_STREAM_MEM_QUANTUM ((int)PAGE_SIZE)
-#define SK_STREAM_MEM_QUANTUM_SHIFT ilog2(SK_STREAM_MEM_QUANTUM)
+#define SK_MEM_QUANTUM ((int)PAGE_SIZE)
+#define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
+#define SK_MEM_SEND	0
+#define SK_MEM_RECV	1

-static inline int sk_stream_pages(int amt)
+static inline int sk_mem_pages(int amt)
 {
-	return (amt + SK_STREAM_MEM_QUANTUM - 1) >> SK_STREAM_MEM_QUANTUM_SHIFT;
+	return (amt + SK_MEM_QUANTUM - 1) >> SK_MEM_QUANTUM_SHIFT;
 }

-static inline void sk_stream_mem_reclaim(struct sock *sk)
+static inline int sk_has_account(struct sock *sk)
 {
-	if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM)
-		__sk_stream_mem_reclaim(sk);
+	/* return true if protocol supports memory accounting */
+	return !!sk->sk_prot->memory_allocated;
 }

-static inline int sk_stream_rmem_schedule(struct sock *sk, struct sk_buff *skb)
+static inline int sk_wmem_schedule(struct sock *sk, int size)
 {
-	return (int)skb->truesize <= sk->sk_forward_alloc ||
-		sk_stream_mem_schedule(sk, skb->truesize, 1);
+	if (!sk_has_account(sk))
+		return 1;
+	return size <= sk->sk_forward_alloc ||
+		__sk_mem_schedule(sk, size, SK_MEM_SEND);
 }

-static inline int sk_stream_wmem_schedule(struct sock *sk, int size)
+static inline int sk_rmem_schedule(struct sock *sk, int size)
 {
+	if (!sk_has_account(sk))
+		return 1;
 	return size <= sk->sk_forward_alloc ||
-	       sk_stream_mem_schedule(sk, size, 0);
+		__sk_mem_schedule(sk, size, SK_MEM_RECV);
+}
+
+static inline void sk_mem_reclaim(struct sock *sk)
+{
+	if (!sk_has_account(sk))
+		return;
+	if (sk->sk_forward_alloc >= SK_MEM_QUANTUM)
+		__sk_mem_reclaim(sk);
+}
+
+static inline void sk_mem_charge(struct sock *sk, int size)
+{
+	if (!sk_has_account(sk))
+		return;
+	sk->sk_forward_alloc -= size;
+}
+
+static inline void sk_mem_uncharge(struct sock *sk, int size)
+{
+	if (!sk_has_account(sk))
+		return;
+	sk->sk_forward_alloc += size;
+}
+
+static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
+{
+	skb_truesize_check(skb);
+	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
+	sk->sk_wmem_queued -= skb->truesize;
+	sk_mem_uncharge(sk, skb->truesize);
+	__kfree_skb(skb);
 }

 /* Used by processes to "lock" a socket state, so that
@@ -1076,12 +1097,6 @@ static inline int sk_can_gso(const struc

 extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);

-static inline void sk_charge_skb(struct sock *sk, struct sk_buff *skb)
-{
-	sk->sk_wmem_queued   += skb->truesize;
-	sk->sk_forward_alloc -= skb->truesize;
-}
-
 static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 				   struct sk_buff *skb, struct page *page,
 				   int off, int copy)
diff -pruN net-2.6.25/net/core/sock.c net-2.6.25-t12t19m-p1/net/core/sock.c
--- net-2.6.25/net/core/sock.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p1/net/core/sock.c	2007-12-29 20:16:31.000000000 -0500
@@ -1384,6 +1384,103 @@ int sk_wait_data(struct sock *sk, long *

 EXPORT_SYMBOL(sk_wait_data);

+/**
+ *	__sk_mem_schedule - increase sk_forward_alloc and memory_allocated
+ *	@sk: socket
+ *	@size: memory size to allocate
+ *	@kind: allocation type
+ *
+ *	If kind is SK_MEM_SEND, it means wmem allocation. Otherwise it means
+ *	rmem allocation. This function assumes that protocols which have
+ *	memory_pressure use sk_wmem_queued as write buffer accounting.
+ */
+int __sk_mem_schedule(struct sock *sk, int size, int kind)
+{
+	struct proto *prot = sk->sk_prot;
+	int amt = sk_mem_pages(size);
+	int allocated;
+
+	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
+	allocated = atomic_add_return(amt, prot->memory_allocated);
+
+	/* Under limit. */
+	if (allocated <= prot->sysctl_mem[0]) {
+		if (prot->memory_pressure && *prot->memory_pressure)
+			*prot->memory_pressure = 0;
+		return 1;
+	}
+
+	/* Under pressure. */
+	if (allocated > prot->sysctl_mem[1])
+		if (prot->enter_memory_pressure)
+			prot->enter_memory_pressure();
+
+	/* Over hard limit. */
+	if (allocated > prot->sysctl_mem[2])
+		goto suppress_allocation;
+
+	/* guarantee minimum buffer size under pressure */
+	if (kind == SK_MEM_RECV) {
+		if (atomic_read(&sk->sk_rmem_alloc) < prot->sysctl_rmem[0])
+			return 1;
+	} else { /* SK_MEM_SEND */
+		if (sk->sk_type == SOCK_STREAM) {
+			if (sk->sk_wmem_queued < prot->sysctl_wmem[0])
+				return 1;
+		} else if (atomic_read(&sk->sk_wmem_alloc) <
+			   prot->sysctl_wmem[0])
+				return 1;
+	}
+
+	if (prot->memory_pressure) {
+		if (!*prot->memory_pressure ||
+		    prot->sysctl_mem[2] > atomic_read(prot->sockets_allocated) *
+		    sk_mem_pages(sk->sk_wmem_queued +
+				 atomic_read(&sk->sk_rmem_alloc) +
+				 sk->sk_forward_alloc))
+			return 1;
+	}
+
+suppress_allocation:
+
+	if (kind == SK_MEM_SEND && sk->sk_type == SOCK_STREAM) {
+		sk_stream_moderate_sndbuf(sk);
+
+		/* Fail only if socket is _under_ its sndbuf.
+		 * In this case we cannot block, so that we have to fail.
+		 */
+		if (sk->sk_wmem_queued + size >= sk->sk_sndbuf)
+			return 1;
+	}
+
+	/* Alas. Undo changes. */
+	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
+	atomic_sub(amt, prot->memory_allocated);
+	return 0;
+}
+
+EXPORT_SYMBOL(__sk_mem_schedule);
+
+/**
+ *	__sk_reclaim - reclaim memory_allocated
+ *	@sk: socket
+ */
+void __sk_mem_reclaim(struct sock *sk)
+{
+	struct proto *prot = sk->sk_prot;
+
+	atomic_sub(sk->sk_forward_alloc / SK_MEM_QUANTUM,
+		   prot->memory_allocated);
+	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
+
+	if (prot->memory_pressure && *prot->memory_pressure &&
+	    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]))
+		*prot->memory_pressure = 0;
+}
+
+EXPORT_SYMBOL(__sk_mem_reclaim);
+
+
 /*
  * Set of default routines for initialising struct proto_ops when
  * the protocol does not support a particular function. In certain
diff -pruN net-2.6.25/net/core/stream.c net-2.6.25-t12t19m-p1/net/core/stream.c
--- net-2.6.25/net/core/stream.c	2007-12-27 10:19:02.000000000 -0500
+++ net-2.6.25-t12t19m-p1/net/core/stream.c	2007-12-29 20:16:31.000000000 -0500
@@ -172,17 +172,6 @@ do_interrupted:

 EXPORT_SYMBOL(sk_stream_wait_memory);

-void sk_stream_rfree(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	skb_truesize_check(skb);
-	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
-	sk->sk_forward_alloc += skb->truesize;
-}
-
-EXPORT_SYMBOL(sk_stream_rfree);
-
 int sk_stream_error(struct sock *sk, int flags, int err)
 {
 	if (err == -EPIPE)
@@ -194,77 +183,6 @@ int sk_stream_error(struct sock *sk, int

 EXPORT_SYMBOL(sk_stream_error);

-void __sk_stream_mem_reclaim(struct sock *sk)
-{
-	atomic_sub(sk->sk_forward_alloc >> SK_STREAM_MEM_QUANTUM_SHIFT,
-		   sk->sk_prot->memory_allocated);
-	sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
-	if (*sk->sk_prot->memory_pressure &&
-	    (atomic_read(sk->sk_prot->memory_allocated) <
-	     sk->sk_prot->sysctl_mem[0]))
-		*sk->sk_prot->memory_pressure = 0;
-}
-
-EXPORT_SYMBOL(__sk_stream_mem_reclaim);
-
-int sk_stream_mem_schedule(struct sock *sk, int size, int kind)
-{
-	int amt = sk_stream_pages(size);
-	struct proto *prot = sk->sk_prot;
-
-	sk->sk_forward_alloc += amt * SK_STREAM_MEM_QUANTUM;
-	atomic_add(amt, prot->memory_allocated);
-
-	/* Under limit. */
-	if (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]) {
-		if (*prot->memory_pressure)
-			*prot->memory_pressure = 0;
-		return 1;
-	}
-
-	/* Over hard limit. */
-	if (atomic_read(prot->memory_allocated) > prot->sysctl_mem[2]) {
-		prot->enter_memory_pressure();
-		goto suppress_allocation;
-	}
-
-	/* Under pressure. */
-	if (atomic_read(prot->memory_allocated) > prot->sysctl_mem[1])
-		prot->enter_memory_pressure();
-
-	if (kind) {
-		if (atomic_read(&sk->sk_rmem_alloc) < prot->sysctl_rmem[0])
-			return 1;
-	} else if (sk->sk_wmem_queued < prot->sysctl_wmem[0])
-		return 1;
-
-	if (!*prot->memory_pressure ||
-	    prot->sysctl_mem[2] > atomic_read(prot->sockets_allocated) *
-				sk_stream_pages(sk->sk_wmem_queued +
-						atomic_read(&sk->sk_rmem_alloc) +
-						sk->sk_forward_alloc))
-		return 1;
-
-suppress_allocation:
-
-	if (!kind) {
-		sk_stream_moderate_sndbuf(sk);
-
-		/* Fail only if socket is _under_ its sndbuf.
-		 * In this case we cannot block, so that we have to fail.
-		 */
-		if (sk->sk_wmem_queued + size >= sk->sk_sndbuf)
-			return 1;
-	}
-
-	/* Alas. Undo changes. */
-	sk->sk_forward_alloc -= amt * SK_STREAM_MEM_QUANTUM;
-	atomic_sub(amt, prot->memory_allocated);
-	return 0;
-}
-
-EXPORT_SYMBOL(sk_stream_mem_schedule);
-
 void sk_stream_kill_queues(struct sock *sk)
 {
 	/* First the read buffer. */
-- 
Hitachi Computer Products (America) Inc.
