From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/2] net: make skb an optional parameter for__skb_flow_dissect()
Date: Mon, 25 Aug 2014 17:03:47 -0700
Message-ID: <1409011427-18438-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1409011427-18438-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:43452 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:04:01 -0400
Received: by mail-pa0-f51.google.com with SMTP id ey11so22226609pad.38
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 17:04:01 -0700 (PDT)
In-Reply-To: <1409011427-18438-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit 690e36e726d00d2 (net: Allow raw buffers to be passed into the flow dissector)
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/flow_keys.h   |  4 ++--
 net/core/flow_dissector.c | 18 +++++++++++++++---
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 4040f63..9a03f73 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -28,10 +28,10 @@ struct flow_keys {
 };
 
 bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
-			void *data, int hlen);
+			void *data, __be16 proto, int nhoff, int hlen);
 static inline bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
 {
-	return __skb_flow_dissect(skb, flow, NULL, 0);
+	return __skb_flow_dissect(skb, flow, NULL, 0, 0, 0);
 }
 __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 			    void *data, int hlen_proto);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index ae8f0db..12f48ca 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -59,14 +59,26 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
-bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow, void *data, int hlen)
+/**
+ * __skb_flow_dissect - extract the flow_keys struct and return it
+ * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
+ * @data: raw buffer pointer to the packet, if NULL use skb->data
+ * @proto: protocol for which to get the flow, if @data is NULL use skb->protocol
+ * @nhoff: network header offset, if @data is NULL use skb_network_offset(skb)
+ * @hlen: packet header length, if @data is NULL use skb_headlen(skb)
+ *
+ * The function will try to retrieve the struct flow_keys from either the skbuff
+ * or a raw buffer specified by the rest parameters
+ */
+bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
+			void *data, __be16 proto, int nhoff, int hlen)
 {
-	int nhoff = skb_network_offset(skb);
 	u8 ip_proto;
-	__be16 proto = skb->protocol;
 
 	if (!data) {
 		data = skb->data;
+		proto = skb->protocol;
+		nhoff = skb_network_offset(skb);
 		hlen = skb_headlen(skb);
 	}
 
-- 
1.8.3.1
