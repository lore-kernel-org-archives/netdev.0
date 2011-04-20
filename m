From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH BUG-FIX] ipv6: udp: fix the wrong headroom check
Date: Wed, 20 Apr 2011 16:52:49 +0800
Message-ID: <4DAE9EE1.1050405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: kuznet@ms2.inr.ac.ru, David Miller <davem@davemloft.net>,
	pekkas@netcore.fi, jmorris@namei.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, Patrick McHa
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52093 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752827Ab1DTI4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 04:56:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point, skb->data points to skb_transport_header.
So, headroom check is wrong. 

For some case:bridge(UFO is on) + eth device(UFO is off),
there is no enough headroom for IPv6 frag head.
But headroom check is always false.

This will bring about data be moved to there prior to skb->head,
when adding IPv6 frag header to skb.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/udp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 15c3774..9e305d7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1335,7 +1335,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u32 features)
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Check if there is enough headroom to insert fragment header. */
-	if ((skb_headroom(skb) < frag_hdr_sz) &&
+	if ((skb_mac_header(skb) < skb->head + frag_hdr_sz) &&
 	    pskb_expand_head(skb, frag_hdr_sz, 0, GFP_ATOMIC))
 		goto out;
 
-- 
1.6.3.3
 
