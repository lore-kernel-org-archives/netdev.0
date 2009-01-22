From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Fri, 23 Jan 2009 10:21:32 +1100
Message-ID: <20090122232131.GA22771@gondor.apana.org.au>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de, michaelc@cs.wisc.edu,
	"David S. Miller" <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47136 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754688AbZAVXVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 18:21:39 -0500
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 12:55:21PM -0800, Brandeburg, Jesse wrote:
> I've filed this bugzilla a while ago.
> http://bugzilla.kernel.org/show_bug.cgi?id=11804
> now other customers are becoming interested as well

Does this patch help?

net: Fix frag_list handling in skb_seq_read

The frag_list handling was broken ini skb_seq_read:

1) We didn't add the stepped offset when looking at the head
are of fragments other than the first.

2) The frag index wasn't reset.

This patch fixes both issues.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d7efaf9..ae03c7f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2215,7 +2215,7 @@ unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
 		return 0;
 
 next_skb:
-	block_limit = skb_headlen(st->cur_skb);
+	block_limit = skb_headlen(st->cur_skb) + st->stepped_offset;
 
 	if (abs_offset < block_limit) {
 		*data = st->cur_skb->data + abs_offset;
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
