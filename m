From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 7/7] sch_choke: Use flow_keys_digest
Date: Fri, 1 May 2015 11:30:18 -0700
Message-ID: <1430505018-496801-8-git-send-email-tom@herbertland.com>
References: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17703 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751825AbbEASar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:30:47 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t41IT8Wa011640
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 11:30:47 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u4dmd897t-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:30:47 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 2e5f0962f03011e49a4d0002c991e86a-3a2d8240 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 11:30:45 -0700
In-Reply-To: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call make_flow_keys_digest to get a digest from flow keys and
use that to pass skbuff cb and for comparing flows.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/sched/sch_choke.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index c009eb9..dfe3da7 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -133,16 +133,10 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 	--sch->q.qlen;
 }
 
-/* private part of skb->cb[] that a qdisc is allowed to use
- * is limited to QDISC_CB_PRIV_LEN bytes.
- * As a flow key might be too large, we store a part of it only.
- */
-#define CHOKE_K_LEN min_t(u32, sizeof(struct flow_keys), QDISC_CB_PRIV_LEN - 3)
-
 struct choke_skb_cb {
 	u16			classid;
 	u8			keys_valid;
-	u8			keys[QDISC_CB_PRIV_LEN - 3];
+	struct			flow_keys_digest keys;
 };
 
 static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)
@@ -177,18 +171,18 @@ static bool choke_match_flow(struct sk_buff *skb1,
 	if (!choke_skb_cb(skb1)->keys_valid) {
 		choke_skb_cb(skb1)->keys_valid = 1;
 		skb_flow_dissect(skb1, &temp);
-		memcpy(&choke_skb_cb(skb1)->keys, &temp, CHOKE_K_LEN);
+		make_flow_keys_digest(&choke_skb_cb(skb1)->keys, &temp);
 	}
 
 	if (!choke_skb_cb(skb2)->keys_valid) {
 		choke_skb_cb(skb2)->keys_valid = 1;
 		skb_flow_dissect(skb2, &temp);
-		memcpy(&choke_skb_cb(skb2)->keys, &temp, CHOKE_K_LEN);
+		make_flow_keys_digest(&choke_skb_cb(skb2)->keys, &temp);
 	}
 
 	return !memcmp(&choke_skb_cb(skb1)->keys,
 		       &choke_skb_cb(skb2)->keys,
-		       CHOKE_K_LEN);
+		       sizeof(choke_skb_cb(skb1)->keys));
 }
 
 /*
-- 
1.8.1
