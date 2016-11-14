From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/8] act_ife: Change to use ife module
Date: Mon, 14 Nov 2016 16:00:32 +0100
Message-ID: <1479135638-3580-3-git-send-email-jiri@resnulli.us>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35415 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932786AbcKNPAo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:00:44 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so16110875wme.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 07:00:43 -0800 (PST)
In-Reply-To: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Use the encode/decode functionality from the ife module instead of using
implementation inside the act_ife.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/tc_act/tc_ife.h        |   3 -
 include/uapi/linux/tc_act/tc_ife.h |  10 +---
 net/sched/Kconfig                  |   1 +
 net/sched/act_ife.c                | 109 +++++++++++--------------------------
 4 files changed, 34 insertions(+), 89 deletions(-)

diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index 9fd2bea0..30ba459 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -6,7 +6,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/module.h>
 
-#define IFE_METAHDRLEN 2
 struct tcf_ife_info {
 	struct tc_action common;
 	u8 eth_dst[ETH_ALEN];
@@ -45,8 +44,6 @@ struct tcf_meta_ops {
 
 int ife_get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi);
 int ife_get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi);
-int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
-			const void *dval);
 int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
 int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
 int ife_check_meta_u32(u32 metaval, struct tcf_meta_info *mi);
diff --git a/include/uapi/linux/tc_act/tc_ife.h b/include/uapi/linux/tc_act/tc_ife.h
index cd18360..7c28178 100644
--- a/include/uapi/linux/tc_act/tc_ife.h
+++ b/include/uapi/linux/tc_act/tc_ife.h
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <linux/pkt_cls.h>
+#include <linux/ife.h>
 
 #define TCA_ACT_IFE 25
 /* Flag bits for now just encoding/decoding; mutually exclusive */
@@ -28,13 +29,4 @@ enum {
 };
 #define TCA_IFE_MAX (__TCA_IFE_MAX - 1)
 
-#define IFE_META_SKBMARK 1
-#define IFE_META_HASHID 2
-#define	IFE_META_PRIO 3
-#define	IFE_META_QMAP 4
-#define	IFE_META_TCINDEX 5
-/*Can be overridden at runtime by module option*/
-#define	__IFE_META_MAX 6
-#define IFE_META_MAX (__IFE_META_MAX - 1)
-
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 87956a7..24f7cac 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -763,6 +763,7 @@ config NET_ACT_SKBMOD
 config NET_ACT_IFE
         tristate "Inter-FE action based on IETF ForCES InterFE LFB"
         depends on NET_CLS_ACT
+        select NET_IFE
         ---help---
 	  Say Y here to allow for sourcing and terminating metadata
 	  For details refer to netdev01 paper:
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 95c463c..5c2478a 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -32,6 +32,7 @@
 #include <uapi/linux/tc_act/tc_ife.h>
 #include <net/tc_act/tc_ife.h>
 #include <linux/etherdevice.h>
+#include <net/ife.h>
 
 #define IFE_TAB_MASK 15
 
@@ -46,23 +47,6 @@ static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
 	[TCA_IFE_TYPE] = { .type = NLA_U16},
 };
 
-/* Caller takes care of presenting data in network order
-*/
-int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
-{
-	u32 *tlv = (u32 *)(skbdata);
-	u16 totlen = nla_total_size(dlen);	/*alignment + hdr */
-	char *dptr = (char *)tlv + NLA_HDRLEN;
-	u32 htlv = attrtype << 16 | (dlen + NLA_HDRLEN);
-
-	*tlv = htonl(htlv);
-	memset(dptr, 0, totlen - NLA_HDRLEN);
-	memcpy(dptr, dval, dlen);
-
-	return totlen;
-}
-EXPORT_SYMBOL_GPL(ife_tlv_meta_encode);
-
 int ife_encode_meta_u16(u16 metaval, void *skbdata, struct tcf_meta_info *mi)
 {
 	u16 edata = 0;
@@ -637,69 +621,60 @@ int find_decode_metaid(struct sk_buff *skb, struct tcf_ife_info *ife,
 	return 0;
 }
 
-struct ifeheadr {
-	__be16 metalen;
-	u8 tlv_data[];
-};
-
-struct meta_tlvhdr {
-	__be16 type;
-	__be16 len;
-};
-
 static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 			  struct tcf_result *res)
 {
 	struct tcf_ife_info *ife = to_ife(a);
+	u32 at = G_TC_AT(skb->tc_verd);
 	int action = ife->tcf_action;
-	struct ifeheadr *ifehdr = (struct ifeheadr *)skb->data;
-	int ifehdrln = (int)ifehdr->metalen;
-	struct meta_tlvhdr *tlv = (struct meta_tlvhdr *)(ifehdr->tlv_data);
+	u8 *ifehdr_end;
+	u8 *tlv_data;
+	u16 metalen;
 
 	spin_lock(&ife->tcf_lock);
 	bstats_update(&ife->tcf_bstats, skb);
 	tcf_lastuse_update(&ife->tcf_tm);
 	spin_unlock(&ife->tcf_lock);
 
-	ifehdrln = ntohs(ifehdrln);
-	if (unlikely(!pskb_may_pull(skb, ifehdrln))) {
+	if (!(at & AT_EGRESS))
+		skb_push(skb, skb->dev->hard_header_len);
+
+	tlv_data = ife_decode(skb, &metalen);
+	if (unlikely(!tlv_data)) {
 		spin_lock(&ife->tcf_lock);
 		ife->tcf_qstats.drops++;
 		spin_unlock(&ife->tcf_lock);
 		return TC_ACT_SHOT;
 	}
 
-	skb_set_mac_header(skb, ifehdrln);
-	__skb_pull(skb, ifehdrln);
-	skb->protocol = eth_type_trans(skb, skb->dev);
-	ifehdrln -= IFE_METAHDRLEN;
-
-	while (ifehdrln > 0) {
-		u8 *tlvdata = (u8 *)tlv;
-		u16 mtype = tlv->type;
-		u16 mlen = tlv->len;
-		u16 alen;
+	ifehdr_end = tlv_data + metalen;
+	for (; tlv_data < ifehdr_end; tlv_data = ife_tlv_meta_next(tlv_data)) {
+		u8 *curr_data;
+		u16 mtype;
+		u16 dlen;
 
-		mtype = ntohs(mtype);
-		mlen = ntohs(mlen);
-		alen = NLA_ALIGN(mlen);
+		curr_data = ife_tlv_meta_decode(tlv_data, &mtype, &dlen, NULL);
 
-		if (find_decode_metaid(skb, ife, mtype, (mlen - NLA_HDRLEN),
-				       (void *)(tlvdata + NLA_HDRLEN))) {
+		if (find_decode_metaid(skb, ife, mtype, dlen, curr_data)) {
 			/* abuse overlimits to count when we receive metadata
 			 * but dont have an ops for it
 			 */
-			pr_info_ratelimited("Unknown metaid %d alnlen %d\n",
-					    mtype, mlen);
+			pr_info_ratelimited("Unknown metaid %d dlen %d\n",
+					    mtype, dlen);
 			ife->tcf_qstats.overlimits++;
 		}
+	}
 
-		tlvdata += alen;
-		ifehdrln -= alen;
-		tlv = (struct meta_tlvhdr *)tlvdata;
+	if (WARN_ON(tlv_data != ifehdr_end)) {
+		spin_lock(&ife->tcf_lock);
+		ife->tcf_qstats.drops++;
+		spin_unlock(&ife->tcf_lock);
+		return TC_ACT_SHOT;
 	}
 
+	skb->protocol = eth_type_trans(skb, skb->dev);
 	skb_reset_network_header(skb);
+
 	return action;
 }
 
@@ -727,7 +702,6 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_ife_info *ife = to_ife(a);
 	int action = ife->tcf_action;
 	struct ethhdr *oethh;	/* outer ether header */
-	struct ethhdr *iethh;	/* inner eth header */
 	struct tcf_meta_info *e;
 	/*
 	   OUTERHDR:TOTMETALEN:{TLVHDR:Metadatum:TLVHDR..}:ORIGDATA
@@ -735,10 +709,11 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	 */
 	u16 metalen = ife_get_sz(skb, ife);
 	int hdrm = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
-	unsigned int skboff = skb->dev->hard_header_len;
+	unsigned int skboff = 0;
 	u32 at = G_TC_AT(skb->tc_verd);
 	int new_len = skb->len + hdrm;
 	bool exceed_mtu = false;
+	void *ife_meta;
 	int err;
 
 	if (at & AT_EGRESS) {
@@ -766,27 +741,10 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		return TC_ACT_SHOT;
 	}
 
-	err = skb_cow_head(skb, hdrm);
-	if (unlikely(err)) {
-		ife->tcf_qstats.drops++;
-		spin_unlock(&ife->tcf_lock);
-		return TC_ACT_SHOT;
-	}
-
 	if (!(at & AT_EGRESS))
 		skb_push(skb, skb->dev->hard_header_len);
 
-	iethh = (struct ethhdr *)skb->data;
-	__skb_push(skb, hdrm);
-	memcpy(skb->data, iethh, skb->mac_len);
-	skb_reset_mac_header(skb);
-	oethh = eth_hdr(skb);
-
-	/*total metadata length */
-	metalen += IFE_METAHDRLEN;
-	metalen = htons(metalen);
-	memcpy((skb->data + skboff), &metalen, IFE_METAHDRLEN);
-	skboff += IFE_METAHDRLEN;
+	ife_meta = ife_encode(skb, metalen);
 
 	/* XXX: we dont have a clever way of telling encode to
 	 * not repeat some of the computations that are done by
@@ -794,7 +752,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	 */
 	list_for_each_entry(e, &ife->metalist, metalist) {
 		if (e->ops->encode) {
-			err = e->ops->encode(skb, (void *)(skb->data + skboff),
+			err = e->ops->encode(skb, (void *)(ife_meta + skboff),
 					     e);
 		}
 		if (err < 0) {
@@ -805,15 +763,12 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		}
 		skboff += err;
 	}
+	oethh = (struct ethhdr *)skb->data;
 
 	if (!is_zero_ether_addr(ife->eth_src))
 		ether_addr_copy(oethh->h_source, ife->eth_src);
-	else
-		ether_addr_copy(oethh->h_source, iethh->h_source);
 	if (!is_zero_ether_addr(ife->eth_dst))
 		ether_addr_copy(oethh->h_dest, ife->eth_dst);
-	else
-		ether_addr_copy(oethh->h_dest, iethh->h_dest);
 	oethh->h_proto = htons(ife->eth_type);
 
 	if (!(at & AT_EGRESS))
-- 
2.7.4
