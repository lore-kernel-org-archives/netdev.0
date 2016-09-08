From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/6] xfrm: Only add l3mdev oif to dst lookups
Date: Thu, 8 Sep 2016 08:29:15 +0200
Message-ID: <1473316155-12186-7-git-send-email-steffen.klassert@secunet.com>
References: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35814 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753356AbcIHG33 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:29:29 -0400
In-Reply-To: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>

Subash reported that commit 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
broke a wifi use case that uses fib rules and xfrms. The intent of
42a7b32b73d6 was driven by VRFs with IPsec. As a compromise relax the
use of oif in xfrm lookups to L3 master devices only (ie., oif is either
an L3 master device or is enslaved to a master device).

Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c | 2 +-
 net/ipv6/xfrm6_policy.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 7b0edb3..e07ed8b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -29,7 +29,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->daddr = daddr->a4;
 	fl4->flowi4_tos = tos;
-	fl4->flowi4_oif = oif;
+	fl4->flowi4_oif = l3mdev_master_ifindex_by_index(net, oif);
 	if (saddr)
 		fl4->saddr = saddr->a4;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c074771..dd84ecd 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -36,7 +36,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 	int err;
 
 	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_oif = oif;
+	fl6.flowi6_oif = l3mdev_master_ifindex_by_index(net, oif);
 	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
 	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
 	if (saddr)
-- 
1.9.1
