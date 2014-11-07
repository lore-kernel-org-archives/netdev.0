From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 07 Nov 2014 12:51:12 -0800
Message-ID: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:44544 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaKGUvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:51:15 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so14652969iga.15
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 12:51:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Alternative to RPS/RFS is to use hardware support for multi queue.

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
 arch/alpha/include/uapi/asm/socket.h   |    2 ++
 arch/avr32/include/uapi/asm/socket.h   |    2 ++
 arch/cris/include/uapi/asm/socket.h    |    2 ++
 arch/frv/include/uapi/asm/socket.h     |    2 ++
 arch/ia64/include/uapi/asm/socket.h    |    2 ++
 arch/m32r/include/uapi/asm/socket.h    |    2 ++
 arch/mips/include/uapi/asm/socket.h    |    2 ++
 arch/mn10300/include/uapi/asm/socket.h |    2 ++
 arch/parisc/include/uapi/asm/socket.h  |    2 ++
 arch/powerpc/include/uapi/asm/socket.h |    2 ++
 arch/s390/include/uapi/asm/socket.h    |    2 ++
 arch/sparc/include/uapi/asm/socket.h   |    2 ++
 arch/xtensa/include/uapi/asm/socket.h  |    2 ++
 include/net/sock.h                     |   12 ++++++++++++
 include/uapi/asm-generic/socket.h      |    2 ++
 net/core/sock.c                        |    5 +++++
 net/ipv4/tcp_ipv4.c                    |    1 +
 net/ipv4/udp.c                         |    1 +
 net/ipv6/tcp_ipv6.c                    |    1 +
 net/ipv6/udp.c                         |    1 +
 net/sctp/ulpqueue.c                    |    5 +++--
 21 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 3de1394bcab821984674e89a3ee022cc6dd5f0f2..e2fe0700b3b442bffc1f606b1b8b0bb7759aa157 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 6e6cd159924b1855aa5f1811ad4e4c60b403c431..92121b0f5b989a61c008e0be24030725bab88e36 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index ed94e5ed0a238c2750e677ccb806a6bc0a94041a..60f60f5b9b35bd219d7a9834fe5394e8ac5fdbab 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -82,6 +82,8 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index ca2c6e6f31c6817780d31a246652adcc9847e373..2c6890209ea60c149bf097c2a1b369519cb8c301 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -80,5 +80,7 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index a1b49bac7951929127ed08db549218c2c16ccf89..09a93fb566f6c6c6fe29c10c95b931881843d1cd 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 6c9a24b3aefa3a4f3048c17a7fa06d97b585ec14..e8589819c2743c6e112b15a245fc3ebd146e6313 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index a14baa218c76f14de988ef106bdac5dadc48aceb..2e9ee8c55a103a0337d9f80f71fe9ef28be1154b 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 6aa3ce1854aa9523d46bc28851eddabd59edeb37..f3492e8c9f7009c33e07168df916f7337bef3929 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index fe35ceacf0e72cad69a43d9b1ce7b8f5ec3da98a..7984a1cab3da980f1f810827967b4b67616eb89b 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 
 #define SO_BPF_EXTENSIONS	0x4029
 
+#define SO_INCOMING_CPU		0x402A
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a9c3e2e18c054a1e952fe33599401de57c6a6544..3474e4ef166df4a573773916b325d0fa9f3b45d0 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index e031332096d7c7b23b5953680289e8f3bcc3b378..8457636c33e1b67a9b7804daa05627839035a8fb 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -86,4 +86,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 54d9608681b6947ae25dab008f808841d96125c0..4a8003a9416348006cfa85d5bcdf7553c8d23958 100644
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
index 39acec0cf0b1d500c1c40f9b523ef3a9a142c2f1..c46f6a696849c6f7f8a34b2cc522b48e04b17380 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 6767d75ecb17693eb59a99b8218da4319854ccc0..7789b59c0c400eb99f65d1f0e03cd9773664cf93 100644
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
index ea0796bdcf88404ef0f127eb6e64ba00c16ea856..f541ccefd4acbeb4ad757be9dbf4b67f204bf21d 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -82,4 +82,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_INCOMING_CPU		49
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index ac56dd06c306f3712e57ce8e4724c79565589499..0725cf0cb685787b2122606437da53299fb24621 100644
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
index 9c7d7621466b1241f404a5ca11de809dcff2d02a..3893f51972f28271a6d27a763c05495c5c2554f7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1662,6 +1662,7 @@ process:
 		goto discard_and_relse;
 
 	sk_mark_napi_id(sk, skb);
+	sk_incoming_cpu_update(sk);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index df19027f44f3d6fbe13dec78d3b085968dbf2329..f52b6081158e87caa5df32e8e5d27dbf314a01b1 100644
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
index ace29b60813cf8a1d7182ad2262cbcbd21810fa7..ac40d23204b5e55da5172c80dafd1d4854b370d5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1455,6 +1455,7 @@ process:
 		goto discard_and_relse;
 
 	sk_mark_napi_id(sk, skb);
+	sk_incoming_cpu_update(sk);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9b6809232b178c16d699ce3d152196b8c4cb096b..0125ca3daf47a4a3333e7462a11550d3e2f96875 100644
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
index d49dc2ed30adb97a809eb37902b9956c366a2862..ce469d648ffbe166f9ae1c5650f481256f31a7f8 100644
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
