From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: [PATCH] flower: check unused bits in MPLS fields
Date: Mon,  1 May 2017 09:58:40 -0400
Message-ID: <1493647120-17406-1-git-send-email-benjamin.lahaise@netronome.com>
Cc: Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <kubakici@wp.pl>, Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36458 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969191AbdEAN7C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 09:59:02 -0400
Received: by mail-io0-f175.google.com with SMTP id p80so118732049iop.3
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 06:59:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since several of the the netlink attributes used to configure the flower
classifier's MPLS TC, BOS and Label fields have additional bits which are
unused, check those bits to ensure that they are actually 0 as suggested
by Jamal.

Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Cc: David Miller <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Simon Horman <simon.horman@netronome.com>
Cc: Jakub Kicinski <kubakici@wp.pl>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_flower.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 3ecf076..ca526c0 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -439,29 +439,39 @@ static void fl_set_key_val(struct nlattr **tb,
 		memcpy(mask, nla_data(tb[mask_type]), len);
 }
 
-static void fl_set_key_mpls(struct nlattr **tb,
-			    struct flow_dissector_key_mpls *key_val,
-			    struct flow_dissector_key_mpls *key_mask)
+static int fl_set_key_mpls(struct nlattr **tb,
+			   struct flow_dissector_key_mpls *key_val,
+			   struct flow_dissector_key_mpls *key_mask)
 {
 	if (tb[TCA_FLOWER_KEY_MPLS_TTL]) {
 		key_val->mpls_ttl = nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_TTL]);
 		key_mask->mpls_ttl = MPLS_TTL_MASK;
 	}
 	if (tb[TCA_FLOWER_KEY_MPLS_BOS]) {
-		key_val->mpls_bos = nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_BOS]);
+		u8 bos = nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_BOS]);
+
+		if (bos & ~MPLS_BOS_MASK)
+			return -EINVAL;
+		key_val->mpls_bos = bos;
 		key_mask->mpls_bos = MPLS_BOS_MASK;
 	}
 	if (tb[TCA_FLOWER_KEY_MPLS_TC]) {
-		key_val->mpls_tc =
-			nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_TC]) & MPLS_TC_MASK;
+		u8 tc = nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_TC]);
+
+		if (tc & ~MPLS_TC_MASK)
+			return -EINVAL;
+		key_val->mpls_tc = tc;
 		key_mask->mpls_tc = MPLS_TC_MASK;
 	}
 	if (tb[TCA_FLOWER_KEY_MPLS_LABEL]) {
-		key_val->mpls_label =
-			nla_get_u32(tb[TCA_FLOWER_KEY_MPLS_LABEL]) &
-			MPLS_LABEL_MASK;
+		u32 label = nla_get_u32(tb[TCA_FLOWER_KEY_MPLS_LABEL]);
+
+		if (label & ~MPLS_LABEL_MASK)
+			return -EINVAL;
+		key_val->mpls_label = label;
 		key_mask->mpls_label = MPLS_LABEL_MASK;
 	}
+	return 0;
 }
 
 static void fl_set_key_vlan(struct nlattr **tb,
@@ -622,7 +632,9 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       sizeof(key->icmp.code));
 	} else if (key->basic.n_proto == htons(ETH_P_MPLS_UC) ||
 		   key->basic.n_proto == htons(ETH_P_MPLS_MC)) {
-		fl_set_key_mpls(tb, &key->mpls, &mask->mpls);
+		ret = fl_set_key_mpls(tb, &key->mpls, &mask->mpls);
+		if (ret)
+			return ret;
 	} else if (key->basic.n_proto == htons(ETH_P_ARP) ||
 		   key->basic.n_proto == htons(ETH_P_RARP)) {
 		fl_set_key_val(tb, &key->arp.sip, TCA_FLOWER_KEY_ARP_SIP,
-- 
2.7.4
