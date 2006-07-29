From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 7/23] [PATCH] [XFRM] STATE: Add a hook to find where to be inserted header in outbound.
Date: Sat, 29 Jul 2006 18:30:23 +0900
Message-ID: <11541654231584-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:18051 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1751404AbWG2JaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:24 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On current kernel, ip6_find_1stfragopt() is used by IPv6 IPsec to find where to
be inserted header in outbound. (BTW, no usage may be needed for IPv4 case.)
Mobile IPv6 requires other logic for routing header and destination
options header respectively.
Based on MIPL2 kernel patch.
---
 include/net/xfrm.h      |    1 +
 net/ipv6/xfrm6_output.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index aaef1c4..bcda8c0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -270,6 +270,7 @@ struct xfrm_type
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
+	int			(*place_find)(struct xfrm_state *, struct sk_buff *, u8 **);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_max_size)(struct xfrm_state *, int size);
 };
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 2736a54..8792b5c 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -48,7 +48,10 @@ static void xfrm6_encap(struct sk_buff *
 		u8 *prevhdr;
 		int hdr_len;
 
-		hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
+		if (x->type->place_find)
+			hdr_len = x->type->place_find(x, skb, &prevhdr);
+		else
+			hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
 		skb->nh.raw = prevhdr - x->props.header_len;
 		skb->h.raw = skb->data + hdr_len;
 		memmove(skb->data, iph, hdr_len);
-- 
1.4.1

