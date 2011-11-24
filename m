From: kaber@trash.net
Subject: [PATCH 12/18] net: core: add function for incremental IPv6 pseudo header checksum updates
Date: Thu, 24 Nov 2011 17:57:23 +0100
Message-ID: <1322153850-10533-13-git-send-email-kaber@trash.net>
References: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756708Ab1KXQ5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 11:57:37 -0500
In-Reply-To: <1322153850-10533-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add inet_proto_csum_replace16 for incrementally updating IPv6 pseudo header
checksums for IPv6 NAT.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/checksum.h |    3 +++
 net/core/utils.c       |   20 ++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index ba55d8b..600d1d7 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -109,6 +109,9 @@ static inline void csum_replace2(__sum16 *sum, __be16 from, __be16 to)
 struct sk_buff;
 extern void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 				     __be32 from, __be32 to, int pseudohdr);
+extern void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
+				      const __be32 *from, const __be32 *to,
+				      int pseudohdr);
 
 static inline void inet_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
 					    __be16 from, __be16 to,
diff --git a/net/core/utils.c b/net/core/utils.c
index 386e263..b09a73a 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -298,6 +298,26 @@ void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(inet_proto_csum_replace4);
 
+void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
+			       const __be32 *from, const __be32 *to,
+			       int pseudohdr)
+{
+	__be32 diff[] = {
+		~from[0], ~from[1], ~from[2], ~from[3],
+		to[0], to[1], to[2], to[3],
+	};
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		*sum = csum_fold(csum_partial(diff, sizeof(diff),
+				 ~csum_unfold(*sum)));
+		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
+			skb->csum = ~csum_partial(diff, sizeof(diff),
+						  ~skb->csum);
+	} else if (pseudohdr)
+		*sum = ~csum_fold(csum_partial(diff, sizeof(diff),
+				  csum_unfold(*sum)));
+}
+EXPORT_SYMBOL(inet_proto_csum_replace16);
+
 int mac_pton(const char *s, u8 *mac)
 {
 	int i;
-- 
1.7.1
