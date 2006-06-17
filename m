From: Catherine Zhang <cxzhang@watson.ibm.com>
Subject: updated [Patch 1/1] AF_UNIX Datagram getpeersec
Date: Fri, 16 Jun 2006 23:54:40 -0400
Message-ID: <20060617035440.GA28169@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: latten@austin.ibm.com, sergeh@us.ibm.com, gcwilson@us.ibm.com,
	czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:53902 "EHLO
	igw2.watson.ibm.com") by vger.kernel.org with ESMTP
	id S1751597AbWFQDu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 23:50:57 -0400
To: netdev@vger.kernel.org, davem@davemloft.net, jmorris@redhat.com,
	chrisw@osdl.org, herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

Enclosed please find the updated AF_UNIX patch, incorporating comments from
James, Stephen, Dave, Chris, Andrew and others.

The patch is now built upon the newly added SELinux functions exported in
selinux/exports.c, which are also used by the auditing subsystem.  One
function, selinux_get_socket_sid(), is added to the list of exported
functions by this patch.

I have tested it with three configurations: with SELinux, w/o SELinux,
and allmodconfig.

As always, comments are appreciated!

thanks,
Catherine


---

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

 include/asm-alpha/socket.h          |    1 +
 include/asm-arm/socket.h            |    1 +
 include/asm-arm26/socket.h          |    1 +
 include/asm-cris/socket.h           |    1 +
 include/asm-frv/socket.h            |    1 +
 include/asm-h8300/socket.h          |    1 +
 include/asm-i386/socket.h           |    1 +
 include/asm-ia64/socket.h           |    1 +
 include/asm-m32r/socket.h           |    1 +
 include/asm-m68k/socket.h           |    1 +
 include/asm-mips/socket.h           |    1 +
 include/asm-parisc/socket.h         |    1 +
 include/asm-powerpc/socket.h        |    1 +
 include/asm-s390/socket.h           |    1 +
 include/asm-sh/socket.h             |    1 +
 include/asm-sparc/socket.h          |    1 +
 include/asm-sparc64/socket.h        |    1 +
 include/asm-v850/socket.h           |    1 +
 include/asm-x86_64/socket.h         |    1 +
 include/asm-xtensa/socket.h         |    1 +
 include/linux/net.h                 |    1 +
 include/net/af_unix.h               |    2 ++
 include/net/scm.h                   |   13 +++++++++++++
 net/core/sock.c                     |   11 +++++++++++
 net/unix/af_unix.c                  |    2 ++
 security/selinux/exports.c          |   11 +++++++++++
 security/selinux/include/security.h |    2 +-
 security/selinux/ss/services.c      |    4 ++--
 28 files changed, 63 insertions(+), 3 deletions(-)

diff -puN include/asm-i386/socket.h~lsm-secpeer-unix include/asm-i386/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-i386/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-i386/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-x86_64/socket.h~lsm-secpeer-unix include/asm-x86_64/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-x86_64/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-x86_64/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-ia64/socket.h~lsm-secpeer-unix include/asm-ia64/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-ia64/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-ia64/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -57,5 +57,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_IA64_SOCKET_H */
diff -puN include/asm-powerpc/socket.h~lsm-secpeer-unix include/asm-powerpc/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-powerpc/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-powerpc/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -55,5 +55,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff -puN include/asm-h8300/socket.h~lsm-secpeer-unix include/asm-h8300/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-h8300/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-h8300/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-s390/socket.h~lsm-secpeer-unix include/asm-s390/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-s390/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-s390/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -56,5 +56,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-mips/socket.h~lsm-secpeer-unix include/asm-mips/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-mips/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-mips/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -69,6 +69,7 @@ To add: #define SO_REUSEPORT 0x0200	/* A
 #define SO_PEERSEC		30
 #define SO_SNDBUFFORCE		31
 #define SO_RCVBUFFORCE		33
+#define SO_PASSSEC		34
 
 #ifdef __KERNEL__
 
diff -puN include/asm-alpha/socket.h~lsm-secpeer-unix include/asm-alpha/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-alpha/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-alpha/socket.h	2006-06-16 16:02:55.000000000 -0400
@@ -51,6 +51,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		30
+#define SO_PASSSEC		34
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		19
diff -puN include/asm-v850/socket.h~lsm-secpeer-unix include/asm-v850/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-v850/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-v850/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __V850_SOCKET_H__ */
diff -puN include/asm-sh/socket.h~lsm-secpeer-unix include/asm-sh/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-sh/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-sh/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* __ASM_SH_SOCKET_H */
diff -puN include/asm-m68k/socket.h~lsm-secpeer-unix include/asm-m68k/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-m68k/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-m68k/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-arm/socket.h~lsm-secpeer-unix include/asm-arm/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-arm/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-arm/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-cris/socket.h~lsm-secpeer-unix include/asm-cris/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-cris/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-cris/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -50,6 +50,7 @@
 #define SO_ACCEPTCONN          30
 
 #define SO_PEERSEC             31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -puN include/asm-arm26/socket.h~lsm-secpeer-unix include/asm-arm26/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-arm26/socket.h~lsm-secpeer-unix	2006-06-12 17:56:06.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-arm26/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-frv/socket.h~lsm-secpeer-unix include/asm-frv/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-frv/socket.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-frv/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,6 +48,7 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_SOCKET_H */
 
diff -puN include/asm-xtensa/socket.h~lsm-secpeer-unix include/asm-xtensa/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-xtensa/socket.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-xtensa/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -59,5 +59,6 @@
 
 #define SO_ACCEPTCONN		30
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif	/* _XTENSA_SOCKET_H */
diff -puN include/asm-m32r/socket.h~lsm-secpeer-unix include/asm-m32r/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-m32r/socket.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-m32r/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		30
 
 #define SO_PEERSEC		31
+#define SO_PASSSEC		34
 
 #endif /* _ASM_M32R_SOCKET_H */
diff -puN include/asm-parisc/socket.h~lsm-secpeer-unix include/asm-parisc/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-parisc/socket.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-parisc/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,5 +48,6 @@
 #define SO_ACCEPTCONN		0x401c
 
 #define SO_PEERSEC		0x401d
+#define SO_PASSSEC		0x401e
 
 #endif /* _ASM_SOCKET_H */
diff -puN include/asm-sparc/socket.h~lsm-secpeer-unix include/asm-sparc/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-sparc/socket.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-sparc/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -puN include/asm-sparc64/socket.h~lsm-secpeer-unix include/asm-sparc64/socket.h
--- linux-2.6.17-rc6-mm2/include/asm-sparc64/socket.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/asm-sparc64/socket.h	2006-06-13 15:45:34.000000000 -0400
@@ -48,6 +48,7 @@
 #define SCM_TIMESTAMP		SO_TIMESTAMP
 
 #define SO_PEERSEC		0x001e
+#define SO_PASSSEC		0x001f
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff -puN include/linux/net.h~lsm-secpeer-unix include/linux/net.h
--- linux-2.6.17-rc6-mm2/include/linux/net.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/linux/net.h	2006-06-13 15:45:34.000000000 -0400
@@ -61,6 +61,7 @@ typedef enum {
 #define SOCK_ASYNC_WAITDATA	1
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
+#define SOCK_PASSSEC		4
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
diff -puN include/net/af_unix.h~lsm-secpeer-unix include/net/af_unix.h
--- linux-2.6.17-rc6-mm2/include/net/af_unix.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/net/af_unix.h	2006-06-13 15:45:34.000000000 -0400
@@ -53,10 +53,12 @@ struct unix_address {
 struct unix_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	u32			sid;		/* Security ID		*/
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms*)&((skb)->cb))
 #define UNIXCREDS(skb)	(&UNIXCB((skb)).creds)
+#define UNIXSID(skb)	(&UNIXCB((skb)).sid)
 
 #define unix_state_rlock(s)	spin_lock(&unix_sk(s)->lock)
 #define unix_state_runlock(s)	spin_unlock(&unix_sk(s)->lock)
diff -puN include/net/scm.h~lsm-secpeer-unix include/net/scm.h
--- linux-2.6.17-rc6-mm2/include/net/scm.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/include/net/scm.h	2006-06-16 13:58:16.000000000 -0400
@@ -3,6 +3,8 @@
 
 #include <linux/limits.h>
 #include <linux/net.h>
+#include <linux/security.h>
+#include <linux/selinux.h>
 
 /* Well, we should have at least one descriptor open
  * to accept passed FDs 8)
@@ -19,6 +21,7 @@ struct scm_cookie
 {
 	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	u32			sid;		/* Passed security ID	*/
 	unsigned long		seq;		/* Connection seqno	*/
 };
 
@@ -42,6 +45,7 @@ static __inline__ int scm_send(struct so
 	scm->creds.gid = p->gid;
 	scm->creds.pid = p->tgid;
 	scm->fp = NULL;
+	selinux_get_sock_sid(sock, &scm->sid);
 	scm->seq = 0;
 	if (msg->msg_controllen <= 0)
 		return 0;
@@ -51,6 +55,9 @@ static __inline__ int scm_send(struct so
 static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
 				struct scm_cookie *scm, int flags)
 {
+	char *scontext;
+	int scontext_len, err;
+
 	if (!msg->msg_control)
 	{
 		if (test_bit(SOCK_PASSCRED, &sock->flags) || scm->fp)
@@ -62,6 +69,12 @@ static __inline__ void scm_recv(struct s
 	if (test_bit(SOCK_PASSCRED, &sock->flags))
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
 
+	if (test_bit(SOCK_PASSSEC, &sock->flags)) {
+		err = selinux_ctxid_to_string(scm->sid, &scontext, &scontext_len);
+		if (!err)
+			put_cmsg(msg, SOL_SOCKET, SCM_SECURITY, scontext_len, scontext);
+	}
+
 	if (!scm->fp)
 		return;
 	
diff -puN net/core/sock.c~lsm-secpeer-unix net/core/sock.c
--- linux-2.6.17-rc6-mm2/net/core/sock.c~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/net/core/sock.c	2006-06-13 15:45:34.000000000 -0400
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
--- linux-2.6.17-rc6-mm2/net/unix/af_unix.c~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/net/unix/af_unix.c	2006-06-13 15:45:34.000000000 -0400
@@ -1290,6 +1290,7 @@ static int unix_dgram_sendmsg(struct kio
 	memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 	if (siocb->scm->fp)
 		unix_attach_fds(siocb->scm, skb);
+	memcpy(UNIXSID(skb), &siocb->scm->sid, sizeof(u32));
 
 	skb->h.raw = skb->data;
 	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
@@ -1570,6 +1571,7 @@ static int unix_dgram_recvmsg(struct kio
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 	siocb->scm->creds = *UNIXCREDS(skb);
+	siocb->scm->sid   = *UNIXSID(skb);
 
 	if (!(flags & MSG_PEEK))
 	{
diff -puN security/selinux/include/security.h~lsm-secpeer-unix security/selinux/include/security.h
--- linux-2.6.17-rc6-mm2/security/selinux/include/security.h~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/security/selinux/include/security.h	2006-06-13 15:45:34.000000000 -0400
@@ -58,7 +58,7 @@ int security_change_sid(u32 ssid, u32 ts
 int security_sid_to_context(u32 sid, char **scontext,
 	u32 *scontext_len);
 
-int security_context_to_sid(char *scontext, u32 scontext_len,
+int security_context_to_sid(const char *scontext, u32 scontext_len,
 	u32 *out_sid);
 
 int security_context_to_sid_default(char *scontext, u32 scontext_len, u32 *out_sid, u32 def_sid);
diff -puN security/selinux/ss/services.c~lsm-secpeer-unix security/selinux/ss/services.c
--- linux-2.6.17-rc6-mm2/security/selinux/ss/services.c~lsm-secpeer-unix	2006-06-12 17:56:07.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/security/selinux/ss/services.c	2006-06-13 15:45:34.000000000 -0400
@@ -623,7 +623,7 @@ out:
 
 }
 
-static int security_context_to_sid_core(char *scontext, u32 scontext_len, u32 *sid, u32 def_sid)
+static int security_context_to_sid_core(const char *scontext, u32 scontext_len, u32 *sid, u32 def_sid)
 {
 	char *scontext2;
 	struct context context;
@@ -749,7 +749,7 @@ out:
  * Returns -%EINVAL if the context is invalid, -%ENOMEM if insufficient
  * memory is available, or 0 on success.
  */
-int security_context_to_sid(char *scontext, u32 scontext_len, u32 *sid)
+int security_context_to_sid(const char *scontext, u32 scontext_len, u32 *sid)
 {
 	return security_context_to_sid_core(scontext, scontext_len,
 	                                    sid, SECSID_NULL);
diff -puN security/selinux/exports.c~lsm-secpeer-unix security/selinux/exports.c
--- linux-2.6.17-rc6-mm2/security/selinux/exports.c~lsm-secpeer-unix	2006-06-16 16:18:48.000000000 -0400
+++ linux-2.6.17-rc6-mm2-cxzhang/security/selinux/exports.c	2006-06-16 16:18:25.000000000 -0400
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
 
+void selinux_get_sock_sid(const struct socket *sock, u32 *sid)
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
_
