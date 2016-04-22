From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] route: move lwtunnel state to a single place
Date: Fri, 22 Apr 2016 12:40:02 +0200
Message-ID: <c59d9a13e4171a887d6dd2acdce216c51a006993.1461321556.git.jbenc@redhat.com>
Cc: Lance Richardson <lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36276 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690AbcDVKlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 06:41:08 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 843F8C049D67
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 10:41:06 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 751a587ac9f9 ("route: fix breakage after moving lwtunnel state")
moved lwtstate to the end of dst_entry for 32bit archs. This makes it share
the cacheline with __refcnt which had an unkown effect on performance. For
this reason, the pointer was kept in place for 64bit archs.

However, later performance measurements showed this is of no concern. It
turns out that every performance sensitive path that accesses lwtstate
accesses also struct rtable or struct rt6_info which share the same cache
line.

Thus, to get rid of a few #ifdefs, move the field to the end of the struct
also for 64bit.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
Full analysis here: http://article.gmane.org/gmane.linux.network/375426
---
 include/net/dst.h | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5c98443c1c9e..6835d224d47b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -85,12 +85,11 @@ struct dst_entry {
 #endif
 
 #ifdef CONFIG_64BIT
-	struct lwtunnel_state   *lwtstate;
 	/*
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
 	 */
-	long			__pad_to_align_refcnt[1];
+	long			__pad_to_align_refcnt[2];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
@@ -99,9 +98,7 @@ struct dst_entry {
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	unsigned long		lastuse;
-#ifndef CONFIG_64BIT
 	struct lwtunnel_state   *lwtstate;
-#endif
 	union {
 		struct dst_entry	*next;
 		struct rtable __rcu	*rt_next;
-- 
1.8.3.1
