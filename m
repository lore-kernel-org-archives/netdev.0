From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 17:43:34 +0300
Message-ID: <20111122144334.GA22824@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61370 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab1KVOnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 09:43:42 -0500
Received: by bke11 with SMTP id 11so279970bke.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 06:43:40 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current addr_match() is errh, under-optimized.

Compiler doesn't know that memcmp() branch doesn't trigger for IPv4.
Pass addresses by value.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h     |   10 ++++++++++
 net/xfrm/xfrm_policy.c |    4 ++--
 2 files changed, 12 insertions(+), 2 deletions(-)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -827,6 +827,16 @@ static inline bool addr_match(const void *token1, const void *token2,
 	return true;
 }
 
+static inline int addr4_match(const __be32 a1, const __be32 a2, const u8 prefixlen)
+{
+	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
+	if (prefixlen == 0) {
+		/* Matching constants result in smaller assembly. */
+		return 0xFFFFFFFFu;
+	}
+	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
+}
+
 static __inline__
 __be16 xfrm_flowi_sport(const struct flowi *fl, const union flowi_uli *uli)
 {
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -61,8 +61,8 @@ __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	const struct flowi4 *fl4 = &fl->u.ip4;
 
-	return  addr_match(&fl4->daddr, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(&fl4->saddr, &sel->saddr, sel->prefixlen_s) &&
+	return  addr4_match(fl4->daddr, sel->daddr.a4, sel->prefixlen_d) &&
+		addr4_match(fl4->saddr, sel->saddr.a4, sel->prefixlen_s) &&
 		!((xfrm_flowi_dport(fl, &fl4->uli) ^ sel->dport) & sel->dport_mask) &&
 		!((xfrm_flowi_sport(fl, &fl4->uli) ^ sel->sport) & sel->sport_mask) &&
 		(fl4->flowi4_proto == sel->proto || !sel->proto) &&
