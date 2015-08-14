From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net 2/3] ipv6: Add rt6_make_pcpu_route()
Date: Fri, 14 Aug 2015 11:05:53 -0700
Message-ID: <1439575554-3823839-3-git-send-email-kafai@fb.com>
References: <1439575554-3823839-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	FB Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51517 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756062AbbHNSU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 14:20:28 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t7EIIRJx007905
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 11:20:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1w9nber0w1-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 11:20:28 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 21df6d5242b111e59ee824be0593f280-dd3fc2b0 for <netdev@vger.kernel.org>;	Fri,
 14 Aug 2015 11:20:25 -0700
In-Reply-To: <1439575554-3823839-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work for fixing a potential deadlock when creating
a pcpu rt.

The current rt6_get_pcpu_route() will also create a pcpu rt if one does not
exist.  This patch moves the pcpu rt creation logic into another function,
rt6_make_pcpu_route().

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c95c319..0a82653 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -993,13 +993,21 @@ static struct rt6_info *ip6_rt_pcpu_alloc(struct rt6_info *rt)
 /* It should be called with read_lock_bh(&tb6_lock) acquired */
 static struct rt6_info *rt6_get_pcpu_route(struct rt6_info *rt)
 {
-	struct rt6_info *pcpu_rt, *prev, **p;
+	struct rt6_info *pcpu_rt, **p;
 
 	p = this_cpu_ptr(rt->rt6i_pcpu);
 	pcpu_rt = *p;
 
-	if (pcpu_rt)
-		goto done;
+	if (pcpu_rt) {
+		dst_hold(&pcpu_rt->dst);
+		rt6_dst_from_metrics_check(pcpu_rt);
+	}
+	return pcpu_rt;
+}
+
+static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
+{
+	struct rt6_info *pcpu_rt, *prev, **p;
 
 	pcpu_rt = ip6_rt_pcpu_alloc(rt);
 	if (!pcpu_rt) {
@@ -1009,6 +1017,7 @@ static struct rt6_info *rt6_get_pcpu_route(struct rt6_info *rt)
 		goto done;
 	}
 
+	p = this_cpu_ptr(rt->rt6i_pcpu);
 	prev = cmpxchg(p, NULL, pcpu_rt);
 	if (prev) {
 		/* If someone did it before us, return prev instead */
@@ -1093,8 +1102,11 @@ redo_rt6_select:
 		rt->dst.lastuse = jiffies;
 		rt->dst.__use++;
 		pcpu_rt = rt6_get_pcpu_route(rt);
-		read_unlock_bh(&table->tb6_lock);
 
+		if (!pcpu_rt)
+			pcpu_rt = rt6_make_pcpu_route(rt);
+
+		read_unlock_bh(&table->tb6_lock);
 		return pcpu_rt;
 	}
 }
-- 
1.8.1
