From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Avoid copying TCP packets unnecessarily
Date: Mon, 15 Oct 2007 13:54:57 +0800
Message-ID: <20071015055457.GA28799@gondor.apana.org.au>
References: <20071006141506.785a6683@localhost.localdomain> <20071014192640.35065e73@inria.fr> <20071014222037.7fa28640@inria.fr> <20071015045723.GA28388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Guillaume Chazarain <guichaz@yahoo.fr>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1081 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753131AbXJOFzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 01:55:10 -0400
Content-Disposition: inline
In-Reply-To: <20071015045723.GA28388@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 12:57:23PM +0800, Herbert Xu wrote:
> 
> However, the fact that you're triggering this code at all tells
> us that there is another bug further up the chain that's causing
> us to generate partial checksums even though the NIC doesn't
> support it.  Can you please give me the output of

Nevermind, tcp_fragment can generate such packets out of
convenience.

Here's a little optimisation to avoid copying the packet in
this case.

[NET]: Avoid copying TCP packets unnecessarily

TCP packets all have writable heads, that is, even though it's cloned, it is
writable up to the end of the TCP header.  This patch makes skb_checksum_help
aware of this fact by using skb_clone_writable and avoiding a copy for TCP.

I've also modified the BUG_ON tests to be unsigned.  The only case where this
makes a difference is if csum_start points to a location before skb->data.
Since skb->data should always include the header where the checksum field
is (and all currently callers adhere to that), this change is safe and may
uncover bugs later.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/dev.c |   21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ab15c11..af75bfd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1355,22 +1355,21 @@ int skb_checksum_help(struct sk_buff *skb)
 		goto out_set_summed;
 	}
 
-	if (skb_cloned(skb)) {
+	offset = skb->csum_start - skb_headroom(skb);
+	BUG_ON(offset >= skb_headlen(skb));
+	csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+	offset += skb->csum_offset;
+	BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
+
+	if (skb_cloned(skb) &&
+	    !skb_clone_writable(skb, offset + sizeof(__sum16))) {
 		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 		if (ret)
 			goto out;
 	}
 
-	offset = skb->csum_start - skb_headroom(skb);
-	BUG_ON(offset > (int)skb->len);
-	csum = skb_checksum(skb, offset, skb->len-offset, 0);
-
-	offset = skb_headlen(skb) - offset;
-	BUG_ON(offset <= 0);
-	BUG_ON(skb->csum_offset + 2 > offset);
-
-	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) =
-		csum_fold(csum);
+	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
 out_set_summed:
 	skb->ip_summed = CHECKSUM_NONE;
 out:

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
