From: David Miller <davem@davemloft.net>
Subject: Re: [net:master 9/12] net/ipv6/ip6_offload.c:120:7-21: WARNING:
 Unsigned expression compared with zero: unfrag_ip6hlen < 0 (fwd)
Date: Wed, 17 May 2017 22:58:31 -0400 (EDT)
Message-ID: <20170517.225831.2041930111066229998.davem@davemloft.net>
References: <alpine.DEB.2.20.1705181000150.3833@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kraig@google.com, netdev@vger.kernel.org, kbuild-all@01.org
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753359AbdERC6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 22:58:33 -0400
In-Reply-To: <alpine.DEB.2.20.1705181000150.3833@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Thu, 18 May 2017 10:01:07 +0800 (SGT)

> It may be worth checking on these.  The code context is shown in the first
> case (line 120).  For the others, at least it gives the line numbers.
 ...
>>> net/ipv6/ip6_offload.c:120:7-21: WARNING: Unsigned expression compared with zero: unfrag_ip6hlen < 0
> --
>>> net/ipv6/ip6_output.c:601:5-9: WARNING: Unsigned expression compared with zero: hlen < 0
> --
>>> net/ipv6/udp_offload.c:94:6-20: WARNING: Unsigned expression compared with zero: unfrag_ip6hlen < 0

Sigh, this is worse than the bug the commit introducing these warnings
was trying to fix.

I've pushed the following:

====================
ipv6: Check ip6_find_1stfragopt() return value properly.

Do not use unsigned variables to see if it returns a negative
error or not.

Fixes: 2423496af35d ("ipv6: Prevent overrun when parsing v6 header options")
Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_offload.c | 9 ++++-----
 net/ipv6/ip6_output.c  | 7 +++----
 net/ipv6/udp_offload.c | 8 +++++---
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index eab36ab..280268f 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -63,7 +63,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	const struct net_offload *ops;
 	int proto;
 	struct frag_hdr *fptr;
-	unsigned int unfrag_ip6hlen;
 	unsigned int payload_len;
 	u8 *prevhdr;
 	int offset = 0;
@@ -116,10 +115,10 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		skb->network_header = (u8 *)ipv6h - skb->head;
 
 		if (udpfrag) {
-			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
-			if (unfrag_ip6hlen < 0)
-				return ERR_PTR(unfrag_ip6hlen);
-			fptr = (struct frag_hdr *)((u8 *)ipv6h + unfrag_ip6hlen);
+			int err = ip6_find_1stfragopt(skb, &prevhdr);
+			if (err < 0)
+				return ERR_PTR(err);
+			fptr = (struct frag_hdr *)((u8 *)ipv6h + err);
 			fptr->frag_off = htons(offset);
 			if (skb->next)
 				fptr->frag_off |= htons(IP6_MF);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 01deecd..d4a31be 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -597,11 +597,10 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	int ptr, offset = 0, err = 0;
 	u8 *prevhdr, nexthdr = 0;
 
-	hlen = ip6_find_1stfragopt(skb, &prevhdr);
-	if (hlen < 0) {
-		err = hlen;
+	err = ip6_find_1stfragopt(skb, &prevhdr);
+	if (err < 0)
 		goto fail;
-	}
+	hlen = err;
 	nexthdr = *prevhdr;
 
 	mtu = ip6_skb_dst_mtu(skb);
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index b348cff..a2267f8 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -29,6 +29,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 	u8 frag_hdr_sz = sizeof(struct frag_hdr);
 	__wsum csum;
 	int tnl_hlen;
+	int err;
 
 	mss = skb_shinfo(skb)->gso_size;
 	if (unlikely(skb->len <= mss))
@@ -90,9 +91,10 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		/* Find the unfragmentable header and shift it left by frag_hdr_sz
 		 * bytes to insert fragment header.
 		 */
-		unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
-		if (unfrag_ip6hlen < 0)
-			return ERR_PTR(unfrag_ip6hlen);
+		err = ip6_find_1stfragopt(skb, &prevhdr);
+		if (err < 0)
+			return ERR_PTR(err);
+		unfrag_ip6hlen = err;
 		nexthdr = *prevhdr;
 		*prevhdr = NEXTHDR_FRAGMENT;
 		unfrag_len = (skb_network_header(skb) - skb_mac_header(skb)) +
-- 
2.7.4
