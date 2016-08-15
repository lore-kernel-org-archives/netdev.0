From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net v3] gre: set inner_protocol on xmit
Date: Mon, 15 Aug 2016 13:06:24 +0200
Message-ID: <1471259184-18294-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Simon Horman <simon.horman@netronome.com>,
	Pravin Shelar <pshelar@ovn.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36365 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbcHOLGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 07:06:38 -0400
Received: by mail-wm0-f49.google.com with SMTP id q128so83939420wma.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 04:06:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that the inner_protocol is set on transmit so that GSO segmentation,
which relies on that field, works correctly.

This is achieved by setting the inner_protocol in gre_build_header rather
than each caller of that function. It ensures that the inner_protocol is
set when gre_fb_xmit() is used to transmit GRE which was not previously the
case.

I have observed this is not the case when OvS transmits GRE using
lwtunnel metadata (which it always does).

Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
Cc: Pravin Shelar <pshelar@ovn.org>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v3
* Move logic to gre_build_header() as suggested by Pravin Shelar.

v2
* Added Alexander's Ack
* Drop RFC designation
---
 include/net/gre.h  | 1 +
 net/ipv4/ip_gre.c  | 1 -
 net/ipv6/ip6_gre.c | 2 --
 3 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 7a54a31d1d4c..73ea256eb7d7 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -104,6 +104,7 @@ static inline void gre_build_header(struct sk_buff *skb, int hdr_len,
 
 	skb_push(skb, hdr_len);
 
+	skb_set_inner_protocol(skb, proto);
 	skb_reset_transport_header(skb);
 	greh = (struct gre_base_hdr *)skb->data;
 	greh->flags = gre_tnl_flags_to_gre_flags(flags);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5b1481be0282..113cc43df789 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -370,7 +370,6 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 			 tunnel->parms.o_flags, proto, tunnel->parms.o_key,
 			 htonl(tunnel->o_seqno));
 
-	skb_set_inner_protocol(skb, proto);
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 776d145113e1..704274cbd495 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -519,8 +519,6 @@ static netdev_tx_t __gre6_xmit(struct sk_buff *skb,
 	gre_build_header(skb, tunnel->tun_hlen, tunnel->parms.o_flags,
 			 protocol, tunnel->parms.o_key, htonl(tunnel->o_seqno));
 
-	skb_set_inner_protocol(skb, protocol);
-
 	return ip6_tnl_xmit(skb, dev, dsfield, fl6, encap_limit, pmtu,
 			    NEXTHDR_GRE);
 }
-- 
2.7.0.rc3.207.g0ac5344
