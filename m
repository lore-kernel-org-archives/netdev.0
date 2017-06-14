From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/2] net: sched: act_tunnel_key: make UDP checksum configurable
Date: Wed, 14 Jun 2017 21:19:31 +0200
Message-ID: <c76f11daaa0e322c9c2ef7b919c30e7c9ff61f56.1497467840.git.jbenc@redhat.com>
References: <cover.1497467840.git.jbenc@redhat.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51206 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751756AbdFNTYU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:24:20 -0400
In-Reply-To: <cover.1497467840.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow requesting of zero UDP checksum for encapsulated packets. The name and
meaning of the attribute is "NO_CSUM" in order to have the same meaning of
the attribute missing and being 0.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/uapi/linux/tc_act/tc_tunnel_key.h |  1 +
 net/sched/act_tunnel_key.c                | 15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/tc_act/tc_tunnel_key.h b/include/uapi/linux/tc_act/tc_tunnel_key.h
index 84ea55e1076b..afcd4be953e2 100644
--- a/include/uapi/linux/tc_act/tc_tunnel_key.h
+++ b/include/uapi/linux/tc_act/tc_tunnel_key.h
@@ -34,6 +34,7 @@ enum {
 	TCA_TUNNEL_KEY_ENC_KEY_ID,	/* be64 */
 	TCA_TUNNEL_KEY_PAD,
 	TCA_TUNNEL_KEY_ENC_DST_PORT,	/* be16 */
+	TCA_TUNNEL_KEY_NO_CSUM,		/* u8 */
 	__TCA_TUNNEL_KEY_MAX,
 };
 
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index b90effa10eb5..fd7e75679c69 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -67,6 +67,7 @@ static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
 	[TCA_TUNNEL_KEY_ENC_IPV6_DST] = { .len = sizeof(struct in6_addr) },
 	[TCA_TUNNEL_KEY_ENC_KEY_ID]   = { .type = NLA_U32 },
 	[TCA_TUNNEL_KEY_ENC_DST_PORT] = {.type = NLA_U16},
+	[TCA_TUNNEL_KEY_NO_CSUM]      = { .type = NLA_U8 },
 };
 
 static int tunnel_key_init(struct net *net, struct nlattr *nla,
@@ -83,6 +84,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 	bool exists = false;
 	__be16 dst_port = 0;
 	__be64 key_id;
+	__be16 flags;
 	int ret = 0;
 	int err;
 
@@ -113,6 +115,11 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 
 		key_id = key32_to_tunnel_id(nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_KEY_ID]));
 
+		flags = TUNNEL_KEY | TUNNEL_CSUM;
+		if (tb[TCA_TUNNEL_KEY_NO_CSUM] &&
+		    nla_get_u8(tb[TCA_TUNNEL_KEY_NO_CSUM]))
+			flags &= ~TUNNEL_CSUM;
+
 		if (tb[TCA_TUNNEL_KEY_ENC_DST_PORT])
 			dst_port = nla_get_be16(tb[TCA_TUNNEL_KEY_ENC_DST_PORT]);
 
@@ -125,7 +132,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in_addr(tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);
 
 			metadata = __ip_tun_set_dst(saddr, daddr, 0, 0,
-						    dst_port, TUNNEL_KEY | TUNNEL_CSUM,
+						    dst_port, flags,
 						    key_id, 0);
 		} else if (tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC] &&
 			   tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]) {
@@ -136,7 +143,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
 
 			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, dst_port,
-						      0, TUNNEL_KEY | TUNNEL_CSUM,
+						      0, flags,
 						      key_id, 0);
 		}
 
@@ -266,7 +273,9 @@ static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
 		if (nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_KEY_ID, key_id) ||
 		    tunnel_key_dump_addresses(skb,
 					      &params->tcft_enc_metadata->u.tun_info) ||
-		    nla_put_be16(skb, TCA_TUNNEL_KEY_ENC_DST_PORT, key->tp_dst))
+		    nla_put_be16(skb, TCA_TUNNEL_KEY_ENC_DST_PORT, key->tp_dst) ||
+		    nla_put_u8(skb, TCA_TUNNEL_KEY_NO_CSUM,
+			       !(key->tun_flags & TUNNEL_CSUM)))
 			goto nla_put_failure;
 	}
 
-- 
1.8.3.1
