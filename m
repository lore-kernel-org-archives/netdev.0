From: Chris Mason <clm@fb.com>
Subject: [PATCH] ipv6: fib: fix fib dump restart
Date: Thu, 24 Apr 2014 09:48:53 -0400
Message-ID: <53591645.7010609@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:18117 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753955AbaDXNsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 09:48:11 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s3ODirMn001053
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 06:48:10 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0a-00082601.pphosted.com with ESMTP id 1keau34gj1-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 06:48:10 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Kumar Sundararajan <kumar@fb.com>

When the ipv6 fib changes during a table dump, the walk is
restarted and the number of nodes dumped are skipped. But the existing
code doesn't advance to the next node after a node is skipped. This can
cause the dump to loop or produce lots of duplicates when the fib
is modified during the dump.

This change advances the walk to the next node if the current node is
skipped after a restart.

Signed-off-by: Chris Mason <clm@fb.com>
---
 net/ipv6/ip6_fib.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 34e0ded..87891f5 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1459,7 +1459,7 @@ static int fib6_walk_continue(struct fib6_walker_t *w)
 
 				if (w->skip) {
 					w->skip--;
-					continue;
+					goto skip;
 				}
 
 				err = w->func(w);
@@ -1469,6 +1469,7 @@ static int fib6_walk_continue(struct fib6_walker_t *w)
 				w->count++;
 				continue;
 			}
+skip:
 			w->state = FWS_U;
 		case FWS_U:
 			if (fn == w->root)
-- 
1.8.1
