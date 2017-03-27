From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: [PATCH net-next 2/2] cls_flower: add support for matching MPLS labels
Date: Mon, 27 Mar 2017 14:16:02 -0400
Message-ID: <20170327181602.GA3260@nvt-d.home.kvack.org>
References: <20170327181342.GA3230@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35656 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751991AbdC0SQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:16:34 -0400
Received: by mail-it0-f44.google.com with SMTP id y18so84963255itc.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:16:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170327181342.GA3230@nvt-d.home.kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to tc flower to match based on fields in MPLS labels (TTL, 
Bottom of Stack, TC field, Label).

Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 7a69f2a..f1129e3 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -432,6 +432,11 @@ enum {
 	TCA_FLOWER_KEY_ARP_THA,		/* ETH_ALEN */
 	TCA_FLOWER_KEY_ARP_THA_MASK,	/* ETH_ALEN */
 
+	TCA_FLOWER_KEY_MPLS_TTL,	/* u8 - 8 bits */
+	TCA_FLOWER_KEY_MPLS_BOS,	/* u8 - 1 bit */
+	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
+	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 9d0c99d..24619f9 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -18,6 +18,7 @@
 #include <linux/if_ether.h>
 #include <linux/in6.h>
 #include <linux/ip.h>
+#include <linux/mpls.h>
 
 #include <net/sch_generic.h>
 #include <net/pkt_cls.h>
@@ -47,6 +48,7 @@ struct fl_flow_key {
 		struct flow_dissector_key_ipv6_addrs enc_ipv6;
 	};
 	struct flow_dissector_key_ports enc_tp;
+	struct flow_dissector_key_mpls mpls;
 } __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
 
 struct fl_flow_mask_range {
@@ -423,6 +425,10 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_ARP_SHA_MASK]	= { .len = ETH_ALEN },
 	[TCA_FLOWER_KEY_ARP_THA]	= { .len = ETH_ALEN },
 	[TCA_FLOWER_KEY_ARP_THA_MASK]	= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_MPLS_TTL]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_MPLS_BOS]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_MPLS_TC]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_MPLS_LABEL]	= { .type = NLA_U32 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -438,6 +444,36 @@ static void fl_set_key_val(struct nlattr **tb,
 		memcpy(mask, nla_data(tb[mask_type]), len);
 }
 
+static void fl_set_key_mpls(struct nlattr **tb,
+			    struct flow_dissector_key_mpls *key_val,
+			    struct flow_dissector_key_mpls *key_mask)
+{
+#define MPLS_TTL_MASK	(MPLS_LS_TTL_MASK >> MPLS_LS_TTL_SHIFT)
+#define MPLS_BOS_MASK	(MPLS_LS_S_MASK >> MPLS_LS_S_SHIFT)
+#define MPLS_TC_MASK	(MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)
+#define MPLS_LABEL_MASK	(MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)
+
+	if (tb[TCA_FLOWER_KEY_MPLS_TTL]) {
+		key_val->mpls_ttl = nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_TTL]);
+		key_mask->mpls_ttl = MPLS_TTL_MASK;
+	}
+	if (tb[TCA_FLOWER_KEY_MPLS_BOS]) {
+		key_val->mpls_bos = nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_BOS]);
+		key_mask->mpls_bos = MPLS_BOS_MASK;
+	}
+	if (tb[TCA_FLOWER_KEY_MPLS_TC]) {
+		key_val->mpls_tc =
+			nla_get_u8(tb[TCA_FLOWER_KEY_MPLS_TC]) & MPLS_TC_MASK;
+		key_mask->mpls_tc = MPLS_TC_MASK;
+	}
+	if (tb[TCA_FLOWER_KEY_MPLS_LABEL]) {
+		key_val->mpls_label =
+			nla_get_u32(tb[TCA_FLOWER_KEY_MPLS_LABEL]) &
+			MPLS_LABEL_MASK;
+		key_mask->mpls_label = MPLS_LABEL_MASK;
+	}
+}
+
 static void fl_set_key_vlan(struct nlattr **tb,
 			    struct flow_dissector_key_vlan *key_val,
 			    struct flow_dissector_key_vlan *key_mask)
@@ -594,6 +630,9 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       &mask->icmp.code,
 			       TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
 			       sizeof(key->icmp.code));
+	} else if (key->basic.n_proto == htons(ETH_P_MPLS_UC) ||
+		   key->basic.n_proto == htons(ETH_P_MPLS_MC)) {
+		fl_set_key_mpls(tb, &key->mpls, &mask->mpls);
 	} else if (key->basic.n_proto == htons(ETH_P_ARP) ||
 		   key->basic.n_proto == htons(ETH_P_RARP)) {
 		fl_set_key_val(tb, &key->arp.sip, TCA_FLOWER_KEY_ARP_SIP,
@@ -730,6 +769,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ARP, arp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_MPLS, mpls);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_VLAN, vlan);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ENC_KEYID, enc_key_id);
@@ -994,6 +1035,41 @@ static int fl_dump_key_val(struct sk_buff *skb,
 	return 0;
 }
 
+static int fl_dump_key_mpls(struct sk_buff *skb,
+			    struct flow_dissector_key_mpls *mpls_key,
+			    struct flow_dissector_key_mpls *mpls_mask)
+{
+	int err;
+
+	if (!memchr_inv(mpls_mask, 0, sizeof(*mpls_mask)))
+		return 0;
+	if (mpls_mask->mpls_ttl) {
+		err = nla_put_u8(skb, TCA_FLOWER_KEY_MPLS_TTL,
+				 mpls_key->mpls_ttl);
+		if (err)
+			return err;
+	}
+	if (mpls_mask->mpls_tc) {
+		err = nla_put_u8(skb, TCA_FLOWER_KEY_MPLS_TC,
+				 mpls_key->mpls_tc);
+		if (err)
+			return err;
+	}
+	if (mpls_mask->mpls_label) {
+		err = nla_put_u32(skb, TCA_FLOWER_KEY_MPLS_LABEL,
+				  mpls_key->mpls_label);
+		if (err)
+			return err;
+	}
+	if (mpls_mask->mpls_bos) {
+		err = nla_put_u8(skb, TCA_FLOWER_KEY_MPLS_BOS,
+				 mpls_key->mpls_bos);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
 static int fl_dump_key_vlan(struct sk_buff *skb,
 			    struct flow_dissector_key_vlan *vlan_key,
 			    struct flow_dissector_key_vlan *vlan_mask)
@@ -1099,6 +1175,9 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			    sizeof(key->basic.n_proto)))
 		goto nla_put_failure;
 
+	if (fl_dump_key_mpls(skb, &key->mpls, &mask->mpls))
+		goto nla_put_failure;
+
 	if (fl_dump_key_vlan(skb, &key->vlan, &mask->vlan))
 		goto nla_put_failure;
 
