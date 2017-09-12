From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 2/2] net/sched: allow flower to match tunnel options
Date: Tue, 12 Sep 2017 16:20:37 +0200
Message-ID: <1505226037-2758-3-git-send-email-simon.horman@netronome.com>
References: <1505226037-2758-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:44845 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdILOVs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 10:21:48 -0400
Received: by mail-wm0-f51.google.com with SMTP id 189so8825wmh.1
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 07:21:47 -0700 (PDT)
In-Reply-To: <1505226037-2758-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow matching on options in tunnel headers.
This makes use of existing tunnel metadata support.

Options are a bytestring of up to 256 bytes.
Tunnel implementations may support less or more options,
or no options at all.

 # ip link add name geneve0 type geneve dstport 0 external
 # tc qdisc add dev eth0 ingress
 # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
 # tc filter add dev eth0 protocol ip parent ffff: \
     flower indev eth0 \
        ip_proto udp \
        action tunnel_key \
            set src_ip 10.0.99.192 \
            dst_ip 10.0.99.193 \
            dst_port 4789 \
            id 11 \
            opts 0102800100800022 \
    action mirred egress redirect dev geneve0

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/net/flow_dissector.h | 13 +++++++++++++
 include/uapi/linux/pkt_cls.h |  3 +++
 net/sched/cls_flower.c       | 35 ++++++++++++++++++++++++++++++++++-
 3 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index fc3dce730a6b..43f98bf0b349 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -183,6 +183,18 @@ struct flow_dissector_key_ip {
 	__u8	ttl;
 };
 
+/**
+ * struct flow_dissector_key_enc_opts:
+ * @data: data
+ * @len: len
+ */
+struct flow_dissector_key_enc_opts {
+	u8 data[256];	/* Using IP_TUNNEL_OPTS_MAX is desired here
+			 * but seems difficult to #include
+			 */
+	u8 len;
+};
+
 enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
@@ -205,6 +217,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
 	FLOW_DISSECTOR_KEY_TCP, /* struct flow_dissector_key_tcp */
 	FLOW_DISSECTOR_KEY_IP, /* struct flow_dissector_key_ip */
+	FLOW_DISSECTOR_KEY_ENC_OPTS, /* struct flow_dissector_key_enc_opts */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index d5e2bf68d0d4..7a09a28f21e0 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -467,6 +467,9 @@ enum {
 	TCA_FLOWER_KEY_IP_TTL,		/* u8 */
 	TCA_FLOWER_KEY_IP_TTL_MASK,	/* u8 */
 
+	TCA_FLOWER_KEY_ENC_OPTS,
+	TCA_FLOWER_KEY_ENC_OPTS_MASK,
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 1a267e77c6de..2a8364ef4fd5 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -51,6 +51,7 @@ struct fl_flow_key {
 	struct flow_dissector_key_mpls mpls;
 	struct flow_dissector_key_tcp tcp;
 	struct flow_dissector_key_ip ip;
+	struct flow_dissector_key_enc_opts enc_opts;
 } __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
 
 struct fl_flow_mask_range {
@@ -181,6 +182,11 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		skb_key.enc_key_id.keyid = tunnel_id_to_key32(key->tun_id);
 		skb_key.enc_tp.src = key->tp_src;
 		skb_key.enc_tp.dst = key->tp_dst;
+
+		if (info->options_len) {
+			skb_key.enc_opts.len = info->options_len;
+			ip_tunnel_info_opts_get(skb_key.enc_opts.data, info);
+		}
 	}
 
 	skb_key.indev_ifindex = skb->skb_iif;
@@ -421,6 +427,8 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_IP_TOS_MASK]	= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_IP_TTL]		= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_IP_TTL_MASK]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ENC_OPTS]	= { .type = NLA_BINARY },
+	[TCA_FLOWER_KEY_ENC_OPTS_MASK]	= { .type = NLA_BINARY },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -712,6 +720,26 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		       &mask->enc_tp.dst, TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,
 		       sizeof(key->enc_tp.dst));
 
+	if (tb[TCA_FLOWER_KEY_ENC_OPTS]) {
+		key->enc_opts.len = nla_len(tb[TCA_FLOWER_KEY_ENC_OPTS]);
+
+		if (key->enc_opts.len > sizeof(key->enc_opts.data))
+			return -EINVAL;
+
+		/* enc_opts is variable length.
+		 * If present ensure the value and mask are the same length.
+		 */
+		if (tb[TCA_FLOWER_KEY_ENC_OPTS_MASK] &&
+		    nla_len(tb[TCA_FLOWER_KEY_ENC_OPTS_MASK]) != key->enc_opts.len)
+			return -EINVAL;
+
+		mask->enc_opts.len = key->enc_opts.len;
+		fl_set_key_val(tb, key->enc_opts.data, TCA_FLOWER_KEY_ENC_OPTS,
+			       mask->enc_opts.data,
+			       TCA_FLOWER_KEY_ENC_OPTS_MASK,
+			       key->enc_opts.len);
+	}
+
 	if (tb[TCA_FLOWER_KEY_FLAGS])
 		ret = fl_set_key_flags(tb, &key->control.flags, &mask->control.flags);
 
@@ -804,6 +832,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 			   enc_control);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ENC_PORTS, enc_tp);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ENC_OPTS, enc_opts);
 
 	skb_flow_dissector_init(&head->dissector, keys, cnt);
 }
@@ -1327,7 +1357,10 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, void *fh,
 			    TCA_FLOWER_KEY_ENC_UDP_DST_PORT,
 			    &mask->enc_tp.dst,
 			    TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,
-			    sizeof(key->enc_tp.dst)))
+			    sizeof(key->enc_tp.dst)) ||
+	    fl_dump_key_val(skb, key->enc_opts.data, TCA_FLOWER_KEY_ENC_OPTS,
+			    mask->enc_opts.data, TCA_FLOWER_KEY_ENC_OPTS_MASK,
+			    key->enc_opts.len))
 		goto nla_put_failure;
 
 	if (fl_dump_key_flags(skb, key->control.flags, mask->control.flags))
-- 
2.1.4
