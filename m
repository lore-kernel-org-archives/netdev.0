From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 2/2] flow_dissector: Add limits for encapsulation and EH
Date: Thu, 31 Aug 2017 15:22:39 -0700
Message-ID: <20170831222239.21509-3-tom@quantonium.net>
References: <20170831222239.21509-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, alex.popov@linux.com,
        hannes@stressinduktion.org, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:37751 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751205AbdHaWYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:24:03 -0400
Received: by mail-pg0-f54.google.com with SMTP id 83so2710765pgb.4
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 15:24:03 -0700 (PDT)
In-Reply-To: <20170831222239.21509-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow dissector there are no limits to the number of nested
encapsulations that might be dissected which makes for a nice DOS
attack. This patch limits for dissecting nested encapsulations
as well as for dissecting over extension headers.

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 net/core/flow_dissector.c | 48 ++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 45 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 5110180a3e96..1bca748de27d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -396,6 +396,35 @@ __skb_flow_dissect_ipv6(const struct sk_buff *skb,
 	key_ip->ttl = iph->hop_limit;
 }
 
+/* Maximum number of nested encapsulations that can be processed in
+ * __skb_flow_dissect
+ */
+#define MAX_FLOW_DISSECT_ENCAPS	5
+
+static bool skb_flow_dissect_encap_allowed(int *num_encaps, unsigned int *flags)
+{
+	++*num_encaps;
+
+	if (*num_encaps >= MAX_FLOW_DISSECT_ENCAPS) {
+		if (*num_encaps == MAX_FLOW_DISSECT_ENCAPS) {
+			/* Allow one more pass but ignore disregard
+			 * further encapsulations
+			 */
+			*flags |= FLOW_DISSECTOR_F_STOP_AT_ENCAP;
+		} else {
+			/* Max encaps reached */
+			return  false;
+		}
+	}
+
+	return true;
+}
+
+/* Maximum number of extension headers can be processed in __skb_flow_dissect
+ * per IPv6 packet
+ */
+#define MAX_FLOW_DISSECT_EH	5
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -426,6 +455,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_vlan *key_vlan;
 	enum flow_dissect_ret fdret;
+	int num_eh, num_encaps = 0;
 	bool skip_vlan = false;
 	u8 ip_proto = 0;
 	bool ret;
@@ -714,7 +744,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case FLOW_DISSECT_RET_OUT_GOOD:
 		goto out_good;
 	case FLOW_DISSECT_RET_PROTO_AGAIN:
-		goto proto_again;
+		if (skb_flow_dissect_encap_allowed(&num_encaps, &flags))
+			goto proto_again;
+		goto out_good;
 	case FLOW_DISSECT_RET_CONTINUE:
 	case FLOW_DISSECT_RET_IPPROTO_AGAIN:
 	case FLOW_DISSECT_RET_IPPROTO_AGAIN_EH:
@@ -724,6 +756,8 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		goto out_bad;
 	}
 
+	num_eh = 0;
+
 ip_proto_again:
 	fdret = FLOW_DISSECT_RET_CONTINUE;
 
@@ -844,10 +878,18 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	/* Process result of IP proto processing */
 	switch (fdret) {
 	case FLOW_DISSECT_RET_PROTO_AGAIN:
-		goto proto_again;
+		if (skb_flow_dissect_encap_allowed(&num_encaps, &flags))
+			goto proto_again;
+		break;
 	case FLOW_DISSECT_RET_IPPROTO_AGAIN:
+		if (skb_flow_dissect_encap_allowed(&num_encaps, &flags))
+			goto ip_proto_again;
+		break;
 	case FLOW_DISSECT_RET_IPPROTO_AGAIN_EH:
-		goto ip_proto_again;
+		++num_eh;
+		if (num_eh <= MAX_FLOW_DISSECT_EH)
+			goto ip_proto_again;
+		break;
 	case FLOW_DISSECT_RET_OUT_GOOD:
 	case FLOW_DISSECT_RET_CONTINUE:
 		break;
-- 
2.11.0
