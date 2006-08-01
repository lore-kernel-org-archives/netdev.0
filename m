From: David Miller <davem@davemloft.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
 2.6.18-rc3
Date: Tue, 01 Aug 2006 00:00:59 -0700 (PDT)
Message-ID: <20060801.000059.57444384.davem@davemloft.net>
References: <44CDDDF7.70004@trash.net>
	<20060731113050.GA25972@gondor.apana.org.au>
	<44CE4DCA.8000609@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55463
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932447AbWHAHBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:01:43 -0400
To: kaber@trash.net
In-Reply-To: <44CE4DCA.8000609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 31 Jul 2006 20:36:58 +0200

> Herbert Xu wrote:
> > So I'd rather see a patch to disable the warnings for 2.6.18 so that
> > the proper fix can be tested more thoroughly.  We should remember that
> > the 2.6.18 minus the warning is still going to be heaps better in this
> > regard compared to 2.6.17 where all TSO packets were essentially
> > discarded due to the incorrect checksum (when the NAT module is loaded).
> 
> I'm fine either way.

I'm going to kill the warning for 2.6.18, using the patch below.
We can queue up Patrick's changes for 2.6.19, just give me the
word and I'll apply it to net-2.6.19

commit 9133d3d0619e637f2e05bf574af4b7a16319e3ca
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Aug 1 00:00:12 2006 -0700

    [NET]: Kill the WARN_ON() calls for checksum fixups.
    
    We have a more complete solution in the works, involving
    the seperation of CHECKSUM_HW on input vs. output, and
    having netfilter properly do incremental checksums.
    
    But that is a very involved patch and is thus 2.6.19
    material.
    
    What we have now is infinitely better than the past,
    wherein all TSO packets were dropped due to corrupt
    checksums as soon at the NAT module was loaded.  At
    least now, the checksums do get fixed up, it just
    isn't the cleanest nor most optimal solution.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 4d2b516..5b630ce 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1166,11 +1166,6 @@ int skb_checksum_help(struct sk_buff *sk
 		goto out_set_summed;
 
 	if (unlikely(skb_shinfo(skb)->gso_size)) {
-		static int warned;
-
-		WARN_ON(!warned);
-		warned = 1;
-
 		/* Let GSO fix up the checksum. */
 		goto out_set_summed;
 	}
@@ -1220,11 +1215,6 @@ struct sk_buff *skb_gso_segment(struct s
 	__skb_pull(skb, skb->mac_len);
 
 	if (unlikely(skb->ip_summed != CHECKSUM_HW)) {
-		static int warned;
-
-		WARN_ON(!warned);
-		warned = 1;
-
 		if (skb_header_cloned(skb) &&
 		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 			return ERR_PTR(err);
