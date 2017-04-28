From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 1/4] flow dissector: return error on port dissection under-run
Date: Fri, 28 Apr 2017 14:00:32 +0200
Message-ID: <20170428120035.15984-2-simon.horman@netronome.com>
References: <20170428120035.15984-1-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38239 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165214AbdD1MB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:01:26 -0400
Received: by mail-wm0-f42.google.com with SMTP id r190so44763585wme.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:01:25 -0700 (PDT)
In-Reply-To: <20170428120035.15984-1-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return an error from __skb_flow_dissect() if insufficient packet data is
present when dissecting layer 4 ports.

Without this change the absence of ports in truncated - e.g. UDP - packets
is treated the same way as the presence of ports with a value of zero.  As
a result the flower classifier is unable to differentiate between these two
cases which may lead to unexpected matching of truncated packets.

The approach taken here is to only return an error if the offset of ports
for the previously dissected IP protocol is known - a non error return from
proto_ports_offset() - and the port data is not present in the packet - an
error return value from __skb_header_pointer().

The behaviour for callers of __skb_flow_get_ports() is changed but the only
callers are skb_flow_get_ports() and the flow dissector.  The former has
been updated so that its behaviour is unchanged.  Behavioural change of the
latter is the intended purpose of this patch but will only take effect with
a separate patch to have it refuse to match if dissection fails.

This change will lead to behavioural changes of the users of the dissector
with FLOW_DISSECTOR_KEY_PORTS - flower, and users of
flow_keys_dissector_keys[] and flow_keys_dissector_symmetric_keys[].  The
behavioural change for *_keys[] changes seem reasonable as the change will
should only be for truncated packets.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/skbuff.h    | 11 ++++++++---
 net/core/flow_dissector.c | 40 ++++++++++++++++++++++++++--------------
 2 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 81ef53f06534..0ad9b3955829 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1108,13 +1108,18 @@ u32 __skb_get_hash_symmetric(const struct sk_buff *skb);
 u32 skb_get_poff(const struct sk_buff *skb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen);
-__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
-			    void *data, int hlen_proto);
+bool __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
+			  void *data, int hlen_proto, __be32 *ports);
 
 static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 					int thoff, u8 ip_proto)
 {
-	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
+	__be32 ports;
+
+	if (__skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0, &ports))
+		return ports;
+	else
+		return 0;
 }
 
 void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 28d94bce4df8..b3bf4886f71f 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -86,30 +86,41 @@ static __be16 skb_flow_get_be16(const struct sk_buff *skb, int poff,
  * @ip_proto: protocol for which to get port offset
  * @data: raw buffer pointer to the packet, if NULL use skb->data
  * @hlen: packet header length, if @data is NULL use skb_headlen(skb)
+ * @ports: pointer to return ports in
  *
  * The function will try to retrieve the ports at offset thoff + poff where poff
- * is the protocol port offset returned from proto_ports_offset
+ * is the protocol port offset returned from proto_ports_offset.
+ *
+ * Returns false on error, true otherwise.
  */
-__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
-			    void *data, int hlen)
+bool __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
+			  void *data, int hlen, __be32 *ports)
 {
 	int poff = proto_ports_offset(ip_proto);
+	__be32 *p, _p;
+
+	/* proto_ports_offset returning an error indicates that ip_proto is
+	 * not known to have ports. This is not considered an error here.
+	 * Rather it is considered that the flow key of the caller may use
+	 * the default value of port fields: 0.
+	 */
+	if (poff < 0) {
+		*ports = 0;
+		return true;
+	}
 
 	if (!data) {
 		data = skb->data;
 		hlen = skb_headlen(skb);
 	}
 
-	if (poff >= 0) {
-		__be32 *ports, _ports;
+	p = __skb_header_pointer(skb, thoff + poff, sizeof(_p),
+				 data, hlen, &_p);
+	if (!p)
+		return false;
+	*ports = *p;
 
-		ports = __skb_header_pointer(skb, thoff + poff,
-					     sizeof(_ports), data, hlen, &_ports);
-		if (ports)
-			return *ports;
-	}
-
-	return 0;
+	return true;
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
@@ -692,8 +703,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		key_ports = skb_flow_dissector_target(flow_dissector,
 						      FLOW_DISSECTOR_KEY_PORTS,
 						      target_container);
-		key_ports->ports = __skb_flow_get_ports(skb, nhoff, ip_proto,
-							data, hlen);
+		if (!__skb_flow_get_ports(skb, nhoff, ip_proto, data, hlen,
+					  &key_ports->ports))
+			goto out_bad;
 	}
 
 	if (dissector_uses_key(flow_dissector,
-- 
2.12.2.816.g2cccc81164
