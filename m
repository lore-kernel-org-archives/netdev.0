From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 2/4] [CORE]: datagram: basic memory accounting functions
Date: Mon, 17 Dec 2007 21:38:17 -0500
Message-ID: <47673299.3010301@redhat.com>
References: <47673195.80004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934452AbXLRCng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 21:43:36 -0500
In-Reply-To: <47673195.80004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes changes in network core sub system for memory
accounting.

Memory scheduling, charging, uncharging and reclaiming functions are
added. These functions use sk_forward_alloc to store socket local
accounting. They currently support only datagram protocols.

sk_datagram_rfree() is a receive buffer detractor for datagram
protocols which are capable of protocol specific memory accounting.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/sock.h  |   81 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/datagram.c |   85 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 166 insertions(+)

diff -pruN net-2.6-udp-take11a1-p1/include/net/sock.h net-2.6-udp-take11a1-p2/include/net/sock.h
--- net-2.6-udp-take11a1-p1/include/net/sock.h	2007-12-11 10:54:53.000000000 -0500
+++ net-2.6-udp-take11a1-p2/include/net/sock.h	2007-12-17 14:42:39.000000000 -0500
@@ -750,6 +750,9 @@ static inline struct inode *SOCK_INODE(s
 	return &container_of(socket, struct socket_alloc, socket)->vfs_inode;
 }

+/*
+ * Functions for memory accounting
+ */
 extern void __sk_stream_mem_reclaim(struct sock *sk);
 extern int sk_stream_mem_schedule(struct sock *sk, int size, int kind);

@@ -778,6 +781,82 @@ static inline int sk_stream_wmem_schedul
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
+extern int __sk_datagram_account_charge(struct sock *sk, int size, int kind);
+extern void __sk_datagram_mem_reclaim(struct sock *sk);
+extern int sk_datagram_mem_schedule(struct sock *sk, int size, int kind);
+
+static inline void sk_datagram_mem_reclaim(struct sock *sk)
+{
+	if (!sk->sk_prot->memory_allocated)
+		return;
+
+	__sk_datagram_mem_reclaim(sk);
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
+	/* account if protocol supports memory accounting. */
+	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
+		return 1;
+
+	return __sk_datagram_account_charge(sk, size, 0);
+}
+
+static inline int sk_account_rmem_charge(struct sock *sk, int size)
+{
+	/* account if protocol supports memory accounting. */
+	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
+		return 1;
+
+	return __sk_datagram_account_charge(sk, size, 1);
+}
+
+static inline void sk_account_uncharge(struct sock *sk, int size)
+{
+	/* account if protocol supports memory accounting. */
+	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
+		return;
+
+	sk->sk_forward_alloc += size;
+}
+
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
@@ -1166,6 +1245,8 @@ static inline void skb_set_owner_r(struc
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 }

+extern void sk_datagram_rfree(struct sk_buff *skb);
+
 extern void sk_reset_timer(struct sock *sk, struct timer_list* timer,
 			   unsigned long expires);

diff -pruN net-2.6-udp-take11a1-p1/net/core/datagram.c net-2.6-udp-take11a1-p2/net/core/datagram.c
--- net-2.6-udp-take11a1-p1/net/core/datagram.c	2007-12-11 10:54:55.000000000 -0500
+++ net-2.6-udp-take11a1-p2/net/core/datagram.c	2007-12-17 14:42:39.000000000 -0500
@@ -484,6 +484,91 @@ fault:
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
+
+/**
+ * 	__sk_datagram_account_charge - send buffer for datagram protocls
+ *	@sk: socket
+ *	@size: memory size to charge
+ *	@kind: charge type
+ *
+ *	If kind is 0, it means wmem allocation. Otherwise it means rmem
+ *	allocation.
+ */
+int __sk_datagram_account_charge(struct sock *sk, int size, int kind)
+{
+	if ((kind && sk_datagram_rmem_schedule(sk, size)) ||
+	    (!kind && sk_datagram_wmem_schedule(sk, size))) {
+		sk->sk_forward_alloc -= size;
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(__sk_datagram_account_charge);
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
-- 
Hitachi Computer Products (America) Inc.
