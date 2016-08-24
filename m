From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 3/4] net/sched: cls_flower: Classify packet in ip tunnels
Date: Wed, 24 Aug 2016 15:27:09 +0300
Message-ID: <20160824122710.30356-4-amir@vadai.me>
References: <20160824122710.30356-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34229 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755153AbcHXMnd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 08:43:33 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so2495684wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 05:43:20 -0700 (PDT)
In-Reply-To: <20160824122710.30356-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce classifying by metadata extracted by the tunnel device.
Outer header fields - source/dest ip and tunnel id, are extracted from
the metadata when classifying.

For example, the following will add a filter on the ingress Qdisc of shared
vxlan device named 'vxlan0'. To forward packets with outer src ip
11.11.0.2, dst ip 11.11.0.1 and tunnel id 11. The packets will be
forwarded to tap device 'vnet0' (after metadata is released):

$ filter add dev vxlan0 protocol ip parent ffff: \
    flower \
      enc_src_ip 11.11.0.2 \
      enc_dst_ip 11.11.0.1 \
      enc_key_id 11 \
      dst_ip 11.11.11.1 \
    action tunnel_key release \
    action mirred egress redirect dev vnet0

The action tunnel_key, will be introduced in the next patch in this series.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/uapi/linux/pkt_cls.h | 11 ++++++
 net/sched/cls_flower.c       | 89 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 51b5b247fb5a..f9c287c67eae 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -431,6 +431,17 @@ enum {
 	TCA_FLOWER_KEY_VLAN_ID,
 	TCA_FLOWER_KEY_VLAN_PRIO,
 	TCA_FLOWER_KEY_VLAN_ETH_TYPE,
+
+	TCA_FLOWER_KEY_ENC_KEY_ID,	/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV4_SRC,	/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV4_DST,	/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,/* be32 */
+	TCA_FLOWER_KEY_ENC_IPV6_SRC,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK,/* struct in6_addr */
+	TCA_FLOWER_KEY_ENC_IPV6_DST,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ENC_IPV6_DST_MASK,/* struct in6_addr */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 1e11e57e6947..90dd776ae6aa 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -23,6 +23,9 @@
 #include <net/ip.h>
 #include <net/flow_dissector.h>
 
+#include <net/dst.h>
+#include <net/dst_metadata.h>
+
 struct fl_flow_key {
 	int	indev_ifindex;
 	struct flow_dissector_key_control control;
@@ -35,6 +38,9 @@ struct fl_flow_key {
 		struct flow_dissector_key_ipv6_addrs ipv6;
 	};
 	struct flow_dissector_key_ports tp;
+	struct flow_dissector_key_keyid enc_key_id;
+	struct flow_dissector_key_ipv4_addrs enc_ipv4;
+	struct flow_dissector_key_ipv6_addrs enc_ipv6;
 } __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
 
 struct fl_flow_mask_range {
@@ -124,11 +130,31 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
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
+
+		switch (ip_tunnel_info_af(info)) {
+		case AF_INET:
+			skb_key.enc_ipv4.src = key->u.ipv4.src;
+			skb_key.enc_ipv4.dst = key->u.ipv4.dst;
+			break;
+		case AF_INET6:
+			skb_key.enc_ipv6.src = key->u.ipv6.src;
+			skb_key.enc_ipv6.dst = key->u.ipv6.dst;
+			break;
+		}
+
+		skb_key.enc_key_id.keyid = tunnel_id_to_key32(key->tun_id);
+	}
+
 	skb_key.indev_ifindex = skb->skb_iif;
 	/* skb_flow_dissect() does not set n_proto in case an unknown protocol,
 	 * so do it rather here.
@@ -297,7 +323,15 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_VLAN_ID]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_VLAN_PRIO]	= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_VLAN_ETH_TYPE]	= { .type = NLA_U16 },
-
+	[TCA_FLOWER_KEY_ENC_KEY_ID]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV4_SRC]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK] = { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV4_DST]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV4_DST_MASK] = { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ENC_IPV6_SRC]	= { .len = sizeof(struct in6_addr) },
+	[TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK] = { .len = sizeof(struct in6_addr) },
+	[TCA_FLOWER_KEY_ENC_IPV6_DST]	= { .len = sizeof(struct in6_addr) },
+	[TCA_FLOWER_KEY_ENC_IPV6_DST_MASK] = { .len = sizeof(struct in6_addr) },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -345,7 +379,6 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		mask->indev_ifindex = 0xffffffff;
 	}
 #endif
-
 	fl_set_key_val(tb, key->eth.dst, TCA_FLOWER_KEY_ETH_DST,
 		       mask->eth.dst, TCA_FLOWER_KEY_ETH_DST_MASK,
 		       sizeof(key->eth.dst));
@@ -408,6 +441,37 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       sizeof(key->tp.dst));
 	}
 
+	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
+	    tb[TCA_FLOWER_KEY_ENC_IPV4_DST] ||
+	    tb[TCA_FLOWER_KEY_ENC_IPV6_SRC] ||
+	    tb[TCA_FLOWER_KEY_ENC_IPV6_DST] ||
+	    tb[TCA_FLOWER_KEY_ENC_KEY_ID]) {
+		fl_set_key_val(tb, &key->enc_ipv4.src,
+			       TCA_FLOWER_KEY_ENC_IPV4_SRC,
+			       &mask->enc_ipv4.src,
+			       TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,
+			       sizeof(key->enc_ipv4.src));
+		fl_set_key_val(tb, &key->enc_ipv4.dst,
+			       TCA_FLOWER_KEY_ENC_IPV4_DST,
+			       &mask->enc_ipv4.dst,
+			       TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,
+			       sizeof(key->enc_ipv4.dst));
+		fl_set_key_val(tb, &key->enc_ipv6.src,
+			       TCA_FLOWER_KEY_ENC_IPV6_SRC,
+			       &mask->enc_ipv6.src,
+			       TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK,
+			       sizeof(key->enc_ipv6.src));
+		fl_set_key_val(tb, &key->enc_ipv6.dst,
+			       TCA_FLOWER_KEY_ENC_IPV6_DST,
+			       &mask->enc_ipv6.dst,
+			       TCA_FLOWER_KEY_ENC_IPV6_DST_MASK,
+			       sizeof(key->enc_ipv6.dst));
+		fl_set_key_val(tb,
+			       &key->enc_key_id.keyid, TCA_FLOWER_KEY_ENC_KEY_ID,
+			       &mask->enc_key_id.keyid, TCA_FLOWER_KEY_ENC_KEY_ID,
+			       sizeof(key->enc_key_id.keyid));
+	}
+
 	return 0;
 }
 
@@ -815,6 +879,27 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
 
+	if (fl_dump_key_val(skb, &key->enc_ipv4.src,
+			    TCA_FLOWER_KEY_ENC_IPV4_SRC, &mask->enc_ipv4.src,
+			    TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,
+			    sizeof(key->enc_ipv4.src)) ||
+	    fl_dump_key_val(skb, &key->enc_ipv4.dst,
+			    TCA_FLOWER_KEY_ENC_IPV4_DST, &mask->enc_ipv4.dst,
+			    TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,
+			    sizeof(key->enc_ipv4.dst)) ||
+	    fl_dump_key_val(skb, &key->enc_ipv6.src,
+			    TCA_FLOWER_KEY_ENC_IPV6_SRC, &mask->enc_ipv6.src,
+			    TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK,
+			    sizeof(key->enc_ipv6.src)) ||
+	    fl_dump_key_val(skb, &key->enc_ipv6.dst,
+			    TCA_FLOWER_KEY_ENC_IPV6_DST, &mask->enc_ipv6.dst,
+			    TCA_FLOWER_KEY_ENC_IPV6_DST_MASK,
+			    sizeof(key->enc_ipv6.dst)) ||
+	    fl_dump_key_val(skb, &key->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
+			    &mask->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
+			    sizeof(key->enc_key_id)))
+		goto nla_put_failure;
+
 	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
 
 	if (tcf_exts_dump(skb, &f->exts))
-- 
2.9.0
