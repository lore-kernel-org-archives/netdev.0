From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 08:02:05 -0700
Message-ID: <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	 <1402338773-5996-2-git-send-email-_govind@gmx.com>
	 <CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	 <alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	 <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:58950 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755841AbaIRPCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 11:02:08 -0400
Received: by mail-pd0-f178.google.com with SMTP id p10so1571749pdj.9
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 08:02:07 -0700 (PDT)
In-Reply-To: <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We cannot make struct qdisc_skb_cb bigger without impacting IPoIB,
or increasing skb->cb[] size.

Commit e0f31d849867 ("flow_keys: Record IP layer protocol in
skb_flow_dissect()") broke IPoIB.

Only current offender is sch_choke, and this one do not need an
absolutely precise flow key.

If we store 17 bytes of flow key, its more than enough. (Its the actual
size of flow_keys if it was a packed structure, but we might add new
fields at the end of it later)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: e0f31d849867 ("flow_keys: Record IP layer protocol in skb_flow_dissect()")
---
 include/net/sch_generic.h |    3 ++-
 net/sched/sch_choke.c     |   18 ++++++++++++++----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a3cfb8ebeb53..620e086c0cbe 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -231,7 +231,8 @@ struct qdisc_skb_cb {
 	unsigned int		pkt_len;
 	u16			slave_dev_queue_mapping;
 	u16			_pad;
-	unsigned char		data[24];
+#define QDISC_CB_PRIV_LEN 20
+	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index ed30e436128b..fb666d1e4de3 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -133,10 +133,16 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
 	--sch->q.qlen;
 }
 
+/* private part of skb->cb[] that a qdisc is allowed to use
+ * is limited to QDISC_CB_PRIV_LEN bytes.
+ * As a flow key might be too large, we store a part of it only.
+ */
+#define CHOKE_K_LEN min_t(u32, sizeof(struct flow_keys), QDISC_CB_PRIV_LEN - 3)
+
 struct choke_skb_cb {
 	u16			classid;
 	u8			keys_valid;
-	struct flow_keys	keys;
+	u8			keys[QDISC_CB_PRIV_LEN - 3];
 };
 
 static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)
@@ -163,22 +169,26 @@ static u16 choke_get_classid(const struct sk_buff *skb)
 static bool choke_match_flow(struct sk_buff *skb1,
 			     struct sk_buff *skb2)
 {
+	struct flow_keys temp;
+
 	if (skb1->protocol != skb2->protocol)
 		return false;
 
 	if (!choke_skb_cb(skb1)->keys_valid) {
 		choke_skb_cb(skb1)->keys_valid = 1;
-		skb_flow_dissect(skb1, &choke_skb_cb(skb1)->keys);
+		skb_flow_dissect(skb1, &temp);
+		memcpy(&choke_skb_cb(skb1)->keys, &temp, CHOKE_K_LEN);
 	}
 
 	if (!choke_skb_cb(skb2)->keys_valid) {
 		choke_skb_cb(skb2)->keys_valid = 1;
-		skb_flow_dissect(skb2, &choke_skb_cb(skb2)->keys);
+		skb_flow_dissect(skb2, &temp);
+		memcpy(&choke_skb_cb(skb2)->keys, &temp, CHOKE_K_LEN);
 	}
 
 	return !memcmp(&choke_skb_cb(skb1)->keys,
 		       &choke_skb_cb(skb2)->keys,
-		       sizeof(struct flow_keys));
+		       CHOKE_K_LEN);
 }
 
 /*
