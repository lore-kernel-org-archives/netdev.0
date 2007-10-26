From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH v2] 2.6.24-rc1 remove architecture warning compiling fealnx
 on ia64
Date: Fri, 26 Oct 2007 17:27:09 -0400
Message-ID: <47225BAD.4080801@garzik.org>
References: <200710262104.OAA14012@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090805090708010206070303"
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42182 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764553AbXJZV1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 17:27:14 -0400
In-Reply-To: <200710262104.OAA14012@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090805090708010206070303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Rick Jones wrote:
> The likelihood of one of these being used on an ia64 box is epsilon
> but it would still be nice to get rid of the warning:
> 
>  #warning Processor architecture undefined! 
> 
> when compiling on same. So, pick some likely similar architectures
> and follow those leads. Compile tested only.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---
> diff -r 35e54d4beaad drivers/net/fealnx.c
> --- a/drivers/net/fealnx.c	Wed Oct 24 05:06:40 2007 +0000
> +++ b/drivers/net/fealnx.c	Fri Oct 26 06:12:00 2007 -0700
> @@ -866,7 +866,7 @@ static int netdev_open(struct net_device
>  //   np->bcrvalue=0x04 | 0x0x38;  /* big-endian, 256 burst length */
>  	np->bcrvalue = 0x04 | 0x10;	/* big-endian, tx 8 burst length */
>  	np->crvalue = 0xe00;	/* rx 128 burst length */
> -#elif defined(__alpha__) || defined(__x86_64__)
> +#elif defined(__alpha__) || defined(__x86_64__) || defined(__ia64__)
>  // 89/9/1 modify,
>  //   np->bcrvalue=0x38;           /* little-endian, 256 burst length */
>  	np->bcrvalue = 0x10;	/* little-endian, 8 burst length */

Overall that poor driver is more than a little bit ugly :)

Looking at the large chain of highly-similar values, I would tend to 
prefer the attached patch...

	Jeff



--------------090805090708010206070303
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 7bb9c72..3c1364d 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -90,6 +90,7 @@ static int full_duplex[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1 };
 #include <asm/processor.h>	/* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/uaccess.h>
+#include <asm/byteorder.h>
 
 /* These identify the driver base version and may not be removed. */
 static char version[] =
@@ -861,40 +862,20 @@ static int netdev_open(struct net_device *dev)
 	   Wait the specified 50 PCI cycles after a reset by initializing
 	   Tx and Rx queues and the address filter list.
 	   FIXME (Ueimor): optimistic for alpha + posted writes ? */
-#if defined(__powerpc__) || defined(__sparc__)
-// 89/9/1 modify,
-//   np->bcrvalue=0x04 | 0x0x38;  /* big-endian, 256 burst length */
-	np->bcrvalue = 0x04 | 0x10;	/* big-endian, tx 8 burst length */
-	np->crvalue = 0xe00;	/* rx 128 burst length */
-#elif defined(__alpha__) || defined(__x86_64__)
-// 89/9/1 modify,
-//   np->bcrvalue=0x38;           /* little-endian, 256 burst length */
-	np->bcrvalue = 0x10;	/* little-endian, 8 burst length */
-	np->crvalue = 0xe00;	/* rx 128 burst length */
-#elif defined(__i386__)
-#if defined(MODULE)
-// 89/9/1 modify,
-//   np->bcrvalue=0x38;           /* little-endian, 256 burst length */
+
 	np->bcrvalue = 0x10;	/* little-endian, 8 burst length */
-	np->crvalue = 0xe00;	/* rx 128 burst length */
-#else
-	/* When not a module we can work around broken '486 PCI boards. */
-#define x86 boot_cpu_data.x86
-// 89/9/1 modify,
-//   np->bcrvalue=(x86 <= 4 ? 0x10 : 0x38);
-	np->bcrvalue = 0x10;
-	np->crvalue = (x86 <= 4 ? 0xa00 : 0xe00);
-	if (x86 <= 4)
-		printk(KERN_INFO "%s: This is a 386/486 PCI system, setting burst "
-		       "length to %x.\n", dev->name, (x86 <= 4 ? 0x10 : 0x38));
+#ifdef __BIG_ENDIAN
+	np->bcrvalue |= 0x04;	/* big-endian */
 #endif
-#else
-// 89/9/1 modify,
-//   np->bcrvalue=0x38;
-	np->bcrvalue = 0x10;
-	np->crvalue = 0xe00;	/* rx 128 burst length */
-#warning Processor architecture undefined!
+
+#if defined(__i386__) && !defined(MODULE)
+	if (boot_cpu_data.x86 <= 4)
+		np->crvalue = 0xa00;
+	else
 #endif
+		np->crvalue = 0xe00;	/* rx 128 burst length */
+
+
 // 89/12/29 add,
 // 90/1/16 modify,
 //   np->imrvalue=FBE|TUNF|CNTOVF|RBU|TI|RI;

--------------090805090708010206070303--
