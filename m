From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/8] tc: sample: Add sequence number and sampler_id fields
Date: Mon, 14 Nov 2016 16:00:36 +0100
Message-ID: <1479135638-3580-7-git-send-email-jiri@resnulli.us>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36084 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932892AbcKNPAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:00:48 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so16035481wma.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 07:00:48 -0800 (PST)
In-Reply-To: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add support for sequence numbering to the sampled packets. The sequence
number counts the sampled packets and enables to check whether sampled
packets have been dropped. The sequence state is kept per sample action
instance.

Add unique id (sampler_id) for each sample action instance, and add that
sampler_id to the packet. This way, a user application can verify sample
drops, by tracking the sequence numbers from each sampler id.

Because of the fact that hw and sw can be triggered by the same tc action
(if the user does not specify both skip_sw and skip_hw), each should
have a different sampler_id, as each generates a different sequence
numbering. To allow that, the macros TC_SAMPLE_HW_ID and TC_SAMPLE_SW_ID,
which, given a sampler_id, calculates the hw sample_id and sw sample_id.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ife.h              |  5 +++--
 include/net/tc_act/tc_sample.h |  9 +++++++++
 include/uapi/linux/ife.h       |  2 ++
 net/ife/ife.c                  | 14 ++++++++++++--
 net/sched/act_sample.c         | 10 +++++++++-
 5 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/include/net/ife.h b/include/net/ife.h
index 5fbcfb3..3ae4f0d 100644
--- a/include/net/ife.h
+++ b/include/net/ife.h
@@ -19,7 +19,8 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
 void *ife_tlv_meta_next(void *skbdata);
 
 struct ethhdr *ife_packet_info_pack(struct sk_buff *skb, int orig_size,
-				    int in_ifindex, int out_ifindex);
+				    int in_ifindex, int out_ifindex,
+				    u32 sampler_id, u32 seq);
 
 #else
 
@@ -52,7 +53,7 @@ static inline void *ife_tlv_meta_next(void *skbdata)
 
 static inline struct ethhdr *
 ife_packet_info_pack(struct sk_buff *skb, int orig_size, int in_ifindex,
-		     int out_ifindex)
+		     int out_ifindex, u32 sampler_id, u32 seq)
 {
 	return NULL;
 }
diff --git a/include/net/tc_act/tc_sample.h b/include/net/tc_act/tc_sample.h
index af99eb8..07638b7 100644
--- a/include/net/tc_act/tc_sample.h
+++ b/include/net/tc_act/tc_sample.h
@@ -13,9 +13,13 @@ struct tcf_sample {
 	u8			eth_dst[ETH_ALEN];
 	u8			eth_src[ETH_ALEN];
 	u16			eth_type;
+	u32			sampler_id;
+	u32			seq;
 	struct list_head	tcfm_list;
 };
 #define to_sample(a) ((struct tcf_sample *)a)
+#define TC_SAMPLE_SW_ID(id) ((id << 1) + 0)
+#define TC_SAMPLE_HW_ID(id) ((id << 1) + 1)
 
 static inline bool is_tcf_sample(const struct tc_action *a)
 {
@@ -61,4 +65,9 @@ static inline void tcf_sample_eth_src_addr(const struct tc_action *a, u8 *src)
 	ether_addr_copy(src, to_sample(a)->eth_src);
 }
 
+static inline u32 tcf_sample_sampler_id(const struct tc_action *a)
+{
+	return to_sample(a)->sampler_id;
+}
+
 #endif /* __NET_TC_SAMPLE_H */
diff --git a/include/uapi/linux/ife.h b/include/uapi/linux/ife.h
index ebdd785..2007818 100644
--- a/include/uapi/linux/ife.h
+++ b/include/uapi/linux/ife.h
@@ -13,6 +13,8 @@ enum {
 	IFE_META_OUT_IFINDEX,
 	IFE_META_ORIGSIZE,
 	IFE_META_SIZE,
+	IFE_META_SAMPLER_ID,
+	IFE_META_SEQ,
 	__IFE_META_MAX
 };
 
diff --git a/net/ife/ife.c b/net/ife/ife.c
index f0b683e..e1b7452d 100644
--- a/net/ife/ife.c
+++ b/net/ife/ife.c
@@ -139,7 +139,8 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
 EXPORT_SYMBOL_GPL(ife_tlv_meta_encode);
 
 struct ethhdr *ife_packet_info_pack(struct sk_buff *skb, int orig_size,
-				    int in_ifindex, int out_ifindex)
+				    int in_ifindex, int out_ifindex,
+				    u32 sampler_id, u32 seq)
 {
 	int curr_size;
 	void *ifetlv;
@@ -148,7 +149,9 @@ struct ethhdr *ife_packet_info_pack(struct sk_buff *skb, int orig_size,
 	curr_size = skb->len;
 
 	metalen = nla_total_size(sizeof(orig_size)) +
-		  nla_total_size(sizeof(curr_size));
+		  nla_total_size(sizeof(curr_size)) +
+		  nla_total_size(sizeof(sampler_id)) +
+		  nla_total_size(sizeof(seq));
 
 	if (in_ifindex)
 		metalen += nla_total_size(sizeof(in_ifindex));
@@ -159,6 +162,8 @@ struct ethhdr *ife_packet_info_pack(struct sk_buff *skb, int orig_size,
 	out_ifindex = htonl(out_ifindex);
 	orig_size = htonl(orig_size);
 	curr_size = htonl(curr_size);
+	sampler_id = htonl(sampler_id);
+	seq = htonl(seq);
 
 	ifetlv = ife_encode(skb, metalen);
 	if (!ifetlv)
@@ -179,6 +184,11 @@ struct ethhdr *ife_packet_info_pack(struct sk_buff *skb, int orig_size,
 	ifetlv += ife_tlv_meta_encode(ifetlv, IFE_META_SIZE,
 				      sizeof(curr_size), &curr_size);
 
+	ifetlv += ife_tlv_meta_encode(ifetlv, IFE_META_SAMPLER_ID,
+				      sizeof(sampler_id), &sampler_id);
+
+	ifetlv += ife_tlv_meta_encode(ifetlv, IFE_META_SEQ, sizeof(seq), &seq);
+
 	return (struct ethhdr *) skb->data;
 }
 EXPORT_SYMBOL(ife_packet_info_pack);
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index 39f1d94c..3fe9489 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -27,6 +27,7 @@
 
 #define SAMPLE_TAB_MASK     7
 static int sample_net_id;
+static u32 samplers;
 static struct tc_action_ops act_sample_ops;
 
 static const struct nla_policy sample_policy[TCA_SAMPLE_MAX + 1] = {
@@ -77,6 +78,7 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 	s->rate = nla_get_u32(tb[TCA_SAMPLE_RATE]);
 	s->mark = nla_get_u32(tb[TCA_SAMPLE_MARK]);
 	s->eth_type = nla_get_u16(tb[TCA_SAMPLE_ETH_TYPE]);
+	s->sampler_id = samplers++;
 
 	s->truncate = tb[TCA_SAMPLE_TRUNC_SIZE];
 	if (tb[TCA_SAMPLE_TRUNC_SIZE])
@@ -117,6 +119,7 @@ static int tcf_sample(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_sample *s = to_sample(a);
 	static struct ethhdr *ethhdr;
 	struct sk_buff *skb2;
+	u32 sampler_id;
 	int orig_size;
 	int retval;
 	u32 at;
@@ -144,8 +147,12 @@ static int tcf_sample(struct sk_buff *skb, const struct tc_action *a,
 			skb_push(skb2, skb2->mac_len);
 
 		orig_size = skb->len + skb->dev->hard_header_len;
+		sampler_id = TC_SAMPLE_SW_ID(s->sampler_id);
+
 		ethhdr = ife_packet_info_pack(skb2, orig_size,
-					      skb->dev->ifindex, 0);
+					      skb->dev->ifindex, 0,
+					      sampler_id, s->seq++);
+
 		if (!ethhdr)
 			goto out;
 
@@ -266,6 +273,7 @@ static struct pernet_operations sample_net_ops = {
 
 static int __init sample_init_module(void)
 {
+	samplers = 0;
 	return tcf_register_action(&act_sample_ops, &sample_net_ops);
 }
 
-- 
2.7.4
