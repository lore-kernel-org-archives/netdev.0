From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 2/2] net/sched: act_mirred: Introduce vxlan support
Date: Sun, 14 Aug 2016 17:06:52 +0300
Message-ID: <20160814140652.15985-3-amir@vadai.me>
References: <20160814140652.15985-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33185 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbcHNOHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 10:07:13 -0400
Received: by mail-wm0-f65.google.com with SMTP id o80so6565966wme.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 07:07:12 -0700 (PDT)
In-Reply-To: <20160814140652.15985-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>>

Signed-off-by: Amir Vadai <amirva@mellanox.com>>
---
 include/net/tc_act/tc_mirred.h        |  5 +++
 include/uapi/linux/tc_act/tc_mirred.h |  7 ++++
 net/sched/act_mirred.c                | 79 +++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 62770add15bd..43704c5550ab 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -11,6 +11,11 @@ struct tcf_mirred {
 	int			tcfm_ok_push;
 	struct net_device __rcu	*tcfm_dev;
 	struct list_head	tcfm_list;
+	struct metadata_dst     *tun_dst;
+	__be32			tcf_enc_saddr;
+	__be32			tcf_enc_daddr;
+	__be32			tcf_enc_key_id;
+	__be16			tcf_enc_port;
 };
 #define to_mirred(a) ((struct tcf_mirred *)a)
 
diff --git a/include/uapi/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
index 3d7a2b352a62..89ae754d8f5e 100644
--- a/include/uapi/linux/tc_act/tc_mirred.h
+++ b/include/uapi/linux/tc_act/tc_mirred.h
@@ -21,6 +21,13 @@ enum {
 	TCA_MIRRED_TM,
 	TCA_MIRRED_PARMS,
 	TCA_MIRRED_PAD,
+
+	TCA_MIRRED_ENC_IPV4_SRC,	/* be32 */
+	TCA_MIRRED_ENC_IPV4_DST,	/* be32 */
+	TCA_MIRRED_ENC_IPV6_SRC,	/* struct in6_addr */
+	TCA_MIRRED_ENC_IPV6_DST,	/* struct in6_addr */
+	TCA_MIRRED_ENC_KEY_ID,		/* be32 */
+	TCA_MIRRED_ENC_DST_PORT,	/* be16 */
 	__TCA_MIRRED_MAX
 };
 #define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6038c85d92f5..3aff8d8b2744 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -26,6 +26,9 @@
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/dst.h>
+#include <net/dst_metadata.h>
+#include <net/vxlan.h>
 
 #include <linux/if_arp.h>
 
@@ -38,6 +41,11 @@ static void tcf_mirred_release(struct tc_action *a, int bind)
 	struct tcf_mirred *m = to_mirred(a);
 	struct net_device *dev;
 
+        if (m->tun_dst) {
+                printk("%s:%d - releasing dst: %p\n", __func__, __LINE__, m->tun_dst);
+                dst_release((struct dst_entry *)m->tun_dst);
+        }
+
 	/* We could be called either in a RCU callback or with RTNL lock held. */
 	spin_lock_bh(&mirred_list_lock);
 	list_del(&m->tcfm_list);
@@ -49,11 +57,67 @@ static void tcf_mirred_release(struct tc_action *a, int bind)
 
 static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
+	[TCA_MIRRED_ENC_IPV4_SRC]	= { .type = NLA_U32 },
+	[TCA_MIRRED_ENC_IPV4_DST]	= { .type = NLA_U32 },
+	[TCA_MIRRED_ENC_KEY_ID]		= { .type = NLA_U32 },
+	[TCA_MIRRED_ENC_DST_PORT]	= { .type = NLA_U16 },
 };
 
 static int mirred_net_id;
 static struct tc_action_ops act_mirred_ops;
 
+static int tunnel_alloc(struct tcf_mirred *m, struct nlattr **tb)
+{
+	struct ip_tunnel_info *tun_info;
+	struct metadata_dst *tun_dst;
+        struct vxlan_metadata md = { 0 };
+        u8 tos = 0;
+        u8 ttl = 0;
+        __be16 tun_flags = TUNNEL_VXLAN_OPT;
+        int err;
+
+	m->tcf_enc_saddr = nla_get_be32(tb[TCA_MIRRED_ENC_IPV4_SRC]);
+	m->tcf_enc_daddr = nla_get_be32(tb[TCA_MIRRED_ENC_IPV4_DST]);
+	m->tcf_enc_key_id = nla_get_be32(tb[TCA_MIRRED_ENC_KEY_ID]);
+	m->tcf_enc_port = nla_get_be32(tb[TCA_MIRRED_ENC_DST_PORT]);
+
+	if (!m->tcf_enc_saddr || !m->tcf_enc_daddr ||
+	    !m->tcf_enc_key_id || !m->tcf_enc_port)
+		return 0;
+
+	tun_dst = metadata_dst_alloc(sizeof(md), GFP_KERNEL);
+	if (!tun_dst)
+		return -ENOMEM;
+        printk("%s:%d allocated dst: %p\n", __func__, __LINE__, tun_dst);
+
+	printk("%s:%d mirred vxlan saddr: %pI4 daddr: %pI4 key_id: %d port: %d\n",
+	       __func__, __LINE__,
+	       &m->tcf_enc_saddr, &m->tcf_enc_daddr,
+	       be32_to_cpu(m->tcf_enc_key_id), be16_to_cpu(m->tcf_enc_port));
+
+	err = dst_cache_init(&tun_dst->u.tun_info.dst_cache, GFP_KERNEL);
+	if (err) {
+		dst_release((struct dst_entry *)tun_dst);
+		return err;
+	}
+
+	tun_info = &tun_dst->u.tun_info;
+	tun_info->mode = IP_TUNNEL_INFO_TX;
+
+        ip_tunnel_key_init(&tun_info->key,
+                           m->tcf_enc_saddr, m->tcf_enc_daddr,
+			   tos, ttl,
+                           0, 0,
+			   m->tcf_enc_port,
+			   vxlan_vni_to_tun_id(m->tcf_enc_key_id),
+			   tun_flags);
+        ip_tunnel_info_opts_set(tun_info, &md, sizeof(md));
+
+	m->tun_dst = tun_dst;
+
+        return 0;
+}
+
 static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			   struct nlattr *est, struct tc_action **a, int ovr,
 			   int bind)
@@ -139,6 +203,13 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		m->tcfm_ok_push = ok_push;
 	}
 
+	/* Should not use ret here !!! */
+	if (tunnel_alloc(m, tb)) {
+		printk("%s:%d - error allocating tunnel info\n",
+		       __func__, __LINE__);
+	}
+
+
 	if (ret == ACT_P_CREATED) {
 		spin_lock_bh(&mirred_list_lock);
 		list_add(&m->tcfm_list, &mirred_list);
@@ -180,6 +251,9 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	if (!skb2)
 		goto out;
 
+	if (m->tun_dst)
+		skb_dst_set_noref(skb2, &m->tun_dst->dst);
+
 	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
 			skb_push_rcsum(skb2, skb->mac_len);
@@ -221,6 +295,11 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 	if (nla_put(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 
+	nla_put_be32(skb, TCA_MIRRED_ENC_IPV4_SRC, m->tcf_enc_saddr);
+	nla_put_be32(skb, TCA_MIRRED_ENC_IPV4_DST, m->tcf_enc_daddr);
+	nla_put_be32(skb, TCA_MIRRED_ENC_KEY_ID, m->tcf_enc_key_id);
+	nla_put_be32(skb, TCA_MIRRED_ENC_DST_PORT, m->tcf_enc_port);
+
 	tcf_tm_dump(&t, &m->tcf_tm);
 	if (nla_put_64bit(skb, TCA_MIRRED_TM, sizeof(t), &t, TCA_MIRRED_PAD))
 		goto nla_put_failure;
-- 
2.9.0
