From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 2/7] sched: Call skb_get_hash_perturb in sch_fq_codel
Date: Fri, 1 May 2015 11:30:13 -0700
Message-ID: <1430505018-496801-3-git-send-email-tom@herbertland.com>
References: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39355 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbbEASag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:30:36 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t41IUUGY001435
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 11:30:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4e27r3fn-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:30:36 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 263a9a08f03011e4bb3b0002c991e86a-3aad9240 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 11:30:32 -0700
In-Reply-To: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_get_hash_perturb instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/sched/sch_fq_codel.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 1e52dec..a6fc53d 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -23,7 +23,6 @@
 #include <linux/vmalloc.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-#include <net/flow_keys.h>
 #include <net/codel.h>
 
 /*	Fair Queue CoDel.
@@ -68,15 +67,9 @@ struct fq_codel_sched_data {
 };
 
 static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
-				  const struct sk_buff *skb)
+				  struct sk_buff *skb)
 {
-	struct flow_keys keys;
-	unsigned int hash;
-
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
+	u32 hash = skb_get_hash_perturb(skb, q->perturbation);
 
 	return reciprocal_scale(hash, q->flows_cnt);
 }
-- 
1.8.1
