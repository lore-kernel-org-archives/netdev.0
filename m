From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] inet: frags: fix defragmented packet's IP header for
 af_packet
Date: Tue, 21 Jul 2015 09:43:59 +0200
Message-ID: <1437464639.1026.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Edward Hyunkoo Jee <edjee@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36866 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbbGUHoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:44:04 -0400
Received: by wibud3 with SMTP id ud3so118444610wib.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 00:44:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Hyunkoo Jee <edjee@google.com>

When ip_frag_queue() computes positions, it assumes that the passed
sk_buff does not contain L2 headers.

However, when PACKET_FANOUT_FLAG_DEFRAG is used, IP reassembly
functions can be called on outgoing packets that contain L2 headers. 

Also, IPv4 checksum is not corrected after reassembly.

Fixes: 7736d33f4262 ("packet: Add pre-defragmentation support for ipv4 fanouts.")
Signed-off-by: Edward Hyunkoo Jee <edjee@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Jerry Chu <hkchu@google.com>
---
 net/ipv4/ip_fragment.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a50dc6d408d1..31f71b15cfba 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -351,7 +351,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	ihl = ip_hdrlen(skb);
 
 	/* Determine the position of this fragment. */
-	end = offset + skb->len - ihl;
+	end = offset + skb->len - skb_network_offset(skb) - ihl;
 	err = -EINVAL;
 
 	/* Is this the final fragment? */
@@ -381,7 +381,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		goto err;
 
 	err = -ENOMEM;
-	if (!pskb_pull(skb, ihl))
+	if (!pskb_pull(skb, skb_network_offset(skb) + ihl))
 		goto err;
 
 	err = pskb_trim_rcsum(skb, end - offset);
@@ -641,6 +641,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		iph->frag_off = 0;
 	}
 
+	ip_send_check(iph);
+
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	qp->q.fragments_tail = NULL;
