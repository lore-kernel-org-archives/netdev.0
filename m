From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v5 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Tue, 11 Feb 2014 21:14:02 +0800
Message-ID: <20140211131401.GA8163@gondor.apana.org.au>
References: <1392064537-30646-1-git-send-email-fw@strlen.de>
 <1392064537-30646-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:42588 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaBKNOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 08:14:06 -0500
Content-Disposition: inline
In-Reply-To: <1392064537-30646-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 09:35:37PM +0100, Florian Westphal wrote:
> Marcelo Ricardo Leitner reported problems when the forwarding link path
> has a lower mtu than the incoming one if the inbound interface supports GRO.
> 
> Given:
> Host <mtu1500> R1 <mtu1200> R2
> 
> Host sends tcp stream which is routed via R1 and R2.  R1 performs GRO.
> 
> In this case, the kernel will fail to send ICMP fragmentation needed
> messages (or pkt too big for ipv6), as GSO packets currently bypass dstmtu
> checks in forward path. Instead, Linux tries to send out packets exceeding
> the mtu.
> 
> When locking route MTU on Host (i.e., no ipv4 DF bit set), R1 does
> not fragment the packets when forwarding, and again tries to send out
> packets exceeding R1-R2 link mtu.
> 
> This alters the forwarding dstmtu checks to take the individual gso
> segment lengths into account.
> 
> For ipv6, we send out pkt too big error for gso if the individual
> segments are too big.
> 
> For ipv4, we either send icmp fragmentation needed, or, if the DF bit
> is not set, perform software segmentation and let the output path
> create fragments when the packet is leaving the machine.
> It is not 100% correct as the error message will contain the headers of
> the GRO skb instead of the original/segmented one, but it seems to
> work fine in my (limited) tests.
> 
> Eric Dumazet suggested to simply shrink mss via ->gso_size to avoid
> sofware segmentation.
> 
> However it turns out that skb_segment() assumes skb nr_frags is related
> to mss size so we would BUG there.  I don't want to mess with it considering
> Herbert and Eric disagree on what the correct behavior should be.
> 
> Hannes Frederic Sowa notes that when we would shrink gso_size
> skb_segment would then also need to deal with the case where
> SKB_MAX_FRAGS would be exceeded.
> 
> This uses sofware segmentation in the forward path when we hit ipv4
> non-DF packets and the outgoing link mtu is too small.  Its not perfect,
> but given the lack of bug reports wrt. GRO fwd being broken this is a
> rare case anyway.  Also its not like this could not be improved later
> once the dust settles.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Although I think we're adding too much complexity for ~DF packets,
I don't see anything wrong with this patch per se since we're
already aggregating ~DF packets.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
