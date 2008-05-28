From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 16:20:55 +0300
Message-ID: <200805281620.55578.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <200805280259.30931.opurdila@ixiacom.com> <20080528085241.GA30367@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4834 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750825AbYE1NWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 09:22:07 -0400
In-Reply-To: <20080528085241.GA30367@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 May 2008, Evgeniy Polyakov wrote:

> > One doubt though: suppose that while we drop the lock the skb gets
> > aggregated with the one after it. If the original skb is fully consumed
> > in the receive actor, then the we will eat the new, aggregated skb,
> > loosing data.
>
> How can it be aggregated with another skb? 

I think that tcp_collapse does this kind of aggregation when we have memory 
pressure: will create a new skb and move the data from the old skbs in the 
new one, freeing the old skb. Right?

> It is only possible that some
> other reader consumes the data, but in that case sequence number will
> not match and we will not find skb. 
>

Hmm, I didn't thought about this, but you are right, we could have other 
consumer sneaking in.

> > Here is a patch, based on your idea, which tries to cope with the above
> > scenario. The !skb check was added for the case in which the actor does
> > not consume anything in the current interration.
>
> If it does not get any data, then skb will likely exists and will be
> consumed in the next run. 

If the consumer didn't consume data, the seq number will not be updated, and 
seq-1 will correspond to a previous skb, which was already dequeued and 
processed. Thus tcp_recv_skb(seq-1) will return NULL.

> I preserved old semantic, when we free skb  
> only if we read it whole or in case of fin. With your changes we can
> also free skb, if it was partially consumed 

If the skb was partially consumed then tcp_recv_skb(seq-1) will return the 
same skb and the offset +1 != skb->len, thus we will not free it.

> and do not free it at all if 
> skb was not processed becuase it is too old (i.e. it lives in receive
> queue, but we already read data siwth sequnce number, which corresponds
> to it), no?

I didn't get this part, shouldn't the entity which dequeues the packet also 
free it? 

Anyways, I am a newbie in this area, so if my logic doesn't make any sense 
please be patient with me :)

Thanks,
tavi

