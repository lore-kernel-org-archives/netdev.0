From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/2] flow_dissecror: Move MPLS dissection into a separate function
Date: Tue, 21 Feb 2017 15:33:19 +0100
Message-ID: <1487687599-5464-2-git-send-email-jiri@resnulli.us>
References: <20170221143141.GD2694@nanopsycho.mtl.com>
 <1487687599-5464-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36317 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753201AbdBUOdZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 09:33:25 -0500
Received: by mail-wm0-f68.google.com with SMTP id r18so20065155wmd.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 06:33:24 -0800 (PST)
In-Reply-To: <1487687599-5464-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Make the main flow_dissect function a bit smaller and move the MPLS
dissection into a separate function. Along with that, do the MPLS header
processing only in case the flow dissection user requires it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/flow_dissector.c | 52 ++++++++++++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 21 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 10dc5bb..3ab935e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -113,6 +113,33 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
+static bool __skb_flow_dissect_mpls(const struct sk_buff *skb,
+				    struct flow_dissector *flow_dissector,
+				    void *target_container, void *data,
+				    int nhoff, int hlen)
+{
+	struct flow_dissector_key_keyid *key_keyid;
+	struct mpls_label *hdr, _hdr[2];
+
+	if (!dissector_uses_key(flow_dissector,
+				FLOW_DISSECTOR_KEY_MPLS_ENTROPY))
+		return true;
+
+	hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
+				   hlen, &_hdr);
+	if (!hdr)
+		return false;
+
+	if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
+	    MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
+		key_keyid = skb_flow_dissector_target(flow_dissector,
+						      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
+						      target_container);
+		key_keyid->keyid = hdr[1].entry & htonl(MPLS_LS_LABEL_MASK);
+	}
+	return true;
+}
+
 static bool __skb_flow_dissect_arp(const struct sk_buff *skb,
 				   struct flow_dissector *flow_dissector,
 				   void *target_container, void *data,
@@ -403,30 +430,13 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	}
 
 	case htons(ETH_P_MPLS_UC):
-	case htons(ETH_P_MPLS_MC): {
-		struct mpls_label *hdr, _hdr[2];
+	case htons(ETH_P_MPLS_MC):
 mpls:
-		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
-					   hlen, &_hdr);
-		if (!hdr)
+		if (!__skb_flow_dissect_mpls(skb, flow_dissector,
+					     target_container, data,
+					     nhoff, hlen))
 			goto out_bad;
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
-			goto out_good;
-		}
-
 		goto out_good;
-	}
 
 	case htons(ETH_P_FCOE):
 		if ((hlen - nhoff) < FCOE_HEADER_LEN)
-- 
2.7.4
