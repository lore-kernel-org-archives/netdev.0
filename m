From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH] net: Reset encap_level to avoid resetting features on
 inner IP headers
Date: Tue, 22 Mar 2016 16:18:07 -0700
Message-ID: <20160322231732.13054.71337.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: tom@herbertland.com, kernel-team@fb.com, davem@davemloft.net,
	alexander.duyck@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34619 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbcCVXSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 19:18:09 -0400
Received: by mail-pf0-f179.google.com with SMTP id x3so330012305pfb.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 16:18:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects an oversight in which we were allowing the encap_level
value to pass from the outer headers to the inner headers.  As a result we
were incorrectly identifying UDP or GRE tunnels as also making use of ipip
or sit when the second header actually represented a tunnel encapsulated in
either a UDP or GRE tunnel which already had the features masked.

Fixes: 76443456227097179c1482 ("net: Move GSO csum into SKB_GSO_CB")
Reported-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |    1 +
 net/ipv4/udp_offload.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index dea0390d65bb..43a5c76742dc 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -49,6 +49,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 
 	/* setup inner skb. */
 	skb->encapsulation = 0;
+	SKB_GSO_CB(skb)->encap_level = 0;
 	__skb_pull(skb, tnl_hlen);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 5fcb93269afb..80236a9e1769 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -56,6 +56,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 
 	/* setup inner skb. */
 	skb->encapsulation = 0;
+	SKB_GSO_CB(skb)->encap_level = 0;
 	__skb_pull(skb, tnl_hlen);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
