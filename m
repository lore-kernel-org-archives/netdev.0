From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v2] uapi glibc compat: fix compile errors when glibc net/if.h included before linux/if.h
Date: Sun, 24 Apr 2016 17:45:00 +0200
Message-ID: <1461512707-23058-1-git-send-email-mikko.rapeli__34748.27880641$1462831734$gmane$org@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@inai.de>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	Waldemar Brodkorb <mail@waldemar-brodkorb.de>,
	Gabriel Laskar <gabriel@lse.epita.fr>,
	netfilter-devel@vger.kernel.org, libc-alpha@sourceware.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:39310 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbcEIWIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 18:08:25 -0400
Received: from lakka.kapsi.fi ([2001:1bc8:1004::1] ident=Debian-exim)
	by mail.kapsi.fi with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <mikko.rapeli@iki.fi>)
	id 1aztLh-00019e-Tc
	for netdev@vger.kernel.org; Tue, 10 May 2016 01:08:21 +0300
Received: from mcfrisk by lakka.kapsi.fi with local (Exim 4.84_2)
	(envelope-from <mikko.rapeli@iki.fi>)
	id 1aztLh-0005JW-S8
	for netdev@vger.kernel.org; Tue, 10 May 2016 01:08:21 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

glibc's net/if.h contains copies of definitions from linux/if.h and the=
se
conflict and cause build failures if both files are included by applica=
tion
source code. Changes in uapi headers, which fixed header file dependenc=
ies to
include linux/if.h when it was needed, e.g. commit 1ffad83d, made the
net/if.h and linux/if.h incompatibilities visible as build failures for
userspace applications like iproute2 and xtables-addons.

This patch fixes compile errors when glibc net/if.h is included before
linux/if.h:

=2E/linux/if.h:99:21: error: redeclaration of enumerator =E2=80=98IFF_N=
OARP=E2=80=99
=2E/linux/if.h:98:23: error: redeclaration of enumerator =E2=80=98IFF_R=
UNNING=E2=80=99
=2E/linux/if.h:97:26: error: redeclaration of enumerator =E2=80=98IFF_N=
OTRAILERS=E2=80=99
=2E/linux/if.h:96:27: error: redeclaration of enumerator =E2=80=98IFF_P=
OINTOPOINT=E2=80=99
=2E/linux/if.h:95:24: error: redeclaration of enumerator =E2=80=98IFF_L=
OOPBACK=E2=80=99
=2E/linux/if.h:94:21: error: redeclaration of enumerator =E2=80=98IFF_D=
EBUG=E2=80=99
=2E/linux/if.h:93:25: error: redeclaration of enumerator =E2=80=98IFF_B=
ROADCAST=E2=80=99
=2E/linux/if.h:92:19: error: redeclaration of enumerator =E2=80=98IFF_U=
P=E2=80=99
=2E/linux/if.h:252:8: error: redefinition of =E2=80=98struct ifconf=E2=80=
=99
=2E/linux/if.h:203:8: error: redefinition of =E2=80=98struct ifreq=E2=80=
=99
=2E/linux/if.h:169:8: error: redefinition of =E2=80=98struct ifmap=E2=80=
=99
=2E/linux/if.h:107:23: error: redeclaration of enumerator =E2=80=98IFF_=
DYNAMIC=E2=80=99
=2E/linux/if.h:106:25: error: redeclaration of enumerator =E2=80=98IFF_=
AUTOMEDIA=E2=80=99
=2E/linux/if.h:105:23: error: redeclaration of enumerator =E2=80=98IFF_=
PORTSEL=E2=80=99
=2E/linux/if.h:104:25: error: redeclaration of enumerator =E2=80=98IFF_=
MULTICAST=E2=80=99
=2E/linux/if.h:103:21: error: redeclaration of enumerator =E2=80=98IFF_=
SLAVE=E2=80=99
=2E/linux/if.h:102:22: error: redeclaration of enumerator =E2=80=98IFF_=
MASTER=E2=80=99
=2E/linux/if.h:101:24: error: redeclaration of enumerator =E2=80=98IFF_=
ALLMULTI=E2=80=99
=2E/linux/if.h:100:23: error: redeclaration of enumerator =E2=80=98IFF_=
PROMISC=E2=80=99

The cases where linux/if.h is included before net/if.h need a similar f=
ix in
the glibc side, or the order of include files can be changed userspace
code as a workaround.

This change was tested in x86 userspace on Debian unstable with
scripts/headers_compile_test.sh:

$ make headers_install && \
  cd usr/include && ../../scripts/headers_compile_test.sh -l -k
=2E..
cc -Wall -c -nostdinc -I /usr/lib/gcc/i586-linux-gnu/5/include -I /usr/=
lib/gcc/i586-linux-gnu/5/include-fixed -I . -I /home/mcfrisk/src/linux-=
2.6/usr/headers_compile_test_include.2uX2zH -I /home/mcfrisk/src/linux-=
2.6/usr/headers_compile_test_include.2uX2zH/i586-linux-gnu -o /dev/null=
 ./linux/if.h_libc_before_kernel.h
PASSED libc before kernel test: ./linux/if.h

Reported-by: Jan Engelhardt <jengelh@inai.de>
Reported-by: Josh Boyer <jwboyer@fedoraproject.org>
Reported-by: Stephen Hemminger <shemming@brocade.com>
Reported-by: Waldemar Brodkorb <mail@waldemar-brodkorb.de>
Cc: Gabriel Laskar <gabriel@lse.epita.fr>
Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if.h          | 28 +++++++++++++++++++++++++
 include/uapi/linux/libc-compat.h | 44 ++++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 72 insertions(+)

v1:
http://marc.info/?l=3Dlinux-kernel&m=3D145485386721798&w=3D2

v2:
Added handling for net_device_flags IFF_LOWER_UP, IFF_DORMANT and IFF_E=
CHO
which are unknown to glibc as suggested by David Miller in
http://marc.info/?l=3Dlinux-kernel&m=3D145650410726228&w=3D2

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index f802775..e601c8c 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -19,14 +19,20 @@
 #ifndef _LINUX_IF_H
 #define _LINUX_IF_H
=20
+#include <linux/libc-compat.h>          /* for compatibility with glib=
c */
 #include <linux/types.h>		/* for "__kernel_caddr_t" et al	*/
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 #include <linux/compiler.h>		/* for "__user" et al           */
=20
+#if __UAPI_DEF_IF_IFNAMSIZ
 #define	IFNAMSIZ	16
+#endif /* __UAPI_DEF_IF_IFNAMSIZ */
 #define	IFALIASZ	256
 #include <linux/hdlc/ioctl.h>
=20
+/* For glibc compatibility. An empty enum does not compile. */
+#if __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO !=3D 0 && \
+    __UAPI_DEF_IF_NET_DEVICE_FLAGS !=3D 0
 /**
  * enum net_device_flags - &struct net_device flags
  *
@@ -68,6 +74,8 @@
  * @IFF_ECHO: echo sent packets. Volatile.
  */
 enum net_device_flags {
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_NET_DEVICE_FLAGS
 	IFF_UP				=3D 1<<0,  /* sysfs */
 	IFF_BROADCAST			=3D 1<<1,  /* volatile */
 	IFF_DEBUG			=3D 1<<2,  /* sysfs */
@@ -84,11 +92,17 @@ enum net_device_flags {
 	IFF_PORTSEL			=3D 1<<13, /* sysfs */
 	IFF_AUTOMEDIA			=3D 1<<14, /* sysfs */
 	IFF_DYNAMIC			=3D 1<<15, /* sysfs */
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS */
+#if __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO
 	IFF_LOWER_UP			=3D 1<<16, /* volatile */
 	IFF_DORMANT			=3D 1<<17, /* volatile */
 	IFF_ECHO			=3D 1<<18, /* volatile */
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO */
 };
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO !=3D 0 =
&& __UAPI_DEF_IF_NET_DEVICE_FLAGS !=3D 0 */
=20
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_NET_DEVICE_FLAGS
 #define IFF_UP				IFF_UP
 #define IFF_BROADCAST			IFF_BROADCAST
 #define IFF_DEBUG			IFF_DEBUG
@@ -105,9 +119,13 @@ enum net_device_flags {
 #define IFF_PORTSEL			IFF_PORTSEL
 #define IFF_AUTOMEDIA			IFF_AUTOMEDIA
 #define IFF_DYNAMIC			IFF_DYNAMIC
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS */
+
+#if __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO
 #define IFF_LOWER_UP			IFF_LOWER_UP
 #define IFF_DORMANT			IFF_DORMANT
 #define IFF_ECHO			IFF_ECHO
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO */
=20
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_E=
CHO|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
@@ -166,6 +184,8 @@ enum {
  *	being very small might be worth keeping for clean configuration.
  */
=20
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_IFMAP
 struct ifmap {
 	unsigned long mem_start;
 	unsigned long mem_end;
@@ -175,6 +195,7 @@ struct ifmap {
 	unsigned char port;
 	/* 3 bytes spare */
 };
+#endif /* __UAPI_DEF_IF_IFMAP */
=20
 struct if_settings {
 	unsigned int type;	/* Type of physical device or protocol */
@@ -200,6 +221,8 @@ struct if_settings {
  * remainder may be interface specific.
  */
=20
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_IFREQ
 struct ifreq {
 #define IFHWADDRLEN	6
 	union
@@ -223,6 +246,7 @@ struct ifreq {
 		struct	if_settings ifru_settings;
 	} ifr_ifru;
 };
+#endif /* __UAPI_DEF_IF_IFREQ */
=20
 #define ifr_name	ifr_ifrn.ifrn_name	/* interface name 	*/
 #define ifr_hwaddr	ifr_ifru.ifru_hwaddr	/* MAC address 		*/
@@ -249,6 +273,8 @@ struct ifreq {
  * must know all networks accessible).
  */
=20
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_IFCONF
 struct ifconf  {
 	int	ifc_len;			/* size of buffer	*/
 	union {
@@ -256,6 +282,8 @@ struct ifconf  {
 		struct ifreq __user *ifcu_req;
 	} ifc_ifcu;
 };
+#endif /* __UAPI_DEF_IF_IFCONF */
+
 #define	ifc_buf	ifc_ifcu.ifcu_buf		/* buffer address	*/
 #define	ifc_req	ifc_ifcu.ifcu_req		/* array of structures	*/
=20
diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc=
-compat.h
index 7d024ce..d5e38c7 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -51,6 +51,40 @@
 /* We have included glibc headers... */
 #if defined(__GLIBC__)
=20
+/* Coordinate with glibc net/if.h header. */
+#if defined(_NET_IF_H)
+
+/* GLIBC headers included first so don't define anything
+ * that would already be defined. */
+
+#define __UAPI_DEF_IF_IFCONF 0
+#define __UAPI_DEF_IF_IFMAP 0
+#define __UAPI_DEF_IF_IFNAMSIZ 0
+#define __UAPI_DEF_IF_IFREQ 0
+/* Everything up to IFF_DYNAMIC, matches net/if.h until glibc 2.23 */
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS 0
+/* For the future if glibc adds IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO=
 */
+#ifndef __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO 1
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO */
+
+#else /* _NET_IF_H */
+
+/* Linux headers included first, and we must define everything
+ * we need. The expectation is that glibc will check the
+ * __UAPI_DEF_* defines and adjust appropriately. */
+
+#define __UAPI_DEF_IF_IFCONF 1
+#define __UAPI_DEF_IF_IFMAP 1
+#define __UAPI_DEF_IF_IFNAMSIZ 1
+#define __UAPI_DEF_IF_IFREQ 1
+/* Everything up to IFF_DYNAMIC, matches net/if.h until glibc 2.23 */
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS 1
+/* For the future if glibc adds IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO=
 */
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO 1
+
+#endif /* _NET_IF_H */
+
 /* Coordinate with glibc netinet/in.h header. */
 #if defined(_NETINET_IN_H)
=20
@@ -117,6 +151,16 @@
  * that we need. */
 #else /* !defined(__GLIBC__) */
=20
+/* Definitions for if.h */
+#define __UAPI_DEF_IF_IFCONF 1
+#define __UAPI_DEF_IF_IFMAP 1
+#define __UAPI_DEF_IF_IFNAMSIZ 1
+#define __UAPI_DEF_IF_IFREQ 1
+/* Everything up to IFF_DYNAMIC, matches net/if.h until glibc 2.23 */
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS 1
+/* For the future if glibc adds IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO=
 */
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS_LOWER_UP_DORMANT_ECHO 1
+
 /* Definitions for in.h */
 #define __UAPI_DEF_IN_ADDR		1
 #define __UAPI_DEF_IN_IPPROTO		1
--=20
2.8.0.rc3
