From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 04/13] net/sched: cls_flower: Add UDP port to tunnel parameters
Date: Mon,  7 Nov 2016 15:14:39 +0200
Message-ID: <1478524488-1377-5-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39582 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753144AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The current IP tunneling classification supports only IP addresses and key.
Enhance UDP based IP tunneling classification parameters by adding UDP
src and dst port.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/flow_dissector.h |  1 +
 include/uapi/linux/pkt_cls.h |  5 +++++
 net/sched/cls_flower.c       | 29 ++++++++++++++++++++++++++++-
 3 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 4e7cf38a..c4f3166 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -132,6 +132,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
 	FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 	FLOW_DISSECTOR_KEY_ENC_CONTROL, /* struct flow_dissector_key_control */
+	FLOW_DISSECTOR_KEY_ENC_PORTS, /* struct flow_dissector_key_ports */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index eb94781..86786d4 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -452,6 +452,11 @@ enum {
 
 	TCA_FLOWER_KEY_SCTP_SRC,	/* be16 */
 	TCA_FLOWER_KEY_SCTP_DST,	/* be16 */
+
+	TCA_FLOWER_KEY_ENC_UDP_SRC_PORT,	/* be16 */
+	TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,	/* be16 */
+	TCA_FLOWER_KEY_ENC_UDP_DST_PORT,	/* be16 */
+	TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,	/* be16 */
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 6369b74..e8dd09a 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -43,6 +43,7 @@ struct fl_flow_key {
 		struct flow_dissector_key_ipv4_addrs enc_ipv4;
 		struct flow_dissector_key_ipv6_addrs enc_ipv6;
 	};
+	struct flow_dissector_key_ports enc_tp;
 } __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
 
 struct fl_flow_mask_range {
@@ -155,6 +156,8 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		}
 
 		skb_key.enc_key_id.keyid = tunnel_id_to_key32(key->tun_id);
+		skb_key.enc_tp.src = key->tp_src;
+		skb_key.enc_tp.dst = key->tp_dst;
 	}
 
 	skb_key.indev_ifindex = skb->skb_iif;
@@ -348,6 +351,10 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_SCTP_DST_MASK]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_SCTP_SRC]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_SCTP_DST]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_ENC_UDP_SRC_PORT]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK]	= { .type = NLA_U16 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -500,6 +507,14 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		       &mask->enc_key_id.keyid, TCA_FLOWER_UNSPEC,
 		       sizeof(key->enc_key_id.keyid));
 
+	fl_set_key_val(tb, &key->enc_tp.src, TCA_FLOWER_KEY_ENC_UDP_SRC_PORT,
+		       &mask->enc_tp.src, TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,
+		       sizeof(key->enc_tp.src));
+
+	fl_set_key_val(tb, &key->enc_tp.dst, TCA_FLOWER_KEY_ENC_UDP_DST_PORT,
+		       &mask->enc_tp.dst, TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,
+		       sizeof(key->enc_tp.dst));
+
 	return 0;
 }
 
@@ -577,6 +592,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	    FL_KEY_IS_MASKED(&mask->key, enc_ipv6))
 		FL_KEY_SET(keys, cnt, FLOW_DISSECTOR_KEY_ENC_CONTROL,
 			   enc_control);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ENC_PORTS, enc_tp);
 
 	skb_flow_dissector_init(&head->dissector, keys, cnt);
 }
@@ -951,7 +968,17 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	if (fl_dump_key_val(skb, &key->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
 			    &mask->enc_key_id, TCA_FLOWER_UNSPEC,
-			    sizeof(key->enc_key_id)))
+			    sizeof(key->enc_key_id)) ||
+	    fl_dump_key_val(skb, &key->enc_tp.src,
+			    TCA_FLOWER_KEY_ENC_UDP_SRC_PORT,
+			    &mask->enc_tp.src,
+			    TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,
+			    sizeof(key->enc_tp.src)) ||
+	    fl_dump_key_val(skb, &key->enc_tp.dst,
+			    TCA_FLOWER_KEY_ENC_UDP_DST_PORT,
+			    &mask->enc_tp.dst,
+			    TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,
+			    sizeof(key->enc_tp.dst)))
 		goto nla_put_failure;
 
 	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
-- 
2.7.4
