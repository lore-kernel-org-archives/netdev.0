From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH] net/sched: cls_flower: Support matching on SCTP ports
Date: Thu,  3 Nov 2016 13:24:22 +0100
Message-ID: <1478175862-28642-2-git-send-email-simon.horman@netronome.com>
References: <1478175862-28642-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37483 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755648AbcKCMYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:24:34 -0400
Received: by mail-wm0-f41.google.com with SMTP id t79so97330870wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:24:33 -0700 (PDT)
In-Reply-To: <1478175862-28642-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support matching on SCTP ports in the same way that matching
on TCP and UDP ports is already supported.

Example usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ip parent ffff: \
        flower indev eth0 ip_proto sctp dst_port 80 \
        action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/uapi/linux/pkt_cls.h |  5 +++++
 net/sched/cls_flower.c       | 19 +++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 8fd715f806a2..eb94781757ee 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -447,6 +447,11 @@ enum {
 	TCA_FLOWER_KEY_TCP_DST_MASK,	/* be16 */
 	TCA_FLOWER_KEY_UDP_SRC_MASK,	/* be16 */
 	TCA_FLOWER_KEY_UDP_DST_MASK,	/* be16 */
+	TCA_FLOWER_KEY_SCTP_SRC_MASK,	/* be16 */
+	TCA_FLOWER_KEY_SCTP_DST_MASK,	/* be16 */
+
+	TCA_FLOWER_KEY_SCTP_SRC,	/* be16 */
+	TCA_FLOWER_KEY_SCTP_DST,	/* be16 */
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index a8fb1ca03b3e..db4cd882a989 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -344,6 +344,10 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_TCP_DST_MASK]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_UDP_SRC_MASK]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_UDP_DST_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_SCTP_SRC_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_SCTP_DST_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_SCTP_SRC]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_SCTP_DST]	= { .type = NLA_U16 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -453,6 +457,13 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		fl_set_key_val(tb, &key->tp.dst, TCA_FLOWER_KEY_UDP_DST,
 			       &mask->tp.dst, TCA_FLOWER_KEY_UDP_DST_MASK,
 			       sizeof(key->tp.dst));
+	} else if (key->basic.ip_proto == IPPROTO_SCTP) {
+		fl_set_key_val(tb, &key->tp.src, TCA_FLOWER_KEY_SCTP_SRC,
+			       &mask->tp.src, TCA_FLOWER_KEY_SCTP_SRC_MASK,
+			       sizeof(key->tp.src));
+		fl_set_key_val(tb, &key->tp.dst, TCA_FLOWER_KEY_SCTP_DST,
+			       &mask->tp.dst, TCA_FLOWER_KEY_SCTP_DST_MASK,
+			       sizeof(key->tp.dst));
 	}
 
 	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
@@ -897,6 +908,14 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  &mask->tp.dst, TCA_FLOWER_KEY_UDP_DST_MASK,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
+	else if (key->basic.ip_proto == IPPROTO_SCTP &&
+		 (fl_dump_key_val(skb, &key->tp.src, TCA_FLOWER_KEY_SCTP_SRC,
+				  &mask->tp.src, TCA_FLOWER_KEY_SCTP_SRC_MASK,
+				  sizeof(key->tp.src)) ||
+		  fl_dump_key_val(skb, &key->tp.dst, TCA_FLOWER_KEY_SCTP_DST,
+				  &mask->tp.dst, TCA_FLOWER_KEY_SCTP_DST_MASK,
+				  sizeof(key->tp.dst))))
+		goto nla_put_failure;
 
 	if (key->enc_control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS &&
 	    (fl_dump_key_val(skb, &key->enc_ipv4.src,
-- 
2.7.0.rc3.207.g0ac5344
