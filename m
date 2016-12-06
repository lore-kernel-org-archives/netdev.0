From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/3] net/sched: cls_flower: Add support for
 matching on flags
Date: Tue, 6 Dec 2016 13:40:06 +0100
Message-ID: <20161206124006.GL1984@nanopsycho>
References: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
 <1481027579-23195-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:36542 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752674AbcLFMkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 07:40:11 -0500
Received: by mail-wj0-f195.google.com with SMTP id j10so16300858wjb.3
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 04:40:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481027579-23195-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 06, 2016 at 01:32:58PM CET, ogerlitz@mellanox.com wrote:
>Add UAPI to provide set of flags for matching, where the flags
>provided from user-space are mapped to flow-dissector flags.
>
>The 1st flag allows to match on whether the packet is an
>IP fragment and corresponds to the FLOW_DIS_IS_FRAGMENT flag.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Reviewed-by: Paul Blakey <paulb@mellanox.com>
>---
> include/uapi/linux/pkt_cls.h |  7 ++++
> net/sched/cls_flower.c       | 83 ++++++++++++++++++++++++++++++++++++++++++++
> 2 files changed, 90 insertions(+)
>
>diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>index 86786d4..f114277 100644
>--- a/include/uapi/linux/pkt_cls.h
>+++ b/include/uapi/linux/pkt_cls.h
>@@ -457,11 +457,18 @@ enum {
> 	TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,	/* be16 */
> 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT,	/* be16 */
> 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,	/* be16 */
>+
>+	TCA_FLOWER_KEY_FLAGS,		/* be32 */
>+	TCA_FLOWER_KEY_FLAGS_MASK,	/* be32 */
> 	__TCA_FLOWER_MAX,
> };
> 
> #define TCA_FLOWER_MAX (__TCA_FLOWER_MAX - 1)
> 
>+enum {
>+	TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT = BIT(0),
>+};
>+
> /* Match-all classifier */
> 
> enum {
>diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
>index c5cea78..d9f4124 100644
>--- a/net/sched/cls_flower.c
>+++ b/net/sched/cls_flower.c
>@@ -383,6 +383,8 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
> 	[TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK]	= { .type = NLA_U16 },
> 	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT]	= { .type = NLA_U16 },
> 	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK]	= { .type = NLA_U16 },
>+	[TCA_FLOWER_KEY_FLAGS]		= { .type = NLA_U32 },
>+	[TCA_FLOWER_KEY_FLAGS_MASK]	= { .type = NLA_U32 },
> };
> 
> static void fl_set_key_val(struct nlattr **tb,
>@@ -417,6 +419,40 @@ static void fl_set_key_vlan(struct nlattr **tb,
> 	}
> }
> 
>+static void set_flags(u32 flower_key, u32 flower_mask,

Use some prefix for helpers like this, or at least __



>+		      u32 *dissector_key, u32 *dissector_mask,
>+		      u32 flower_flag_bit, u32 dissector_flag_bit)
>+{
>+	if (flower_mask & flower_flag_bit) {
>+		*dissector_mask |= dissector_flag_bit;
>+		if (flower_key & flower_flag_bit)
>+			*dissector_key |= dissector_flag_bit;
>+	}
>+}
>+
>+static void fl_set_key_flags(struct nlattr **tb,
>+			     u32 *flags_key,
>+			     u32 *flags_mask)
>+{
>+	u32 key, mask;
>+
>+	if (!tb[TCA_FLOWER_KEY_FLAGS])
>+		return;
>+
>+	key = be32_to_cpu(nla_get_u32(tb[TCA_FLOWER_KEY_FLAGS]));
>+
>+	if (!tb[TCA_FLOWER_KEY_FLAGS_MASK])
>+		mask = ~0;
>+	else
>+		mask = be32_to_cpu(nla_get_u32(tb[TCA_FLOWER_KEY_FLAGS_MASK]));
>+
>+	*flags_key  = 0;
>+	*flags_mask = 0;
>+
>+	set_flags(key, mask, flags_key, flags_mask,
>+		  TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT, FLOW_DIS_IS_FRAGMENT);
>+}
>+
> static int fl_set_key(struct net *net, struct nlattr **tb,
> 		      struct fl_flow_key *key, struct fl_flow_key *mask)
> {
>@@ -543,6 +579,8 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
> 		       &mask->enc_tp.dst, TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,
> 		       sizeof(key->enc_tp.dst));
> 
>+	fl_set_key_flags(tb, &key->control.flags, &mask->control.flags);
>+
> 	return 0;
> }
> 
>@@ -877,6 +915,48 @@ static int fl_dump_key_vlan(struct sk_buff *skb,
> 	return 0;
> }
> 
>+static void get_flags(u32 dissector_key, u32 dissector_mask,

Same here.


>+		      u32 *flower_key, u32 *flower_mask,
>+		      u32 flower_flag_bit, u32 dissector_flag_bit)
>+{
>+	if (dissector_mask & dissector_flag_bit) {
>+		*flower_mask |= flower_flag_bit;
>+		if (dissector_key & dissector_flag_bit)
>+			*flower_key |= flower_flag_bit;
>+	}
>+}
>+
>+static int fl_dump_key_flags(struct sk_buff *skb,
>+			     u32 flags_key,
>+			     u32 flags_mask)

over-wrapped :)


>+{
>+	u32 key, mask;
>+	__be32 _key, _mask;
>+	int err;
>+
>+	if (!memchr_inv(&flags_mask, 0, sizeof(flags_mask)))
>+		return 0;
>+
>+	key  = 0;
            ^ remove the extra space


>+	mask = 0;
>+
>+	get_flags(flags_key, flags_mask, &key, &mask,
>+		  TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT, FLOW_DIS_IS_FRAGMENT);
>+
>+	_key  = cpu_to_be32(key);
             ^ remove the extra space


>+	_mask = cpu_to_be32(mask);
>+
>+	err = nla_put(skb, TCA_FLOWER_KEY_FLAGS, 4, &_key);
>+	if (err)
>+		return err;
>+
>+	err = nla_put(skb, TCA_FLOWER_KEY_FLAGS_MASK, 4, &_mask);

Just return nla_put...


>+	if (err)
>+		return err;
>+
>+	return 0;
>+}
>+
> static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
> 		   struct sk_buff *skb, struct tcmsg *t)
> {
>@@ -1012,6 +1092,9 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
> 			    sizeof(key->enc_tp.dst)))
> 		goto nla_put_failure;
> 
>+	if (fl_dump_key_flags(skb, key->control.flags, mask->control.flags))
>+		goto nla_put_failure;
>+
> 	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
> 
> 	if (tcf_exts_dump(skb, &f->exts))
>-- 
>2.3.7
>
