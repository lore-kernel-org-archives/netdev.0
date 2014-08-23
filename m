From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Allow raw buffers to be passed into the flow
 dissector.
Date: Sat, 23 Aug 2014 12:18:55 -0700 (PDT)
Message-ID: <20140823.121855.1259915921868754968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, idos@mellanox.com,
	eric.dumazet@gmail.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaHWTS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 15:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Drivers, and perhaps other entities we have not yet considered,
sometimes want to know how deep the protocol headers go before
deciding how large of an SKB to allocate and how much of the packet to
place into the linear SKB area.

For example, consider a driver which has a device which DMAs into
pools of pages and then tells the driver where the data went in the
DMA descriptor(s).  The driver can then build an SKB and reference
most of the data via SKB fragments (which are page/offset/length
triplets).

However at least some of the front of the packet should be placed into
the linear SKB area, which comes before the fragments, so that packet
processing can get at the headers efficiently.  The first thing each
protocol layer is going to do is a "pskb_may_pull()" so we might as
well aggregate as much of this as possible while we're building the
SKB in the driver.

Part of supporting this is that we don't have an SKB yet, so we want
to be able to let the flow dissector operate on a raw buffer in order
to compute the offset of the end of the headers.

So now we have a __skb_flow_dissect() which takes an explicit data
pointer and length.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I'll commit this to net-next.

Amir, please re-spin your changes on top of this.  Thanks!

 include/linux/skbuff.h    | 18 ++++++++++++------
 include/net/flow_keys.h   | 14 ++++++++++++--
 net/core/flow_dissector.c | 40 ++++++++++++++++++++++++++--------------
 3 files changed, 50 insertions(+), 22 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index abde271..18ddf96 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2567,20 +2567,26 @@ __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
 __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
 		    __wsum csum);
 
-static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
-				       int len, void *buffer)
+static inline void *__skb_header_pointer(const struct sk_buff *skb, int offset,
+					 int len, void *data, int hlen, void *buffer)
 {
-	int hlen = skb_headlen(skb);
-
 	if (hlen - offset >= len)
-		return skb->data + offset;
+		return data + offset;
 
-	if (skb_copy_bits(skb, offset, buffer, len) < 0)
+	if (!skb ||
+	    skb_copy_bits(skb, offset, buffer, len) < 0)
 		return NULL;
 
 	return buffer;
 }
 
+static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
+				       int len, void *buffer)
+{
+	return __skb_header_pointer(skb, offset, len, skb->data,
+				    skb_headlen(skb), buffer);
+}
+
 /**
  *	skb_needs_linearize - check if we need to linearize a given skb
  *			      depending on the given device features.
diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 6667a05..4040f63 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -27,7 +27,17 @@ struct flow_keys {
 	u8 ip_proto;
 };
 
-bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
-__be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto);
+bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
+			void *data, int hlen);
+static inline bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
+{
+	return __skb_flow_dissect(skb, flow, NULL, 0);
+}
+__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
+			    void *data, int hlen_proto);
+static inline __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
+{
+	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
+}
 u32 flow_hash_from_keys(struct flow_keys *keys);
 #endif
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 5f362c1..660c649 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -34,29 +34,40 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
  * The function will try to retrieve the ports at offset thoff + poff where poff
  * is the protocol port offset returned from proto_ports_offset
  */
-__be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
+__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
+			    void *data, int hlen)
 {
 	int poff = proto_ports_offset(ip_proto);
 
+	if (!data) {
+		data = skb->data;
+		hlen = skb_headlen(skb);
+	}
+
 	if (poff >= 0) {
 		__be32 *ports, _ports;
 
-		ports = skb_header_pointer(skb, thoff + poff,
-					   sizeof(_ports), &_ports);
+		ports = __skb_header_pointer(skb, thoff + poff,
+					     sizeof(_ports), data, hlen, &_ports);
 		if (ports)
 			return *ports;
 	}
 
 	return 0;
 }
-EXPORT_SYMBOL(skb_flow_get_ports);
+EXPORT_SYMBOL(__skb_flow_get_ports);
 
-bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
+bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow, void *data, int hlen)
 {
 	int nhoff = skb_network_offset(skb);
 	u8 ip_proto;
 	__be16 proto = skb->protocol;
 
+	if (!data) {
+		data = skb->data;
+		hlen = skb_headlen(skb);
+	}
+
 	memset(flow, 0, sizeof(*flow));
 
 again:
@@ -65,7 +76,7 @@ again:
 		const struct iphdr *iph;
 		struct iphdr _iph;
 ip:
-		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
+		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
 		if (!iph || iph->ihl < 5)
 			return false;
 		nhoff += iph->ihl * 4;
@@ -83,7 +94,7 @@ ip:
 		__be32 flow_label;
 
 ipv6:
-		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
+		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
 		if (!iph)
 			return false;
 
@@ -113,7 +124,7 @@ ipv6:
 		const struct vlan_hdr *vlan;
 		struct vlan_hdr _vlan;
 
-		vlan = skb_header_pointer(skb, nhoff, sizeof(_vlan), &_vlan);
+		vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan), data, hlen, &_vlan);
 		if (!vlan)
 			return false;
 
@@ -126,7 +137,7 @@ ipv6:
 			struct pppoe_hdr hdr;
 			__be16 proto;
 		} *hdr, _hdr;
-		hdr = skb_header_pointer(skb, nhoff, sizeof(_hdr), &_hdr);
+		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
 			return false;
 		proto = hdr->proto;
@@ -151,7 +162,7 @@ ipv6:
 			__be16 proto;
 		} *hdr, _hdr;
 
-		hdr = skb_header_pointer(skb, nhoff, sizeof(_hdr), &_hdr);
+		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
 			return false;
 		/*
@@ -171,8 +182,9 @@ ipv6:
 				const struct ethhdr *eth;
 				struct ethhdr _eth;
 
-				eth = skb_header_pointer(skb, nhoff,
-							 sizeof(_eth), &_eth);
+				eth = __skb_header_pointer(skb, nhoff,
+							   sizeof(_eth),
+							   data, hlen, &_eth);
 				if (!eth)
 					return false;
 				proto = eth->h_proto;
@@ -194,12 +206,12 @@ ipv6:
 
 	flow->n_proto = proto;
 	flow->ip_proto = ip_proto;
-	flow->ports = skb_flow_get_ports(skb, nhoff, ip_proto);
+	flow->ports = __skb_flow_get_ports(skb, nhoff, ip_proto, data, hlen);
 	flow->thoff = (u16) nhoff;
 
 	return true;
 }
-EXPORT_SYMBOL(skb_flow_dissect);
+EXPORT_SYMBOL(__skb_flow_dissect);
 
 static u32 hashrnd __read_mostly;
 static __always_inline void __flow_hash_secret_init(void)
-- 
1.7.11.7
