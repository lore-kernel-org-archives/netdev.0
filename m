From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 12/44] [XFRM] STATE: Add a hook to obtain local/remote outbound address.
Date: Thu, 24 Aug 2006 00:02:13 +0900
Message-ID: <1156345366288-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:63624 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964925AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <11563453651452-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Outbound transformation replaces both source and destination address with
state's end-point addresses at the same time when IPsec tunnel mode.
It is also required to change them for Mobile IPv6 route optimization, but we
should care about the following differences:
 - changing result is not end-point but care-of address
 - either source or destination is replaced for each state
This hook is a common platform to change outbound address.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h      |    2 ++
 net/ipv6/xfrm6_policy.c |   20 ++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6d0dafb..cbfacdb 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -267,6 +267,8 @@ struct xfrm_type
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
 	int			(*hdr_offset)(struct xfrm_state *, struct sk_buff *, u8 **);
+	xfrm_address_t		*(*local_addr)(struct xfrm_state *, xfrm_address_t *);
+	xfrm_address_t		*(*remote_addr)(struct xfrm_state *, xfrm_address_t *);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_max_size)(struct xfrm_state *, int size);
 };
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 81355bb..9328fc8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -59,6 +59,22 @@ __xfrm6_find_bundle(struct flowi *fl, st
 	return dst;
 }
 
+static inline struct in6_addr*
+__xfrm6_bundle_addr_remote(struct xfrm_state *x, struct in6_addr *addr)
+{
+	return (x->type->remote_addr) ?
+		(struct in6_addr*)x->type->remote_addr(x, (xfrm_address_t *)addr) :
+		(struct in6_addr*)&x->id.daddr;
+}
+
+static inline struct in6_addr*
+__xfrm6_bundle_addr_local(struct xfrm_state *x, struct in6_addr *addr)
+{
+	return (x->type->local_addr) ?
+		(struct in6_addr*)x->type->local_addr(x, (xfrm_address_t *)addr) :
+		(struct in6_addr*)&x->props.saddr;
+}
+
 /* Allocate chain of dst_entry's, attach known xfrm's, calculate
  * all the metrics... Shortly, bundle a bundle.
  */
@@ -115,8 +131,8 @@ __xfrm6_bundle_create(struct xfrm_policy
 		dst1->next = dst_prev;
 		dst_prev = dst1;
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			remote = (struct in6_addr*)&xfrm[i]->id.daddr;
-			local  = (struct in6_addr*)&xfrm[i]->props.saddr;
+			remote = __xfrm6_bundle_addr_remote(xfrm[i], remote);
+			local  = __xfrm6_bundle_addr_local(xfrm[i], local);
 			tunnel = 1;
 		}
 		header_len += xfrm[i]->props.header_len;
-- 
1.4.0

