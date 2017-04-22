From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Subject: [PATCH net-next 1/2] flow_dissector: add mpls support (v2)
Date: Sat, 22 Apr 2017 16:52:46 -0400
Message-ID: <1492894367-11637-2-git-send-email-benjamin.lahaise@netronome.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
Cc: Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>,
        "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:36454 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426682AbdDVUyD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 16:54:03 -0400
Received: by mail-qt0-f182.google.com with SMTP id g60so91033415qtd.3
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 13:54:02 -0700 (PDT)
In-Reply-To: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for parsing MPLS flows to the flow dissector in preparation for
adding MPLS match support to cls_flower.

Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Simon Horman <simon.horman@netronome.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Cc: Eric Dumazet <jhs@mojatatu.com>
Cc: Hadar Hen Zion <hadarh@mellanox.com>
Cc: Gao Feng <fgao@ikuai8.com>
---
 include/linux/mpls.h         |  5 +++++
 include/net/flow_dissector.h |  8 ++++++++
 net/core/flow_dissector.c    | 25 ++++++++++++++++++++++---
 3 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/include/linux/mpls.h b/include/linux/mpls.h
index 9999145..384fb22 100644
--- a/include/linux/mpls.h
+++ b/include/linux/mpls.h
@@ -3,4 +3,9 @@
 
 #include <uapi/linux/mpls.h>
 
+#define MPLS_TTL_MASK		(MPLS_LS_TTL_MASK >> MPLS_LS_TTL_SHIFT)
+#define MPLS_BOS_MASK		(MPLS_LS_S_MASK >> MPLS_LS_S_SHIFT)
+#define MPLS_TC_MASK		(MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)
+#define MPLS_LABEL_MASK		(MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)
+
 #endif  /* _LINUX_MPLS_H */
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index ac97030..8d21d44 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -41,6 +41,13 @@ struct flow_dissector_key_vlan {
 	u16	padding;
 };
 
+struct flow_dissector_key_mpls {
+	u32	mpls_ttl:8,
+		mpls_bos:1,
+		mpls_tc:3,
+		mpls_label:20;
+};
+
 struct flow_dissector_key_keyid {
 	__be32	keyid;
 };
@@ -169,6 +176,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 	FLOW_DISSECTOR_KEY_ENC_CONTROL, /* struct flow_dissector_key_control */
 	FLOW_DISSECTOR_KEY_ENC_PORTS, /* struct flow_dissector_key_ports */
+	FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c9cf425..28d94bc 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -126,9 +126,11 @@ __skb_flow_dissect_mpls(const struct sk_buff *skb,
 {
 	struct flow_dissector_key_keyid *key_keyid;
 	struct mpls_label *hdr, _hdr[2];
+	u32 entry, label;
 
 	if (!dissector_uses_key(flow_dissector,
-				FLOW_DISSECTOR_KEY_MPLS_ENTROPY))
+				FLOW_DISSECTOR_KEY_MPLS_ENTROPY) &&
+	    !dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_MPLS))
 		return FLOW_DISSECT_RET_OUT_GOOD;
 
 	hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
@@ -136,8 +138,25 @@ __skb_flow_dissect_mpls(const struct sk_buff *skb,
 	if (!hdr)
 		return FLOW_DISSECT_RET_OUT_BAD;
 
-	if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
-	    MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
+	entry = ntohl(hdr[0].entry);
+	label = (entry & MPLS_LS_LABEL_MASK) >> MPLS_LS_LABEL_SHIFT;
+
+	if (dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_MPLS)) {
+		struct flow_dissector_key_mpls *key_mpls;
+
+		key_mpls = skb_flow_dissector_target(flow_dissector,
+						     FLOW_DISSECTOR_KEY_MPLS,
+						     target_container);
+		key_mpls->mpls_label = label;
+		key_mpls->mpls_ttl = (entry & MPLS_LS_TTL_MASK)
+					>> MPLS_LS_TTL_SHIFT;
+		key_mpls->mpls_tc = (entry & MPLS_LS_TC_MASK)
+					>> MPLS_LS_TC_SHIFT;
+		key_mpls->mpls_bos = (entry & MPLS_LS_S_MASK)
+					>> MPLS_LS_S_SHIFT;
+	}
+
+	if (label == MPLS_LABEL_ENTROPY) {
 		key_keyid = skb_flow_dissector_target(flow_dissector,
 						      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
 						      target_container);
-- 
2.7.4
