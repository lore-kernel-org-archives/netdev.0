From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] ipv4: use l4 hash for locally generated multipath flows
Date: Wed, 28 Oct 2015 18:39:34 +0100
Message-ID: <006ec2edb2d592ab9b90ccc5c084ac8926e811df.1446053264.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, pch@ordbogen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832AbbJ1RkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 13:40:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes how the multipath hash is computed for locally
generated UDP or TCP flows: now the hash comprises also l4 information
(source and destination port).

This allows better utilization of the available paths when the existing
flows have the same source IP and the same destination IP: with l3 hash,
even when multiple connections are in place simultaneously, a single path
will be used, while with l4 hash we can use all the available paths.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/ip_fib.h     | 12 ++++++++++++
 net/ipv4/fib_semantics.c |  3 ++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ac5c6e8..56bf68c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -328,6 +328,18 @@ static inline int fib_multipath_hash(__be32 saddr, __be32 daddr)
 	return jhash_2words(saddr, daddr, fib_multipath_secret) >> 1;
 }
 
+static inline int fib_multipath_output_hash(const struct flowi4 *fl4)
+{
+	if ((fl4->flowi4_proto == IPPROTO_TCP) ||
+	    (fl4->flowi4_proto == IPPROTO_UDP))
+		return jhash_3words(fl4->saddr, fl4->daddr,
+				    *((__u32 *)&fl4->uli.ports),
+				    fib_multipath_secret) >> 1;
+
+	return jhash_2words(fl4->saddr, fl4->daddr, fib_multipath_secret) >> 1;
+}
+
+
 void fib_select_multipath(struct fib_result *res, int hash);
 void fib_select_path(struct net *net, struct fib_result *res,
 		     struct flowi4 *fl4, int mp_hash);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 42778d9..8a18349 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1564,7 +1564,8 @@ void fib_select_path(struct net *net, struct fib_result *res,
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi->fib_nhs > 1 && fl4->flowi4_oif == 0) {
 		if (mp_hash < 0)
-			mp_hash = fib_multipath_hash(fl4->saddr, fl4->daddr);
+			mp_hash = fib_multipath_output_hash(fl4);
+
 		fib_select_multipath(res, mp_hash);
 	}
 	else
-- 
1.8.3.1
