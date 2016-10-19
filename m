From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 2/7] flow_dissector: Limit processing of next encaps and extensions
Date: Wed, 19 Oct 2016 16:03:04 -0700
Message-ID: <20161019230309.3746853-3-tom@herbertland.com>
References: <20161019230309.3746853-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45260 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754608AbcJSXD5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 19:03:57 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u9JN3PVE012840
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:03:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2668cg3g1g-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:03:56 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 3a77df18965011e68e6b0002c9521c9e-f4df9a50 for <netdev@vger.kernel.org>;        Wed,
 19 Oct 2016 16:03:20 -0700
In-Reply-To: <20161019230309.3746853-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flow dissector does not limit the number of encapsulated packets or IPv6
header extensions that will be processed. This could easily be
suceptible to DOS attack-- for instance a 1500 byte packet could contain
75 IPIP headers.

This patch places limits on the number of encapsulations and IPv6 extension
headers that are processed in flow dissector

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 37 +++++++++++++++++++++++++++----------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1a7b80f..919bd02 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -91,6 +91,22 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
+#define MAX_DISSECT_DEPTH	10
+#define MAX_DISSECT_EXT		10
+
+#define __DISSECT_AGAIN(_target, _depth, _limit) do {	\
+	(_depth)++;					\
+	if ((_depth) > (_limit))				\
+		goto out_good;				\
+	else						\
+		goto _target;				\
+} while (0)
+
+#define DISSECT_AGAIN(target) \
+	__DISSECT_AGAIN(target, depth, MAX_DISSECT_DEPTH)
+#define DISSECT_AGAIN_EXT(target) \
+	__DISSECT_AGAIN(target, ext_cnt, MAX_DISSECT_EXT)
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -123,6 +139,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	bool skip_vlan = false;
 	u8 ip_proto = 0;
 	bool ret = false;
+	int depth = 0, ext_cnt = 0;
 
 	if (!data) {
 		data = skb->data;
@@ -262,7 +279,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			proto = vlan->h_vlan_encapsulated_proto;
 			nhoff += sizeof(*vlan);
 			if (skip_vlan)
-				goto again;
+				DISSECT_AGAIN(again);
 		}
 
 		skip_vlan = true;
@@ -285,7 +302,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			}
 		}
 
-		goto again;
+		DISSECT_AGAIN(again);
 	}
 	case htons(ETH_P_PPP_SES): {
 		struct {
@@ -299,9 +316,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		nhoff += PPPOE_SES_HLEN;
 		switch (proto) {
 		case htons(PPP_IP):
-			goto ip;
+			DISSECT_AGAIN(ip);
 		case htons(PPP_IPV6):
-			goto ipv6;
+			DISSECT_AGAIN(ipv6);
 		default:
 			goto out_bad;
 		}
@@ -472,7 +489,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 			goto out_good;
 
-		goto again;
+		DISSECT_AGAIN(again);
 	}
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
@@ -490,7 +507,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		ip_proto = opthdr[0];
 		nhoff += (opthdr[1] + 1) << 3;
 
-		goto ip_proto_again;
+		DISSECT_AGAIN_EXT(ip_proto_again);
 	}
 	case NEXTHDR_FRAGMENT: {
 		struct frag_hdr _fh, *fh;
@@ -512,7 +529,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		if (!(fh->frag_off & htons(IP6_OFFSET))) {
 			key_control->flags |= FLOW_DIS_FIRST_FRAG;
 			if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG)
-				goto ip_proto_again;
+				DISSECT_AGAIN_EXT(ip_proto_again);
 		}
 		goto out_good;
 	}
@@ -523,7 +540,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 			goto out_good;
 
-		goto ip;
+		DISSECT_AGAIN(ip);
 	case IPPROTO_IPV6:
 		proto = htons(ETH_P_IPV6);
 
@@ -531,10 +548,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 			goto out_good;
 
-		goto ipv6;
+		DISSECT_AGAIN(ipv6);
 	case IPPROTO_MPLS:
 		proto = htons(ETH_P_MPLS_UC);
-		goto mpls;
+		DISSECT_AGAIN(mpls);
 	default:
 		break;
 	}
-- 
2.9.3
