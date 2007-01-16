From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: passthrough openswan connection not working with 2.6.19.2
Date: Wed, 17 Jan 2007 07:59:05 +1100
Message-ID: <E1H6vOb-0005Nr-00@gondolin.me.apana.org.au>
References: <BAY103-DAV4EF774BDC46293F57EA4DB2B40@phx.gbl>
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3636 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751640AbXAPU7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 15:59:16 -0500
To: pupilla@hotmail.com (Marco Berizzi)
In-Reply-To: <BAY103-DAV4EF774BDC46293F57EA4DB2B40@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi <pupilla@hotmail.com> wrote:
> Yesterday I have updated to linux 2.6.19.2
> (from 2.6.19.1) and passthrough openswan
> connection aren't working anymore.
> This is the 'ip -s x s' output:

I presume you mean ip -s x p :)

> src 10.180.0.0/16 dst 172.16.0.0/23 uid 0
> dir in action allow index 208 priority 2384 ptype main share any flag
> 0x00000000
> lifetime config:
>   limit: soft (INF)(bytes), hard (INF)(bytes)
>   limit: soft (INF)(packets), hard (INF)(packets)
>   expire add: soft 0(sec), hard 0(sec)
>   expire use: soft 0(sec), hard 0(sec)
> lifetime current:
>   0(bytes), 0(packets)
>   add 2007-01-16 03:20:30 use 2007-01-16 16:48:47

...
 
> Apparently the passthrough connection
> is correctly displayed by 'ip -s x s',
> but packets from 172.16.0.0/23 to
> 10.180.0.0/16 are eaten by this ipsec
> policy:
> 
> src 10.0.0.0/8 dst 172.16.0.0/23 uid 0
> dir in action allow index 344 priority 2392 ptype main share any flag
> 0x00000000
> lifetime config:
>   limit: soft (INF)(bytes), hard (INF)(bytes)
>   limit: soft (INF)(packets), hard (INF)(packets)
>   expire add: soft 0(sec), hard 0(sec)
>   expire use: soft 0(sec), hard 0(sec)
> lifetime current:
>   0(bytes), 0(packets)
>   add 2007-01-16 03:20:34 use 2007-01-16 16:17:15
> tmpl src milano dst venessia
>  proto comp spi 0x00000000(0) reqid 16430(0x0000402e) mode tunnel
>  level use share any
>  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
> tmpl src 0.0.0.0 dst 0.0.0.0
>  proto esp spi 0x00000000(0) reqid 16429(0x0000402d) mode transport
>  level required share any
>  enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

Nasty.  This means that the policy list is no longer sorted by priority.
Can you please try this patch and let me know if it fixes the problem?

[IPSEC]: Policy list disorder

The recent hashing introduced an off-by-one bug in policy list insertion.
Instead of adding after the last entry with a lesser or equal priority,
we're adding after the successor of that entry.

This patch fixes this and also adds a warning if we detect a duplicate
entry in the policy list.  This should never happen due to this if clause.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
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
