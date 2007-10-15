From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Fix csum_start update in pskb_expand_head
Date: Mon, 15 Oct 2007 12:57:23 +0800
Message-ID: <20071015045723.GA28388@gondor.apana.org.au>
References: <20071006141506.785a6683@localhost.localdomain> <20071014192640.35065e73@inria.fr> <20071014222037.7fa28640@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Guillaume Chazarain <guichaz@yahoo.fr>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4490 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751226AbXJOE53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 00:57:29 -0400
Content-Disposition: inline
In-Reply-To: <20071014222037.7fa28640@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 14, 2007 at 08:20:37PM +0000, Guillaume Chazarain wrote:
> 
> Just another data point, it seems that running the standard Bittorrent
> client helps triggering the bug.

Doh! It was my patch a month ago which added code to update
csum_start if the headroom changed that broke this.

We'll need this patch for stable as well.

[NET]: Fix csum_start update in pskb_expand_head

I got confused by the dual nature of the off variable in the
function pskb_expand_head.  The csum_start offset should use
nhead instead of off which can change depending on whether we
are using offsets or pointers.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

However, the fact that you're triggering this code at all tells
us that there is another bug further up the chain that's causing
us to generate partial checksums even though the NIC doesn't
support it.  Can you please give me the output of

ethtool -k <IFNAME>

where <IFNAME> is the interface that TCP connection is going
out of?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c3aa68c..70d9b5d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -682,7 +682,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->transport_header += off;
 	skb->network_header   += off;
 	skb->mac_header	      += off;
-	skb->csum_start       += off;
+	skb->csum_start       += nhead;
 	skb->cloned   = 0;
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
