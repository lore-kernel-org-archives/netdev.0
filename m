From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next 2/2] flow_dissector: Add limit for number of headers to dissect
Date: Fri,  1 Sep 2017 14:04:12 -0700
Message-ID: <20170901210412.2915-3-tom@quantonium.net>
References: <20170901210412.2915-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        alex.popov@linux.com, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34863 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752416AbdIAVEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 17:04:50 -0400
Received: by mail-pg0-f51.google.com with SMTP id 63so3622146pgc.2
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 14:04:49 -0700 (PDT)
In-Reply-To: <20170901210412.2915-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow dissector there are no limits to the number of nested
encapsulations or headers that might be dissected which makes for a
nice DOS attack. This patch sets a limit of the number of headers
that flow dissector will parse.

Headers includes network layer headers, transport layer headers, shim
headers for encapsulation, IPv6 extension headers, etc. The limit for
maximum number of headers to parse has be set to fifteen to account for
a reasonable number of encapsulations, extension headers, VLAN,
in a packet. Note that this limit does not supercede the STOP_AT_*
flags which may stop processing before the headers limit is reached.

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 net/core/flow_dissector.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index e0ea17d1c7fc..0a977373d003 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -396,6 +396,18 @@ __skb_flow_dissect_ipv6(const struct sk_buff *skb,
 	key_ip->ttl = iph->hop_limit;
 }
 
+/* Maximum number of protocol headers that can be parsed in
+ * __skb_flow_dissect
+ */
+#define MAX_FLOW_DISSECT_HDRS	15
+
+static bool skb_flow_dissect_allowed(int *num_hdrs)
+{
+	++*num_hdrs;
+
+	return (*num_hdrs <= MAX_FLOW_DISSECT_HDRS);
+}
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -427,6 +439,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_vlan *key_vlan;
 	enum flow_dissect_ret fdret;
 	bool skip_vlan = false;
+	int num_hdrs = 0;
 	u8 ip_proto = 0;
 	bool ret;
 
@@ -714,7 +727,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case FLOW_DISSECT_RET_OUT_GOOD:
 		goto out_good;
 	case FLOW_DISSECT_RET_PROTO_AGAIN:
-		goto proto_again;
+		if (skb_flow_dissect_allowed(&num_hdrs))
+			goto proto_again;
+		goto out_good;
 	case FLOW_DISSECT_RET_CONTINUE:
 	case FLOW_DISSECT_RET_IPPROTO_AGAIN:
 		break;
@@ -843,9 +858,13 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	/* Process result of IP proto processing */
 	switch (fdret) {
 	case FLOW_DISSECT_RET_PROTO_AGAIN:
-		goto proto_again;
+		if (skb_flow_dissect_allowed(&num_hdrs))
+			goto proto_again;
+		break;
 	case FLOW_DISSECT_RET_IPPROTO_AGAIN:
-		goto ip_proto_again;
+		if (skb_flow_dissect_allowed(&num_hdrs))
+			goto ip_proto_again;
+		break;
 	case FLOW_DISSECT_RET_OUT_GOOD:
 	case FLOW_DISSECT_RET_CONTINUE:
 		break;
-- 
2.11.0
