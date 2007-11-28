From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 2/4] datagram: mem_scheudle functions
Date: Wed, 28 Nov 2007 13:52:59 -0500
Message-ID: <474DB90B.9090107@redhat.com>
References: <474DB80E.5070403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754556AbXK1Sy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 13:54:28 -0500
In-Reply-To: <474DB80E.5070403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces datagram memory accounting functions. Owing to
call memory schedule functions from IP layer, sk_wmem_schedule() is
also added.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 include/net/sock.h  |   31 +++++++++++++++++++++++++++++++
 net/core/datagram.c |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+)

diff -pruN net-2.6-udp-take9a2-p1/include/net/sock.h net-2.6-udp-take9a2-p2/include/net/sock.h
--- net-2.6-udp-take9a2-p1/include/net/sock.h	2007-11-20 10:29:40.000000000 -0500
+++ net-2.6-udp-take9a2-p2/include/net/sock.h	2007-11-27 11:11:38.000000000 -0500
@@ -778,6 +778,37 @@ static inline int sk_stream_wmem_schedul
 	       sk_stream_mem_schedule(sk, size, 0);
 }

+extern int sk_datagram_mem_schedule(struct sock *sk, int size, int kind);
+
+#define SK_DATAGRAM_MEM_QUANTUM ((unsigned int)PAGE_SIZE)
+
+static inline int sk_datagram_pages(int amt)
+{
+	/* Cast to unsigned as an optimization, since amt is always positive. */
+	return DIV_ROUND_UP((unsigned int)amt, SK_DATAGRAM_MEM_QUANTUM);
+}
+
+static inline int sk_datagram_rmem_schedule(struct sock *sk,
+					    struct sk_buff *skb)
+{
+	return sk_datagram_mem_schedule(sk, skb->truesize, 1);
+}
+
+static inline int sk_datagram_wmem_schedule(struct sock *sk, int size)
+{
+	return sk_datagram_mem_schedule(sk, size, 0);
+}
+
+static inline int sk_wmem_schedule(struct sock *sk, int size)
+{
+	if (sk->sk_type == SOCK_STREAM)
+		return sk_stream_wmem_schedule(sk, size);
+	else if (sk->sk_type == SOCK_DGRAM)
+		return sk_datagram_wmem_schedule(sk, size);
+	else
+		return 1;
+}
+
 /* Used by processes to "lock" a socket state, so that
  * interrupts and bottom half handlers won't change it
  * from under us. It essentially blocks any incoming
diff -pruN net-2.6-udp-take9a2-p1/net/core/datagram.c net-2.6-udp-take9a2-p2/net/core/datagram.c
--- net-2.6-udp-take9a2-p1/net/core/datagram.c	2007-11-14 10:49:06.000000000 -0500
+++ net-2.6-udp-take9a2-p2/net/core/datagram.c	2007-11-28 12:10:05.000000000 -0500
@@ -484,6 +484,39 @@ fault:
 }

 /**
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
+	if (prot->memory_allocated == NULL)
+		return 1;
+
+	amt = sk_datagram_pages(size);
+	atomic_add(amt, prot->memory_allocated);
+	if (kind &&
+	    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0] ||
+	     atomic_read(&sk->sk_rmem_alloc) + size < prot->sysctl_rmem[0]))
+		return 1;
+	else if (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0] ||
+		 atomic_read(&sk->sk_wmem_alloc) + size < prot->sysctl_wmem[0])
+		return 1;
+
+	/* Undo changes. */
+	atomic_sub(amt, prot->memory_allocated);
+	return 0;
+}
+
+/**
  * 	datagram_poll - generic datagram poll
  *	@file: file struct
  *	@sock: socket
@@ -542,3 +575,4 @@ EXPORT_SYMBOL(skb_copy_and_csum_datagram
 EXPORT_SYMBOL(skb_copy_datagram_iovec);
 EXPORT_SYMBOL(skb_free_datagram);
 EXPORT_SYMBOL(skb_recv_datagram);
+EXPORT_SYMBOL(sk_datagram_mem_schedule);
-- 
Hitachi Computer Products (America) Inc.
