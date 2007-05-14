From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Don't warn if high-order hash resize fails
Date: Mon, 14 May 2007 17:39:41 +1000
Message-ID: <20070514073941.GA24722@gondor.apana.org.au>
References: <20070514054837.GA18879@gondor.apana.org.au> <20070513.233635.28398106.davem@davemloft.net> <20070514070733.GA23173@gondor.apana.org.au> <20070514072657.GA24412@gondor.apana.org.au> <20070514072755.GB24412@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1514 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756490AbXENHjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 03:39:46 -0400
Content-Disposition: inline
In-Reply-To: <20070514072755.GB24412@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2007 at 05:27:55PM +1000, Herbert Xu wrote:
> 
> In fact that's a clue.  If you add them all up they come out at the
> same value.  So we're getting the directions mixed up...

Found the problem.  It was my own fault in a way :)

[IPSEC]: Check validity of direction in xfrm_policy_byid

The function xfrm_policy_byid takes a dir argument but finds the policy
using the index instead.  We only use the dir argument to update the
policy count for that direction.  Since the user can supply any value
for dir, this can corrupt our policy count.

I know this is the problem because a few days ago I was deleting
policies by hand using indicies and accidentally typed in the wrong
direction.  It still deleted the policy and at the time I thought
that was cool.  In retrospect it isn't such a good idea :)

I decided against letting it delete the policy anyway just in case
we ever remove the connection between indicies and direction.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 95271e8..d0882e5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -796,6 +796,10 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 	struct hlist_head *chain;
 	struct hlist_node *entry;
 
+	*err = -ENOENT;
+	if (xfrm_policy_id2dir(id) != dir)
+		return NULL;
+
 	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
 	chain = xfrm_policy_byidx + idx_hash(id);
