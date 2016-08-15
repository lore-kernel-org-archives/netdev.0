From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] xfrm: Only add l3mdev oif to dst lookups
Date: Sun, 14 Aug 2016 19:52:56 -0700
Message-ID: <1471229576-29981-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35094 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbcHOCxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 22:53:03 -0400
Received: by mail-pa0-f41.google.com with SMTP id i5so12624065pat.2
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 19:53:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subash reported that commit 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
broke a wifi use case that uses fib rules and xfrms. The intent of
42a7b32b73d6 was driven by VRFs with IPsec. As a compromise relax the
use of oif in xfrm lookups to L3 master devices only (ie., oif is either
an L3 master device or is enslaved to a master device).

Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/xfrm4_policy.c | 2 +-
 net/ipv6/xfrm6_policy.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index b644a23c3db0..41f5b504a782 100644
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
index 6cc97003e4a9..70a86adad875 100644
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
2.1.4
