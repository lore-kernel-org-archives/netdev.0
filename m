From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 14:43:08 +0100
Message-ID: <20061206134308.GL9556@sunsite.mff.cuni.cz>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <1165410114.5253.218.camel@pmac.infradead.org>
Reply-To: Jakub Jelinek <jakub@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, "Joseph S. Myers" <joseph@codesourcery.com>,         netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,         "David S. Miller" <davem@davemloft.net>
Return-path: <libc-alpha-return-19599-glibc-alpha=m.gmane.org@sourceware.org>
To: Ulrich Drepper <drepper@redhat.com>, David Woodhouse <dwmw2@infradead.org>
Content-Disposition: inline
In-Reply-To: <1165410114.5253.218.camel@pmac.infradead.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 06, 2006 at 01:01:54PM +0000, David Woodhouse wrote:
> No. They _are_ doing it right -- they're running 'make headers_install'
> against the 2.6.19 kernel and only _now_ are they finding that we broke
> it without even the courtesy of a warning, let alone any consultation.
> 
> If _we_ had done it right, then they would have been warned when we
> decided to change this, and we wouldn't have just released 2.6.19 with
> changes which break the glibc build.

Yeah, I don't think glibc was doing anything wrong and the 2.6.19
changes to the make headers_install created headers mean we'd
either need to add configure checks for the headers (we can't
simply #include <linux/if_addr.h> because that header didn't
exist pre 2.6.19 and IF*_{RTA,PAYLOAD} macros were dropped anyway),
or we need to start defining this ourselves.

Here is the second variant.
I just hope further kernel header "cleanups" don't cause similar
breakage though.

2006-12-06  Jakub Jelinek  <jakub@redhat.com>

	* sysdeps/unix/sysv/linux/netlinkaccess.h (struct ifaddrmsg): New type.
	(IFA_UNSPEC, IFA_ADDRESS, IFA_LOCAL, IFA_LABEL, IFA_BROADCAST,
	IFA_ANYCAST, IFA_CACHEINFO, IFA_MULTICAST): New enum.
	(IFA_F_SECONDARY, IFA_F_TEMPORARY, IFA_F_HOMEADDRESS,
	IFA_F_DEPRECATED): Define if not defined.
	(IFA_RTA, IFA_PAYLOAD, IFLA_RTA, IFLA_PAYLOAD): Likewise.
	* sysdeps/unix/sysv/linux/check_pf.c: Include netlinkaccess.h
	instead of asm/types.h, linux/netlink.h and linux/rtnetlink.h.

--- libc/sysdeps/unix/sysv/linux/netlinkaccess.h.jj	2006-01-08 09:21:15.000000000 +0100
+++ libc/sysdeps/unix/sysv/linux/netlinkaccess.h	2006-12-06 13:48:50.000000000 +0100
@@ -25,6 +25,51 @@
 
 #include <kernel-features.h>
 
+/* 2.6.19 kernel headers helpfully removed some macros and
+   moved lots of stuff into new headers, some of which aren't
+   included by linux/rtnetlink.h.  */
+
+#ifndef IFA_MAX
+struct ifaddrmsg
+{
+  uint8_t ifa_family;
+  uint8_t ifa_prefixlen;
+  uint8_t ifa_flags;
+  uint8_t ifa_scope;
+  uint32_t ifa_index;
+};
+
+enum
+{
+  IFA_UNSPEC,
+  IFA_ADDRESS,
+  IFA_LOCAL,
+  IFA_LABEL,
+  IFA_BROADCAST,
+  IFA_ANYCAST,
+  IFA_CACHEINFO,
+  IFA_MULTICAST
+};
+#endif
+
+#ifndef IFA_F_SECONDARY
+# define IFA_F_SECONDARY	0x01
+# define IFA_F_TEMPORARY	IFA_F_SECONDARY
+# define IFA_F_HOMEADDRESS	0x10
+# define IFA_F_DEPRECATED	0x20
+#endif
+
+#ifndef IFA_RTA
+# define IFA_RTA(r) \
+  ((struct rtattr *) ((char *)(r) + NLMSG_ALIGN (sizeof (struct ifaddrmsg))))
+# define IFA_PAYLOAD(n) NLMSG_PAYLOAD (n, sizeof (struct ifaddrmsg))
+#endif
+
+#ifndef IFLA_RTA
+# define IFLA_RTA(r) \
+  ((struct rtattr *) ((char *)(r) + NLMSG_ALIGN (sizeof (struct ifinfomsg))))
+# define IFLA_PAYLOAD(n) NLMSG_PAYLOAD (n, sizeof (struct ifinfomsg))
+#endif
 
 struct netlink_res
 {
--- libc/sysdeps/unix/sysv/linux/check_pf.c.jj	2006-09-24 18:50:22.000000000 +0200
+++ libc/sysdeps/unix/sysv/linux/check_pf.c	2006-12-06 13:54:37.000000000 +0100
@@ -27,13 +27,10 @@
 #include <unistd.h>
 #include <sys/socket.h>
 
-#include <asm/types.h>
-#include <linux/netlink.h>
-#include <linux/rtnetlink.h>
-
 #include <not-cancel.h>
 #include <kernel-features.h>
 
+#include "netlinkaccess.h"
 
 #ifndef IFA_F_TEMPORARY
 # define IFA_F_TEMPORARY IFA_F_SECONDARY


	Jakub
