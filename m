From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 1/2] net/sched: cls_flower: Add support for matching on flags
Date: Wed,  7 Dec 2016 14:03:10 +0200
Message-ID: <1481112191-14115-2-git-send-email-ogerlitz@mellanox.com>
References: <1481112191-14115-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37731 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752704AbcLGMDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:03:18 -0500
In-Reply-To: <1481112191-14115-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add UAPI to provide set of flags for matching, where the flags
provided from user-space are mapped to flow-dissector flags.

The 1st flag allows to match on whether the packet is an
IP fragment and corresponds to the FLOW_DIS_IS_FRAGMENT flag.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/pkt_cls.h |  7 ++++
 net/sched/cls_flower.c       | 76 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 86786d4..42ee221 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -457,11 +457,18 @@ enum {
 	TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,	/* be16 */
 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT,	/* be16 */
 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,	/* be16 */
+
+	TCA_FLOWER_KEY_FLAGS,		/* be32 */
+	TCA_FLOWER_KEY_FLAGS_MASK,	/* be32 */
 	__TCA_FLOWER_MAX,
 };
 
 #define TCA_FLOWER_MAX (__TCA_FLOWER_MAX - 1)
 
+enum {
+	TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT = (1 << 0),
+};
+
 /* Match-all classifier */
 
 enum {
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index c5cea78..0efbeb0 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -383,6 +383,8 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_FLAGS]		= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_FLAGS_MASK]	= { .type = NLA_U32 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -417,6 +419,39 @@ static void fl_set_key_vlan(struct nlattr **tb,
 	}
 }
 
+static void fl_set_key_flag(u32 flower_key, u32 flower_mask,
+			    u32 *dissector_key, u32 *dissector_mask,
+			    u32 flower_flag_bit, u32 dissector_flag_bit)
+{
+	if (flower_mask & flower_flag_bit) {
+		*dissector_mask |= dissector_flag_bit;
+		if (flower_key & flower_flag_bit)
+			*dissector_key |= dissector_flag_bit;
+	}
+}
+
+static void fl_set_key_flags(struct nlattr **tb,
+			     u32 *flags_key, u32 *flags_mask)
+{
+	u32 key, mask;
+
+	if (!tb[TCA_FLOWER_KEY_FLAGS])
+		return;
+
+	key = be32_to_cpu(nla_get_u32(tb[TCA_FLOWER_KEY_FLAGS]));
+
+	if (!tb[TCA_FLOWER_KEY_FLAGS_MASK])
+		mask = ~0;
+	else
+		mask = be32_to_cpu(nla_get_u32(tb[TCA_FLOWER_KEY_FLAGS_MASK]));
+
+	*flags_key  = 0;
+	*flags_mask = 0;
+
+	fl_set_key_flag(key, mask, flags_key, flags_mask,
+			TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT, FLOW_DIS_IS_FRAGMENT);
+}
+
 static int fl_set_key(struct net *net, struct nlattr **tb,
 		      struct fl_flow_key *key, struct fl_flow_key *mask)
 {
@@ -543,6 +578,8 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		       &mask->enc_tp.dst, TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,
 		       sizeof(key->enc_tp.dst));
 
+	fl_set_key_flags(tb, &key->control.flags, &mask->control.flags);
+
 	return 0;
 }
 
@@ -877,6 +914,42 @@ static int fl_dump_key_vlan(struct sk_buff *skb,
 	return 0;
 }
 
+static void fl_get_key_flag(u32 dissector_key, u32 dissector_mask,
+			    u32 *flower_key, u32 *flower_mask,
+			    u32 flower_flag_bit, u32 dissector_flag_bit)
+{
+	if (dissector_mask & dissector_flag_bit) {
+		*flower_mask |= flower_flag_bit;
+		if (dissector_key & dissector_flag_bit)
+			*flower_key |= flower_flag_bit;
+	}
+}
+
+static int fl_dump_key_flags(struct sk_buff *skb, u32 flags_key, u32 flags_mask)
+{
+	u32 key, mask;
+	__be32 _key, _mask;
+	int err;
+
+	if (!memchr_inv(&flags_mask, 0, sizeof(flags_mask)))
+		return 0;
+
+	key = 0;
+	mask = 0;
+
+	fl_get_key_flag(flags_key, flags_mask, &key, &mask,
+			TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT, FLOW_DIS_IS_FRAGMENT);
+
+	_key = cpu_to_be32(key);
+	_mask = cpu_to_be32(mask);
+
+	err = nla_put(skb, TCA_FLOWER_KEY_FLAGS, 4, &_key);
+	if (err)
+		return err;
+
+	return nla_put(skb, TCA_FLOWER_KEY_FLAGS_MASK, 4, &_mask);
+}
+
 static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
@@ -1012,6 +1085,9 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			    sizeof(key->enc_tp.dst)))
 		goto nla_put_failure;
 
+	if (fl_dump_key_flags(skb, key->control.flags, mask->control.flags))
+		goto nla_put_failure;
+
 	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
 
 	if (tcf_exts_dump(skb, &f->exts))
-- 
2.3.7
