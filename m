From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/2] net: introduce SO_INCOMING_CPU
Date: Tue, 11 Nov 2014 05:54:28 -0800
Message-ID: <1415714068-21028-3-git-send-email-edumazet@google.com>
References: <1415714068-21028-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Ying Cai <ycai@google.com>, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:39338 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbaKKNzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:55:04 -0500
Received: by mail-qc0-f202.google.com with SMTP id m20so740825qcx.5
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 05:55:03 -0800 (PST)
In-Reply-To: <1415714068-21028-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alternative to RPS/RFS is to use hardware support for multiple
queues.

Then split a set of million of sockets into worker threads, each
one using epoll() to manage events on its own socket pool.

Ideally, we want one thread per RX/TX queue/cpu, but we have no way to
know after accept() or connect() on which queue/cpu a socket is managed.

We normally use one cpu per RX queue (IRQ smp_affinity being properly
set), so remembering on socket structure which cpu delivered last packet
is enough to solve the problem.

After accept(), connect(), or even file descriptor passing around
processes, applications can use :

 int cpu;
 socklen_t len = sizeof(cpu);

 getsockopt(fd, SOL_SOCKET, SO_INCOMING_CPU, &cpu, &len);

And use this information to put the socket into the right silo
for optimal performance, as all networking stack should run
on the appropriate cpu, without need to send IPI (RPS/RFS).

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   |  2 ++
 arch/avr32/include/uapi/asm/socket.h   |  2 ++
 arch/cris/include/uapi/asm/socket.h    |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  2 ++
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  2 ++
 arch/mips/include/uapi/asm/socket.h    |  2 ++
 arch/mn10300/include/uapi/asm/socket.h |  2 ++
 arch/parisc/include/uapi/asm/socket.h  |  2 ++
 arch/powerpc/include/uapi/asm/socket.h |  2 ++
 arch/s390/include/uapi/asm/socket.h    |  2 ++
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  2 ++
 include/net/sock.h                     | 12 ++++++++++++
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        |  5 +++++
 net/ipv4/tcp_ipv4.c                    |  1 +
 net/ipv4/udp.c                         |  1 +
 net/ipv6/tcp_ipv6.c                    |  1 +
 net/ipv6/udp.c                         |  1 +
 net/sctp/ulpqueue.c                    |  5 +++--
 21 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 3de1394bcab8..e2fe0700b3b4 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 6e6cd159924b..92121b0f5b98 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index ed94e5ed0a23..60f60f5b9b35 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -82,6 +82,8 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index ca2c6e6f31c6..2c6890209ea6 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -80,5 +80,7 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index a1b49bac7951..09a93fb566f6 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 6c9a24b3aefa..e8589819c274 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index a14baa218c76..2e9ee8c55a10 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 6aa3ce1854aa..f3492e8c9f70 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index fe35ceacf0e7..7984a1cab3da 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 
 #define SO_BPF_EXTENSIONS	0x4029
 
+#define SO_INCOMING_CPU		0x402A
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a9c3e2e18c05..3474e4ef166d 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index e031332096d7..8457636c33e1 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -86,4 +86,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 54d9608681b6..4a8003a94163 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -76,6 +76,8 @@
 
 #define SO_BPF_EXTENSIONS	0x0032
 
+#define SO_INCOMING_CPU		0x0033
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 39acec0cf0b1..c46f6a696849 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 7db3db112baa..ff2c3f11fb8f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -273,6 +273,7 @@ struct cg_proto;
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
   *	@sk_rxhash: flow hash received from netif layer
+  *	@sk_incoming_cpu: record cpu processing incoming packets
   *	@sk_txhash: computed flow hash for use on transmit
   *	@sk_filter: socket filtering instructions
   *	@sk_protinfo: private area, net family specific, when not using slab
@@ -350,6 +351,12 @@ struct sock {
 #ifdef CONFIG_RPS
 	__u32			sk_rxhash;
 #endif
+	u16			sk_incoming_cpu;
+	/* 16bit hole
+	 * Warned : sk_incoming_cpu can be set from softirq,
+	 * Do not use this hole without fully understanding possible issues.
+	 */
+
 	__u32			sk_txhash;
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int		sk_napi_id;
@@ -833,6 +840,11 @@ static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
+static inline void sk_incoming_cpu_update(struct sock *sk)
+{
+	sk->sk_incoming_cpu = raw_smp_processor_id();
+}
+
 static inline void sock_rps_record_flow_hash(__u32 hash)
 {
 #ifdef CONFIG_RPS
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index ea0796bdcf88..f541ccefd4ac 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -82,4 +82,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 15e0c67b1069..14998b161035 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1213,6 +1213,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_max_pacing_rate;
 		break;
 
+	case SO_INCOMING_CPU:
+		v.val = sk->sk_incoming_cpu;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1517,6 +1521,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 		newsk->sk_err	   = 0;
 		newsk->sk_priority = 0;
+		newsk->sk_incoming_cpu = raw_smp_processor_id();
 		/*
 		 * Before updating sk_refcnt, we must commit prior changes to memory
 		 * (Documentation/RCU/rculist_nulls.txt for details)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8893598a4124..2c6a955fd5c3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1663,6 +1663,7 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
+	sk_incoming_cpu_update(sk);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db5471bb5..52235ca1f352 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1445,6 +1445,7 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (inet_sk(sk)->inet_daddr) {
 		sock_rps_save_rxhash(sk, skb);
 		sk_mark_napi_id(sk, skb);
+		sk_incoming_cpu_update(sk);
 	}
 
 	rc = sock_queue_rcv_skb(sk, skb);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index fd8e50b380e7..1985b4933a6b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1456,6 +1456,7 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
+	sk_incoming_cpu_update(sk);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f6ba535b6feb..2c7790c9ac65 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -577,6 +577,7 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (!ipv6_addr_any(&sk->sk_v6_daddr)) {
 		sock_rps_save_rxhash(sk, skb);
 		sk_mark_napi_id(sk, skb);
+		sk_incoming_cpu_update(sk);
 	}
 
 	rc = sock_queue_rcv_skb(sk, skb);
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index d49dc2ed30ad..ce469d648ffb 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -205,9 +205,10 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	if (sock_flag(sk, SOCK_DEAD) || (sk->sk_shutdown & RCV_SHUTDOWN))
 		goto out_free;
 
-	if (!sctp_ulpevent_is_notification(event))
+	if (!sctp_ulpevent_is_notification(event)) {
 		sk_mark_napi_id(sk, skb);
-
+		sk_incoming_cpu_update(sk);
+	}
 	/* Check if the user wishes to receive this event.  */
 	if (!sctp_ulpevent_is_enabled(event, &sctp_sk(sk)->subscribe))
 		goto out_free;
-- 
2.1.0.rc2.206.gedb03e5
