From: alexander.duyck@gmail.com
Subject: [PATCH net] gre: Fix regression in gretap TSO support
Date: Wed, 29 Oct 2014 20:26:42 -0700
Message-ID: <20141030032430.4452.46388.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "H.K. Jerry Chu" <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:37345 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbaJ3DfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 23:35:20 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so4512688pab.22
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 20:35:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

On recent kernels I found that TSO on gretap interfaces didn't work.  After
bisecting it I found that commit b884b1a4 had introduced a regression in
which the Ethernet header was being included in the GRE header length.

This change corrects that by basing the GRE header length on the inner mac
header in the case of GRE tunnels using transparent Ethernet bridging, and
uses the network header for all other GRE tunnel types.

Fixes: b884b1a4 ("gre_offload: simplify GRE header length calculation in gre_gso_segment()")
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/gre_offload.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index f6e345c..67a1f66 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -47,7 +47,10 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 
 	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 
-	ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
+	if (greh->protocol == htons(ETH_P_TEB))
+		ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
+	else
+		ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
 	if (unlikely(ghl < sizeof(*greh)))
 		goto out;
 
