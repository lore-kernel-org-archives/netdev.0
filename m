From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension
 headers sorting.
Date: Fri, 25 Aug 2006 03:16:51 -0700 (PDT)
Message-ID: <20060825.031651.88475974.davem@davemloft.net>
References: <20060824.045850.74749237.davem@davemloft.net>
	<44EE4ABC.6050604@linux-ipv6.org>
	<44EECBB0.7070001@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14547
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750944AbWHYKQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 06:16:50 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44EECBB0.7070001@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 25 Aug 2006 19:06:40 +0900

> I've found a problem about MIPv6 CN with the patch below.

We just need to search by priority in the inexact list, even
if we get a hit in the hash table.

The fix is trivial, please try this patch:

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 200e6e5..060f115 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -908,6 +908,7 @@ static struct xfrm_policy *xfrm_policy_l
 	xfrm_address_t *daddr, *saddr;
 	struct hlist_node *entry;
 	struct hlist_head *chain;
+	u32 priority = ~0U;
 
 	daddr = xfrm_flowi_daddr(fl, family);
 	saddr = xfrm_flowi_saddr(fl, family);
@@ -919,21 +920,21 @@ static struct xfrm_policy *xfrm_policy_l
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (xfrm_policy_match(pol, fl, type, family, dir)) {
-			xfrm_pol_hold(pol);
 			ret = pol;
+			priority = ret->priority;
 			break;
 		}
 	}
-	if (!ret) {
-		chain = &xfrm_policy_inexact[dir];
-		hlist_for_each_entry(pol, entry, chain, bydst) {
-			if (xfrm_policy_match(pol, fl, type, family, dir)) {
-				xfrm_pol_hold(pol);
-				ret = pol;
-				break;
-			}
+	chain = &xfrm_policy_inexact[dir];
+	hlist_for_each_entry(pol, entry, chain, bydst) {
+		if (xfrm_policy_match(pol, fl, type, family, dir) &&
+		    pol->priority < priority) {
+			ret = pol;
+			break;
 		}
 	}
+	if (ret)
+		xfrm_pol_hold(ret);
 	read_unlock_bh(&xfrm_policy_lock);
 
 	return ret;
