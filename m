From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/7] sched: Call skb_get_hash_perturb in sch_hhf
Date: Fri, 1 May 2015 11:30:14 -0700
Message-ID: <1430505018-496801-4-git-send-email-tom@herbertland.com>
References: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:11082 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751825AbbEASag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:30:36 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t41ISg8g005667
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 11:30:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4e4m83tc-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:30:36 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 28288d7af03011e480ec0002c991e86a-392d6240 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 11:30:35 -0700
In-Reply-To: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_get_hash_perturb instead of doing skb_flow_dissect and then
jhash by hand.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/sched/sch_hhf.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 15d3aab..9d15cb6 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -9,7 +9,6 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/vmalloc.h>
-#include <net/flow_keys.h>
 #include <net/pkt_sched.h>
 #include <net/sock.h>
 
@@ -176,22 +175,6 @@ static u32 hhf_time_stamp(void)
 	return jiffies;
 }
 
-static unsigned int skb_hash(const struct hhf_sched_data *q,
-			     const struct sk_buff *skb)
-{
-	struct flow_keys keys;
-	unsigned int hash;
-
-	if (skb->sk && skb->sk->sk_hash)
-		return skb->sk->sk_hash;
-
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
-	return hash;
-}
-
 /* Looks up a heavy-hitter flow in a chaining list of table T. */
 static struct hh_flow_state *seek_list(const u32 hash,
 				       struct list_head *head,
@@ -280,7 +263,7 @@ static enum wdrr_bucket_idx hhf_classify(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	/* Get hashed flow-id of the skb. */
-	hash = skb_hash(q, skb);
+	hash = skb_get_hash_perturb(skb, q->perturbation);
 
 	/* Check if this packet belongs to an already established HH flow. */
 	flow_pos = hash & HHF_BIT_MASK;
-- 
1.8.1
