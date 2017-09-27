From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 net-next 1/2] net/sched: add tunnel option support to act_tunnel_key
Date: Wed, 27 Sep 2017 10:16:33 +0200
Message-ID: <1506500194-17637-2-git-send-email-simon.horman@netronome.com>
References: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:50947 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752028AbdI0IQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 04:16:51 -0400
Received: by mail-qt0-f170.google.com with SMTP id f15so12851656qtf.7
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 01:16:51 -0700 (PDT)
In-Reply-To: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow setting tunnel options using the act_tunnel_key action.

Options are a bitwise maskable bytestring of up to 256 bytes.
Tunnel implementations may support less or more options,
or no options at all.

 # ip link add name geneve0 type geneve dstport 0 external
 # tc qdisc add dev eth0 ingress
 # tc filter add dev eth0 protocol ip parent ffff: \
     flower indev eth0 \
        ip_proto udp \
        action tunnel_key \
            set src_ip 10.0.99.192 \
            dst_ip 10.0.99.193 \
            dst_port 6081 \
            id 11 \
            opts 0102800100800022 \
    action mirred egress redirect dev geneve0

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
v2
* Correct example which was incorrectly described matching rather
  than setting tunnel options
---
 include/uapi/linux/tc_act/tc_tunnel_key.h |  1 +
 net/sched/act_tunnel_key.c                | 26 +++++++++++++++++++++-----
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/tc_act/tc_tunnel_key.h b/include/uapi/linux/tc_act/tc_tunnel_key.h
index afcd4be953e2..e0cb1121d132 100644
--- a/include/uapi/linux/tc_act/tc_tunnel_key.h
+++ b/include/uapi/linux/tc_act/tc_tunnel_key.h
@@ -35,6 +35,7 @@ enum {
 	TCA_TUNNEL_KEY_PAD,
 	TCA_TUNNEL_KEY_ENC_DST_PORT,	/* be16 */
 	TCA_TUNNEL_KEY_NO_CSUM,		/* u8 */
+	TCA_TUNNEL_KEY_ENC_OPTS,
 	__TCA_TUNNEL_KEY_MAX,
 };
 
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index 30c96274c638..77b5890a48b9 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -66,6 +66,7 @@ static const struct nla_policy tunnel_key_policy[TCA_TUNNEL_KEY_MAX + 1] = {
 	[TCA_TUNNEL_KEY_ENC_KEY_ID]   = { .type = NLA_U32 },
 	[TCA_TUNNEL_KEY_ENC_DST_PORT] = {.type = NLA_U16},
 	[TCA_TUNNEL_KEY_NO_CSUM]      = { .type = NLA_U8 },
+	[TCA_TUNNEL_KEY_ENC_OPTS]     = { .type = NLA_BINARY },
 };
 
 static int tunnel_key_init(struct net *net, struct nlattr *nla,
@@ -81,9 +82,11 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 	struct tcf_tunnel_key *t;
 	bool exists = false;
 	__be16 dst_port = 0;
+	int opts_len = 0;
 	__be64 key_id;
 	__be16 flags;
 	int ret = 0;
+	u8 *opts;
 	int err;
 
 	if (!nla)
@@ -121,6 +124,11 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 		if (tb[TCA_TUNNEL_KEY_ENC_DST_PORT])
 			dst_port = nla_get_be16(tb[TCA_TUNNEL_KEY_ENC_DST_PORT]);
 
+		if (tb[TCA_TUNNEL_KEY_ENC_OPTS]) {
+			opts = nla_data(tb[TCA_TUNNEL_KEY_ENC_OPTS]);
+			opts_len = nla_len(tb[TCA_TUNNEL_KEY_ENC_OPTS]);
+		}
+
 		if (tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC] &&
 		    tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]) {
 			__be32 saddr;
@@ -131,7 +139,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 
 			metadata = __ip_tun_set_dst(saddr, daddr, 0, 0,
 						    dst_port, flags,
-						    key_id, 0);
+						    key_id, opts_len);
 		} else if (tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC] &&
 			   tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]) {
 			struct in6_addr saddr;
@@ -142,9 +150,13 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 
 			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, dst_port,
 						      0, flags,
-						      key_id, 0);
+						      key_id, opts_len);
 		}
 
+		if (opts_len)
+			ip_tunnel_info_opts_set(&metadata->u.tun_info,
+						opts, opts_len);
+
 		if (!metadata) {
 			ret = -EINVAL;
 			goto err_out;
@@ -264,8 +276,9 @@ static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
 		goto nla_put_failure;
 
 	if (params->tcft_action == TCA_TUNNEL_KEY_ACT_SET) {
-		struct ip_tunnel_key *key =
-			&params->tcft_enc_metadata->u.tun_info.key;
+		struct ip_tunnel_info *info =
+			&params->tcft_enc_metadata->u.tun_info;
+		struct ip_tunnel_key *key = &info->key;
 		__be32 key_id = tunnel_id_to_key32(key->tun_id);
 
 		if (nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_KEY_ID, key_id) ||
@@ -273,7 +286,10 @@ static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
 					      &params->tcft_enc_metadata->u.tun_info) ||
 		    nla_put_be16(skb, TCA_TUNNEL_KEY_ENC_DST_PORT, key->tp_dst) ||
 		    nla_put_u8(skb, TCA_TUNNEL_KEY_NO_CSUM,
-			       !(key->tun_flags & TUNNEL_CSUM)))
+			       !(key->tun_flags & TUNNEL_CSUM)) ||
+		    (info->options_len &&
+		     nla_put(skb, TCA_TUNNEL_KEY_ENC_OPTS, info->options_len,
+			     info + 1)))
 			goto nla_put_failure;
 	}
 
-- 
2.1.4
