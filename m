From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/sched: cls_flower: Mandate mask when matching on flags
Date: Thu, 22 Dec 2016 14:28:15 +0200
Message-ID: <1482409695-27956-3-git-send-email-ogerlitz@mellanox.com>
References: <1482409695-27956-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58716 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965298AbcLVM2a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 07:28:30 -0500
In-Reply-To: <1482409695-27956-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When matching on flags, we should require the user to provide the
mask and avoid using an all-ones mask. Not doing so causes matching
on flags provided w.o mask to hit on the value being unset for all
flags, which may not what the user wanted to happen.

Fixes: faa3ffce7829 ('net/sched: cls_flower: Add support for matching on flags')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Paul Blakey <paulb@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 35ac28d..333f8e2 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -442,32 +442,32 @@ static void fl_set_key_flag(u32 flower_key, u32 flower_mask,
 	}
 }
 
-static void fl_set_key_flags(struct nlattr **tb,
-			     u32 *flags_key, u32 *flags_mask)
+static int fl_set_key_flags(struct nlattr **tb,
+			    u32 *flags_key, u32 *flags_mask)
 {
 	u32 key, mask;
 
-	if (!tb[TCA_FLOWER_KEY_FLAGS])
-		return;
+	/* mask is mandatory for flags */
+	if (!tb[TCA_FLOWER_KEY_FLAGS_MASK])
+		return -EINVAL;
 
 	key = be32_to_cpu(nla_get_u32(tb[TCA_FLOWER_KEY_FLAGS]));
-
-	if (!tb[TCA_FLOWER_KEY_FLAGS_MASK])
-		mask = ~0;
-	else
-		mask = be32_to_cpu(nla_get_u32(tb[TCA_FLOWER_KEY_FLAGS_MASK]));
+	mask = be32_to_cpu(nla_get_u32(tb[TCA_FLOWER_KEY_FLAGS_MASK]));
 
 	*flags_key  = 0;
 	*flags_mask = 0;
 
 	fl_set_key_flag(key, mask, flags_key, flags_mask,
 			TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT, FLOW_DIS_IS_FRAGMENT);
+
+	return 0;
 }
 
 static int fl_set_key(struct net *net, struct nlattr **tb,
 		      struct fl_flow_key *key, struct fl_flow_key *mask)
 {
 	__be16 ethertype;
+	int ret = 0;
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_FLOWER_INDEV]) {
 		int err = tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);
@@ -614,9 +614,10 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		       &mask->enc_tp.dst, TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,
 		       sizeof(key->enc_tp.dst));
 
-	fl_set_key_flags(tb, &key->control.flags, &mask->control.flags);
+	if (tb[TCA_FLOWER_KEY_FLAGS])
+		ret = fl_set_key_flags(tb, &key->control.flags, &mask->control.flags);
 
-	return 0;
+	return ret;
 }
 
 static bool fl_mask_eq(struct fl_flow_mask *mask1,
-- 
2.3.7
