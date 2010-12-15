From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [2.6.37-rc5] Build error on parisc.
Date: Wed, 15 Dec 2010 17:01:14 +0900
Message-ID: <201012150801.oBF81EVm047830@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:58432 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab0LOIBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 03:01:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[2.6.37-rc5] Build error on parisc.

Commit 5635c10d "net: make sure struct dst_entry refcount is aligned on 64 bytes"
uses manual padding. I triggered BUILD_BUG_ON() when using
http://kernel.org/pub/tools/crosstool/files/bin/i686/4.5.1/i686-gcc-4.5.1-nolibc_hppa64-linux.tar.bz2 .

  make -s CROSS_COMPILE=hppa64-linux- ARCH=parisc

  include/net/dst.h: In function 'dst_hold':
  include/net/dst.h:161:2: error: negative width in bit-field '<anonymous>'

I think below patch can fix the error but that commit says that we cannot use
__atribute((aligned)). Why?

diff --git a/include/net/dst.h b/include/net/dst.h
index ffe9cb7..02df303 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -62,8 +62,6 @@ struct dst_entry {
 	struct hh_cache		*hh;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
-#else
-	void			*__pad1;
 #endif
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
@@ -74,23 +72,15 @@ struct dst_entry {
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
-#else
-	__u32			__pad2;
-#endif
-
-
-	/*
-	 * Align __refcnt to a 64 bytes alignment
-	 * (L1_CACHE_SIZE would be too much)
-	 */
-#ifdef CONFIG_64BIT
-	long			__pad_to_align_refcnt[1];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
 	 * input/output/ops or performance tanks badly
+	 *
+	 * Align __refcnt to a 64 bytes alignment
+	 * (L1_CACHE_SIZE would be too much)
 	 */
-	atomic_t		__refcnt;	/* client references	*/
+	atomic_t		__refcnt __aligned(64);	/* client references */
 	int			__use;
 	unsigned long		lastuse;
 	union {
@@ -154,11 +144,6 @@ dst_metric_locked(struct dst_entry *dst, int metric)
 
 static inline void dst_hold(struct dst_entry * dst)
 {
-	/*
-	 * If your kernel compilation stops here, please check
-	 * __pad_to_align_refcnt declaration in struct dst_entry
-	 */
-	BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);
 	atomic_inc(&dst->__refcnt);
 }
 
