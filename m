From: alexander.duyck@gmail.com
Subject: [PATCH v4] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 12:09:12 -0700
Message-ID: <20141010190716.8311.98709.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:59186 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbaJJTJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:09:13 -0400
Received: by mail-pd0-f170.google.com with SMTP id p10so2187410pdj.29
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 12:09:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This patch addresses a kernel unaligned access bug seen on a sparc64 system
with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
be32 pointer which was then having the value directly returned.

In order to prevent this it is actually easier to simply not populate the
ports or address values when an skb is not present.  In this case the
assumption is that the data isn't needed and rather than slow down the
faster aligned accesses by making them have to assume the unaligned path on
architectures that don't support efficent unaligned access it makes more
sense to simply switch off the bits that were copying the source and
destination address/port for the case where we only care about the protocol
types and lengths which are normally 16 bit fields anyway.

Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

v2: Fixed alignment to __be16 on ports
v3: Discarded previous approach and instead simplified things by
    not populating ports, or src/dst addresses if skb is not present.
    By doing this we avoid the unaligned access issue entirely and do not
    populate fields that will not be used by the eth_get_headlen function.
v4: Minor whitespace cleanups
    Added workaround for access of doff resulting in unaligned access

 net/core/flow_dissector.c |   36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 8560dea..4508493 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -100,6 +100,13 @@ ip:
 		if (ip_is_fragment(iph))
 			ip_proto = 0;
 
+		/* skip the address processing if skb is NULL.  The assumption
+		 * here is that if there is no skb we are not looking for flow
+		 * info but lengths and protocols.
+		 */
+		if (!skb)
+			break;
+
 		iph_to_flow_copy_addrs(flow, iph);
 		break;
 	}
@@ -114,17 +121,15 @@ ipv6:
 			return false;
 
 		ip_proto = iph->nexthdr;
-		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
-		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
 		nhoff += sizeof(struct ipv6hdr);
 
-		/* skip the flow label processing if skb is NULL.  The
-		 * assumption here is that if there is no skb we are not
-		 * looking for flow info as much as we are length.
-		 */
+		/* see comment above in IPv4 section */
 		if (!skb)
 			break;
 
+		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
+		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
+
 		flow_label = ip6_flowlabel(iph);
 		if (flow_label) {
 			/* Awesome, IPv6 packet has a flow label so we can
@@ -231,9 +236,13 @@ ipv6:
 
 	flow->n_proto = proto;
 	flow->ip_proto = ip_proto;
-	flow->ports = __skb_flow_get_ports(skb, nhoff, ip_proto, data, hlen);
 	flow->thoff = (u16) nhoff;
 
+	/* unless skb is set we don't need to record port info */
+	if (skb)
+		flow->ports = __skb_flow_get_ports(skb, nhoff, ip_proto,
+						   data, hlen);
+
 	return true;
 }
 EXPORT_SYMBOL(__skb_flow_dissect);
@@ -334,15 +343,16 @@ u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 
 	switch (keys->ip_proto) {
 	case IPPROTO_TCP: {
-		const struct tcphdr *tcph;
-		struct tcphdr _tcph;
+		/* access doff as u8 to avoid unaligned access */
+		const u8 *doff;
+		u8 _doff;
 
-		tcph = __skb_header_pointer(skb, poff, sizeof(_tcph),
-					    data, hlen, &_tcph);
-		if (!tcph)
+		doff = __skb_header_pointer(skb, poff + 12, sizeof(_doff),
+					    data, hlen, &_doff);
+		if (!doff)
 			return poff;
 
-		poff += max_t(u32, sizeof(struct tcphdr), tcph->doff * 4);
+		poff += max_t(u32, sizeof(struct tcphdr), (*doff & 0xF0) >> 2);
 		break;
 	}
 	case IPPROTO_UDP:
