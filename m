From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 13/20] sock: add net to prot->enter_memory_pressure callback
Date: Wed, 16 Jul 2008 12:27:53 +0400
Message-ID: <487DB109.40506@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52829 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbYGPI2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:28:42 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tcp_enter_memory_pressure calls NET_INC_STATS, but doesn't
have where to get the net from.

I decided to add a sk argument, not the net itself, only to factor
all the required sock_net(sk) calls inside the enter_memory_pressure 
callback itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/sock.h     |    4 ++--
 include/net/tcp.h      |    2 +-
 net/core/sock.c        |    2 +-
 net/decnet/af_decnet.c |    2 +-
 net/ipv4/tcp.c         |    4 ++--
 net/sctp/socket.c      |    2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3f4897a..06c5259 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -565,7 +565,7 @@ struct proto {
 #endif
 
 	/* Memory pressure */
-	void			(*enter_memory_pressure)(void);
+	void			(*enter_memory_pressure)(struct sock *sk);
 	atomic_t		*memory_allocated;	/* Current allocated memory. */
 	atomic_t		*sockets_allocated;	/* Current number of sockets. */
 	/*
@@ -1210,7 +1210,7 @@ static inline struct page *sk_stream_alloc_page(struct sock *sk)
 
 	page = alloc_pages(sk->sk_allocation, 0);
 	if (!page) {
-		sk->sk_prot->enter_memory_pressure();
+		sk->sk_prot->enter_memory_pressure(sk);
 		sk_stream_moderate_sndbuf(sk);
 	}
 	return page;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4d78818..c25cb52 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -975,7 +975,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->rmt_port = tcp_hdr(skb)->source;
 }
 
-extern void tcp_enter_memory_pressure(void);
+extern void tcp_enter_memory_pressure(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
 {
diff --git a/net/core/sock.c b/net/core/sock.c
index 2c0ba52..10a64d5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1442,7 +1442,7 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 	/* Under pressure. */
 	if (allocated > prot->sysctl_mem[1])
 		if (prot->enter_memory_pressure)
-			prot->enter_memory_pressure();
+			prot->enter_memory_pressure(sk);
 
 	/* Over hard limit. */
 	if (allocated > prot->sysctl_mem[2])
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 931bdf9..61b7df5 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -451,7 +451,7 @@ static void dn_destruct(struct sock *sk)
 
 static int dn_memory_pressure;
 
-static void dn_enter_memory_pressure(void)
+static void dn_enter_memory_pressure(struct sock *sk)
 {
 	if (!dn_memory_pressure) {
 		dn_memory_pressure = 1;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 315b82e..44b2fda 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -316,7 +316,7 @@ int tcp_memory_pressure __read_mostly;
 
 EXPORT_SYMBOL(tcp_memory_pressure);
 
-void tcp_enter_memory_pressure(void)
+void tcp_enter_memory_pressure(struct sock *sk)
 {
 	if (!tcp_memory_pressure) {
 		NET_INC_STATS(LINUX_MIB_TCPMEMORYPRESSURES);
@@ -649,7 +649,7 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 		}
 		__kfree_skb(skb);
 	} else {
-		sk->sk_prot->enter_memory_pressure();
+		sk->sk_prot->enter_memory_pressure(sk);
 		sk_stream_moderate_sndbuf(sk);
 	}
 	return NULL;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index df5572c..6aba01b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -116,7 +116,7 @@ static int sctp_memory_pressure;
 static atomic_t sctp_memory_allocated;
 static atomic_t sctp_sockets_allocated;
 
-static void sctp_enter_memory_pressure(void)
+static void sctp_enter_memory_pressure(struct sock *sk)
 {
 	sctp_memory_pressure = 1;
 }
-- 
1.5.5.1

