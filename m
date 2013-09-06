From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Fri, 6 Sep 2013 14:12:27 +0100
Message-ID: <20130906131227.GJ14104@zion.uk.xensource.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>
 <1378472268.31445.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32963 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267Ab3IFNMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 09:12:30 -0400
Content-Disposition: inline
In-Reply-To: <1378472268.31445.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 06, 2013 at 05:57:48AM -0700, Eric Dumazet wrote:
> On Fri, 2013-09-06 at 11:16 +0100, Wei Liu wrote:
> > Hi Eric
> > 
> > I have some questions regarding TSQ and I hope you can shed some light
> > on this.
> > 
> > Our observation is that with the default TSQ limit (128K), throughput
> > for Xen network driver for large packets degrades. That's because we now
> > only have 1 packet in queue.
> > 
> > I double-checked that skb->len is indeed <64K. Then I discovered that
> > TSQ actually accounts for skb->truesize and the packets generated had
> > skb->truesize > 64K which effectively prevented us from putting 2
> > packets in queue.
> > 
> > There seems to be no way to limit skb->truesize inside driver -- the skb
> > is already constructed when it comes to xen-netfront.
> > 
> 
> What is the skb->truesize value then ? It must be huge, and its clearly
> a problem, because the tcp _receiver_ will also grow its window slower,
> if packet is looped back.
> 

It's ~66KB.

> > My questions are:
> >   1) I see the comment in tcp_output.c saying: "TSQ : sk_wmem_alloc
> >      accounts skb truesize, including skb overhead. But thats OK", I
> >      don't quite understand why it is OK.
> >   2) presumably other drivers will suffer from this as well, is it
> >      possible to account for skb->len instead of skb->truesize?
> 
> Well, I have no problem to get line rate on 20Gb with a single flow, so
> other drivers have no problem.
> 

OK, good to know this.

> >   3) if accounting skb->truesize is on purpose, does that mean we only
> >      need to tune that value instead of trying to fix our driver (if
> >      there is a way to)?
> 
> The check in TCP allows for two packets at least, unless a single skb
> truesize is 128K ?
> 
> 
> if (atomic_read(&sk->sk_wmem_alloc) >= sysctl_tcp_limit_output_bytes) {
>     set_bit(TSQ_THROTTLED, &tp->tsq_flags);
>     break;
> }
> 
> So if a skb->truesize is 100K, this condition allows two packets, before
> throttling the third packet.
> 

OK. I need to check why we're getting only 1 then.

Thanks for your reply.

Wei.

> Its actually hard to account for skb->len, because sk_wmem_alloc
> accounts for skb->truesize : I do not want to add another
> sk->sk_wbytes_alloc new atomic field.
> 
> 
