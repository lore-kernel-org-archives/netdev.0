From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : Adding SO_TIMESTAMPNS / SCM_TIMESTAMPNS support
Date: Fri, 9 Mar 2007 19:39:42 +0100
Message-ID: <200703091939.42656.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <200703021538.41284.dada1@cosmosbay.com> <200703081517.57539.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_una8F7858Puufvk"
Cc: netdev@vger.kernel.org, linux-arch@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39387 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716AbXCISje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 13:39:34 -0500
In-Reply-To: <200703081517.57539.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_una8F7858Puufvk
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

This patch is against net-2.6.22 git tree.

Thank you

[PATCH] NET : Adding SO_TIMESTAMPNS / SCM_TIMESTAMPNS support

Now that network timestamps use ktime_t infrastructure, we can add a new 
SOL_SOCKET sockopt  SO_TIMESTAMPNS.

This command is similar to SO_TIMESTAMP, but permits transmission of 
a 'timespec struct' instead of a 'timeval struct' control message. 
(nanosecond resolution instead of microsecond)

Control message is labelled SCM_TIMESTAMPNS instead of SCM_TIMESTAMP

A socket cannot mix SO_TIMESTAMP and SO_TIMESTAMPNS : the two modes are 
mutually exclusive.

sock_recv_timestamp() became too big to be fully inlined so I added a 
__sock_recv_timestamp() helper function.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
CC: linux-arch@vger.kernel.org


--Boundary-00=_una8F7858Puufvk
Content-Type: text/plain;
  charset="utf-8";
  name="SCM_TIMESTAMPNS.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="SCM_TIMESTAMPNS.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index 5124657..390c047 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -390,6 +390,7 @@ enum sock_flags {
 	SOCK_USE_WRITE_QUEUE, /* whether to call sk->sk_write_space in sock_wfree */
 	SOCK_DBG, /* %SO_DEBUG setting */
 	SOCK_RCVTSTAMP, /* %SO_TIMESTAMP setting */
+	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
 };
@@ -1283,21 +1284,17 @@ static inline int sock_intr_errno(long t
 	return timeo == MAX_SCHEDULE_TIMEOUT ? -ERESTARTSYS : -EINTR;
 }
 
+extern void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
+	struct sk_buff *skb);
+
 static __inline__ void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
 	ktime_t kt = skb->tstamp;
 
-	if (sock_flag(sk, SOCK_RCVTSTAMP)) {
-		struct timeval tv;
-		/* Race occurred between timestamp enabling and packet
-		   receiving.  Fill in the current time for now. */
-		if (kt.tv64 == 0)
-			kt = ktime_get_real();
-		skb->tstamp = kt;
-		tv = ktime_to_timeval(kt);
-		put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMP, sizeof(tv), &tv);
-	} else
+	if (sock_flag(sk, SOCK_RCVTSTAMP))
+		__sock_recv_timestamp(msg, sk, skb);
+	else
 		sk->sk_stamp = kt;
 }
 
diff --git a/net/compat.c b/net/compat.c
index 0e40756..9a0f5f2 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -215,6 +215,7 @@ Efault:
 int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *data)
 {
 	struct compat_timeval ctv;
+	struct compat_timespec cts;
 	struct compat_cmsghdr __user *cm = (struct compat_cmsghdr __user *) kmsg->msg_control;
 	struct compat_cmsghdr cmhdr;
 	int cmlen;
@@ -229,7 +230,14 @@ int put_cmsg_compat(struct msghdr *kmsg,
 		ctv.tv_sec = tv->tv_sec;
 		ctv.tv_usec = tv->tv_usec;
 		data = &ctv;
-		len = sizeof(struct compat_timeval);
+		len = sizeof(ctv);
+	}
+	if (level == SOL_SOCKET && type == SO_TIMESTAMPNS) {
+		struct timespec *ts = (struct timespec *)data;
+		cts.tv_sec = ts->tv_sec;
+		cts.tv_nsec = ts->tv_nsec;
+		data = &cts;
+		len = sizeof(cts);
 	}
 
 	cmlen = CMSG_COMPAT_LEN(len);
diff --git a/net/core/sock.c b/net/core/sock.c
index a016661..d4c89f8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -521,11 +521,18 @@ #endif
 		break;
 
 	case SO_TIMESTAMP:
+	case SO_TIMESTAMPNS:
 		if (valbool)  {
+			if (optname == SO_TIMESTAMP)
+				sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
+			else
+				sock_set_flag(sk, SOCK_RCVTSTAMPNS);
 			sock_set_flag(sk, SOCK_RCVTSTAMP);
 			sock_enable_timestamp(sk);
-		} else
+		} else {
 			sock_reset_flag(sk, SOCK_RCVTSTAMP);
+			sock_reset_flag(sk, SOCK_RCVTSTAMPNS);
+		}
 		break;
 
 	case SO_RCVLOWAT:
@@ -715,7 +722,12 @@ int sock_getsockopt(struct socket *sock,
 		break;
 
 	case SO_TIMESTAMP:
-		v.val = sock_flag(sk, SOCK_RCVTSTAMP);
+		v.val = sock_flag(sk, SOCK_RCVTSTAMP) &&
+				!sock_flag(sk, SOCK_RCVTSTAMPNS);
+		break;
+
+	case SO_TIMESTAMPNS:
+		v.val = sock_flag(sk, SOCK_RCVTSTAMPNS);
 		break;
 
 	case SO_RCVTIMEO:
diff --git a/net/socket.c b/net/socket.c
index 724b9cd..15e4327 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -585,6 +585,35 @@ int kernel_sendmsg(struct socket *sock, 
 	return result;
 }
 
+/*
+ * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
+ */
+void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
+	struct sk_buff *skb)
+{
+	ktime_t kt = skb->tstamp;
+
+	if (!sock_flag(sk, SOCK_RCVTSTAMPNS)) {
+		struct timeval tv;
+		/* Race occurred between timestamp enabling and packet
+		   receiving.  Fill in the current time for now. */
+		if (kt.tv64 == 0)
+			kt = ktime_get_real();
+		skb->tstamp = kt;
+		tv = ktime_to_timeval(kt);
+		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP, sizeof(tv), &tv);
+	} else {
+		struct timespec ts;
+		/* Race occurred between timestamp enabling and packet
+		   receiving.  Fill in the current time for now. */
+		if (kt.tv64 == 0)
+			kt = ktime_get_real();
+		skb->tstamp = kt;
+		ts = ktime_to_timespec(kt);
+		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS, sizeof(ts), &ts);
+	}
+}
+
 static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 				 struct msghdr *msg, size_t size, int flags)
 {
diff --git a/include/asm-alpha/socket.h b/include/asm-alpha/socket.h
index d22ab97..1fede7f 100644
--- a/include/asm-alpha/socket.h
+++ b/include/asm-alpha/socket.h
@@ -52,6 +52,8 @@ #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		30
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		19
diff --git a/include/asm-arm/socket.h b/include/asm-arm/socket.h
index 19f7df7..65a1a64 100644
--- a/include/asm-arm/socket.h
+++ b/include/asm-arm/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-arm26/socket.h b/include/asm-arm26/socket.h
index 19f7df7..65a1a64 100644
--- a/include/asm-arm26/socket.h
+++ b/include/asm-arm26/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-avr32/socket.h b/include/asm-avr32/socket.h
index 543229d..a0d0507 100644
--- a/include/asm-avr32/socket.h
+++ b/include/asm-avr32/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/include/asm-cris/socket.h b/include/asm-cris/socket.h
index 01cfdf1..5b18dfd 100644
--- a/include/asm-cris/socket.h
+++ b/include/asm-cris/socket.h
@@ -51,6 +51,8 @@ #define SO_ACCEPTCONN          30
 
 #define SO_PEERSEC             31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/include/asm-frv/socket.h b/include/asm-frv/socket.h
index 31db18f..a823bef 100644
--- a/include/asm-frv/socket.h
+++ b/include/asm-frv/socket.h
@@ -49,6 +49,8 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/include/asm-h8300/socket.h b/include/asm-h8300/socket.h
index ebc830f..39911d8 100644
--- a/include/asm-h8300/socket.h
+++ b/include/asm-h8300/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-i386/socket.h b/include/asm-i386/socket.h
index 5755d57..99ca648 100644
--- a/include/asm-i386/socket.h
+++ b/include/asm-i386/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-ia64/socket.h b/include/asm-ia64/socket.h
index d638ef3..9e42ce4 100644
--- a/include/asm-ia64/socket.h
+++ b/include/asm-ia64/socket.h
@@ -58,5 +58,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/include/asm-m32r/socket.h b/include/asm-m32r/socket.h
index acdf748..793d5d3 100644
--- a/include/asm-m32r/socket.h
+++ b/include/asm-m32r/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/include/asm-m68k/socket.h b/include/asm-m68k/socket.h
index a5966ec..6d21b90 100644
--- a/include/asm-m68k/socket.h
+++ b/include/asm-m68k/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-mips/socket.h b/include/asm-mips/socket.h
index 36ebe4e..9594568 100644
--- a/include/asm-mips/socket.h
+++ b/include/asm-mips/socket.h
@@ -70,6 +70,8 @@ #define SO_PEERSEC		30
 #define SO_SNDBUFFORCE		31
 #define SO_RCVBUFFORCE		33
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-parisc/socket.h b/include/asm-parisc/socket.h
index ce2eae1..99e868f 100644
--- a/include/asm-parisc/socket.h
+++ b/include/asm-parisc/socket.h
@@ -33,6 +33,8 @@ #define SO_PASSCRED	0x4010
 #define SO_PEERCRED	0x4011
 #define SO_TIMESTAMP	0x4012
 #define SCM_TIMESTAMP	SO_TIMESTAMP
+#define SO_TIMESTAMPNS	0x4013
+#define SCM_TIMESTAMPNS	SO_TIMESTAMPNS
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x4016
diff --git a/include/asm-powerpc/socket.h b/include/asm-powerpc/socket.h
index c8b1da5..403e9fd 100644
--- a/include/asm-powerpc/socket.h
+++ b/include/asm-powerpc/socket.h
@@ -56,5 +56,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/include/asm-s390/socket.h b/include/asm-s390/socket.h
index 1778a49..1161ebe 100644
--- a/include/asm-s390/socket.h
+++ b/include/asm-s390/socket.h
@@ -57,5 +57,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-sh/socket.h b/include/asm-sh/socket.h
index ca70362..c48d6fc 100644
--- a/include/asm-sh/socket.h
+++ b/include/asm-sh/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* __ASM_SH_SOCKET_H */
diff --git a/include/asm-sparc/socket.h b/include/asm-sparc/socket.h
index f6c4e5b..d77768e 100644
--- a/include/asm-sparc/socket.h
+++ b/include/asm-sparc/socket.h
@@ -49,6 +49,8 @@ #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
 #define SO_PASSSEC		0x001f
+#define SO_TIMESTAMPNS		0x0020
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff --git a/include/asm-sparc64/socket.h b/include/asm-sparc64/socket.h
index 754d46a..1bd9f52 100644
--- a/include/asm-sparc64/socket.h
+++ b/include/asm-sparc64/socket.h
@@ -49,6 +49,8 @@ #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
 #define SO_PASSSEC		0x001f
+#define SO_TIMESTAMPNS		0x0020
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff --git a/include/asm-v850/socket.h b/include/asm-v850/socket.h
index 0dfe55a..a4c2493 100644
--- a/include/asm-v850/socket.h
+++ b/include/asm-v850/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* __V850_SOCKET_H__ */
diff --git a/include/asm-x86_64/socket.h b/include/asm-x86_64/socket.h
index b467026..90af60c 100644
--- a/include/asm-x86_64/socket.h
+++ b/include/asm-x86_64/socket.h
@@ -49,5 +49,7 @@ #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-xtensa/socket.h b/include/asm-xtensa/socket.h
index 971d231..1f5aeac 100644
--- a/include/asm-xtensa/socket.h
+++ b/include/asm-xtensa/socket.h
@@ -60,5 +60,7 @@ #define SCM_TIMESTAMP		SO_TIMESTAMP
 #define SO_ACCEPTCONN		30
 #define SO_PEERSEC		31
 #define SO_PASSSEC		34
+#define SO_TIMESTAMPNS		35
+#define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
 #endif	/* _XTENSA_SOCKET_H */

--Boundary-00=_una8F7858Puufvk--
