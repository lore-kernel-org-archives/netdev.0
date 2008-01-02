From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [klibc] [patch] import socket defines
Date: Wed, 02 Jan 2008 10:09:56 -0800
Message-ID: <477BD374.6060506@zytor.com>
References: <200801012029.21432.vapier@gentoo.org> <477AF86E.1080309@zytor.com> <200801020830.43449.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010705010503020402050605"
Cc: Netdev List <netdev@vger.kernel.org>, klibc list <klibc@zytor.com>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:48859 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbYABSKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 13:10:15 -0500
In-Reply-To: <200801020830.43449.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010705010503020402050605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Mike Frysinger wrote:
> On Tuesday 01 January 2008, H. Peter Anvin wrote:
>> Mike Frysinger wrote:
>>> The kernel __GLIBC__ hacks were re-added so as to appease klibc people,
>>> but the klibc people didnt actually fix the problem on their side.  This
>>> patch imports the structures/defines that klibc seems to need.  Build
>>> tested on x86_64 (i dont actually use klibc so no idea how to test it).
>> The whole point was to NOT need to replicate all these structures and
>> constants, which are part of the ABI, in klibc...
> 
> then figure out a way that doesnt make the kernel headers blow for everyone 
> else out there.  change the __GLIBC__ crap to __KLIBC__ or something.

Seems the most logical thing to do would be to break out the small 
portion that everyone wants into <linux/sockaddr.h> or somesuch, and 
then remove those ifdefs entirely.

Proposed patch (still being tested) attached...

	-hpa

--------------010705010503020402050605
Content-Type: text/x-patch;
 name="0001-linux-socket.h-break-out-glibc-portions-into-l.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-linux-socket.h-break-out-glibc-portions-into-l.patch"

>From 727c56ac213bdaedb9247c442375a5979686acf5 Mon Sep 17 00:00:00 2001
From: H. Peter Anvin <hpa@zytor.com>
Date: Wed, 2 Jan 2008 10:08:16 -0800
Subject: [PATCH] <linux/socket.h>: break out "glibc" portions into <linux/sockaddr.h>

Some userspaces (e.g. klibc) want to be able to use the full set of
ABI constants in <linux/socket.h>, others (e.g. glibc) do not, and
rather want just the bare minimum to build a kernel-valid
sockaddr... but apparently they want that much.  This is currently
keyed on the existence of __GLIBC__, which is clearly wrong.

This patch breaks out the "bare minimum" into <linux/sockaddr.h> for
the userspaces who want to do it themselves, and eliminates the
ifdefs completely.

Signed-off-by: H. Peter Anvin <hpa@zytor.com>
---
 include/linux/Kbuild     |    1 +
 include/linux/sockaddr.h |   19 +++++++++++++++++++
 include/linux/socket.h   |   21 ++-------------------
 3 files changed, 22 insertions(+), 19 deletions(-)
 create mode 100644 include/linux/sockaddr.h

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index f30fa92..f8bbb31 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -139,6 +139,7 @@ header-y += rose.h
 header-y += serial_reg.h
 header-y += smbno.h
 header-y += snmp.h
+header-y += sockaddr.h
 header-y += sockios.h
 header-y += som.h
 header-y += sound.h
diff --git a/include/linux/sockaddr.h b/include/linux/sockaddr.h
new file mode 100644
index 0000000..f182083
--- /dev/null
+++ b/include/linux/sockaddr.h
@@ -0,0 +1,19 @@
+#ifndef _KERNEL_SOCKADDR_H
+#define _KERNEL_SOCKADDR_H
+
+/*
+ * Desired design of maximum size and alignment (see RFC2553)
+ */
+#define _K_SS_MAXSIZE	128	/* Implementation specific max size */
+#define _K_SS_ALIGNSIZE	(__alignof__ (struct sockaddr *))
+				/* Implementation specific desired alignment */
+
+struct __kernel_sockaddr_storage {
+	unsigned short	ss_family;		/* address family */
+	/* Following field(s) are implementation specific */
+	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
+				/* space to achieve desired size, */
+				/* _SS_MAXSIZE value minus size of ss_family */
+} __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment */
+
+#endif /* _KERNEL_SOCKADDR_H */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index c22ef1c..9cd6edc 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -1,23 +1,7 @@
 #ifndef _LINUX_SOCKET_H
 #define _LINUX_SOCKET_H
 
-/*
- * Desired design of maximum size and alignment (see RFC2553)
- */
-#define _K_SS_MAXSIZE	128	/* Implementation specific max size */
-#define _K_SS_ALIGNSIZE	(__alignof__ (struct sockaddr *))
-				/* Implementation specific desired alignment */
-
-struct __kernel_sockaddr_storage {
-	unsigned short	ss_family;		/* address family */
-	/* Following field(s) are implementation specific */
-	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
-				/* space to achieve desired size, */
-				/* _SS_MAXSIZE value minus size of ss_family */
-} __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment */
-
-#if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
-
+#include <linux/sockaddr.h>
 #include <asm/socket.h>			/* arch-dependent defines	*/
 #include <linux/sockios.h>		/* the SIOCxxx I/O controls	*/
 #include <linux/uio.h>			/* iovec support		*/
@@ -310,7 +294,6 @@ extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
 extern int move_addr_to_user(void *kaddr, int klen, void __user *uaddr, int __user *ulen);
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
+#endif /* __KERNEL__ */
 
-#endif
-#endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
-- 
1.5.3.6


--------------010705010503020402050605--
