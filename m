From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: passthrough openswan connection not working with 2.6.19.2
Date: Wed, 17 Jan 2007 13:35:01 +1100
Message-ID: <20070117023501.GA23015@gondor.apana.org.au>
References: <BAY103-DAV4EF774BDC46293F57EA4DB2B40@phx.gbl> <E1H6vOb-0005Nr-00@gondolin.me.apana.org.au> <20070116.170719.74742439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pupilla@hotmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1568 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751779AbXAQCfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 21:35:11 -0500
To: David Miller <davem@davemloft.net>, stable@kernel.org
Content-Disposition: inline
In-Reply-To: <20070116.170719.74742439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 16, 2007 at 05:07:19PM -0800, David Miller wrote:
> 
> Good catch Herbert, patch applied, thanks.

Thanks Dave.  I think we need this for 2.6.19 too.

[IPSEC]: Policy list disorder

The recent hashing introduced an off-by-one bug in policy list insertion.
Instead of adding after the last entry with a lesser or equal priority,
we're adding after the successor of that entry.

This patch fixes this and also adds a warning if we detect a duplicate
entry in the policy list.  This should never happen due to this if clause.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index bebd40e..b7e537f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -650,19 +650,18 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct xfrm_policy *pol;
 	struct xfrm_policy *delpol;
 	struct hlist_head *chain;
-	struct hlist_node *entry, *newpos, *last;
+	struct hlist_node *entry, *newpos;
 	struct dst_entry *gc_list;
 
 	write_lock_bh(&xfrm_policy_lock);
 	chain = policy_hash_bysel(&policy->selector, policy->family, dir);
 	delpol = NULL;
 	newpos = NULL;
-	last = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
-		if (!delpol &&
-		    pol->type == policy->type &&
+		if (pol->type == policy->type &&
 		    !selector_cmp(&pol->selector, &policy->selector) &&
-		    xfrm_sec_ctx_match(pol->security, policy->security)) {
+		    xfrm_sec_ctx_match(pol->security, policy->security) &&
+		    !WARN_ON(delpol)) {
 			if (excl) {
 				write_unlock_bh(&xfrm_policy_lock);
 				return -EEXIST;
@@ -671,17 +670,12 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 			if (policy->priority > pol->priority)
 				continue;
 		} else if (policy->priority >= pol->priority) {
-			last = &pol->bydst;
+			newpos = &pol->bydst;
 			continue;
 		}
-		if (!newpos)
-			newpos = &pol->bydst;
 		if (delpol)
 			break;
-		last = &pol->bydst;
 	}
-	if (!newpos)
-		newpos = last;
 	if (newpos)
 		hlist_add_after(newpos, &policy->bydst);
 	else

