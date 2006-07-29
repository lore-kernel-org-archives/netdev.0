From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 8/23] [PATCH] [XFRM] STATE: Add a hook to obtain local/remote outbound address.
Date: Sat, 29 Jul 2006 18:30:25 +0900
Message-ID: <115416542536-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:19075 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1751424AbWG2Ja0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:26 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Outbound transformation replaces both source and destination address with
state's end-point addresses at the same time when IPsec tunnel mode.
It is also required to change them for Mobile IPv6 route optimization, but we
should care about the following differences:
 - changing result is not end-point but care-of address
 - either source or destination is replaced for each state
This hook is a common platform to change outbound address.
Based on MIPL2 kernel patch.
---
 include/net/xfrm.h      |    2 ++
 net/ipv6/xfrm6_policy.c |    8 ++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bcda8c0..e14ae3c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -271,6 +271,8 @@ struct xfrm_type
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
 	int			(*place_find)(struct xfrm_state *, struct sk_buff *, u8 **);
+	xfrm_address_t		*(*local_addr)(struct xfrm_state *, xfrm_address_t *);
+	xfrm_address_t		*(*remote_addr)(struct xfrm_state *, xfrm_address_t *);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_max_size)(struct xfrm_state *, int size);
 };
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 1d8489b..28bc272 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -118,8 +118,12 @@ __xfrm6_bundle_create(struct xfrm_policy
 		dst1->next = dst_prev;
 		dst_prev = dst1;
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			remote = (struct in6_addr*)&xfrm[i]->id.daddr;
-			local  = (struct in6_addr*)&xfrm[i]->props.saddr;
+			remote = (xfrm[i]->type->remote_addr) ?
+				(struct in6_addr*)xfrm[i]->type->remote_addr(xfrm[i], (xfrm_address_t *)remote):
+				(struct in6_addr*)&xfrm[i]->id.daddr;
+			local  = (xfrm[i]->type->local_addr) ?
+				(struct in6_addr*)xfrm[i]->type->local_addr(xfrm[i], (xfrm_address_t *)local):
+				(struct in6_addr*)&xfrm[i]->props.saddr;
 			tunnel = 1;
 		}
 		header_len += xfrm[i]->props.header_len;
-- 
1.4.1

