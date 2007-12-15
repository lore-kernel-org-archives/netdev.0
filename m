From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 2/4] [CORE]: datagram: mem_scheudle functions
Date: Sat, 15 Dec 2007 00:15:04 -0500
Message-ID: <476362D8.4070807@redhat.com>
References: <47636120.4050701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbXLOFUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2007 00:20:46 -0500
In-Reply-To: <47636120.4050701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes changes in network core sub system for memory
accounting.

Memory scheduling, charging, uncharging and reclaiming functions are
added. These functions use sk_forward_alloc to store socket local
accounting. They also need to use lock to keep consistency of
sk_forward_alloc and memory_allocated. They currently support only
datagram protocols.

sk_datagram_rfree() is a receive buffer detractor for datagram
protocols which are capable of protocol specific memory accounting.

To enable memory accounting in releasing receive buffer,
sock_queue_rcv_skb() is modified although the interface isn't changed.
The body of the function is implemented in
sock_queue_rcv_skb_with_owner(). Additionally, skb_set_owner_r() is
moved to sock.h to core/datagram.c because we want to use it as a
call back function.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/sock.h  |  117 +++++++++++++++++++++++++++++++++++++++++++++++++---
 net/core/datagram.c |   72 ++++++++++++++++++++++++++++++++
 net/core/sock.c     |   13 ++++-
 3 files changed, 193 insertions(+), 9 deletions(-)

diff -pruN net-2.6-udp-take10a4-p1/include/net/sock.h net-2.6-udp-take10a4-p2/include/net/sock.h
--- net-2.6-udp-take10a4-p1/include/net/sock.h	2007-12-11 10:54:53.000000000 -0500
+++ net-2.6-udp-take10a4-p2/include/net/sock.h	2007-12-14 20:27:40.000000000 -0500
@@ -750,6 +750,9 @@ static inline struct inode *SOCK_INODE(s
 	return &container_of(socket, struct socket_alloc, socket)->vfs_inode;
 }

+/*
+ * Functions for memory accounting
+ */
 extern void __sk_stream_mem_reclaim(struct sock *sk);
 extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);

@@ -778,6 +781,107 @@ static inline int sk_stream_wmem_schedul
 	       sk_stream_mem_schedule(sk, size, 0);
 }

+extern void __sk_datagram_mem_reclaim(struct sock *sk);
+extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);
+
+#define SK_DATAGRAM_MEM_QUANTUM ((unsigned int)PAGE_SIZE)
+
+static inline int sk_datagram_pages(int amt)
+{
+	/* Cast to unsigned as an optimization, since amt is always positive. */
+	return DIV_ROUND_UP((unsigned int)amt, SK_DATAGRAM_MEM_QUANTUM);
+}
+
+extern void __sk_datagram_mem_reclaim(struct sock *sk);
+extern int sk_datagram_mem_schedule(struct sock *sk, int size, int kind);
+
+static inline void sk_datagram_mem_reclaim(struct sock *sk)
+{
+	unsigned long flags;
+
+	if (!sk->sk_prot->memory_allocated)
+		return;
+
+	spin_lock_irqsave(&sk->sk_lock.slock, flags);
+	__sk_datagram_mem_reclaim(sk);
+	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
+}
+
+static inline int sk_datagram_rmem_schedule(struct sock *sk, int size)
+{
+	return size <= sk->sk_forward_alloc ||
+		sk_datagram_mem_schedule(sk, size, 1);
+}
+
+static inline int sk_datagram_wmem_schedule(struct sock *sk, int size)
+{
+	return size <= sk->sk_forward_alloc ||
+		sk_datagram_mem_schedule(sk, size, 0);
+}
+
+static inline void sk_mem_reclaim(struct sock *sk)
+{
+	if (sk->sk_type == SOCK_DGRAM)
+		sk_datagram_mem_reclaim(sk);
+}
+
+static inline int sk_wmem_schedule(struct sock *sk, int size)
+{
+	if (sk->sk_type == SOCK_DGRAM)
+		return sk_datagram_wmem_schedule(sk, size);
+	else
+		return 1;
+}
+
+static inline int sk_account_wmem_charge(struct sock *sk, int size)
+{
+	unsigned long flags;
+
+	/* account if protocol supports memory accounting. */
+	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
+		return 1;
+
+	spin_lock_irqsave(&sk->sk_lock.slock, flags);
+	if (sk_datagram_wmem_schedule(sk, size)) {
+		sk->sk_forward_alloc -= size;
+		spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
+		return 1;
+	}
+	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
+	return 0;
+}
+
+static inline int sk_account_rmem_charge(struct sock *sk, int size)
+{
+	unsigned long flags;
+
+	/* account if protocol supports memory accounting. */
+	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
+		return 1;
+
+	spin_lock_irqsave(&sk->sk_lock.slock, flags);
+	if (sk_datagram_rmem_schedule(sk, size)) {
+		sk->sk_forward_alloc -= size;
+		spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
+		return 1;
+	}
+	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
+	return 0;
+}
+
+static inline void sk_account_uncharge(struct sock *sk, int size)
+{
+	unsigned long flags;
+
+	/* account if protocol supports memory accounting. */
+	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
+		return;
+
+	spin_lock_irqsave(&sk->sk_lock.slock, flags);
+	sk->sk_forward_alloc += size;
+	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
+}
+
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
@@ -1159,18 +1263,19 @@ static inline void skb_set_owner_w(struc
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 }

-static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
-{
-	skb->sk = sk;
-	skb->destructor = sock_rfree;
-	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
-}
+extern void skb_set_owner_r(struct sk_buff *skb, struct sock *sk);
+
+void sk_datagram_rfree(struct sk_buff *skb);

 extern void sk_reset_timer(struct sock *sk, struct timer_list* timer,
 			   unsigned long expires);

 extern void sk_stop_timer(struct sock *sk, struct timer_list* timer);

+extern int sock_queue_rcv_skb_with_owner(struct sock *sk, struct sk_buff *skb,
+					 void set_owner_r(struct sk_buff *nskb,
+							  struct sock* nsk));
+
 extern int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);

 static inline int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
diff -pruN net-2.6-udp-take10a4-p1/net/core/datagram.c net-2.6-udp-take10a4-p2/net/core/datagram.c
--- net-2.6-udp-take10a4-p1/net/core/datagram.c	2007-12-11 10:54:55.000000000 -0500
+++ net-2.6-udp-take10a4-p2/net/core/datagram.c	2007-12-14 20:26:18.000000000 -0500
@@ -200,6 +200,14 @@ void skb_free_datagram(struct sock *sk,
 	kfree_skb(skb);
 }

+void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
+{
+	skb->sk = sk;
+	skb->destructor = sock_rfree;
+	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+}
+EXPORT_SYMBOL(skb_set_owner_r);
+
 /**
  *	skb_kill_datagram - Free a datagram skbuff forcibly
  *	@sk: socket
@@ -484,6 +492,70 @@ fault:
 }

 /**
+ *	sk_datagram_rfree - receive buffer detractor for datagram protocls
+ *	@skb: skbuff
+ */
+void sk_datagram_rfree(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	skb_truesize_check(skb);
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+	sk_account_uncharge(sk, skb->truesize);
+	sk_datagram_mem_reclaim(sk);
+}
+EXPORT_SYMBOL(sk_datagram_rfree);
+
+/**
+ * 	__sk_datagram_mem_reclaim - send buffer for datagram protocls
+ *	@sk: socket
+ */
+void __sk_datagram_mem_reclaim(struct sock *sk)
+{
+	if (sk->sk_forward_alloc < SK_DATAGRAM_MEM_QUANTUM)
+		return;
+
+	atomic_sub(sk->sk_forward_alloc / SK_DATAGRAM_MEM_QUANTUM,
+		   sk->sk_prot->memory_allocated);
+	sk->sk_forward_alloc &= SK_DATAGRAM_MEM_QUANTUM - 1;
+}
+EXPORT_SYMBOL(__sk_datagram_mem_reclaim);
+
+/**
+ * 	sk_datagram_mem_schedule - memory accounting for datagram protocls
+ *	@sk: socket
+ *	@size: memory size to allocate
+ *	@kind: allocation type
+ *
+ *	If kind is 0, it means wmem allocation. Otherwise it means rmem
+ *	allocation.
+ */
+int sk_datagram_mem_schedule(struct sock *sk, int size, int kind)
+{
+	int amt;
+	struct proto *prot = sk->sk_prot;
+
+	/* Don't account and limit memory if protocol doesn't support. */
+	if (!prot->memory_allocated)
+		return 1;
+
+	amt = sk_datagram_pages(size);
+	if (atomic_add_return(amt, prot->memory_allocated) >
+	    prot->sysctl_mem[0])
+		if ((kind && atomic_read(&sk->sk_rmem_alloc) + size >=
+		     prot->sysctl_rmem[0]) ||
+		    (!kind && atomic_read(&sk->sk_wmem_alloc) + size >=
+		     prot->sysctl_wmem[0])) {
+			/* Undo changes. */
+			atomic_sub(amt, prot->memory_allocated);
+			return 0;
+		}
+	sk->sk_forward_alloc += amt * SK_DATAGRAM_MEM_QUANTUM;
+	return 1;
+}
+EXPORT_SYMBOL(sk_datagram_mem_schedule);
+
+/**
  * 	datagram_poll - generic datagram poll
  *	@file: file struct
  *	@sock: socket
diff -pruN net-2.6-udp-take10a4-p1/net/core/sock.c net-2.6-udp-take10a4-p2/net/core/sock.c
--- net-2.6-udp-take10a4-p1/net/core/sock.c	2007-12-11 10:54:55.000000000 -0500
+++ net-2.6-udp-take10a4-p2/net/core/sock.c	2007-12-14 16:42:06.000000000 -0500
@@ -263,8 +263,9 @@ static void sock_disable_timestamp(struc
 	}
 }

-
-int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+int sock_queue_rcv_skb_with_owner(struct sock *sk, struct sk_buff *skb,
+				  void set_owner_r(struct sk_buff *nskb,
+						   struct sock* nsk))
 {
 	int err = 0;
 	int skb_len;
@@ -283,7 +284,7 @@ int sock_queue_rcv_skb(struct sock *sk,
 		goto out;

 	skb->dev = NULL;
-	skb_set_owner_r(skb, sk);
+	set_owner_r(skb, sk);

 	/* Cache the SKB length before we tack it onto the receive
 	 * queue.  Once it is added it no longer belongs to us and
@@ -299,6 +300,12 @@ int sock_queue_rcv_skb(struct sock *sk,
 out:
 	return err;
 }
+EXPORT_SYMBOL(sock_queue_rcv_skb_with_owner);
+
+int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	return sock_queue_rcv_skb_with_owner(sk, skb, skb_set_owner_r);
+}
 EXPORT_SYMBOL(sock_queue_rcv_skb);

 int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
-- 
Hitachi Computer Products (America) Inc.
