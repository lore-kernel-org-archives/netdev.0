From: alexander.duyck@gmail.com
Subject: [PATCH] flow-dissector: Fix alignment issue in __skb_flow_get_ports
Date: Thu, 09 Oct 2014 21:03:28 -0700
Message-ID: <20141010035840.21428.359.stgit@ahduyck-workstation.home>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50386 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaJJED2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 00:03:28 -0400
Received: by mail-pa0-f47.google.com with SMTP id rd3so930051pab.20
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 21:03:27 -0700 (PDT)
In-Reply-To: <20141009.201248.1210454965155680255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This patch addresses a kernel unaligned access bug seen on a sparc64 system
with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
be32 pointer which was then having the value directly returned.

In order to keep the handling of the ports consistent with how we were
handling the IPv4 and IPv6 addresses I have instead replaced the assignment
with a memcpy to the flow key ports value.  This way it should stay a
memcpy on systems that cannot handle unaligned access, and will likely be
converted to a 32b assignment on the systems that can support it.

Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 include/net/flow_keys.h         |   10 ++++++----
 net/core/flow_dissector.c       |   21 +++++++++++++--------
 3 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c9ac06c..326eb3d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2993,7 +2993,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 		return false;
 	}
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34 && proto >= 0)
-		fk->ports = skb_flow_get_ports(skb, noff, proto);
+		skb_flow_get_ports(fk, skb, noff, proto);
 
 	return true;
 }
diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 7ee2df0..66235f4 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -33,11 +33,13 @@ static inline bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys
 {
 	return __skb_flow_dissect(skb, flow, NULL, 0, 0, 0);
 }
-__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
-			    void *data, int hlen_proto);
-static inline __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
+void __skb_flow_get_ports(struct flow_keys *flow, const struct sk_buff *skb,
+			  int thoff, u8 ip_proto, void *data, int hlen_proto);
+static inline void skb_flow_get_ports(struct flow_keys *flow,
+				      const struct sk_buff *skb, int thoff,
+				      u8 ip_proto)
 {
-	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
+	__skb_flow_get_ports(flow, skb, thoff, ip_proto, NULL, 0);
 }
 u32 flow_hash_from_keys(struct flow_keys *keys);
 unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 8560dea..baf8fe3 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -28,6 +28,7 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
 
 /**
  * __skb_flow_get_ports - extract the upper layer ports and return them
+ * @flow: Flow key to place port informatin into
  * @skb: sk_buff to extract the ports from
  * @thoff: transport header offset
  * @ip_proto: protocol for which to get port offset
@@ -37,8 +38,8 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
  * The function will try to retrieve the ports at offset thoff + poff where poff
  * is the protocol port offset returned from proto_ports_offset
  */
-__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
-			    void *data, int hlen)
+void __skb_flow_get_ports(struct flow_keys *flow, const struct sk_buff *skb,
+			  int thoff, u8 ip_proto, void *data, int hlen)
 {
 	int poff = proto_ports_offset(ip_proto);
 
@@ -48,15 +49,19 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 	}
 
 	if (poff >= 0) {
-		__be32 *ports, _ports;
+		__be32 *ports;
 
 		ports = __skb_header_pointer(skb, thoff + poff,
-					     sizeof(_ports), data, hlen, &_ports);
-		if (ports)
-			return *ports;
+					     sizeof(flow->ports), data, hlen,
+					     &flow->ports);
+		if (ports) {
+			if (&flow->ports != ports)
+				memcpy(&flow->ports, ports, sizeof(flow->ports));
+			return;
+		}
 	}
 
-	return 0;
+	memset(&flow->ports, 0, sizeof(flow->ports));
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
@@ -231,7 +236,7 @@ ipv6:
 
 	flow->n_proto = proto;
 	flow->ip_proto = ip_proto;
-	flow->ports = __skb_flow_get_ports(skb, nhoff, ip_proto, data, hlen);
+	__skb_flow_get_ports(flow, skb, nhoff, ip_proto, data, hlen);
 	flow->thoff = (u16) nhoff;
 
 	return true;
