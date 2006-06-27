From: James Morris <jmorris@namei.org>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec [Updated #2]
Date: Tue, 27 Jun 2006 09:57:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606270954080.804@d.namei>
References: <20060627052255.GA1311@jiayuguan.watson.ibm.com>
 <Pine.LNX.4.64.0606270311210.30073@d.namei>  <Pine.LNX.4.64.0606270315130.30073@d.namei>
 <1151414069.20419.37.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Catherine Zhang <cxzhang@watson.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, jmorris@redhat.com,
	chrisw@osdl.org, Herbert Xu <herbert@gondor.apana.org.au>,
	tjaeger@cse.psu.edu, Andrew Morton <akpm@osdl.org>,
	latten@austin.ibm.com, sergeh@us.ibm.com, gcwilson@us.ibm.com,
	czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:37865 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932161AbWF0N5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 09:57:20 -0400
To: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <1151414069.20419.37.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2006, Stephen Smalley wrote:

> What about saving the u32 seclen with the secdata, and using it later
> rather than recomputing strlen(secdata)?  That also avoids encoding an
> assumption in the af_unix code about the content of the data (i.e.
> NUL-terminated string), leaving that to the security module.

Ok, this and other issues are addressed in the patch below, which is now 
back to a single patch.

I also #ifdef'd the security fields in struct unix_skb_parms.

Please review and test.

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
 include/linux/selinux.h      |   15 +++++++++++++++
 include/net/af_unix.h        |    7 +++++++
 include/net/scm.h            |   17 +++++++++++++++++
 net/core/sock.c              |   11 +++++++++++
 net/unix/af_unix.c           |   25 +++++++++++++++++++++++++
 security/selinux/exports.c   |   11 +++++++++++
 security/selinux/hooks.c     |    8 +++++++-
 28 files changed, 114 insertions(+), 1 deletion(-)

diff -purN -X dontdiff linux-2.6.o/include/asm-alpha/socket.h linux-2.6.w/include/asm-alpha/socket.h
--- linux-2.6.o/include/asm-alpha/socket.h	2006-06-21 00:02:08.000000000 -0400
+++ linux-2.6.w/include/asm-alpha/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -51,6 +51,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		30
+#define SO_PASSSEC		34
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		19
diff -purN -X dontdiff linux-2.6.o/include/asm-arm/socket.h linux-2.6.w/include/asm-arm/socket.h
--- linux-2.6.o/include/asm-arm/socket.h	2006-06-21 00:02:10.000000000 -0400
+++ linux-2.6.w/include/asm-arm/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-arm26/socket.h linux-2.6.w/include/asm-arm26/socket.h
--- linux-2.6.o/include/asm-arm26/socket.h	2006-06-21 00:02:10.000000000 -0400
+++ linux-2.6.w/include/asm-arm26/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-cris/socket.h linux-2.6.w/include/asm-cris/socket.h
--- linux-2.6.o/include/asm-cris/socket.h	2006-06-21 00:02:11.000000000 -0400
+++ linux-2.6.w/include/asm-cris/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -50,6 +50,7 @@
 #define SO_ACCEPTCONN          30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -purN -X dontdiff linux-2.6.o/include/asm-frv/socket.h linux-2.6.w/include/asm-frv/socket.h
--- linux-2.6.o/include/asm-frv/socket.h	2006-06-21 00:02:11.000000000 -0400
+++ linux-2.6.w/include/asm-frv/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,6 +48,7 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -purN -X dontdiff linux-2.6.o/include/asm-h8300/socket.h linux-2.6.w/include/asm-h8300/socket.h
--- linux-2.6.o/include/asm-h8300/socket.h	2006-06-21 00:02:11.000000000 -0400
+++ linux-2.6.w/include/asm-h8300/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-i386/socket.h linux-2.6.w/include/asm-i386/socket.h
--- linux-2.6.o/include/asm-i386/socket.h	2006-06-21 00:02:12.000000000 -0400
+++ linux-2.6.w/include/asm-i386/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-ia64/socket.h linux-2.6.w/include/asm-ia64/socket.h
--- linux-2.6.o/include/asm-ia64/socket.h	2006-06-21 00:02:12.000000000 -0400
+++ linux-2.6.w/include/asm-ia64/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -57,5 +57,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_IA64_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-m32r/socket.h linux-2.6.w/include/asm-m32r/socket.h
--- linux-2.6.o/include/asm-m32r/socket.h	2006-06-21 00:02:13.000000000 -0400
+++ linux-2.6.w/include/asm-m32r/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_M32R_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-m68k/socket.h linux-2.6.w/include/asm-m68k/socket.h
--- linux-2.6.o/include/asm-m68k/socket.h	2006-06-21 00:02:13.000000000 -0400
+++ linux-2.6.w/include/asm-m68k/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-mips/socket.h linux-2.6.w/include/asm-mips/socket.h
--- linux-2.6.o/include/asm-mips/socket.h	2006-06-21 00:02:15.000000000 -0400
+++ linux-2.6.w/include/asm-mips/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -69,6 +69,7 @@ To add: #define SO_REUSEPORT 0x0200	/* A
 #define SO_PEERSEC		30
 #define SO_SNDBUFFORCE		31
 #define SO_RCVBUFFORCE		33
+#define SO_PASSSEC		34
 
 #ifdef __KERNEL__
 
diff -purN -X dontdiff linux-2.6.o/include/asm-parisc/socket.h linux-2.6.w/include/asm-parisc/socket.h
--- linux-2.6.o/include/asm-parisc/socket.h	2006-06-21 00:02:15.000000000 -0400
+++ linux-2.6.w/include/asm-parisc/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		0x401c
 
 #define SO_PEERSEC		0x401d
+#define SO_PASSSEC		0x401e
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-powerpc/socket.h linux-2.6.w/include/asm-powerpc/socket.h
--- linux-2.6.o/include/asm-powerpc/socket.h	2006-06-21 00:02:16.000000000 -0400
+++ linux-2.6.w/include/asm-powerpc/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -55,5 +55,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-s390/socket.h linux-2.6.w/include/asm-s390/socket.h
--- linux-2.6.o/include/asm-s390/socket.h	2006-06-21 00:02:17.000000000 -0400
+++ linux-2.6.w/include/asm-s390/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -56,5 +56,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-sh/socket.h linux-2.6.w/include/asm-sh/socket.h
--- linux-2.6.o/include/asm-sh/socket.h	2006-06-21 00:02:17.000000000 -0400
+++ linux-2.6.w/include/asm-sh/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __ASM_SH_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-sparc/socket.h linux-2.6.w/include/asm-sparc/socket.h
--- linux-2.6.o/include/asm-sparc/socket.h	2006-06-21 00:02:18.000000000 -0400
+++ linux-2.6.w/include/asm-sparc/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -purN -X dontdiff linux-2.6.o/include/asm-sparc64/socket.h linux-2.6.w/include/asm-sparc64/socket.h
--- linux-2.6.o/include/asm-sparc64/socket.h	2006-06-21 00:02:19.000000000 -0400
+++ linux-2.6.w/include/asm-sparc64/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -purN -X dontdiff linux-2.6.o/include/asm-v850/socket.h linux-2.6.w/include/asm-v850/socket.h
--- linux-2.6.o/include/asm-v850/socket.h	2006-06-21 00:02:20.000000000 -0400
+++ linux-2.6.w/include/asm-v850/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __V850_SOCKET_H__ */
diff -purN -X dontdiff linux-2.6.o/include/asm-x86_64/socket.h linux-2.6.w/include/asm-x86_64/socket.h
--- linux-2.6.o/include/asm-x86_64/socket.h	2006-06-21 00:02:20.000000000 -0400
+++ linux-2.6.w/include/asm-x86_64/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/asm-xtensa/socket.h linux-2.6.w/include/asm-xtensa/socket.h
--- linux-2.6.o/include/asm-xtensa/socket.h	2006-06-21 00:02:21.000000000 -0400
+++ linux-2.6.w/include/asm-xtensa/socket.h	2006-06-27 02:08:49.000000000 -0400
@@ -59,5 +59,6 @@
 
 #define SO_ACCEPTCONN		30
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _XTENSA_SOCKET_H */
diff -purN -X dontdiff linux-2.6.o/include/linux/net.h linux-2.6.w/include/linux/net.h
--- linux-2.6.o/include/linux/net.h	2006-06-21 00:02:23.000000000 -0400
+++ linux-2.6.w/include/linux/net.h	2006-06-27 02:08:49.000000000 -0400
@@ -61,6 +61,7 @@ typedef enum {
 #define SOCK_ASYNC_WAITDATA	1
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
+#define SOCK_PASSSEC		4
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff -purN -X dontdiff linux-2.6.o/include/linux/selinux.h linux-2.6.w/include/linux/selinux.h
--- linux-2.6.o/include/linux/selinux.h	2006-06-21 00:02:23.000000000 -0400
+++ linux-2.6.w/include/linux/selinux.h	2006-06-27 02:18:47.000000000 -0400
@@ -18,6 +18,7 @@ struct selinux_audit_rule;
 struct audit_context;
 struct inode;
 struct kern_ipc_perm;
+struct socket;
 
 #ifdef CONFIG_SECURITY_SELINUX
 
@@ -119,6 +120,15 @@ void selinux_get_ipc_sid(const struct ke
 void selinux_get_task_sid(struct task_struct *tsk, u32 *sid);
 
 /**
+ *     selinux_get_sock_sid - return the SID of socket
+ *     @sock: the socket whose SID will be returned
+ *     @sid: pointer to security context ID to be filled in.
+ *
+ *     Returns nothing
+ */
+void selinux_get_sock_sid(struct socket *sock, u32 *sid);
+
+/**
  *     selinux_string_to_sid - map a security context string to a security ID
  *     @str: the security context string to be mapped
  *     @sid: ID value returned via this.
@@ -193,6 +203,11 @@ static inline void selinux_get_task_sid(
 	*sid = 0;
 }
 
+static inline void selinux_get_sock_sid(struct socket *sock, u32 *sid)
+{
+	*sid = 0;
+}
+
 static inline int selinux_string_to_sid(const char *str, u32 *sid)
 {
        *sid = 0;
diff -purN -X dontdiff linux-2.6.o/include/net/af_unix.h linux-2.6.w/include/net/af_unix.h
--- linux-2.6.o/include/net/af_unix.h	2006-06-21 00:02:24.000000000 -0400
+++ linux-2.6.w/include/net/af_unix.h	2006-06-27 09:28:04.000000000 -0400
@@ -53,10 +53,17 @@ struct unix_address {
 struct unix_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+#ifdef CONFIG_SECURITY_NETWORKING
+	char			*secdata;	/* Security context	*/
+	u32			seclen;		/* Security length	*/
+#endif
+	
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms*)&((skb)->cb))
 #define UNIXCREDS(skb)	(&UNIXCB((skb)).creds)
+#define UNIXSECDATA(skb)	(&UNIXCB((skb)).secdata)
+#define UNIXSECLEN(skb)		(&UNIXCB((skb)).seclen)
 
 #define unix_state_rlock(s)	spin_lock(&unix_sk(s)->lock)
 #define unix_state_runlock(s)	spin_unlock(&unix_sk(s)->lock)
diff -purN -X dontdiff linux-2.6.o/include/net/scm.h linux-2.6.w/include/net/scm.h
--- linux-2.6.o/include/net/scm.h	2006-06-21 00:02:24.000000000 -0400
+++ linux-2.6.w/include/net/scm.h	2006-06-27 09:32:27.000000000 -0400
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
+#endif	/* CONFIG_SECURITY_NETWORK */
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
 	
diff -purN -X dontdiff linux-2.6.o/net/core/sock.c linux-2.6.w/net/core/sock.c
--- linux-2.6.o/net/core/sock.c	2006-06-21 00:02:27.000000000 -0400
+++ linux-2.6.w/net/core/sock.c	2006-06-27 02:08:49.000000000 -0400
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
 
diff -purN -X dontdiff linux-2.6.o/net/unix/af_unix.c linux-2.6.w/net/unix/af_unix.c
--- linux-2.6.o/net/unix/af_unix.c	2006-06-21 00:02:30.000000000 -0400
+++ linux-2.6.w/net/unix/af_unix.c	2006-06-27 09:30:12.000000000 -0400
@@ -128,6 +128,28 @@ static atomic_t unix_nr_socks = ATOMIC_I
 
 #define UNIX_ABSTRACT(sk)	(unix_sk(sk)->addr->hash != UNIX_HASH_SIZE)
 
+#ifdef CONFIG_SECURITY_NETWORKING
+static void unix_get_peersec_dgram(struct sk_buff *skb)
+{
+	err = security_socket_getpeersec_dgram(skb, UNIXSECDATA(skb),
+					       UNIXSECLEN(skb));
+	if (err)
+		*(UNIXSEC(skb)) = NULL;
+}
+
+static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
+{
+	scm->secdata = *UNIXSECDATA(skb);
+	scm->seclen = UNIXSECLEN(skb);
+}
+#else
+static void unix_get_peersec_dgram(struct sk_buff *skb)
+{ }
+
+static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
+{ }
+#endif /* CONFIG_SECURITY_NETWORKING */
+
 /*
  *  SMP locking strategy:
  *    hash table is protected with spinlock unix_table_lock
@@ -1291,6 +1313,8 @@ static int unix_dgram_sendmsg(struct kio
 	if (siocb->scm->fp)
 		unix_attach_fds(siocb->scm, skb);
 
+	unix_get_peersec_dgram(skb);
+
 	skb->h.raw = skb->data;
 	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
 	if (err)
@@ -1570,6 +1594,7 @@ static int unix_dgram_recvmsg(struct kio
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 	siocb->scm->creds = *UNIXCREDS(skb);
+	unix_set_secdata(siocb->scm, skb);
 
 	if (!(flags & MSG_PEEK))
 	{
diff -purN -X dontdiff linux-2.6.o/security/selinux/exports.c linux-2.6.w/security/selinux/exports.c
--- linux-2.6.o/security/selinux/exports.c	2006-06-21 00:02:31.000000000 -0400
+++ linux-2.6.w/security/selinux/exports.c	2006-06-27 02:19:16.000000000 -0400
@@ -17,6 +17,7 @@
 #include <linux/selinux.h>
 #include <linux/fs.h>
 #include <linux/ipc.h>
+#include <net/sock.h>
 
 #include "security.h"
 #include "objsec.h"
@@ -72,6 +73,16 @@ void selinux_get_task_sid(struct task_st
 	*sid = 0;
 }
 
+void selinux_get_sock_sid(struct socket *sock, u32 *sid)
+{
+	if (selinux_enabled) {
+		const struct inode *inode = SOCK_INODE(sock);
+		selinux_get_inode_sid(inode, sid);
+		return;
+	}
+	*sid = 0;
+}
+
 int selinux_string_to_sid(char *str, u32 *sid)
 {
 	if (selinux_enabled)
diff -purN -X dontdiff linux-2.6.o/security/selinux/hooks.c linux-2.6.w/security/selinux/hooks.c
--- linux-2.6.o/security/selinux/hooks.c	2006-06-26 14:47:31.000000000 -0400
+++ linux-2.6.w/security/selinux/hooks.c	2006-06-27 02:08:49.000000000 -0400
@@ -69,6 +69,7 @@
 #include <linux/sysctl.h>
 #include <linux/audit.h>
 #include <linux/string.h>
+#include <linux/selinux.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -3418,7 +3419,12 @@ out:	
 static int selinux_socket_getpeersec_dgram(struct sk_buff *skb, char **secdata, u32 *seclen)
 {
 	int err = 0;
-	u32 peer_sid = selinux_socket_getpeer_dgram(skb);
+	u32 peer_sid;
+
+	if (skb->sk->sk_family == PF_UNIX)
+		selinux_get_sock_sid(skb->sk->sk_socket, &peer_sid);
+	else
+		peer_sid = selinux_socket_getpeer_dgram(skb);
 
 	if (peer_sid == SECSID_NULL)
 		return -EINVAL;
