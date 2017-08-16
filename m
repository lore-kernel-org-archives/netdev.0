From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 6/6] mpls: pseudowire control word support
Date: Wed, 16 Aug 2017 19:02:02 +0200
Message-ID: <20170816170202.456851-7-equinox@diac24.net>
References: <20170816170202.456851-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:43724 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752514AbdHPRCb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 13:02:31 -0400
In-Reply-To: <20170816170202.456851-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[TODO: maybe rename this to MPLS_FLAGS and use it for non-pseudowire OAM
bits too (e.g. enabling G-ACh or LSP ping.)]

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/uapi/linux/rtnetlink.h |  4 ++++
 net/mpls/af_mpls.c             | 11 +++++++++++
 net/mpls/internal.h            |  8 ++------
 net/mpls/vpls.c                | 34 +++++++++++++++++++++++++++++++++-
 4 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index b7840ed94526..b5a34e0e4327 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -327,6 +327,7 @@ enum rtattr_type_t {
 	RTA_UID,
 	RTA_TTL_PROPAGATE,
 	RTA_VPLS_IF,
+	RTA_VPLS_FLAGS,
 	__RTA_MAX
 };
 
@@ -335,6 +336,9 @@ enum rtattr_type_t {
 #define RTM_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct rtmsg))))
 #define RTM_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct rtmsg))
 
+#define RTA_VPLS_F_CW_RX	(1 << 0)
+#define RTA_VPLS_F_CW_TX	(1 << 1)
+
 /* RTM_MULTIPATH --- array of struct rtnexthop.
  *
  * "struct rtnexthop" describes all necessary nexthop information,
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 4d3ce007b7db..9036beeca173 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -477,6 +477,7 @@ struct mpls_route_config {
 	u32			rc_protocol;
 	u32			rc_ifindex;
 	u32			rc_vpls_ifindex;
+	u8			rc_vpls_flags;
 	u8			rc_via_table;
 	u8			rc_via_alen;
 	u8			rc_via[MAX_VIA_ALEN];
@@ -1036,6 +1037,7 @@ static int mpls_route_add(struct mpls_route_config *cfg,
 	rt->rt_payload_type = cfg->rc_payload_type;
 	rt->rt_ttl_propagate = cfg->rc_ttl_propagate;
 	rt->rt_vpls_dev = vpls_dev;
+	rt->rt_vpls_flags = cfg->rc_vpls_flags;
 
 	if (cfg->rc_mp)
 		err = mpls_nh_build_multi(cfg, rt, max_labels, extack);
@@ -1819,6 +1821,9 @@ static int rtm_to_route_config(struct sk_buff *skb,
 			cfg->rc_vpls_ifindex = nla_get_u32(nla);
 			cfg->rc_payload_type = MPT_VPLS;
 			break;
+		case RTA_VPLS_FLAGS:
+			cfg->rc_vpls_flags = nla_get_u8(nla);
+			break;
 		case RTA_NEWDST:
 			if (nla_get_labels(nla, MAX_NEW_LABELS,
 					   &cfg->rc_output_labels,
@@ -1957,6 +1962,9 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	if (rt->rt_vpls_dev)
 		if (nla_put_u32(skb, RTA_VPLS_IF, rt->rt_vpls_dev->ifindex))
 			goto nla_put_failure;
+	if (rt->rt_vpls_flags)
+		if (nla_put_u8(skb, RTA_VPLS_FLAGS, rt->rt_vpls_flags))
+			goto nla_put_failure;
 
 	if (rt->rt_nhn == 1) {
 		const struct mpls_nh *nh = rt->rt_nh;
@@ -2270,6 +2278,9 @@ static int mpls_getroute(struct sk_buff *in_skb, struct nlmsghdr *in_nlh,
 	if (rt->rt_vpls_dev)
 		if (nla_put_u32(skb, RTA_VPLS_IF, rt->rt_vpls_dev->ifindex))
 			goto nla_put_failure;
+	if (rt->rt_vpls_flags)
+		if (nla_put_u8(skb, RTA_VPLS_FLAGS, rt->rt_vpls_flags))
+			goto nla_put_failure;
 
 	if (nh->nh_labels &&
 	    nla_put_labels(skb, RTA_NEWDST, nh->nh_labels,
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 876ae9993207..03048e3a5d83 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -79,11 +79,6 @@ enum mpls_payload_type {
 	MPT_VPLS = 2,	/* pseudowire */
 	MPT_IPV4 = 4,
 	MPT_IPV6 = 6,
-
-	/* Other types not implemented:
-	 *  - Pseudo-wire with or without control word (RFC4385)
-	 *  - GAL (RFC5586)
-	 */
 };
 
 struct mpls_nh { /* next hop label forwarding entry */
@@ -153,7 +148,8 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_nhn_alive;
 	u8			rt_nh_size;
 	u8			rt_via_offset;
-	u8			rt_reserved1;
+
+	u8			rt_vpls_flags;
 	struct net_device	*rt_vpls_dev;
 
 	struct mpls_nh		rt_nh[0];
diff --git a/net/mpls/vpls.c b/net/mpls/vpls.c
index 28ac810da6e9..1496683d871c 100644
--- a/net/mpls/vpls.c
+++ b/net/mpls/vpls.c
@@ -27,6 +27,14 @@
 #define MIN_MTU 68		/* Min L3 MTU */
 #define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
 
+struct vpls_cw {
+	u8 type_flags;
+#define VPLS_CWTYPE(cw) ((cw)->type_flags & 0x0f)
+
+	u8 len;
+	u16 seqno;
+};
+
 struct vpls_wirelist {
 	struct rcu_head rcu;
 	size_t count;
@@ -53,6 +61,14 @@ static int vpls_xmit_wire(struct sk_buff *skb, struct net_device *dev,
 	if (rt->rt_vpls_dev != dev)
 		return -EINVAL;
 
+	if (rt->rt_vpls_flags & RTA_VPLS_F_CW_TX) {
+		struct vpls_cw *cw;
+		if (skb_cow(skb, sizeof(*cw)))
+			return -ENOMEM;
+		cw = skb_push(skb, sizeof(*cw));
+		memset(cw, 0, sizeof(*cw));
+	}
+
 	return mpls_rt_xmit(skb, rt, dec);
 }
 
@@ -123,6 +139,7 @@ int vpls_rcv(struct sk_buff *skb, struct net_device *in_dev,
 	struct mpls_entry_decoded dec;
 	struct metadata_dst *md_dst;
 	struct pcpu_sw_netstats *stats;
+	void *next;
 
 	if (!dev)
 		goto drop_nodev;
@@ -133,7 +150,22 @@ int vpls_rcv(struct sk_buff *skb, struct net_device *in_dev,
 		goto drop;
 	}
 
-	skb_pull(skb, sizeof(*hdr));
+	/* bottom label is still in the skb */
+	next = skb_pull(skb, sizeof(*hdr));
+
+	if (rt->rt_vpls_flags & RTA_VPLS_F_CW_RX) {
+		struct vpls_cw *cw = next;
+		if (unlikely(!pskb_may_pull(skb, sizeof(*cw)))) {
+			dev->stats.rx_length_errors++;
+			goto drop;
+		}
+		next = skb_pull(skb, sizeof(*cw));
+
+		if (VPLS_CWTYPE(cw) != 0) {
+			/* insert MPLS OAM implementation here */
+			goto drop_nodev;
+		}
+	}
 
 	if (unlikely(!pskb_may_pull(skb, ETH_HLEN))) {
 		dev->stats.rx_length_errors++;
-- 
2.13.0
