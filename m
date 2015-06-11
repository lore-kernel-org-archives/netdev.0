From: Shaohua Li <shli@fb.com>
Subject: [RFC] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 13:24:31 -0700
Message-ID: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Kernel-team@fb.com>,
	Eric Dumazet <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56037 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752046AbbFKUYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 16:24:35 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t5BKMeXC010897
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 13:24:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uyddk0vq0-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 13:24:34 -0700
Received: from facebook.com (2401:db00:20:7003:face:0:4d:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 de3d87f2107711e5b6730002c992ebde-30ff92a0 for <netdev@vger.kernel.org>;	Thu,
 11 Jun 2015 13:24:32 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We saw excessive memory compaction triggered by skb_page_frag_refill.
This causes performance issues. Commit 5640f7685831e0 introduces the
order-3 allocation to improve performance. But memory compaction has
high overhead. The benefit of order-3 allocation can't compensate the
overhead of memory compaction.

This patch makes the order-3 page allocation atomic. If there is no
memory pressure and memory isn't fragmented, the alloction will still
success, so we don't sacrifice the order-3 benefit here. If the atomic
allocation fails, compaction will not be triggered and we will fallback
to order-0 immediately.

The mellanox driver does similar thing, if this is accepted, we must fix
the driver too.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 net/core/sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 292f422..e9855a4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
 
 	pfrag->offset = 0;
 	if (SKB_FRAG_PAGE_ORDER) {
-		pfrag->page = alloc_pages(gfp | __GFP_COMP |
+		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
 					  __GFP_NOWARN | __GFP_NORETRY,
 					  SKB_FRAG_PAGE_ORDER);
 		if (likely(pfrag->page)) {
-- 
1.8.1
