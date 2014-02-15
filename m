From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] csum_partial_copy_from_user: clean up inconsistencies in
 implementations
Date: Sat, 15 Feb 2014 10:49:54 -0500 (EST)
Message-ID: <alpine.LRH.2.02.1402151044010.25662@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, Michael Cree <mcree@orcon.net.nz>,
	Matt Turner <mattst88@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Jay Estabrook <jay.estabrook@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Here I'm sending a patch for networking to clean up inconsistent 
implementations of csum_partial_copy_from_user in various architectures. 
This patch doesn't fix any bug, but the confusion in implementations 
caused a bug in the past. The patch should be queued for the kernel 3.15.

Mikulas



From: Mikulas Patocka <mpatocka@redhat.com>

csum_partial_copy_from_user is called only from csum_and_copy_from_user in
include/net/checksum.h. csum_and_copy_from_user verifies the userspace
range with access_ok, so there is no need to repeat access_ok in the
implementation of csum_partial_copy_from_user.

Some architectures repeat the acces_ok check anyway, sometimes people were
adding this check blindly (see patch
3ddc5b46a8e90f3c9251338b60191d0a804b0d92 that adds it for the alpha
architecture) and that caused serious network breakage because in the
alpha implementation, csum_partial_copy_from_user is also used when
copying from kernel space (called from the function
csum_partial_copy_nocheck) and that access_ok check broke it.

There were follow-up patches to fix the alpha breakage
(5cfe8f1ba5eebe6f4b6e5858cdb1a5be4f3272a6 and
0ef38d70d4118b2ce1a538d14357be5ff9dc2bbd), however these patches just add
junk to the code - the best thing would be to not perform access_ok in
csum_partial_copy_from_user in the first place.

This patch reverts the access_ok part of
3ddc5b46a8e90f3c9251338b60191d0a804b0d92, reverts the patches
5cfe8f1ba5eebe6f4b6e5858cdb1a5be4f3272a6 and
0ef38d70d4118b2ce1a538d14357be5ff9dc2bbd completely, and drops the check
for access_ok from other architectures that were performing the check.

This patch also changes all the implementations of
csum_partial_copy_from_user so that they don't zero the destination buffer
on page fault - csum_and_copy_from_user is not zeroing the buffer when the
access_ok fails, so it is pointless to zero the buffer in
csum_partial_copy_from_user.

The purpose of this patch is to make all the implementations of
csum_partial_copy_from_user consistent, so that people will keep them
consistent in the future.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 arch/alpha/lib/csum_partial_copy.c |   22 ++++++----------------
 arch/c6x/lib/checksum.c            |    5 ++---
 arch/frv/lib/checksum.c            |   11 +++--------
 arch/m32r/lib/csum_partial_copy.c  |    6 +++---
 arch/metag/lib/checksum.c          |    5 ++---
 arch/mn10300/lib/checksum.c        |    4 ++--
 arch/parisc/lib/checksum.c         |    4 ++--
 arch/s390/include/asm/checksum.h   |    4 ++--
 arch/score/lib/checksum_copy.c     |    4 ++--
 arch/x86/lib/csum-wrappers_64.c    |   12 ------------
 arch/x86/um/asm/checksum.h         |    2 +-
 lib/checksum.c                     |    5 ++---
 12 files changed, 27 insertions(+), 57 deletions(-)

Index: linux-3.14-rc2/arch/alpha/lib/csum_partial_copy.c
===================================================================
--- linux-3.14-rc2.orig/arch/alpha/lib/csum_partial_copy.c	2014-02-13 19:38:09.000000000 +0100
+++ linux-3.14-rc2/arch/alpha/lib/csum_partial_copy.c	2014-02-13 19:41:23.000000000 +0100
@@ -130,7 +130,7 @@ csum_partial_cfu_aligned(const unsigned 
 		*dst = word | tmp;
 		checksum += carry;
 	}
-	if (err && errp) *errp = err;
+	if (err) *errp = err;
 	return checksum;
 }
 
@@ -185,7 +185,7 @@ csum_partial_cfu_dest_aligned(const unsi
 		*dst = word | tmp;
 		checksum += carry;
 	}
-	if (err && errp) *errp = err;
+	if (err) *errp = err;
 	return checksum;
 }
 
@@ -242,7 +242,7 @@ csum_partial_cfu_src_aligned(const unsig
 	stq_u(partial_dest | second_dest, dst);
 out:
 	checksum += carry;
-	if (err && errp) *errp = err;
+	if (err) *errp = err;
 	return checksum;
 }
 
@@ -325,7 +325,7 @@ csum_partial_cfu_unaligned(const unsigne
 		stq_u(partial_dest | word | second_dest, dst);
 		checksum += carry;
 	}
-	if (err && errp) *errp = err;
+	if (err) *errp = err;
 	return checksum;
 }
 
@@ -338,11 +338,6 @@ csum_partial_copy_from_user(const void _
 	unsigned long doff = 7 & (unsigned long) dst;
 
 	if (len) {
-		if (!access_ok(VERIFY_READ, src, len)) {
-			if (errp) *errp = -EFAULT;
-			memset(dst, 0, len);
-			return sum;
-		}
 		if (!doff) {
 			if (!soff)
 				checksum = csum_partial_cfu_aligned(
@@ -378,11 +373,6 @@ csum_partial_copy_from_user(const void _
 __wsum
 csum_partial_copy_nocheck(const void *src, void *dst, int len, __wsum sum)
 {
-	__wsum checksum;
-	mm_segment_t oldfs = get_fs();
-	set_fs(KERNEL_DS);
-	checksum = csum_partial_copy_from_user((__force const void __user *)src,
-						dst, len, sum, NULL);
-	set_fs(oldfs);
-	return checksum;
+	return csum_partial_copy_from_user((__force const void __user *)src,
+			dst, len, sum, NULL);
 }
Index: linux-3.14-rc2/arch/c6x/lib/checksum.c
===================================================================
--- linux-3.14-rc2.orig/arch/c6x/lib/checksum.c	2014-02-13 19:57:44.000000000 +0100
+++ linux-3.14-rc2/arch/c6x/lib/checksum.c	2014-02-13 19:58:09.000000000 +0100
@@ -20,10 +20,9 @@ csum_partial_copy_from_user(const void _
 
 	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*csum_err = -EFAULT;
-	} else
-		*csum_err = 0;
+		return (__force __wsum)-1;
+	}
 
 	return csum_partial(dst, len, sum);
 }
Index: linux-3.14-rc2/arch/frv/lib/checksum.c
===================================================================
--- linux-3.14-rc2.orig/arch/frv/lib/checksum.c	2014-02-13 20:02:28.000000000 +0100
+++ linux-3.14-rc2/arch/frv/lib/checksum.c	2014-02-13 20:02:54.000000000 +0100
@@ -137,15 +137,10 @@ csum_partial_copy_from_user(const void _
 {
 	int rem;
 
-	if (csum_err)
-		*csum_err = 0;
-
-	rem = copy_from_user(dst, src, len);
+	rem = __copy_from_user(dst, src, len);
 	if (rem != 0) {
-		if (csum_err)
-			*csum_err = -EFAULT;
-		memset(dst + len - rem, 0, rem);
-		len = rem;
+		*csum_err = -EFAULT;
+		return (__force __wsum)-1;
 	}
 
 	return csum_partial(dst, len, sum);
Index: linux-3.14-rc2/arch/m32r/lib/csum_partial_copy.c
===================================================================
--- linux-3.14-rc2.orig/arch/m32r/lib/csum_partial_copy.c	2014-02-13 20:00:12.000000000 +0100
+++ linux-3.14-rc2/arch/m32r/lib/csum_partial_copy.c	2014-02-13 20:00:36.000000000 +0100
@@ -47,13 +47,13 @@ csum_partial_copy_from_user (const void 
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
+		return (__force __wsum)-1;
 	}
 
-	return csum_partial(dst, len-missing, sum);
+	return csum_partial(dst, len, sum);
 }
 EXPORT_SYMBOL(csum_partial_copy_from_user);
 EXPORT_SYMBOL(csum_partial);
Index: linux-3.14-rc2/arch/metag/lib/checksum.c
===================================================================
--- linux-3.14-rc2.orig/arch/metag/lib/checksum.c	2014-02-13 20:00:55.000000000 +0100
+++ linux-3.14-rc2/arch/metag/lib/checksum.c	2014-02-13 20:01:23.000000000 +0100
@@ -146,10 +146,9 @@ csum_partial_copy_from_user(const void _
 
 	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*csum_err = -EFAULT;
-	} else
-		*csum_err = 0;
+		return (__force __wsum)-1;
+	}
 
 	return csum_partial(dst, len, sum);
 }
Index: linux-3.14-rc2/arch/mn10300/lib/checksum.c
===================================================================
--- linux-3.14-rc2.orig/arch/mn10300/lib/checksum.c	2014-02-13 19:59:09.000000000 +0100
+++ linux-3.14-rc2/arch/mn10300/lib/checksum.c	2014-02-13 19:59:31.000000000 +0100
@@ -73,10 +73,10 @@ __wsum csum_partial_copy_from_user(const
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
+		return (__force __wsum)-1;
 	}
 
 	return csum_partial(dst, len, sum);
Index: linux-3.14-rc2/arch/parisc/lib/checksum.c
===================================================================
--- linux-3.14-rc2.orig/arch/parisc/lib/checksum.c	2014-02-13 19:58:19.000000000 +0100
+++ linux-3.14-rc2/arch/parisc/lib/checksum.c	2014-02-13 19:58:36.000000000 +0100
@@ -138,10 +138,10 @@ __wsum csum_partial_copy_from_user(const
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
+		return (__force __wsum)-1;
 	}
 		
 	return csum_partial(dst, len, sum);
Index: linux-3.14-rc2/arch/s390/include/asm/checksum.h
===================================================================
--- linux-3.14-rc2.orig/arch/s390/include/asm/checksum.h	2014-02-13 19:56:37.000000000 +0100
+++ linux-3.14-rc2/arch/s390/include/asm/checksum.h	2014-02-13 19:57:16.000000000 +0100
@@ -54,10 +54,10 @@ csum_partial_copy_from_user(const void _
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
+		return (__force __wsum)-1;
 	}
 		
 	return csum_partial(dst, len, sum);
Index: linux-3.14-rc2/arch/score/lib/checksum_copy.c
===================================================================
--- linux-3.14-rc2.orig/arch/score/lib/checksum_copy.c	2014-02-13 19:55:29.000000000 +0100
+++ linux-3.14-rc2/arch/score/lib/checksum_copy.c	2014-02-13 19:55:54.000000000 +0100
@@ -42,10 +42,10 @@ unsigned int csum_partial_copy_from_user
 {
 	int missing;
 
-	missing = copy_from_user(dst, src, len);
+	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*err_ptr = -EFAULT;
+		return -1;
 	}
 
 	return csum_partial(dst, len, sum);
Index: linux-3.14-rc2/arch/x86/lib/csum-wrappers_64.c
===================================================================
--- linux-3.14-rc2.orig/arch/x86/lib/csum-wrappers_64.c	2014-02-13 19:49:53.000000000 +0100
+++ linux-3.14-rc2/arch/x86/lib/csum-wrappers_64.c	2014-02-13 19:50:15.000000000 +0100
@@ -24,10 +24,6 @@ csum_partial_copy_from_user(const void _
 			    int len, __wsum isum, int *errp)
 {
 	might_sleep();
-	*errp = 0;
-
-	if (!likely(access_ok(VERIFY_READ, src, len)))
-		goto out_err;
 
 	/*
 	 * Why 6, not 7? To handle odd addresses aligned we
@@ -57,14 +53,6 @@ csum_partial_copy_from_user(const void _
 	isum = csum_partial_copy_generic((__force const void *)src,
 				dst, len, isum, errp, NULL);
 	clac();
-	if (unlikely(*errp))
-		goto out_err;
-
-	return isum;
-
-out_err:
-	*errp = -EFAULT;
-	memset(dst, 0, len);
 
 	return isum;
 }
Index: linux-3.14-rc2/arch/x86/um/asm/checksum.h
===================================================================
--- linux-3.14-rc2.orig/arch/x86/um/asm/checksum.h	2014-02-13 19:54:28.000000000 +0100
+++ linux-3.14-rc2/arch/x86/um/asm/checksum.h	2014-02-13 19:54:47.000000000 +0100
@@ -46,7 +46,7 @@ static __inline__
 __wsum csum_partial_copy_from_user(const void __user *src, void *dst,
 					 int len, __wsum sum, int *err_ptr)
 {
-	if (copy_from_user(dst, src, len)) {
+	if (__copy_from_user(dst, src, len)) {
 		*err_ptr = -EFAULT;
 		return (__force __wsum)-1;
 	}
Index: linux-3.14-rc2/lib/checksum.c
===================================================================
--- linux-3.14-rc2.orig/lib/checksum.c	2014-02-13 20:21:02.000000000 +0100
+++ linux-3.14-rc2/lib/checksum.c	2014-02-13 20:21:06.000000000 +0100
@@ -160,10 +160,9 @@ csum_partial_copy_from_user(const void _
 
 	missing = __copy_from_user(dst, src, len);
 	if (missing) {
-		memset(dst + len - missing, 0, missing);
 		*csum_err = -EFAULT;
-	} else
-		*csum_err = 0;
+		return (__force __wsum)-1;
+	}
 
 	return csum_partial(dst, len, sum);
 }
