From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: e1000: include <net/ip6_checksum.h> for IA64
Date: Wed, 8 Nov 2006 16:32:03 -0800
Message-ID: <000201c70396$7c049000$ff0da8c0@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andrew Morton'" <akpm@osdl.org>,
	"'NetDev'" <netdev@vger.kernel.org>,
	"'Linux Kernel Mailing List'" <linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Luck, Tony" <tony.luck@intel.com>, <linux-ia64@vger.kernel.org>
Return-path: <linux-ia64-owner@vger.kernel.org>
To: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: 
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chen, Kenneth wrote on Wednesday, November 08, 2006 4:10 PM
> Auke Kok wrote on Wednesday, November 08, 2006 9:49 AM
> > Of course, someone really should come up with an asm version for ia64 of the
> > missing function ;)
> 
> Sure, absolutely.  Here is an implementation for ia64.  Tested heavily. Tony, please > merge.


Hmm.  Forgot about the signed-off line.  Here it is:

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com> 



[patch] implement csum_ipv6_magic for ia64. The asm version is 3.4 times faster than
        the generic version.

--- ./arch/ia64/lib/ip_fast_csum.S.orig	2006-11-08 12:26:28.000000000 -0800
+++ ./arch/ia64/lib/ip_fast_csum.S	2006-11-08 16:39:24.000000000 -0800
@@ -8,8 +8,8 @@
  *      in0: address of buffer to checksum (char *)
  *      in1: length of the buffer (int)
  *
- * Copyright (C) 2002 Intel Corp.
- * Copyright (C) 2002 Ken Chen <kenneth.w.chen@intel.com>
+ * Copyright (C) 2002, 2006 Intel Corp.
+ * Copyright (C) 2002, 2006 Ken Chen <kenneth.w.chen@intel.com>
  */
 
 #include <asm/asmmacro.h>
@@ -25,6 +25,9 @@
 
 #define in0	r32
 #define in1	r33
+#define in2	r34
+#define in3	r35
+#define in4	r36
 #define ret0	r8
 
 GLOBAL_ENTRY(ip_fast_csum)
@@ -88,3 +91,51 @@ GLOBAL_ENTRY(ip_fast_csum)
 	mov	b0=r34
 	br.ret.sptk.many b0
 END(ip_fast_csum)
+
+GLOBAL_ENTRY(csum_ipv6_magic)
+	ld4	r20=[in0],4
+	ld4	r21=[in1],4
+	dep	r15=in2,in3,16,16
+	;;
+	ld4	r22=[in0],4
+	ld4	r23=[in1],4
+	mux1	r15=r15,@rev
+	;;
+	ld4	r24=[in0],4
+	ld4	r25=[in1],4
+	shr.u	r15=r15,32
+	add	r16=r20,r21
+	add	r17=r22,r23
+	;;
+	ld4	r26=[in0],4
+	ld4	r27=[in1],4
+	add	r18=r24,r25
+	add	r8=r16,r17
+	;;
+	add	r19=r26,r27
+	add	r8=r8,r18
+	;;
+	add	r8=r8,r19
+	add	r15=r15,in4
+	;;
+	add	r8=r8,r15
+	;;
+	shr.u	r10=r8,16	// now fold sum into short
+	zxt2	r11=r8
+	;;
+	add	r8=r10,r11
+	;;
+	shr.u	r10=r8,16	// yeah, keep it rolling
+	zxt2	r11=r8
+	;;
+	add	r8=r10,r11
+	;;
+	shr.u	r10=r8,16	// three times lucky
+	zxt2	r11=r8
+	;;
+	add	r8=r10,r11
+	mov	r9=0xffff
+	;;
+	andcm	r8=r9,r8
+	br.ret.sptk.many b0
+END(csum_ipv6_magic)
--- ./include/asm-ia64/checksum.h.orig	2006-11-08 16:52:16.000000000 -0800
+++ ./include/asm-ia64/checksum.h	2006-11-08 17:01:09.000000000 -0800
@@ -73,4 +73,10 @@ csum_fold (unsigned int sum)
 	return ~sum;
 }
 
+#define _HAVE_ARCH_IPV6_CSUM	1
+struct in6_addr;
+extern unsigned short int csum_ipv6_magic(struct in6_addr *saddr,
+	struct in6_addr *daddr, __u32 len, unsigned short proto,
+	unsigned int csum);
+
 #endif /* _ASM_IA64_CHECKSUM_H */
