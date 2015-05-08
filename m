From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] Revert "ipv6: Allow for partial checksums on non-ufo
 packets"
Date: Fri, 08 May 2015 15:22:45 -0700
Message-ID: <1431123765.22756.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de>
	 <1431002384.22756.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <12346713.ZyFExCo3ux@h2o.as.studentenwerk.mhn.de>
	 <2088438.42IY8hjjd5@h2o.as.studentenwerk.mhn.de>
	 <1431122268.22756.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37060 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbbEHWWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 18:22:47 -0400
Received: by igbsb11 with SMTP id sb11so33236615igb.0
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 15:22:46 -0700 (PDT)
In-Reply-To: <1431122268.22756.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Wolfgang Walter reported crashes using traceroute6, root caused to this
commit.

UDP packets can be sent from RAW sockets.

Note that the faulty commit addressed a non problem, as normal
UDP v6 packets use udp_v6_send_skb() which correctly setup
CHECKSUM_PARTIAL properly if device has the correct feature.

It seems not worth trying to 'fix' the raw path.

Fixes: 32dce968dd98 ("ipv6: Allow for partial checksums on non-ufo packets")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Wolfgang Walter <linux@stwm.de>
Cc: Vlad Yasevich <vyasevich@gmail.com>
---
 net/ipv6/ip6_output.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7fde1f265c90..1fe5c687328e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1218,7 +1218,6 @@ static int __ip6_append_data(struct sock *sk,
 	u32 tskey = 0;
 	struct rt6_info *rt = (struct rt6_info *)cork->dst;
 	struct ipv6_txoptions *opt = v6_cork->opt;
-	int csummode = CHECKSUM_NONE;
 
 	skb = skb_peek_tail(queue);
 	if (!skb) {
@@ -1275,14 +1274,6 @@ emsgsize:
 			tskey = sk->sk_tskey++;
 	}
 
-	/* If this is the first and only packet and device
-	 * supports checksum offloading, let's use it.
-	 */
-	if (!skb && sk->sk_protocol == IPPROTO_UDP &&
-	    length + fragheaderlen < mtu &&
-	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
-	    !exthdrlen)
-		csummode = CHECKSUM_PARTIAL;
 	/*
 	 * Let's try using as much space as possible.
 	 * Use MTU if total length of the message fits into the MTU.
@@ -1396,7 +1387,7 @@ alloc_new_skb:
 			 *	Fill in the control structures
 			 */
 			skb->protocol = htons(ETH_P_IPV6);
-			skb->ip_summed = csummode;
+			skb->ip_summed = CHECKSUM_NONE;
 			skb->csum = 0;
 			/* reserve for fragmentation and ipsec header */
 			skb_reserve(skb, hh_len + sizeof(struct frag_hdr) +
