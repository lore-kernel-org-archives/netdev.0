From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/13] net/sched: act_tunnel_key: Add UDP dst port option
Date: Mon,  7 Nov 2016 15:14:41 +0200
Message-ID: <1478524488-1377-7-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39579 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753411AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The current tunnel set action supports only IP addresses and key
options. Add UDP dst port option.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/uapi/linux/tc_act/tc_tunnel_key.h |  1 +
 net/sched/act_tunnel_key.c                | 14 +++++++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/tc_act/tc_tunnel_key.h b/include/uapi/linux/tc_act/tc_tunnel_key.h
index 890106f..84ea55e 100644
--- a/include/uapi/linux/tc_act/tc_tunnel_key.h
+++ b/include/uapi/linux/tc_act/tc_tunnel_key.h
@@ -33,6 +33,7 @@ enum {
 	TCA_TUNNEL_KEY_ENC_IPV6_DST,	/* struct in6_addr */
 	TCA_TUNNEL_KEY_ENC_KEY_ID,	/* be64 */
 	TCA_TUNNEL_KEY_PAD,
+	TCA_TUNNEL_KEY_ENC_DST_PORT,	/* be16 */
 	__TCA_TUNNEL_KEY_MAX,
 };
 
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index bd2f63e..edc720f 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -66,6 +66,7 @@ static const struct nla_policy tunnel_key_policy[TCA_TUNNEL_KEY_MAX + 1] = {
 	[TCA_TUNNEL_KEY_ENC_IPV6_SRC] = { .len = sizeof(struct in6_addr) },
 	[TCA_TUNNEL_KEY_ENC_IPV6_DST] = { .len = sizeof(struct in6_addr) },
 	[TCA_TUNNEL_KEY_ENC_KEY_ID]   = { .type = NLA_U32 },
+	[TCA_TUNNEL_KEY_ENC_DST_PORT] = {.type = NLA_U16},
 };
 
 static int tunnel_key_init(struct net *net, struct nlattr *nla,
@@ -80,6 +81,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 	struct tc_tunnel_key *parm;
 	struct tcf_tunnel_key *t;
 	bool exists = false;
+	__be16 dst_port = 0;
 	__be64 key_id;
 	int ret = 0;
 	int err;
@@ -110,6 +112,9 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 
 		key_id = key32_to_tunnel_id(nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_KEY_ID]));
 
+		if (tb[TCA_TUNNEL_KEY_ENC_DST_PORT])
+			dst_port = nla_get_be16(tb[TCA_TUNNEL_KEY_ENC_DST_PORT]);
+
 		if (tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC] &&
 		    tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]) {
 			__be32 saddr;
@@ -119,7 +124,8 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in_addr(tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);
 
 			metadata = __ip_tun_set_dst(saddr, daddr, 0, 0,
-						    0, TUNNEL_KEY, key_id, 0);
+						    dst_port, TUNNEL_KEY,
+						    key_id, 0);
 		} else if (tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC] &&
 			   tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]) {
 			struct in6_addr saddr;
@@ -129,7 +135,8 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
 
 			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, 0,
-						      0, TUNNEL_KEY, key_id, 0);
+						      dst_port, TUNNEL_KEY,
+						      key_id, 0);
 		}
 
 		if (!metadata) {
@@ -257,7 +264,8 @@ static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
 
 		if (nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_KEY_ID, key_id) ||
 		    tunnel_key_dump_addresses(skb,
-					      &params->tcft_enc_metadata->u.tun_info))
+					      &params->tcft_enc_metadata->u.tun_info) ||
+		    nla_put_be16(skb, TCA_TUNNEL_KEY_ENC_DST_PORT, key->tp_dst))
 			goto nla_put_failure;
 	}
 
-- 
2.7.4
