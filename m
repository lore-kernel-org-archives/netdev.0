From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 13/24] [IPSEC]: Move x->outer_mode->output out of locked section
Date: Tue, 13 Nov 2007 19:51:19 +0800
Message-ID: <20071113115119.GA1086@gondor.apana.org.au>
References: <E1Ipla1-0001Hb-00@gondolin.me.apana.org.au> <200711071717.43429.netdev@axxeo.de> <20071108003903.GA11963@gondor.apana.org.au> <20071113.033348.13935138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@axxeo.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1459 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753981AbXKMLvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:51:32 -0500
Content-Disposition: inline
In-Reply-To: <20071113.033348.13935138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 03:33:48AM -0800, David Miller wrote:
>
> Make 'lastused' an 'unsigned long' (that's all that get_seconds()
> gives to us anyways), fix up the nla_total_size(x->lastused) thing in
> net/xfrm/xfrm_user.c, and then you can remove this lock acquisition
> completely because the store into x->lastused will now be atomic and
> therefore locks aren't protecting anything.

Brilliant, make that patch 25/25 :)

[IPSEC]: Make x->lastused an unsigned long

Currently x->lastused is u64 which means that it cannot be read/written
atomically on all architectures.  David Miller observed that the value
stored in it is only an unsigned long which is always atomic.

So based on his suggestion this patch changes the internal representation
from u64 to unsigned long while the user-interface still refers to it as
u64.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h       |    2 +-
 net/ipv6/xfrm6_mode_ro.c |    2 --
 net/xfrm/xfrm_user.c     |    4 ++--
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 944fdad..e184c11 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -183,7 +183,7 @@ struct xfrm_state
 	struct timer_list	timer;
 
 	/* Last used time */
-	u64			lastused;
+	unsigned long		lastused;
 
 	/* Reference to data common to all the instances of this
 	 * transformer. */
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 4a01cb3..63d5d49 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -54,9 +54,7 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	__skb_pull(skb, hdr_len);
 	memmove(ipv6_hdr(skb), iph, hdr_len);
 
-	spin_lock_bh(&x->lock);
 	x->lastused = get_seconds();
-	spin_unlock_bh(&x->lock);
 
 	return 0;
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d41588d..02cf26f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1993,8 +1993,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 	if (x->coaddr)
 		l += nla_total_size(sizeof(*x->coaddr));
 
-	/* Must count this as this may become non-zero behind our back. */
-	l += nla_total_size(sizeof(x->lastused));
+	/* Must count x->lastused as it may become non-zero behind our back. */
+	l += nla_total_size(sizeof(u64));
 
 	return l;
 }

-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
