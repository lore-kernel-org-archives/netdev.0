From: "Mandeep Baines" <mandeep.baines@gmail.com>
Subject: Re: pktgen terminating condition
Date: Wed, 29 Aug 2007 09:59:42 -0700
Message-ID: <535ddc6b0708290959j4b89579dk37c97f555f7cfcb9@mail.gmail.com>
References: <20070829044352.GA4133@ludhiana>
	 <1188395183.4274.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rick.jones2@hp.com, msb@google.com,
	netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, venza@brownhat.org, jeff@garzik.org,
	nhorman@tuxdriver.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:28208 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbXH2Q7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 12:59:43 -0400
Received: by wa-out-1112.google.com with SMTP id v27so268891wah
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 09:59:43 -0700 (PDT)
In-Reply-To: <1188395183.4274.19.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/29/07, jamal <hadi@cyberus.ca> wrote:
> On Tue, 2007-28-08 at 21:43 -0700, Mandeep Singh Baines wrote:
>
> > I interpret this to mean that the interrupt gets generates after a packet
> > is transferred to the TFIFO on the NIC and the next packet in the ring is
> > NULL.
>
> iow, when tx transits to idle ..
>
> > This interrupt gets generates less often then TxOK which gets generated
> > after every completed packet transmit. So I'm thinking that maybe the
> > driver was written to use this interrupt instead of TxOK for this reason.
> > Really just my speculation.
>
> It does make sense if you are trying to cut down on tx interupts. It's a
> little extreme - and if you dont have much memory it may not be the best
> scheme. OTOH, you have moved to the other extreme imo ;-> You are
> generating an interupt per tx packet. This may not matter on modern
> hardware because that NIC seems to be Fast Ethernet.
> You may wanna heed Dave's advice and just always set the idle on a
> per-descriptor basis as well as txcomplete on every Xth packet (4 was
> suggested).

My hardware at home is not so modern:( I'm running a AMD Geode NX1750.
I like to punish myself:) Actually, it does the job and is very power
efficient.

Agreed, interrupting every packet is inefficient. A better solution is
probably NAPI. I'll work on a new patch.

> Looking at sis900_start_xmit() at the spot where OWN is set
> on the descriptor, theres possibly another bit in tx_ring[entry].cmdsts
> you may could set that will ask for tx complete; which makes me wonder:
> is that "outl(TxENA | inl(ioaddr + cr), ioaddr + cr)" really needed on a
> per-packet basis? Should it not be sufficient to turn it on once at
> open()?
>

You have to set this bit to restart the Tx State Machine. You could
optimize this if you use the TxIdle interrupt to tell you when you
really need to set this bit.

> > Anyway, if I rewrite the driver to use TxOK instead of TxIdle, pktgen
> > works fine.
>
> I think its a good thing pktgen caught this; i am unsure however if it
> is doing the right thing. Hoping Robert would respond.
> One thing pktgen could do is restrict the amount of outstanding buffers
> by using accounting the way sockets do - this at least wont stop
> progress as it did in your case.
>
> > I'm attaching the patch.
>
> Looks good to me given the desire. I would bounce it by whoever the
> maintainer is - they may have some insights on the lazy tx prune habit.
>

+ nhorman@tuxdriver.com
+ jeff@garzik.org

I'll work on a NAPI patch.

Regards,
Mandeep
