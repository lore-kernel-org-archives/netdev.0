From: Tom Herbert <therbert@google.com>
Subject: [PATCH 6/8] flow_dissector: Use IPv6 flow label in flow_dissector
Date: Tue, 1 Jul 2014 21:33:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012104001.4650@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:52584 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaGBEdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:33:02 -0400
Received: by mail-ve0-f201.google.com with SMTP id jz11so1170722veb.0
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:33:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the receive side to support RFC 6438 which is to
use the flow label as an ECMP hash. If an IPv6 flow label is set
in a packet we can use this as input for computing an L4-hash. There
should be no need to parse any transport headers in this case.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 62d1cb6..c5f3912 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -80,6 +80,8 @@ ip:
 	case htons(ETH_P_IPV6): {
 		const struct ipv6hdr *iph;
 		struct ipv6hdr _iph;
+		__be32 flow_label;
+
 ipv6:
 		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
 		if (!iph)
@@ -89,6 +91,21 @@ ipv6:
 		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
 		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
 		nhoff += sizeof(struct ipv6hdr);
+
+		flow_label = ip6_flowlabel(iph);
+		if (flow_label) {
+			/* Awesome, IPv6 packet has a flow label so we can
+			 * use that to represent the ports without any
+			 * further dissection.
+			 */
+			flow->n_proto = proto;
+			flow->ip_proto = ip_proto;
+			flow->ports = flow_label;
+			flow->thoff = (u16)nhoff;
+
+			return true;
+		}
+
 		break;
 	}
 	case htons(ETH_P_8021AD):
-- 
2.0.0.526.g5318336
