From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Tue, 27 Jan 2009 09:30:22 +1100
Message-ID: <20090126223022.GA24046@gondor.apana.org.au>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com> <20090122232131.GA22771@gondor.apana.org.au> <4979097B.4040108@cs.wisc.edu> <20090125.213222.192571170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michaelc@cs.wisc.edu, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51462 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751497AbZAZWag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 17:30:36 -0500
Content-Disposition: inline
In-Reply-To: <20090125.213222.192571170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 25, 2009 at 09:32:22PM -0800, David Miller wrote:
> From: Mike Christie <michaelc@cs.wisc.edu>
> Date: Thu, 22 Jan 2009 18:04:11 -0600
> 
> > With the patch running against linus's git tree, my box locks
> > up. You cannot ping it. I do not get a oops or anything in the logs,
> > and the keyboard does not respond. I will try to get some oops
> > output and more info.
> 
> Herbert, any idea offhand?

Yeah, I missed an offset update in there :) Here's a better version.

net: Fix frag_list handling in skb_seq_read

The frag_list handling was broken in skb_seq_read:

1) We didn't add the stepped offset when looking at the head
are of fragments other than the first.

2) We didn't take the stepped offset away when setting the data
pointer in the head area.

3) The frag index wasn't reset.

This patch fixes both issues.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d7efaf9..d4d0e31 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2215,10 +2215,10 @@ unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
 		return 0;
 
 next_skb:
-	block_limit = skb_headlen(st->cur_skb);
+	block_limit = skb_headlen(st->cur_skb) + st->stepped_offset;
 
 	if (abs_offset < block_limit) {
-		*data = st->cur_skb->data + abs_offset;
+		*data = st->cur_skb->data + (abs_offset - st->stepped_offset);
 		return block_limit - abs_offset;
 	}
 
@@ -2260,6 +2260,7 @@ next_skb:
 	} else if (st->root_skb == st->cur_skb &&
 		   skb_shinfo(st->root_skb)->frag_list) {
 		st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
+		st->frag_idx = 0;
 		goto next_skb;
 	}
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
