From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Tue, 29 Jul 2014 21:58:53 -0700 (PDT)
Message-ID: <20140729.215853.2058634690190963314.davem@davemloft.net>
References: <1406542451-8857-1-git-send-email-amirv@mellanox.com>
	<1406542451-8857-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, idos@mellanox.com,
	eric.dumazet@gmail.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaG3E64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 00:58:56 -0400
In-Reply-To: <1406542451-8857-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 28 Jul 2014 13:14:10 +0300

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> This commit is based on Eric Dumazet suggestion.
> Use flow dissector to calculate header length.
> Tested the following with a mlx4, and it indeed speeds up GRE traffic,
> as GRO packets can now contain 17 MSS instead of 8.
> (Pulling payload means GRO had to use 2 'frags' per MSS)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

So I decided to see how bad it would be if we tried to avoid making
that funky on-stack SKB and came up with the patch below.

With this you can make __skb_get_poff() take "data" and "hlen" too,
pass it onward to __skb_flow_dissect(), and then your new function is
just:

u32 eth_frame_headlen(void *data, unsigned int len)
{
	if (unlikely(len < ETH_HLEN))
		return len;
	return __skb_get_poff(NULL, data, hlen) + ETH_HLEN;
}

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 281dece..1e0b04c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2554,20 +2554,26 @@ __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
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
