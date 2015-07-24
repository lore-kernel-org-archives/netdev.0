From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v2 2/2] ipv6: Avoid rt6_probe() taking writer lock in the fast path
Date: Fri, 24 Jul 2015 09:57:43 -0700
Message-ID: <1437757063-1186401-3-git-send-email-kafai@fb.com>
References: <1437757063-1186401-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:3626 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754326AbbGXQ6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 12:58:00 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t6OGvXeX027361
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 09:57:59 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1vuqhw09hf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 09:57:59 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 21a839a0322511e5901e24be0595f910-e8bfa2b0 for <netdev@vger.kernel.org>;	Fri,
 24 Jul 2015 09:57:56 -0700
In-Reply-To: <1437757063-1186401-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch checks neigh->nud_state before acquiring the writer lock.
Note that rt6_probe() is only used in CONFIG_IPV6_ROUTER_PREF.

40 udpflood processes and a /64 gateway route are used.
The gateway has NUD_PERMANENT.  Each of them is run for 30s.
At the end, the total number of finished sendto():

Before: 55M
After: 95M

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
CC: Julian Anastasov <ja@ssi.bg>
CC: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
---
 net/ipv6/route.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6d503db..76dcff8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -560,6 +560,9 @@ static void rt6_probe(struct rt6_info *rt)
 	rcu_read_lock_bh();
 	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
 	if (neigh) {
+		if (neigh->nud_state & NUD_VALID)
+			goto out;
+
 		work = NULL;
 		write_lock(&neigh->lock);
 		if (!(neigh->nud_state & NUD_VALID) &&
@@ -583,6 +586,7 @@ static void rt6_probe(struct rt6_info *rt)
 		schedule_work(&work->work);
 	}
 
+out:
 	rcu_read_unlock_bh();
 }
 #else
-- 
1.8.1
