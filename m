From: Edward Jee <edjee@google.com>
Subject: [PATCH] inet: frags: fix defragmented packet's IP header for af_packet
Date: Thu, 16 Jul 2015 01:54:41 -0700
Message-ID: <1437036881-708-1-git-send-email-edjee@google.com>
Cc: willemb@google.com, edumazet@google.com, hkchu@google.com,
	netdev@vger.kernel.org, Edward Jee <edjee@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37573 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589AbbGPIzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:55:11 -0400
Received: by igbpg9 with SMTP id pg9so8610957igb.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:55:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ip_frag_queue() computes positions, it assumes that the passed
sk_buff does not contain L2 headers. However, when
PACKET_FANOUT_FLAG_DEFRAG is used, IP defragmentation functions can be
called on outgoing packets that contain L2 headers. Also, IPv4
checksum is not corrected after defragmentation.

Fixes: 7736d33f4262 ("packet: Add pre-defragmentation support for ipv4 fanouts.")
Signed-off-by: Edward Hyunkoo Jee <edjee@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Jerry Chu <hkchu@google.com>
---
 net/ipv4/ip_fragment.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a50dc6d..44c8f2a 100644
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
 
+	ip_send_check(ip_hdr(skb));
+
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	qp->q.fragments_tail = NULL;
-- 
2.4.3.573.g4eafbef
