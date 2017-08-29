From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next 1/6] flow_dissector: Move ETH_P_TEB processing to main switch
Date: Tue, 29 Aug 2017 16:27:06 -0700
Message-ID: <20170829232711.1465-2-tom@quantonium.net>
References: <20170829232711.1465-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33396 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdH2X1d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:27:33 -0400
Received: by mail-pg0-f42.google.com with SMTP id t3so15023119pgt.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 16:27:33 -0700 (PDT)
In-Reply-To: <20170829232711.1465-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for processing TEB is currently in GRE flow dissection as a
special case. This can be moved to be a case the main proto switch in
__skb_flow_dissect.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 net/core/flow_dissector.c | 44 +++++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 21 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index e2eaa1ff948d..12302acdb073 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -288,27 +288,8 @@ __skb_flow_dissect_gre(const struct sk_buff *skb,
 	if (hdr->flags & GRE_SEQ)
 		offset += sizeof(((struct pptp_gre_header *) 0)->seq);
 
-	if (gre_ver == 0) {
-		if (*p_proto == htons(ETH_P_TEB)) {
-			const struct ethhdr *eth;
-			struct ethhdr _eth;
-
-			eth = __skb_header_pointer(skb, *p_nhoff + offset,
-						   sizeof(_eth),
-						   data, *p_hlen, &_eth);
-			if (!eth)
-				return FLOW_DISSECT_RET_OUT_BAD;
-			*p_proto = eth->h_proto;
-			offset += sizeof(*eth);
-
-			/* Cap headers that we access via pointers at the
-			 * end of the Ethernet header as our maximum alignment
-			 * at that point is only 2 bytes.
-			 */
-			if (NET_IP_ALIGN)
-				*p_hlen = *p_nhoff + offset;
-		}
-	} else { /* version 1, must be PPTP */
+	/* version 1, must be PPTP */
+	if (gre_ver == 1) {
 		u8 _ppp_hdr[PPP_HDRLEN];
 		u8 *ppp_hdr;
 
@@ -573,6 +554,27 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 		break;
 	}
+	case htons(ETH_P_TEB): {
+		const struct ethhdr *eth;
+		struct ethhdr _eth;
+
+		eth = __skb_header_pointer(skb, nhoff, sizeof(_eth),
+					   data, hlen, &_eth);
+		if (!eth)
+			goto out_bad;
+
+		proto = eth->h_proto;
+		nhoff += sizeof(*eth);
+
+		/* Cap headers that we access via pointers at the
+		 * end of the Ethernet header as our maximum alignment
+		 * at that point is only 2 bytes.
+		 */
+		if (NET_IP_ALIGN)
+			hlen = nhoff;
+
+		goto proto_again;
+	}
 	case htons(ETH_P_8021AD):
 	case htons(ETH_P_8021Q): {
 		const struct vlan_hdr *vlan;
-- 
2.11.0
