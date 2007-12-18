From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [RFC][PATCH][IPV4] ip_gre: use skb->{mac,network}_header consistently
Date: Tue, 18 Dec 2007 15:59:37 +0200
Message-ID: <4767D249.5050602@iki.fi>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net> <471E19E5.5040509@iki.fi> <20071023202036.GA12066@ms2.inr.ac.ru> <471EDE22.4090408@iki.fi> <20071024100842.GA19369@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:44284 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192AbXLRN7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 08:59:25 -0500
Received: by fk-out-0910.google.com with SMTP id z23so2071157fkz.5
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 05:59:23 -0800 (PST)
In-Reply-To: <20071024100842.GA19369@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>

Make both send and receive paths use consistently skb->*_header:
  mac_header = outer IPv4 header
  network_header = encapsulated packet (e.g. inner IPv4 header)

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
Currently in send path:
  network_header = outer IPv4 header
  transport_header = encapsulated packet
And receive path:
  network_header = encapsulated packet
  mac_header = GRE header

mac_header used to be the outer IPv4 header on receive path, but it was
broken/changed when skb_reset_mac_header() was introduced.

This also makes ipgre_header_parse() work correctly as it assumes that
mac_header points to the outer IPv4 header always. Though, it returns
zeros for outgoing packets that are tcpdumped from gre tunnel without
explicit local address, since the routing is done in ipgre_tunnel_xmit().

 net/ipv4/ip_gre.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 02b02a8..eba1ade 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -613,7 +613,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 				offset += 4;
 		}
 
-		skb_reset_mac_header(skb);
+		skb->mac_header = skb->network_header;
 		__pskb_pull(skb, offset);
 		skb_reset_network_header(skb);
 		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
@@ -826,9 +826,8 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		old_iph = ip_hdr(skb);
 	}
 
-	skb->transport_header = skb->network_header;
 	skb_push(skb, gre_hlen);
-	skb_reset_network_header(skb);
+	skb_reset_mac_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
@@ -839,7 +838,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	 *	Push down and install the IPIP header.
 	 */
 
-	iph 			=	ip_hdr(skb);
+	iph 			=	(struct iphdr *) skb_mac_header(skb);
 	iph->version		=	4;
 	iph->ihl		=	sizeof(struct iphdr) >> 2;
 	iph->frag_off		=	df;
@@ -1070,6 +1069,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 	struct iphdr *iph = (struct iphdr *)skb_push(skb, t->hlen);
 	__be16 *p = (__be16*)(iph+1);
 
+	skb_reset_mac_header(skb);
 	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
 	p[0]		= t->parms.o_flags;
 	p[1]		= htons(type);
-- 
1.5.2.5


