From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next v2 2/4] flow dissector: return error on icmp dissection under-run
Date: Fri,  5 May 2017 14:47:04 +0200
Message-ID: <1493988426-22854-3-git-send-email-simon.horman@netronome.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33859 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752752AbdEEMrT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 08:47:19 -0400
Received: by mail-wm0-f43.google.com with SMTP id u65so2631287wmu.1
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 05:47:18 -0700 (PDT)
In-Reply-To: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return an error from __skb_flow_dissect() if insufficient packet data is
present when dissecting icmp type and code.

Without this patch the absence of the ICMP type and code in truncated
ICMPv4 or IPVPv6 packets is treated the way same as the presence of a code
and type of value of zero.  And without this patch the flower classifier is
unable to differentiate between these two cases which may lead to
unexpected matching of truncated packets.

With this patch the flow dissector and in turn the flower classifier can
differentiate between packets with zero ICMP type and code, and truncated
packets.

The approach taken here is to return an error if the IP protocol indicates
ICMP but the type and code data is not present in the packet - an error
return value from __skb_header_pointer().

This should only effect the flower classifier as it is the only user of
W_DISSECTOR_KEY_ICMP.  The behavioural update for flower only takes effect
with a separate patch to have it refuse to match if dissection fails.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
---
rfc2
* Update changelog
---
 net/core/flow_dissector.c | 65 +++++++++++++++++++++++++----------------------
 1 file changed, 34 insertions(+), 31 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index b3bf4886f71f..496afd7b3051 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -58,28 +58,6 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 EXPORT_SYMBOL(skb_flow_dissector_init);
 
 /**
- * skb_flow_get_be16 - extract be16 entity
- * @skb: sk_buff to extract from
- * @poff: offset to extract at
- * @data: raw buffer pointer to the packet
- * @hlen: packet header length
- *
- * The function will try to retrieve a be32 entity at
- * offset poff
- */
-static __be16 skb_flow_get_be16(const struct sk_buff *skb, int poff,
-				void *data, int hlen)
-{
-	__be16 *u, _u;
-
-	u = __skb_header_pointer(skb, poff, sizeof(_u), data, hlen, &_u);
-	if (u)
-		return *u;
-
-	return 0;
-}
-
-/**
  * __skb_flow_get_ports - extract the upper layer ports and return them
  * @skb: sk_buff to extract the ports from
  * @thoff: transport header offset
@@ -353,6 +331,29 @@ __skb_flow_dissect_gre(const struct sk_buff *skb,
 	return FLOW_DISSECT_RET_OUT_PROTO_AGAIN;
 }
 
+static enum flow_dissect_ret
+__skb_flow_dissect_icmp(const struct sk_buff *skb,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data, int nhoff, int hlen)
+{
+	struct flow_dissector_key_icmp *key_icmp;
+	__be16 *u, _u;
+
+	if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ICMP))
+		return FLOW_DISSECT_RET_OUT_GOOD;
+
+	u = __skb_header_pointer(skb, nhoff, sizeof(_u), data, hlen, &_u);
+	if (!u)
+		return FLOW_DISSECT_RET_OUT_BAD;
+
+	key_icmp = skb_flow_dissector_target(flow_dissector,
+					     FLOW_DISSECTOR_KEY_ICMP,
+					     target_container);
+	key_icmp->icmp = *u;
+
+	return FLOW_DISSECT_RET_OUT_GOOD;
+}
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -379,7 +380,6 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_basic *key_basic;
 	struct flow_dissector_key_addrs *key_addrs;
 	struct flow_dissector_key_ports *key_ports;
-	struct flow_dissector_key_icmp *key_icmp;
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_vlan *key_vlan;
 	bool skip_vlan = false;
@@ -694,6 +694,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case IPPROTO_MPLS:
 		proto = htons(ETH_P_MPLS_UC);
 		goto mpls;
+	case IPPROTO_ICMP:
+	case NEXTHDR_ICMP:
+		switch (__skb_flow_dissect_icmp(skb, flow_dissector,
+						target_container, data,
+						nhoff, hlen)) {
+		case FLOW_DISSECT_RET_OUT_GOOD:
+			goto out_good;
+		case FLOW_DISSECT_RET_OUT_BAD:
+		default:
+			goto out_bad;
+		}
 	default:
 		break;
 	}
@@ -708,14 +719,6 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			goto out_bad;
 	}
 
-	if (dissector_uses_key(flow_dissector,
-			       FLOW_DISSECTOR_KEY_ICMP)) {
-		key_icmp = skb_flow_dissector_target(flow_dissector,
-						     FLOW_DISSECTOR_KEY_ICMP,
-						     target_container);
-		key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
-	}
-
 out_good:
 	ret = true;
 
-- 
2.1.4
