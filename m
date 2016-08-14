From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 1/2] net/sched: cls_flower: Introduce classify by vxlan outer headers
Date: Sun, 14 Aug 2016 17:06:51 +0300
Message-ID: <20160814140652.15985-2-amir@vadai.me>
References: <20160814140652.15985-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33172 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbcHNOHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 10:07:11 -0400
Received: by mail-wm0-f65.google.com with SMTP id o80so6565880wme.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 07:07:10 -0700 (PDT)
In-Reply-To: <20160814140652.15985-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>>

Signed-off-by: Amir Vadai <amirva@mellanox.com>>
---
 include/uapi/linux/pkt_cls.h | 11 +++++++++
 net/sched/cls_flower.c       | 53 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index d1c1ccaba787..a192195a5516 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -428,6 +428,17 @@ enum {
 	TCA_FLOWER_KEY_UDP_DST,		/* be16 */
 
 	TCA_FLOWER_FLAGS,
+
+	TCA_FLOWER_KEY_ENC_IPV4_SRC,	/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV4_DST,	/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV6_SRC,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ENC_IPV6_DST,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ENC_IPV6_DST_MASK,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ENC_KEY_ID,	/* be32 */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 5060801a2f6d..26436dd34e21 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -23,12 +23,18 @@
 #include <net/ip.h>
 #include <net/flow_dissector.h>
 
+#include <net/dst.h>
+#include <net/dst_metadata.h>
+#include <net/vxlan.h>
+
 struct fl_flow_key {
 	int	indev_ifindex;
 	struct flow_dissector_key_control control;
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_eth_addrs eth;
 	struct flow_dissector_key_addrs ipaddrs;
+	struct flow_dissector_key_ipv4_addrs enc_ipv4;
+	struct flow_dissector_key_keyid enc_key_id;
 	union {
 		struct flow_dissector_key_ipv4_addrs ipv4;
 		struct flow_dissector_key_ipv6_addrs ipv6;
@@ -123,11 +129,27 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct cls_fl_filter *f;
 	struct fl_flow_key skb_key;
 	struct fl_flow_key skb_mkey;
+	struct ip_tunnel_info *info;
 
 	if (!atomic_read(&head->ht.nelems))
 		return -1;
 
 	fl_clear_masked_range(&skb_key, &head->mask);
+
+	info = skb_tunnel_info(skb);
+	if (info) {
+		struct ip_tunnel_key *key = &info->key;
+		netdev_err(skb->dev, "%s:%d saddr: %pI4, daddr: %pI4 vni: %d tos: %#x ttl: %#x src_port: %d dst_port: %d\n",
+			      __func__, __LINE__,
+			      &key->u.ipv4.src, &key->u.ipv4.dst,
+			      be32_to_cpu(vxlan_tun_id_to_vni(key->tun_id)),
+			      key->tos, key->ttl,
+			      ntohs(key->tp_src), ntohs(key->tp_dst));
+		skb_key.enc_ipv4.src = key->u.ipv4.src;
+		skb_key.enc_ipv4.dst = key->u.ipv4.dst;
+		skb_key.enc_key_id.keyid = vxlan_tun_id_to_vni(key->tun_id);
+	}
+
 	skb_key.indev_ifindex = skb->skb_iif;
 	/* skb_flow_dissect() does not set n_proto in case an unknown protocol,
 	 * so do it rather here.
@@ -293,6 +315,12 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_TCP_DST]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_UDP_SRC]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_UDP_DST]	= { .type = NLA_U16 },
+
+	[TCA_FLOWER_KEY_ENC_IPV4_SRC]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK] = { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV4_DST]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV4_DST_MASK] = { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_KEY_ID]	= { .type = NLA_U32 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -373,6 +401,20 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       sizeof(key->tp.dst));
 	}
 
+	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
+	    tb[TCA_FLOWER_KEY_ENC_IPV4_DST] ||
+	    tb[TCA_FLOWER_KEY_ENC_KEY_ID]) {
+		fl_set_key_val(tb, &key->enc_ipv4.src, TCA_FLOWER_KEY_ENC_IPV4_SRC,
+			       &mask->enc_ipv4.src, TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,
+			       sizeof(key->enc_ipv4.src));
+		fl_set_key_val(tb, &key->enc_ipv4.dst, TCA_FLOWER_KEY_ENC_IPV4_DST,
+			       &mask->enc_ipv4.dst, TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,
+			       sizeof(key->enc_ipv4.dst));
+		fl_set_key_val(tb, &key->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
+			       &mask->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
+			       sizeof(key->enc_key_id));
+	}
+
 	return 0;
 }
 
@@ -753,6 +795,17 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
 
+	if (fl_dump_key_val(skb, &key->enc_ipv4.src, TCA_FLOWER_KEY_ENC_IPV4_SRC,
+			    &mask->enc_ipv4.src, TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,
+			    sizeof(key->enc_ipv4.src)) ||
+	    fl_dump_key_val(skb, &key->enc_ipv4.dst, TCA_FLOWER_KEY_ENC_IPV4_DST,
+			    &mask->enc_ipv4.dst, TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,
+			    sizeof(key->enc_ipv4.dst)) ||
+	    fl_dump_key_val(skb, &key->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
+			    &mask->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
+			    sizeof(key->enc_key_id)))
+		goto nla_put_failure;
+
 	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
 
 	if (tcf_exts_dump(skb, &f->exts))
-- 
2.9.0
