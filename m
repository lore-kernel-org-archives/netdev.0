From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v4 5/6] mpls: Differentiate implicit-null and unlabeled neighbours
Date: Tue, 14 Apr 2015 23:45:02 +0100
Message-ID: <1429051503-31287-6-git-send-email-rshearma@brocade.com>
References: <1427739356-28113-1-git-send-email-rshearma@brocade.com>
 <1429051503-31287-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:32554 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932286AbbDNWrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 18:47:14 -0400
In-Reply-To: <1429051503-31287-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The control plane can advertise labels for neighbours that don't have
an outgoing label which means that in terms of RFC3031 the label is
valid, but there won't be an NHFLE. RFC3031 s3.22 states in this
situation that either the remaining labels should be popped (if the
control plane can determine that it's safe to do so, which in light of
MPLS-VPN, RFC4364, is never the case now) or that the packet should
be discarded.

Therefore, introduce a new route attribute, RTA_MPLS_PAYLOAD_TYPE,
that allows the control plane to restrict/specify what traffic is
carried by the LSP (suggested by Eric W. Biederman). Add a flag that
can be used in combination with a type to allow the control plane to
specify that packets arriving on an LSP must be BOS only. Otherwise,
the packets are dropped.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/uapi/linux/mpls.h      | 16 +++++++++++
 include/uapi/linux/rtnetlink.h |  1 +
 net/mpls/af_mpls.c             | 61 +++++++++++++++++++++++++++---------------
 3 files changed, 57 insertions(+), 21 deletions(-)

diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
index bc9abfe88c9a..fb6aa9a054a8 100644
--- a/include/uapi/linux/mpls.h
+++ b/include/uapi/linux/mpls.h
@@ -31,4 +31,20 @@ struct mpls_label {
 #define MPLS_LS_TTL_MASK        0x000000FF
 #define MPLS_LS_TTL_SHIFT       0
 
+/* RTA_MPLS_PAYLOAD_TYPE - u32 specifying type and zero or more flags */
+enum rtmpls_payload_type {
+	RTMPT_IP		= 0x0000, /* IPv4 or IPv6 */
+	RTMPT_IPV4		= 0x0004,
+	RTMPT_IPV6		= 0x0006,
+
+	/* Other types not implemented:
+	 *  - Pseudo-wire with or without control word (RFC4385)
+	 *  - GAL (RFC5586)
+	 */
+};
+#define RTMPT_TYPE_MASK		0x0000ffff
+
+#define RTMPT_FLAG_BOS_ONLY	0x80000000
+#define RTMPT_ALL_FLAGS		(RTMPT_FLAG_BOS_ONLY)
+
 #endif /* _UAPI_MPLS_H */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 974db03f7b1a..aa9b7a775a2e 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -308,6 +308,7 @@ enum rtattr_type_t {
 	RTA_VIA,
 	RTA_NEWDST,
 	RTA_PREF,
+	RTA_MPLS_PAYLOAD_TYPE,
 	__RTA_MAX
 };
 
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index f802578f5172..e99f88556d6b 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -23,23 +23,12 @@
 /* This maximum ha length copied from the definition of struct neighbour */
 #define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
 
-enum mpls_payload_type {
-	MPT_UNSPEC, /* IPv4 or IPv6 */
-	MPT_IPV4 = 4,
-	MPT_IPV6 = 6,
-
-	/* Other types not implemented:
-	 *  - Pseudo-wire with or without control word (RFC4385)
-	 *  - GAL (RFC5586)
-	 */
-};
-
 struct mpls_route { /* next hop label forwarding entry */
 	struct net_device __rcu *rt_dev;
 	struct rcu_head		rt_rcu;
 	u32			rt_label[MAX_NEW_LABELS];
+	u32                     rt_payload_type;
 	u8			rt_protocol; /* routing protocol that set this entry */
-	u8                      rt_payload_type;
 	u8			rt_labels;
 	u8			rt_via_alen;
 	u8			rt_via_table;
@@ -101,7 +90,7 @@ static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 			struct mpls_entry_decoded dec)
 {
-	enum mpls_payload_type payload_type;
+	enum rtmpls_payload_type payload_type;
 	bool success = false;
 
 	/* The IPv4 code below accesses through the IPv4 header
@@ -117,12 +106,12 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 	if (!pskb_may_pull(skb, 12))
 		return false;
 
-	payload_type = rt->rt_payload_type;
-	if (payload_type == MPT_UNSPEC)
+	payload_type = rt->rt_payload_type & RTMPT_TYPE_MASK;
+	if (payload_type == RTMPT_IP)
 		payload_type = ip_hdr(skb)->version;
 
 	switch (payload_type) {
-	case MPT_IPV4: {
+	case RTMPT_IPV4: {
 		struct iphdr *hdr4 = ip_hdr(skb);
 		skb->protocol = htons(ETH_P_IP);
 		csum_replace2(&hdr4->check,
@@ -132,14 +121,15 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 		success = true;
 		break;
 	}
-	case MPT_IPV6: {
+	case RTMPT_IPV6: {
 		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
 		skb->protocol = htons(ETH_P_IPV6);
 		hdr6->hop_limit = dec.ttl;
 		success = true;
 		break;
 	}
-	case MPT_UNSPEC:
+	case RTMPT_IP:
+		/* Should have decided which protocol it is by now */
 		break;
 	}
 
@@ -225,6 +215,11 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		/* Penultimate hop popping */
 		if (!mpls_egress(rt, skb, dec))
 			goto drop;
+	} else if (rt->rt_payload_type & RTMPT_FLAG_BOS_ONLY) {
+		/* Labeled traffic destined to unlabeled peer should
+		 * be discarded
+		 */
+		goto drop;
 	} else {
 		bool bos;
 		int i;
@@ -258,6 +253,7 @@ static struct packet_type mpls_packet_type __read_mostly = {
 static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 	[RTA_DST]		= { .type = NLA_U32 },
 	[RTA_OIF]		= { .type = NLA_U32 },
+	[RTA_MPLS_PAYLOAD_TYPE]	= { .type = NLA_U32 },
 };
 
 struct mpls_route_config {
@@ -270,7 +266,7 @@ struct mpls_route_config {
 	u32			rc_output_labels;
 	u32			rc_output_label[MAX_NEW_LABELS];
 	u32			rc_nlflags;
-	enum mpls_payload_type	rc_payload_type;
+	u32			rc_payload_type;
 	struct nl_info		rc_nlinfo;
 };
 
@@ -781,6 +777,24 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			memcpy(cfg->rc_via, via->rtvia_addr, cfg->rc_via_alen);
 			break;
 		}
+		case RTA_MPLS_PAYLOAD_TYPE:
+			cfg->rc_payload_type = nla_get_u32(nla);
+
+			/* Ensure there are no unsupported flags */
+			if (cfg->rc_payload_type &
+			    ~(RTMPT_TYPE_MASK | RTMPT_ALL_FLAGS))
+				goto errout;
+
+			switch (cfg->rc_payload_type & RTMPT_TYPE_MASK) {
+			case RTMPT_IP:
+			case RTMPT_IPV4:
+			case RTMPT_IPV6:
+				break;
+			default:
+				goto errout;
+			}
+
+			break;
 		default:
 			/* Unsupported attribute */
 			goto errout;
@@ -849,6 +863,9 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		goto nla_put_failure;
 	if (nla_put_labels(skb, RTA_DST, 1, &label))
 		goto nla_put_failure;
+	if (rt->rt_payload_type &&
+	    nla_put_u32(skb, RTA_MPLS_PAYLOAD_TYPE, rt->rt_payload_type))
+		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -899,6 +916,8 @@ static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 		payload += nla_total_size(rt->rt_labels * 4);
 	if (rt->rt_dev)					/* RTA_OIF */
 		payload += nla_total_size(4);
+	if (rt->rt_payload_type)
+		payload += nla_total_size(4); /* RTA_MPLS_PAYLOAD_TYPE */
 	return payload;
 }
 
@@ -955,7 +974,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 			goto nort0;
 		RCU_INIT_POINTER(rt0->rt_dev, lo);
 		rt0->rt_protocol = RTPROT_KERNEL;
-		rt0->rt_payload_type = MPT_IPV4;
+		rt0->rt_payload_type = RTMPT_IPV4;
 		rt0->rt_via_table = NEIGH_LINK_TABLE;
 		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
 	}
@@ -966,7 +985,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 			goto nort2;
 		RCU_INIT_POINTER(rt2->rt_dev, lo);
 		rt2->rt_protocol = RTPROT_KERNEL;
-		rt2->rt_payload_type = MPT_IPV6;
+		rt2->rt_payload_type = RTMPT_IPV6;
 		rt2->rt_via_table = NEIGH_LINK_TABLE;
 		memcpy(rt2->rt_via, lo->dev_addr, lo->addr_len);
 	}
-- 
2.1.4
