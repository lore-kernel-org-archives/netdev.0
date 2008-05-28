From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 18:11:04 +0400
Message-ID: <20080528141104.GA5543@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <200805280259.30931.opurdila@ixiacom.com> <20080528085241.GA30367@2ka.mipt.ru> <200805281620.55578.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60246 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbYE1OL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 10:11:28 -0400
Content-Disposition: inline
In-Reply-To: <200805281620.55578.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2008 at 04:20:55PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> > I preserved old semantic, when we free skb  
> > only if we read it whole or in case of fin. With your changes we can
> > also free skb, if it was partially consumed 
> 
> If the skb was partially consumed then tcp_recv_skb(seq-1) will return the 
> same skb and the offset +1 != skb->len, thus we will not free it.

I understand now, please correct me if I got your idea wrong.
We only ned to search for the skb again only in case we processed it and
it was possible that socket lock was dropped. So, the only needed place
to put tcp_recv_skb() is where you pointed. Next, to find current skb we
have to get sequence number inside its data, and seq-1 is indeed that
case, even if skb was changed under us (like combined with others), we
still will find it in the queue. Offset in tcp_recv_skb() is set to
number of bytes between starting sequence number for skb and given
sequence number, thus if we search for (seq-1), it will point to the
last byte processed by the code, and thus offset will 'point' to last
processed byte, not byte to start from, so we check against (offset+1)
and if (offset+1) equals to the size of the skb found we can free this
skb (in the code below). If it is not the case and skb contains data
behind (offset+1) we break and the rest of the data will be processed
in the next run. If there is no skb, we just break out of the loop.

So yes, your patch is simpler and faster than mine so you should push it
upstream. Fortunately David Miller is in copy and will (David, will
you?) pick it up and push, likely it is also needed for stable?

> Anyways, I am a newbie in this area, so if my logic doesn't make any sense 
> please be patient with me :)

We all are newbies somewhere and even splice code itself is rather new :)


-- 
	Evgeniy Polyakov
