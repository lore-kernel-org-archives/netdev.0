From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/10] ipvs: fix ipv6 route unreach panic
Date: Thu, 23 Jul 2015 01:00:45 +0200
Message-ID: <1437606052-5179-4-git-send-email-pablo@netfilter.org>
References: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54426 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753358AbbGVWzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 18:55:20 -0400
In-Reply-To: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>

Previously there was a trivial panic

unshare -n /bin/bash <<EOF
ip addr add dev lo face::1/128
ipvsadm -A -t [face::1]:15213
ipvsadm -a -t [face::1]:15213 -r b00c::1
echo boom | nc face::1 15213
EOF

This patch allows us to replicate the net logic above and simply capture
the skb_dst(skb)->dev and use that for the purpose of the invocation.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index bf66a86..b99d806 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -505,6 +505,13 @@ err_put:
 	return -1;
 
 err_unreach:
+	/* The ip6_link_failure function requires the dev field to be set
+	 * in order to get the net (further for the sake of fwmark
+	 * reflection).
+	 */
+	if (!skb->dev)
+		skb->dev = skb_dst(skb)->dev;
+
 	dst_link_failure(skb);
 	return -1;
 }
-- 
1.7.10.4
