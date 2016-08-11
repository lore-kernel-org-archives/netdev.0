From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] ipv6: suppress sparse warnings in IP6_ECN_set_ce()
Date: Thu, 11 Aug 2016 12:04:43 +0200
Message-ID: <1470909883-5463-1-git-send-email-johannes@sipsolutions.net>
Cc: Eric Dumazet <edumazet@google.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51852 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbcHKKEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2016 06:04:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Use the correct type for these manipulations, which is __wsum,
instead of using __be32. This doesn't really change anything
since __wsum really *is* __be32, but removes the address space
warnings from sparse.

Cc: Eric Dumazet <edumazet@google.com>
Fixes: 34ae6a1aa054 ("ipv6: update skb->csum when CE mark is propagated")
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/inet_ecn.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 0dc0a51da38f..89aa4e73fc37 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -119,14 +119,14 @@ struct ipv6hdr;
  */
 static inline int IP6_ECN_set_ce(struct sk_buff *skb, struct ipv6hdr *iph)
 {
-	__be32 from, to;
+	__wsum from, to;
 
 	if (INET_ECN_is_not_ect(ipv6_get_dsfield(iph)))
 		return 0;
 
-	from = *(__be32 *)iph;
-	to = from | htonl(INET_ECN_CE << 20);
-	*(__be32 *)iph = to;
+	from = *(__wsum *)iph;
+	to = from | (__force __wsum)htonl(INET_ECN_CE << 20);
+	*(__wsum *)iph = to;
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_add(csum_sub(skb->csum, from), to);
 	return 1;
-- 
2.8.1
