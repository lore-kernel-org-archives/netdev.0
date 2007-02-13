From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Wed, 14 Feb 2007 04:51:21 +1100
Message-ID: <20070213175121.GA27281@gondor.apana.org.au>
References: <E1HFc6X-0006n7-00@gondolin.me.apana.org.au> <45D1CC83.8080603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Accetta <maccetta@laurelnetworks.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1762 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751371AbXBMRvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 12:51:48 -0500
Content-Disposition: inline
In-Reply-To: <45D1CC83.8080603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 03:34:43PM +0100, Patrick McHardy wrote:
>
> The callpath shows the REJECT target sending a TCP reset.
> I'm guessing it has something to do with skb_copy_expand
> copying the gso fields.

Indeed.  We need to reset the GSO bits there since the new
packet is nothing like the one it's copied from.

[NETFILTER]: Clear GSO bits for TCP reset packet

The TCP reset packet is copied from the original.  This
includes all the GSO bits which do not apply to the new
packet.  So we should clear those bits.

Spotted by Patrick McHardy.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Something like this is needed for all trees with GSO.
Actually it applies to TSO too although the effect there
is a bit harder to notice.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index a9eb363..80f739e 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -80,6 +80,10 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	nskb->mark = 0;
 	skb_init_secmark(nskb);
 
+	skb_shinfo(nskb)->gso_size = 0;
+	skb_shinfo(nskb)->gso_segs = 0;
+	skb_shinfo(nskb)->gso_type = 0;
+
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
 
 	/* Swap source and dest */
