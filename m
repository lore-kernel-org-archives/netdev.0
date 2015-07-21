From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next] ipv6: Avoid rt6_probe() taking writer lock in the fast path
Date: Tue, 21 Jul 2015 16:51:20 -0700
Message-ID: <1437522680-3515872-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:64413 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933284AbbGUXvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 19:51:25 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6LNoq3x016836
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 16:51:24 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vsypar3n7-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 16:51:24 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 6313fc4a300311e5ba1424be0595f910-e03fd2b0 for <netdev@vger.kernel.org>;	Tue,
 21 Jul 2015 16:51:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch checks neigh->nud_state before acquiring the writer lock.
Note that rt6_probe() is only used in CONFIG_IPV6_ROUTER_PREF.

I also take this chance to re-arrange the code.

40 udpflood processes and a /64 gateway route are used.
The gateway has NUD_PERMANENT.  Each of them is run for 30s.
At the end, the total number of finished sendto():

Before    After
55M	  95M

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 41 ++++++++++++++++++++---------------------
 1 file changed, 20 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6090969..a6c6b5a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -544,6 +544,7 @@ static void rt6_probe_deferred(struct work_struct *w)
 
 static void rt6_probe(struct rt6_info *rt)
 {
+	struct __rt6_probe_work *work;
 	struct neighbour *neigh;
 	/*
 	 * Okay, this does not seem to be appropriate
@@ -558,34 +559,32 @@ static void rt6_probe(struct rt6_info *rt)
 	rcu_read_lock_bh();
 	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
 	if (neigh) {
-		write_lock(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
 			goto out;
-	}
-
-	if (!neigh ||
-	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
-		struct __rt6_probe_work *work;
 
+		work = NULL;
+		write_lock(&neigh->lock);
+		if (!(neigh->nud_state & NUD_VALID) &&
+		    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
+			work = kmalloc(sizeof(*work), GFP_ATOMIC);
+			if (work) {
+				__neigh_set_probe_once(neigh);
+			}
+		}
+		write_unlock(&neigh->lock);
+	} else {
 		work = kmalloc(sizeof(*work), GFP_ATOMIC);
+	}
 
-		if (neigh && work)
-			__neigh_set_probe_once(neigh);
-
-		if (neigh)
-			write_unlock(&neigh->lock);
+	if (work) {
+		INIT_WORK(&work->work, rt6_probe_deferred);
+		work->target = rt->rt6i_gateway;
+		dev_hold(rt->dst.dev);
+		work->dev = rt->dst.dev;
+		schedule_work(&work->work);
+	}
 
-		if (work) {
-			INIT_WORK(&work->work, rt6_probe_deferred);
-			work->target = rt->rt6i_gateway;
-			dev_hold(rt->dst.dev);
-			work->dev = rt->dst.dev;
-			schedule_work(&work->work);
-		}
-	} else {
 out:
-		write_unlock(&neigh->lock);
-	}
 	rcu_read_unlock_bh();
 }
 #else
-- 
1.8.1
