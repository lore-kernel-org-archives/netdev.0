From: Ben Hutchings <ben@decadent.org.uk>
Subject: Bug#538372: [PATCH] net: Support inclusion of <linux/socket.h> before <sys/socket.h>
Date: Sun, 04 Oct 2009 04:42:44 +0100
Message-ID: <1254627764.2395.48.camel@localhost>
Reply-To: Ben Hutchings <ben@decadent.org.uk>, 538372@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Bastian Blank <waldi@debian.org>, Manuel Prinz <manuel@debian.org>, 538372@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.538372.B538372.125462777514271@bugs.debian.org>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

From: Bastian Blank <waldi@debian.org>

The following user-space program fails to compile:

    #include <linux/socket.h>
    #include <sys/socket.h>
    int main() { return 0; }

The reason is that <linux/socket.h> tests __GLIBC__ to decide whether it
should define various structures and macros that are now defined for
user-space by <sys/socket.h>, but __GLIBC__ is not defined if no libc
headers have yet been included.

It seems safe to drop support for libc 5 now.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This patch was previously mentioned on netdev by Manuel Prinz, but
without a full explanation.  Hopefully the above is sufficient.

Bastian, please add your S-o-b.

Ben.

--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -16,7 +16,7 @@ struct __kernel_sockaddr_storage {
 				/* _SS_MAXSIZE value minus size of ss_family */
 } __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment *=
/
=20
-#if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
+#ifdef __KERNEL__
=20
 #include <asm/socket.h>			/* arch-dependent defines	*/
 #include <linux/sockios.h>		/* the SIOCxxx I/O controls	*/
@@ -101,21 +101,6 @@ struct cmsghdr {
 			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
=20
 /*
- *	This mess will go away with glibc
- */
-=20
-#ifdef __KERNEL__
-#define __KINLINE static inline
-#elif  defined(__GNUC__)=20
-#define __KINLINE static __inline__
-#elif defined(__cplusplus)
-#define __KINLINE static inline
-#else
-#define __KINLINE static
-#endif
-
-
-/*
  *	Get the next cmsg header
  *
  *	PLEASE, do not touch this function. If you think, that it is
@@ -128,7 +113,7 @@ struct cmsghdr {
  *	ancillary object DATA.				--ANK (980731)
  */
 =20
-__KINLINE struct cmsghdr * __cmsg_nxthdr(void *__ctl, __kernel_size_t __si=
ze,
+static inline struct cmsghdr * __cmsg_nxthdr(void *__ctl, __kernel_size_t =
__size,
 					       struct cmsghdr *__cmsg)
 {
 	struct cmsghdr * __ptr;
@@ -140,7 +125,7 @@ __KINLINE struct cmsghdr * __cmsg_nxthdr(void *__ctl, _=
_kernel_size_t __size,
 	return __ptr;
 }
=20
-__KINLINE struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsgh=
dr *__cmsg)
+static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct c=
msghdr *__cmsg)
 {
 	return __cmsg_nxthdr(__msg->msg_control, __msg->msg_controllen, __cmsg);
 }

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.
