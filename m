From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] net: Use IPv6 flow label in flow_dissector
Date: Sat, 26 Apr 2014 16:00:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261553060.15726@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:56330 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbaDZXAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 19:00:18 -0400
Received: by mail-qc0-f202.google.com with SMTP id x13so678627qcv.1
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 16:00:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the receive side to support RFC6438 which is to
use the flow label as an ECMP hash. If an IPv6 flow label is set
in a packet we can use this as input for computing an l4-hash.
There should be no need to parse any transport headers in this
case.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/flow_dissector.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 107ed12..1c37d7b 100644
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
@@ -89,6 +91,20 @@ ipv6:
 		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
 		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
 		nhoff += sizeof(struct ipv6hdr);
+
+		if ((flow_label = ip6_flowlabel(iph))) {
+			/*
+			 * Awesome, IPv6 packet has a flow label so we can
+			 * use that to represent the ports without any
+			 * further dissection.
+			 */
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
1.9.1.423.g4596e3a
