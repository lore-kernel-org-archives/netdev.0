From: Tom Herbert <therbert@google.com>
Subject: PATCH] net: Cache align dst refcnt
Date: Tue, 17 Dec 2013 10:15:36 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312171013050.5720@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:42534 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab3LQSV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 13:21:59 -0500
Received: by mail-ve0-f201.google.com with SMTP id jw12so666504veb.4
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 10:21:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4_dst_check is coming up very high in perf top for TCP_RR tests and
it really is not doing much interesting. Looks like we have false
sharing with dst->refcnt. This patch cache aligns refcnt. There were
already some comments in the code that refcnt needs to be cache aligned.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/dst.h | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 44995c1..265b4cd 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -85,17 +85,12 @@ struct dst_entry {
 #endif
 
 	/*
-	 * Align __refcnt to a 64 bytes alignment
-	 * (L1_CACHE_SIZE would be too much)
-	 */
-#ifdef CONFIG_64BIT
-	long			__pad_to_align_refcnt[2];
-#endif
-	/*
 	 * __refcnt wants to be on a different cache line from
 	 * input/output/ops or performance tanks badly
 	 */
-	atomic_t		__refcnt;	/* client references	*/
+	atomic_t		__refcnt ____cacheline_aligned_in_smp;
+				/* client references	*/
+
 	int			__use;
 	unsigned long		lastuse;
 	union {
-- 
1.8.5.1
