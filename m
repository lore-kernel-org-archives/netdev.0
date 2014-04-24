From: Chris Mason <clm@fb.com>
Subject: [PATCH RFC] ipv6_fib limit spinlock hold times for /proc/net/ipv6_route
Date: Thu, 24 Apr 2014 09:59:24 -0400
Message-ID: <535918BC.5030708@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:21083 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753681AbaDXN6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 09:58:40 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s3ODtwBC024797
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 06:58:39 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1kesr3smch-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 06:58:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The ipv6 code to dump routes in /proc/net/ipv6_route can hold
a read lock on the table for a very long time.  This ends up blocking
writers and triggering softlockups.

This patch is a simple work around to limit the number of entries
we'll walk while processing /proc/net/ipv6_route.  It intentionally
slows down proc file reading to make sure we don't lock out the
real ipv6 traffic.

This patch is also horrible, and doesn't actually fix the entire
problem.  We still have rcu_read_lock held the whole time we cat
/proc/net/ipv6_route.  On an unpatched machine, I've clocked the
time required to cat /proc/net/ipv6_route at 14 minutes.

java cats this proc file on startup to search for local routes, and the
resulting contention on the table lock makes our boxes fall over.

So, I'm sending the partial fix to get discussion started.

Signed-off-by: Chris Mason <clm@fb.com>

---
 net/ipv6/ip6_fib.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 87891f5..19b0f78 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1814,6 +1814,7 @@ struct ipv6_route_iter {
 	loff_t skip;
 	struct fib6_table *tbl;
 	__u32 sernum;
+	int max_walk;
 };
 
 static int ipv6_route_seq_show(struct seq_file *seq, void *v)
@@ -1853,8 +1854,11 @@ static int ipv6_route_yield(struct fib6_walker_t *w)
 		iter->skip--;
 		if (!iter->skip && iter->w.leaf)
 			return 1;
+		iter->max_walk--;
 	} while (iter->w.leaf);
 
+	if (iter->max_walk <= 0)
+		return -EAGAIN;
 	return 0;
 }
 
@@ -1867,6 +1871,7 @@ static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
 	iter->w.node = iter->w.root;
 	iter->w.args = iter;
 	iter->sernum = iter->w.root->fn_sernum;
+	iter->max_walk = 128;
 	INIT_LIST_HEAD(&iter->w.lh);
 	fib6_walker_link(&iter->w);
 }
@@ -1921,7 +1926,9 @@ static void *ipv6_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 iter_table:
 	ipv6_route_check_sernum(iter);
+iter_again:
 	read_lock(&iter->tbl->tb6_lock);
+	iter->max_walk = 128;
 	r = fib6_walk_continue(&iter->w);
 	read_unlock(&iter->tbl->tb6_lock);
 	if (r > 0) {
@@ -1929,6 +1936,8 @@ iter_table:
 			++*pos;
 		return iter->w.leaf;
 	} else if (r < 0) {
+		if (r == -EAGAIN)
+			goto iter_again;
 		fib6_walker_unlink(&iter->w);
 		return NULL;
 	}
-- 
1.8.1
