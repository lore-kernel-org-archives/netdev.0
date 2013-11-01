From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] xfrm: Fix null pointer dereference when decoding sessions
Date: Fri,  1 Nov 2013 09:21:47 +0100
Message-ID: <1383294107-7509-4-git-send-email-steffen.klassert@secunet.com>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49483 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab3KAIVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 04:21:54 -0400
In-Reply-To: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some codepaths the skb does not have a dst entry
when xfrm_decode_session() is called. So check for
a valid skb_dst() before dereferencing the device
interface index. We use 0 as the device index if
there is no valid skb_dst(), or at reverse decoding
we use skb_iif as device interface index.

Bug was introduced with git commit bafd4bd4dc
("xfrm: Decode sessions with output interface.").

Reported-by: Meelis Roos <mroos@linux.ee>
Tested-by: Meelis Roos <mroos@linux.ee>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c |    6 +++++-
 net/ipv6/xfrm6_policy.c |    6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4764ee4..e1a6393 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -104,10 +104,14 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	const struct iphdr *iph = ip_hdr(skb);
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 	struct flowi4 *fl4 = &fl->u.ip4;
+	int oif = 0;
+
+	if (skb_dst(skb))
+		oif = skb_dst(skb)->dev->ifindex;
 
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
-	fl4->flowi4_oif = skb_dst(skb)->dev->ifindex;
+	fl4->flowi4_oif = reverse ? skb->skb_iif : oif;
 
 	if (!ip_is_fragment(iph)) {
 		switch (iph->protocol) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index dd503a3..5f8e128 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -135,10 +135,14 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	struct ipv6_opt_hdr *exthdr;
 	const unsigned char *nh = skb_network_header(skb);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
+	int oif = 0;
+
+	if (skb_dst(skb))
+		oif = skb_dst(skb)->dev->ifindex;
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
-	fl6->flowi6_oif = skb_dst(skb)->dev->ifindex;
+	fl6->flowi6_oif = reverse ? skb->skb_iif : oif;
 
 	fl6->daddr = reverse ? hdr->saddr : hdr->daddr;
 	fl6->saddr = reverse ? hdr->daddr : hdr->saddr;
-- 
1.7.9.5
