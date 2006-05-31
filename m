From: jamal <hadi@cyberus.ca>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 09:03:25 -0400
Message-ID: <1149080605.5462.90.camel@jzny2>
References: <20060531051451.GA7110@gondor.apana.org.au>
	 <20060530.232626.00456312.davem@davemloft.net>
	 <20060531063152.GA8032@gondor.apana.org.au>
	 <20060531.000818.78646242.davem@davemloft.net>
	 <20060531120626.GA11925@gondor.apana.org.au>
	 <1149078972.5462.72.camel@jzny2>
	 <20060531124036.GA12171@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Andi Kleen <ak@suse.de>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:47263 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S965001AbWEaNDa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 09:03:30 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FlQMG-0000O3-N9
	for netdev@vger.kernel.org; Wed, 31 May 2006 09:03:32 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060531124036.GA12171@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-31-05 at 22:40 +1000, Herbert Xu wrote:
> On Wed, May 31, 2006 at 08:36:12AM -0400, jamal wrote:
> >
[..]
> > 
> > Been done in the past, bad numbers especially in SMP for reasons of
> > latency and likelihood that a tasklet will run in a totally different
> > CPU.
> 
> Was the bad latency measured with code like the above or was it with
> an unconditional tasklet schedule?
> 

The idea was to prune those skbs for reuse within reason so as to
not sacrifice perfomance. Perfomance is sacrificed if you have too many
TX EOLs, or you dont prune the descriptors fast enough. The dynamics of
proved to be hard to nail in a generic way because behavior varies based
on traffic patterns.
So the "within reason" part will unconditionally schedule a tasklet on
the tx if certain DMA ring thresholds are crossed, way after the tx lock
has been grabbed which is different from your suggestion to do it when
you cant grab a lock.
Otherwise you let the hardirq take care of things. Tasklets proved to be
a bad idea and instead we ended reclaiming the skb/descriptors right at
the point where  we initially had scheduled tasklets. I dont know what
happened to using that technique - Robert can testify better than i.

> Please note that my code will do the completion in the IRQ handler
> most of the time.  Only if there is contention for the spin lock will
> it defer work to the softirq.

that part is different and I think there may be potential - it will
require experimenting with a variety of traffic patterns. I wish i had
time to help.

cheers,
jamal

