From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v2 1/2] ipv6: Re-arrange code in rt6_probe()
Date: Fri, 24 Jul 2015 09:57:42 -0700
Message-ID: <1437757063-1186401-2-git-send-email-kafai@fb.com>
References: <1437757063-1186401-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:6470 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753082AbbGXQ55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 12:57:57 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6OGuhVo023968
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 09:57:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vuqpmg8sw-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 09:57:56 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 214e2ac8322511e59d8e0002c99331b0-fb7fc2b0 for <netdev@vger.kernel.org>;	Fri,
 24 Jul 2015 09:57:55 -0700
In-Reply-To: <1437757063-1186401-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work for the next patch to remove write_lock
from rt6_probe().

1. Reduce the number of if(neigh) check.  From 4 to 1.
2. Bring the write_(un)lock() closer to the operations that the
   lock is protecting.

Hopefully, the above make rt6_probe() more readable.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
---
 net/ipv6/route.c | 44 ++++++++++++++++++++------------------------
 1 file changed, 20 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7f2214f..6d503db 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -545,6 +545,7 @@ static void rt6_probe_deferred(struct work_struct *w)
 
 static void rt6_probe(struct rt6_info *rt)
 {
+	struct __rt6_probe_work *work;
 	struct neighbour *neigh;
 	/*
 	 * Okay, this does not seem to be appropriate
@@ -559,34 +560,29 @@ static void rt6_probe(struct rt6_info *rt)
 	rcu_read_lock_bh();
 	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
 	if (neigh) {
+		work = NULL;
 		write_lock(&neigh->lock);
-		if (neigh->nud_state & NUD_VALID)
-			goto out;
-	}
-
-	if (!neigh ||
-	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
-		struct __rt6_probe_work *work;
-
-		work = kmalloc(sizeof(*work), GFP_ATOMIC);
-
-		if (neigh && work)
-			__neigh_set_probe_once(neigh);
-
-		if (neigh)
-			write_unlock(&neigh->lock);
-
-		if (work) {
-			INIT_WORK(&work->work, rt6_probe_deferred);
-			work->target = rt->rt6i_gateway;
-			dev_hold(rt->dst.dev);
-			work->dev = rt->dst.dev;
-			schedule_work(&work->work);
+		if (!(neigh->nud_state & NUD_VALID) &&
+		    time_after(jiffies,
+			       neigh->updated +
+			       rt->rt6i_idev->cnf.rtr_probe_interval)) {
+			work = kmalloc(sizeof(*work), GFP_ATOMIC);
+			if (work)
+				__neigh_set_probe_once(neigh);
 		}
-	} else {
-out:
 		write_unlock(&neigh->lock);
+	} else {
+		work = kmalloc(sizeof(*work), GFP_ATOMIC);
+	}
+
+	if (work) {
+		INIT_WORK(&work->work, rt6_probe_deferred);
+		work->target = rt->rt6i_gateway;
+		dev_hold(rt->dst.dev);
+		work->dev = rt->dst.dev;
+		schedule_work(&work->work);
 	}
+
 	rcu_read_unlock_bh();
 }
 #else
-- 
1.8.1
