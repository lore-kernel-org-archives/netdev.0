From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] flow_dissector: Move MPLS dissection into a separate function
Date: Mon,  6 Mar 2017 16:39:52 +0100
Message-ID: <1488814795-5152-3-git-send-email-jiri@resnulli.us>
References: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, hadarh@mellanox.com, e@erig.me,
        fgao@ikuai8.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34922 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754685AbdCFPkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 10:40:02 -0500
Received: by mail-wm0-f66.google.com with SMTP id z63so12192892wmg.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 07:40:01 -0800 (PST)
In-Reply-To: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Make the main flow_dissect function a bit smaller and move the MPLS
dissection into a separate function. Along with that, do the MPLS header
processing only in case the flow dissection user requires it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/flow_dissector.c | 56 ++++++++++++++++++++++++++++-------------------
 1 file changed, 34 insertions(+), 22 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d79fb8f..8d01298 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -119,6 +119,33 @@ enum flow_dissect_ret {
 };
 
 static enum flow_dissect_ret
+__skb_flow_dissect_mpls(const struct sk_buff *skb,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data, int nhoff, int hlen)
+{
+	struct flow_dissector_key_keyid *key_keyid;
+	struct mpls_label *hdr, _hdr[2];
+
+	if (!dissector_uses_key(flow_dissector,
+				FLOW_DISSECTOR_KEY_MPLS_ENTROPY))
+		return FLOW_DISSECT_RET_OUT_GOOD;
+
+	hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
+				   hlen, &_hdr);
+	if (!hdr)
+		return FLOW_DISSECT_RET_OUT_BAD;
+
+	if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
+	    MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
+		key_keyid = skb_flow_dissector_target(flow_dissector,
+						      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
+						      target_container);
+		key_keyid->keyid = hdr[1].entry & htonl(MPLS_LS_LABEL_MASK);
+	}
+	return FLOW_DISSECT_RET_OUT_GOOD;
+}
+
+static enum flow_dissect_ret
 __skb_flow_dissect_arp(const struct sk_buff *skb,
 		       struct flow_dissector *flow_dissector,
 		       void *target_container, void *data, int nhoff, int hlen)
@@ -408,31 +435,16 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	}
 
 	case htons(ETH_P_MPLS_UC):
-	case htons(ETH_P_MPLS_MC): {
-		struct mpls_label *hdr, _hdr[2];
+	case htons(ETH_P_MPLS_MC):
 mpls:
-		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
-					   hlen, &_hdr);
-		if (!hdr)
-			goto out_bad;
-
-		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
-		     MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
-			if (dissector_uses_key(flow_dissector,
-					       FLOW_DISSECTOR_KEY_MPLS_ENTROPY)) {
-				key_keyid = skb_flow_dissector_target(flow_dissector,
-								      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
-								      target_container);
-				key_keyid->keyid = hdr[1].entry &
-					htonl(MPLS_LS_LABEL_MASK);
-			}
-
+		switch (__skb_flow_dissect_mpls(skb, flow_dissector,
+						target_container, data,
+						nhoff, hlen)) {
+		case FLOW_DISSECT_RET_OUT_GOOD:
 			goto out_good;
+		case FLOW_DISSECT_RET_OUT_BAD:
+			goto out_bad;
 		}
-
-		goto out_good;
-	}
-
 	case htons(ETH_P_FCOE):
 		if ((hlen - nhoff) < FCOE_HEADER_LEN)
 			goto out_bad;
-- 
2.7.4
