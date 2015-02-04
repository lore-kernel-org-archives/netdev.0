From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v3 11/18] net: bury net/core/iovec.c - nothing in there is used anymore
Date: Wed,  4 Feb 2015 06:40:02 +0000
Message-ID: <1423032009-18367-11-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43093 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbbBDGkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:40:12 -0500
In-Reply-To: <20150204063730.GG29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/socket.h |   7 ---
 net/core/Makefile      |   2 +-
 net/core/iovec.c       | 137 -------------------------------------------------
 3 files changed, 1 insertion(+), 145 deletions(-)
 delete mode 100644 net/core/iovec.c

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 6e49a14..5c19cba 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -318,13 +318,6 @@ struct ucred {
 /* IPX options */
 #define IPX_TYPE	1
 
-extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
-					  struct iovec *iov, 
-					  int offset, 
-					  unsigned int len, __wsum *csump);
-extern unsigned long iov_pages(const struct iovec *iov, int offset,
-			       unsigned long nr_segs);
-
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_storage *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
diff --git a/net/core/Makefile b/net/core/Makefile
index 235e6c5..fec0856 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -2,7 +2,7 @@
 # Makefile for the Linux networking core.
 #
 
-obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
+obj-y := sock.o request_sock.o skbuff.o datagram.o stream.o scm.o \
 	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
diff --git a/net/core/iovec.c b/net/core/iovec.c
deleted file mode 100644
index dcbe98b..0000000
--- a/net/core/iovec.c
+++ /dev/null
@@ -1,137 +0,0 @@
-/*
- *	iovec manipulation routines.
- *
- *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
- *
- *	Fixes:
- *		Andrew Lunn	:	Errors in iovec copying.
- *		Pedro Roque	:	Added memcpy_fromiovecend and
- *					csum_..._fromiovecend.
- *		Andi Kleen	:	fixed error handling for 2.1
- *		Alexey Kuznetsov:	2.1 optimisations
- *		Andi Kleen	:	Fix csum*fromiovecend for IPv6.
- */
-
-#include <linux/errno.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/mm.h>
-#include <linux/net.h>
-#include <linux/in6.h>
-#include <asm/uaccess.h>
-#include <asm/byteorder.h>
-#include <net/checksum.h>
-#include <net/sock.h>
-
-/*
- *	And now for the all-in-one: copy and checksum from a user iovec
- *	directly to a datagram
- *	Calls to csum_partial but the last must be in 32 bit chunks
- *
- *	ip_build_xmit must ensure that when fragmenting only the last
- *	call to this function will be unaligned also.
- */
-int csum_partial_copy_fromiovecend(unsigned char *kdata, struct iovec *iov,
-				 int offset, unsigned int len, __wsum *csump)
-{
-	__wsum csum = *csump;
-	int partial_cnt = 0, err = 0;
-
-	/* Skip over the finished iovecs */
-	while (offset >= iov->iov_len) {
-		offset -= iov->iov_len;
-		iov++;
-	}
-
-	while (len > 0) {
-		u8 __user *base = iov->iov_base + offset;
-		int copy = min_t(unsigned int, len, iov->iov_len - offset);
-
-		offset = 0;
-
-		/* There is a remnant from previous iov. */
-		if (partial_cnt) {
-			int par_len = 4 - partial_cnt;
-
-			/* iov component is too short ... */
-			if (par_len > copy) {
-				if (copy_from_user(kdata, base, copy))
-					goto out_fault;
-				kdata += copy;
-				base += copy;
-				partial_cnt += copy;
-				len -= copy;
-				iov++;
-				if (len)
-					continue;
-				*csump = csum_partial(kdata - partial_cnt,
-							 partial_cnt, csum);
-				goto out;
-			}
-			if (copy_from_user(kdata, base, par_len))
-				goto out_fault;
-			csum = csum_partial(kdata - partial_cnt, 4, csum);
-			kdata += par_len;
-			base  += par_len;
-			copy  -= par_len;
-			len   -= par_len;
-			partial_cnt = 0;
-		}
-
-		if (len > copy) {
-			partial_cnt = copy % 4;
-			if (partial_cnt) {
-				copy -= partial_cnt;
-				if (copy_from_user(kdata + copy, base + copy,
-						partial_cnt))
-					goto out_fault;
-			}
-		}
-
-		if (copy) {
-			csum = csum_and_copy_from_user(base, kdata, copy,
-							csum, &err);
-			if (err)
-				goto out;
-		}
-		len   -= copy + partial_cnt;
-		kdata += copy + partial_cnt;
-		iov++;
-	}
-	*csump = csum;
-out:
-	return err;
-
-out_fault:
-	err = -EFAULT;
-	goto out;
-}
-EXPORT_SYMBOL(csum_partial_copy_fromiovecend);
-
-unsigned long iov_pages(const struct iovec *iov, int offset,
-			unsigned long nr_segs)
-{
-	unsigned long seg, base;
-	int pages = 0, len, size;
-
-	while (nr_segs && (offset >= iov->iov_len)) {
-		offset -= iov->iov_len;
-		++iov;
-		--nr_segs;
-	}
-
-	for (seg = 0; seg < nr_segs; seg++) {
-		base = (unsigned long)iov[seg].iov_base + offset;
-		len = iov[seg].iov_len - offset;
-		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
-		pages += size;
-		offset = 0;
-	}
-
-	return pages;
-}
-EXPORT_SYMBOL(iov_pages);
-- 
2.1.4
