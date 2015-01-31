From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 6/6] ipv6: Allow for partial checksums on non-ufo packets
Date: Sat, 31 Jan 2015 10:40:18 -0500
Message-ID: <1422718818-21093-7-git-send-email-vyasevic@redhat.com>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:47017 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978AbbAaPl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 10:41:27 -0500
Received: by mail-qa0-f52.google.com with SMTP id x12so23881450qac.11
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 07:41:26 -0800 (PST)
In-Reply-To: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currntly, if we are not doing UFO on the packet, all UDP
packets will start with CHECKSUM_NONE and thus perform full
checksum computations in software even if device support
IPv6 checksum offloading.

Let's start start with CHECKSUM_PARTIAL if the device
supports it and we are sending only a single packet at
or below mtu size.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/ipv6/ip6_output.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b89d3c2..1a036f3 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1227,6 +1227,7 @@ static int __ip6_append_data(struct sock *sk,
 	u32 tskey = 0;
 	struct rt6_info *rt = (struct rt6_info *)cork->dst;
 	struct ipv6_txoptions *opt = v6_cork->opt;
+	int csummode = CHECKSUM_NONE;
 
 	skb = skb_peek_tail(queue);
 	if (!skb) {
@@ -1283,6 +1284,14 @@ emsgsize:
 			tskey = sk->sk_tskey++;
 	}
 
+	/* If this is the first and only packet and device
+	 * supports checksum offloading, let's use it.
+	 */
+	if (!skb &&
+	    length + fragheaderlen < mtu &&
+	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
+	    !exthdrlen)
+		csummode = CHECKSUM_PARTIAL;
 	/*
 	 * Let's try using as much space as possible.
 	 * Use MTU if total length of the message fits into the MTU.
@@ -1395,7 +1404,7 @@ alloc_new_skb:
 			 *	Fill in the control structures
 			 */
 			skb->protocol = htons(ETH_P_IPV6);
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = csummode;
 			skb->csum = 0;
 			/* reserve for fragmentation and ipsec header */
 			skb_reserve(skb, hh_len + sizeof(struct frag_hdr) +
-- 
1.9.3
