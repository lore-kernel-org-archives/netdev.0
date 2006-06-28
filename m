From: Catherine Zhang <cxzhang@watson.ibm.com>
Subject: [Patch 1/1] AF_UNIX Datagram getpeersec (minor fix)
Date: Wed, 28 Jun 2006 01:34:32 -0400
Message-ID: <20060628053432.GA27226@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: latten@austin.ibm.com, sergeh@us.ibm.com, gcwilson@us.ibm.com,
	czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:62657 "EHLO
	igw2.watson.ibm.com") by vger.kernel.org with ESMTP
	id S1422694AbWF1F0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 01:26:49 -0400
To: netdev@vger.kernel.org, davem@davemloft.net, jmorris@redhat.com,
	chrisw@osdl.org, herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Minor fix (un-export selinux_get_sock_sid()).

thanks,
Catherine

--

From: cxzhang@watson.ibm.com

This patch implements an API whereby an application can determine the 
label of its peer's Unix datagram sockets via the auxiliary data mechanism of 
recvmsg.

Patch purpose:

This patch enables a security-aware application to retrieve the
security context of the peer of a Unix datagram socket.  The application 
can then use this security context to determine the security context for 
processing on behalf of the peer who sent the packet. 

Patch design and implementation:

The design and implementation is very similar to the UDP case for INET 
sockets.  Basically we build upon the existing Unix domain socket API for
retrieving user credentials.  Linux offers the API for obtaining user
credentials via ancillary messages (i.e., out of band/control messages
that are bundled together with a normal message).  To retrieve the security 
context, the application first indicates to the kernel such desire by 
setting the SO_PASSSEC option via getsockopt.  Then the application 
retrieves the security context using the auxiliary data mechanism.  

An example server application for Unix datagram socket should look like this:

toggle = 1;
toggle_len = sizeof(toggle);

setsockopt(sockfd, SOL_SOCKET, SO_PASSSEC, &toggle, &toggle_len);
recvmsg(sockfd, &msg_hdr, 0);
if (msg_hdr.msg_controllen > sizeof(struct cmsghdr)) {
    cmsg_hdr = CMSG_FIRSTHDR(&msg_hdr);
    if (cmsg_hdr->cmsg_len <= CMSG_LEN(sizeof(scontext)) &&
        cmsg_hdr->cmsg_level == SOL_SOCKET &&
        cmsg_hdr->cmsg_type == SCM_SECURITY) {
        memcpy(&scontext, CMSG_DATA(cmsg_hdr), sizeof(scontext));
    }
}

sock_setsockopt is enhanced with a new socket option SOCK_PASSSEC to allow
a server socket to receive security context of the peer.  

Testing:

We have tested the patch by setting up Unix datagram client and server
applications.  We verified that the server can retrieve the security context 
using the auxiliary data mechanism of recvmsg.


---

 include/asm-alpha/socket.h   |    1 +
 include/asm-arm/socket.h     |    1 +
 include/asm-arm26/socket.h   |    1 +
 include/asm-cris/socket.h    |    1 +
 include/asm-frv/socket.h     |    1 +
 include/asm-h8300/socket.h   |    1 +
 include/asm-i386/socket.h    |    1 +
 include/asm-ia64/socket.h    |    1 +
 include/asm-m32r/socket.h    |    1 +
 include/asm-m68k/socket.h    |    1 +
 include/asm-mips/socket.h    |    1 +
 include/asm-parisc/socket.h  |    1 +
 include/asm-powerpc/socket.h |    1 +
 include/asm-s390/socket.h    |    1 +
 include/asm-sh/socket.h      |    1 +
 include/asm-sparc/socket.h   |    1 +
 include/asm-sparc64/socket.h |    1 +
 include/asm-v850/socket.h    |    1 +
 include/asm-x86_64/socket.h  |    1 +
 include/asm-xtensa/socket.h  |    1 +
 include/linux/net.h          |    1 +
 include/net/af_unix.h        |    6 ++++++
 include/net/scm.h            |   17 +++++++++++++++++
 net/core/sock.c              |   11 +++++++++++
 net/unix/af_unix.c           |   27 +++++++++++++++++++++++++++
 security/selinux/hooks.c     |   11 ++++++++---
 26 files changed, 90 insertions(+), 3 deletions(-)

diff -puN include/asm-alpha/socket.h~lsm-secpeer-unix include/asm-alpha/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-alpha/socket.h~lsm-secpeer-unix	2006-06-27 18:14:52.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-alpha/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -51,6 +51,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		30
+#define SO_PASSSEC		34
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		19
diff -puN include/asm-arm/socket.h~lsm-secpeer-unix include/asm-arm/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-arm/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-arm/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-arm26/socket.h~lsm-secpeer-unix include/asm-arm26/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-arm26/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-arm26/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-cris/socket.h~lsm-secpeer-unix include/asm-cris/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-cris/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-cris/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -50,6 +50,7 @@
 #define SO_ACCEPTCONN          30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -puN include/asm-frv/socket.h~lsm-secpeer-unix include/asm-frv/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-frv/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-frv/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,6 +48,7 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -puN include/asm-h8300/socket.h~lsm-secpeer-unix include/asm-h8300/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-h8300/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-h8300/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-i386/socket.h~lsm-secpeer-unix include/asm-i386/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-i386/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-i386/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-ia64/socket.h~lsm-secpeer-unix include/asm-ia64/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-ia64/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-ia64/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -57,5 +57,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_IA64_SOCKET_H */
diff -puN include/asm-m32r/socket.h~lsm-secpeer-unix include/asm-m32r/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-m32r/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-m32r/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_M32R_SOCKET_H */
diff -puN include/asm-m68k/socket.h~lsm-secpeer-unix include/asm-m68k/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-m68k/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-m68k/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-mips/socket.h~lsm-secpeer-unix include/asm-mips/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-mips/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-mips/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -69,6 +69,7 @@ To add: #define SO_REUSEPORT 0x0200	/* A
 #define SO_PEERSEC		30
 #define SO_SNDBUFFORCE		31
 #define SO_RCVBUFFORCE		33
+#define SO_PASSSEC		34
 
 #ifdef __KERNEL__
 
diff -puN include/asm-parisc/socket.h~lsm-secpeer-unix include/asm-parisc/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-parisc/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-parisc/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		0x401c
 
 #define SO_PEERSEC		0x401d
+#define SO_PASSSEC		0x401e
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-powerpc/socket.h~lsm-secpeer-unix include/asm-powerpc/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-powerpc/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-powerpc/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -55,5 +55,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff -puN include/asm-s390/socket.h~lsm-secpeer-unix include/asm-s390/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-s390/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-s390/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -56,5 +56,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-sh/socket.h~lsm-secpeer-unix include/asm-sh/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-sh/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-sh/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __ASM_SH_SOCKET_H */
diff -puN include/asm-sparc/socket.h~lsm-secpeer-unix include/asm-sparc/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-sparc/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-sparc/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -puN include/asm-sparc64/socket.h~lsm-secpeer-unix include/asm-sparc64/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-sparc64/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-sparc64/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -puN include/asm-v850/socket.h~lsm-secpeer-unix include/asm-v850/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-v850/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-v850/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __V850_SOCKET_H__ */
diff -puN include/asm-x86_64/socket.h~lsm-secpeer-unix include/asm-x86_64/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-x86_64/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-x86_64/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-xtensa/socket.h~lsm-secpeer-unix include/asm-xtensa/socket.h
--- linux-2.6.17-rc6-mm2-JM/include/asm-xtensa/socket.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/asm-xtensa/socket.h	2006-06-27 18:16:31.000000000 -0400
@@ -59,5 +59,6 @@
 
 #define SO_ACCEPTCONN		30
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _XTENSA_SOCKET_H */
diff -puN include/linux/net.h~lsm-secpeer-unix include/linux/net.h
--- linux-2.6.17-rc6-mm2-JM/include/linux/net.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/linux/net.h	2006-06-27 18:16:31.000000000 -0400
@@ -61,6 +61,7 @@ typedef enum {
 #define SOCK_ASYNC_WAITDATA	1
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
+#define SOCK_PASSSEC		4
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff -puN include/net/af_unix.h~lsm-secpeer-unix include/net/af_unix.h
--- linux-2.6.17-rc6-mm2-JM/include/net/af_unix.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/net/af_unix.h	2006-06-27 18:23:28.000000000 -0400
@@ -53,10 +53,16 @@ struct unix_address {
 struct unix_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+#ifdef CONFIG_SECURITY_NETWORK
+	char			*secdata;	/* Security context	*/
+	u32			seclen;		/* Security length	*/
+#endif
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms*)&((skb)->cb))
 #define UNIXCREDS(skb)	(&UNIXCB((skb)).creds)
+#define UNIXSECDATA(skb)	(&UNIXCB((skb)).secdata)
+#define UNIXSECLEN(skb)		(&UNIXCB((skb)).seclen)
 
 #define unix_state_rlock(s)	spin_lock(&unix_sk(s)->lock)
 #define unix_state_runlock(s)	spin_unlock(&unix_sk(s)->lock)
diff -puN include/net/scm.h~lsm-secpeer-unix include/net/scm.h
--- linux-2.6.17-rc6-mm2-JM/include/net/scm.h~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/include/net/scm.h	2006-06-27 18:21:59.000000000 -0400
@@ -19,6 +19,10 @@ struct scm_cookie
 {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+#ifdef CONFIG_SECURITY_NETWORK
+	char			*secdata;	/* Security context	*/
+	u32			seclen;		/* Security length	*/
+#endif
 	unsigned long		seq;		/* Connection seqno	*/
 };
 
@@ -48,6 +52,17 @@ static __inline__ int scm_send(struct so
 	return __scm_send(sock, msg, scm);
 }
 
+#ifdef CONFIG_SECURITY_NETWORK
+static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
+{
+	if (test_bit(SOCK_PASSSEC, &sock->flags) && scm->secdata != NULL)
+		put_cmsg(msg, SOL_SOCKET, SCM_SECURITY, scm->seclen, scm->secdata);
+}
+#else
+static inline void scm_passec(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
+{ }
+#endif /* CONFIG_SECURITY_NETWORK */
+
 static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 				struct scm_cookie *scm, int flags)
 {
@@ -62,6 +77,8 @@ static __inline__ void scm_recv(struct s
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
+	scm_passec(sock, msg, scm);
+
 	if (!scm->fp)
 		return;
 	
diff -puN net/core/sock.c~lsm-secpeer-unix net/core/sock.c
--- linux-2.6.17-rc6-mm2-JM/net/core/sock.c~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/net/core/sock.c	2006-06-27 18:16:31.000000000 -0400
@@ -565,6 +565,13 @@ set_rcvbuf:
 			ret = -ENONET;
 			break;
 
+		case SO_PASSSEC:
+			if (valbool)
+				set_bit(SOCK_PASSSEC, &sock->flags);
+			else
+				clear_bit(SOCK_PASSSEC, &sock->flags);
+			break;
+
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
 		default:
@@ -723,6 +730,10 @@ int sock_getsockopt(struct socket *sock,
 			v.val = sk->sk_state == TCP_LISTEN;
 			break;
 
+		case SO_PASSSEC:
+			v.val = test_bit(SOCK_PASSSEC, &sock->flags) ? 1 : 0;
+			break;
+
 		case SO_PEERSEC:
 			return security_socket_getpeersec_stream(sock, optval, optlen, len);
 
diff -puN net/unix/af_unix.c~lsm-secpeer-unix net/unix/af_unix.c
--- linux-2.6.17-rc6-mm2-JM/net/unix/af_unix.c~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/net/unix/af_unix.c	2006-06-27 18:25:42.000000000 -0400
@@ -128,6 +128,30 @@ static atomic_t unix_nr_socks = ATOMIC_I
 
 #define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
 
+#ifdef CONFIG_SECURITY_NETWORK
+static void unix_get_peersec_dgram(struct sk_buff *skb)
+{
+	int err;
+
+	err = security_socket_getpeersec_dgram(skb, UNIXSECDATA(skb),
+					       UNIXSECLEN(skb));
+	if (err)
+		*(UNIXSECDATA(skb)) = NULL;
+}
+
+static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
+{
+	scm->secdata = *UNIXSECDATA(skb);
+	scm->seclen = *UNIXSECLEN(skb);
+}
+#else
+static void unix_get_peersec_dgram(struct sk_buff *skb)
+{ }
+
+static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
+{ }
+#endif /* CONFIG_SECURITY_NETWORK */
+
 /*
  *  SMP locking strategy:
  *    hash table is protected with spinlock unix_table_lock
@@ -1291,6 +1315,8 @@ static int unix_dgram_sendmsg(struct kio
 	if (siocb->scm->fp)
 		unix_attach_fds(siocb->scm, skb);
 
+	unix_get_peersec_dgram(skb);
+
 	skb->h.raw = skb->data;
 	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
 	if (err)
@@ -1570,6 +1596,7 @@ static int unix_dgram_recvmsg(struct kio
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 	siocb->scm->creds = *UNIXCREDS(skb);
+	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK))
 	{
diff -puN security/selinux/hooks.c~lsm-secpeer-unix security/selinux/hooks.c
--- linux-2.6.17-rc6-mm2-JM/security/selinux/hooks.c~lsm-secpeer-unix	2006-06-27 18:15:10.000000000 -0400
+++ linux-2.6.17-rc6-mm2-JM-cxzhang/security/selinux/hooks.c	2006-06-27 23:46:03.625599136 -0400
@@ -69,6 +69,7 @@
 #include <linux/sysctl.h>
 #include <linux/audit.h>
 #include <linux/string.h>
+#include <linux/selinux.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -3396,7 +3397,13 @@ out:	
 static int selinux_socket_getpeersec_dgram(struct sk_buff *skb, char **secdata, u32 *seclen)
 {
 	int err = 0;
-	u32 peer_sid = selinux_socket_getpeer_dgram(skb);
+	u32 peer_sid;
+
+	if (skb->sk->sk_family == PF_UNIX)
+		selinux_get_inode_sid(SOCK_INODE(skb->sk->sk_socket),
+				      &peer_sid);
+	else
+		peer_sid = selinux_socket_getpeer_dgram(skb);
 
 	if (peer_sid == SECSID_NULL)
 		return -EINVAL;
@@ -3408,8 +3415,6 @@ static int selinux_socket_getpeersec_dgr
 	return 0;
 }
 
-
-
 static int selinux_sk_alloc_security(struct sock *sk, int family, gfp_t priority)
 {
 	return sk_alloc_security(sk, family, priority);
_
