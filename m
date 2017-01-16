From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH net-next] net/sched: cls_flower: Disallow duplicate internal elements
Date: Mon, 16 Jan 2017 10:45:13 +0200
Message-ID: <1484556313-33614-1-git-send-email-paulb@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49004 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751107AbdAPIpZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 03:45:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flower currently allows having the same filter twice with the same
priority. Actions (and statistics update) will always execute on the
first inserted rule leaving the second rule unused.
This patch disallows that.

Signed-off-by: Paul Blakey <paulb@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index a3bfda3..2793445 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -134,6 +134,14 @@ static void fl_clear_masked_range(struct fl_flow_key *key,
 	memset(fl_key_get_start(key, mask), 0, fl_mask_range(mask));
 }
 
+static struct cls_fl_filter *fl_lookup(struct cls_fl_head *head,
+				       struct fl_flow_key *mkey)
+{
+	return rhashtable_lookup_fast(&head->ht,
+				      fl_key_get_start(mkey, &head->mask),
+				      head->ht_params);
+}
+
 static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		       struct tcf_result *res)
 {
@@ -181,9 +189,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 	fl_set_masked_key(&skb_mkey, &skb_key, &head->mask);
 
-	f = rhashtable_lookup_fast(&head->ht,
-				   fl_key_get_start(&skb_mkey, &head->mask),
-				   head->ht_params);
+	f = fl_lookup(head, &skb_mkey);
 	if (f && !tc_skip_sw(f->flags)) {
 		*res = f->res;
 		return tcf_exts_exec(skb, &f->exts, res);
@@ -875,6 +881,11 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 
 	if (!tc_skip_sw(fnew->flags)) {
+		if (!fold && fl_lookup(head, &fnew->mkey)) {
+			err = -EEXIST;
+			goto errout;
+		}
+
 		err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
 					     head->ht_params);
 		if (err)
-- 
2.7.4
