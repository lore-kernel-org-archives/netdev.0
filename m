From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Tue, 21 Sep 2010 11:57:35 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1009211154150.32565@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sridharr@google.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:49754 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830Ab0IUS5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 14:57:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patch we propose to adds some socket API to retrieve the
 "transmit completion sequence number", essentially a byte counter
for the number of bytes that have been transmitted and will not be
retransmitted.  In the case of TCP, this should correspond to snd_una.

The purpose of this API is to provide information to userspace about
which buffers can be reclaimed when sending with vmsplice() on a
socket.

There are two methods for retrieving the completed sequence number:
through a simple getsockopt (implemented here for TCP), as well as
returning the value in the ancilary data of a recvmsg.

The expected flow would be something like:
   - Connect is created
   - Initial completion seq # is retrieved through the sockopt, and is
     stored in userspace "compl_seq" variable for the connection.
   - Whenever a send is done, compl_seq += # bytes sent.
   - When doing a vmsplice the completion sequence number is saved
     for each user space buffer, buffer_compl_seq = compl_seq.
   - When recvmsg returns with a completion sequence number in
     ancillary data, any buffers cover by that sequence number
     (where buffer_compl_seq < recvmsg_compl_seq) are reclaimed
     and can be written to again.
   - If no data is receieved on a connection (recvmsg does not
     return), a timeout can be used to call the getsockopt and
     reclaim buffers as a fallback.

Using recvmsg data in this manner is sort of a cheap way to get a
"callback" for when a vmspliced buffer is consumed.  It will work
well for a client where the response causes recvmsg to return.
On the server side it works well if there are a sufficient
number of requests coming on the connection (resorting to the
timeout if necessary as described above).

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index 06edfef..3587082 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -69,6 +69,9 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socket.h
index 90ffd04..962c365 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -62,4 +62,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/socket.h
index c8d1fae..de59dfe 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -62,4 +62,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/socket.h
index 1a4a619..fe9a1ba 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -64,6 +64,8 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/asm/socket.h b/arch/frv/include/asm/socket.h
index a6b2688..769f1f5 100644
--- a/arch/frv/include/asm/socket.h
+++ b/arch/frv/include/asm/socket.h
@@ -62,5 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index 04c0f45..5ef4551 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -62,4 +62,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/socket.h
index 51427ea..217e4d8 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -71,4 +71,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/socket.h
index 469787c..e0830c6 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -62,4 +62,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/asm/socket.h b/arch/m68k/include/asm/socket.h
index 9bf49c8..438cb8e 100644
--- a/arch/m68k/include/asm/socket.h
+++ b/arch/m68k/include/asm/socket.h
@@ -62,4 +62,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/socket.h
index 9de5190..cb927d7 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -82,6 +82,9 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
+
 #ifdef __KERNEL__
 
 /** sock_type - Socket types
diff --git a/arch/mn10300/include/asm/socket.h b/arch/mn10300/include/asm/socket.h
index 4e60c42..1c09487 100644
--- a/arch/mn10300/include/asm/socket.h
+++ b/arch/mn10300/include/asm/socket.h
@@ -62,4 +62,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm/socket.h
index 225b7d6..c1b0479 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -61,6 +61,9 @@
 
 #define SO_RXQ_OVFL             0x4021
 
+#define SO_XMIT_COMPL_SEQ	0x4022
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/asm/socket.h
index 866f760..9452547 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -69,4 +69,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/socket.h
index fdff1e9..3e3c17b 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -70,4 +70,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/socket.h
index 9d3fefc..0675f54 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -58,6 +58,9 @@
 
 #define SO_RXQ_OVFL             0x0024
 
+#define SO_XMIT_COMPL_SEQ	0x0025
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/asm/socket.h b/arch/xtensa/include/asm/socket.h
index cbdf2ff..3c5afbf 100644
--- a/arch/xtensa/include/asm/socket.h
+++ b/arch/xtensa/include/asm/socket.h
@@ -73,4 +73,6 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..6dc1ed8 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,7 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+#define SO_XMIT_COMPL_SEQ	41
+#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e64f4c6..f044aff 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -106,6 +106,7 @@ enum {
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 #define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
+#define TCP_XMIT_COMPL_SEQ	19	/* Return current snd_una */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
diff --git a/include/net/sock.h b/include/net/sock.h
index 8ae97c4..e820e2b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -543,6 +543,7 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_XMIT_COMPL_SEQ, /* SO_XMIT_COMPL_SEQ setting */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/net/core/sock.c b/net/core/sock.c
index f3a06c4..7a10215 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -740,6 +740,12 @@ set_rcvbuf:
 		else
 			sock_reset_flag(sk, SOCK_RXQ_OVFL);
 		break;
+	case SO_XMIT_COMPL_SEQ:
+		if (valbool)
+			sock_set_flag(sk, SOCK_XMIT_COMPL_SEQ);
+		else
+			sock_reset_flag(sk, SOCK_XMIT_COMPL_SEQ);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -961,6 +967,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = !!sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
 
+	case SO_XMIT_COMPL_SEQ:
+		v.val = !!sock_flag(sk, SOCK_XMIT_COMPL_SEQ);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3e8a4db..5e30381 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1387,6 +1387,21 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 EXPORT_SYMBOL(tcp_read_sock);
 
 /*
+ * Copy the first unacked seq into the receive msg control part.
+ */
+static inline void tcp_sock_xmit_compl_seq(struct msghdr *msg,
+					   struct sock *sk)
+{
+	if (sock_flag(sk, SOCK_XMIT_COMPL_SEQ)) {
+		struct tcp_sock *tp = tcp_sk(sk);
+		if (msg->msg_controllen >= sizeof(tp->snd_una)) {
+			put_cmsg(msg, SOL_SOCKET, SCM_XMIT_COMPL_SEQ,
+			    sizeof(tp->snd_una), &tp->snd_una);
+		}
+	}
+}
+
+/*
  *	This routine copies from a sock struct into the user buffer.
  *
  *	Technical note: in 2.3 we work on _locked_ socket, so that
@@ -1763,6 +1778,8 @@ skip_copy:
 	 * on connected socket. I was just happy when found this 8) --ANK
 	 */
 
+	tcp_sock_xmit_compl_seq(msg, sk);
+
 	/* Clean up data we have read: This will do ACK frames. */
 	tcp_cleanup_rbuf(sk, copied);
 
@@ -2617,6 +2634,9 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+	case TCP_XMIT_COMPL_SEQ:
+		val = tp->snd_una;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
