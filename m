From: jamal <hadi@cyberus.ca>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 08:36:12 -0400
Message-ID: <1149078972.5462.72.camel@jzny2>
References: <20060531051451.GA7110@gondor.apana.org.au>
	 <20060530.232626.00456312.davem@davemloft.net>
	 <20060531063152.GA8032@gondor.apana.org.au>
	 <20060531.000818.78646242.davem@davemloft.net>
	 <20060531120626.GA11925@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, mchan@broadcom.com,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:6379 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S964983AbWEaMgS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 08:36:18 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FlPvx-0006QV-15
	for netdev@vger.kernel.org; Wed, 31 May 2006 08:36:21 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060531120626.GA11925@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-31-05 at 22:06 +1000, Herbert Xu wrote:
> On Wed, May 31, 2006 at 12:08:18AM -0700, David Miller wrote:
> > 
> > I understand what you're saying.  What I'm talking about is that in
> > net channel drivers we might go back to IRQ disabling locks again.
> 
> OK, let's assume that the TX completion will go back into the IRQ
> handler.  I contend that we can still get by with a BH-disabling
> xmit_lock.  This is how it would work:
> 
> The IRQ handler would look like
> 
> 	if (!spin_trylock(&dev->xmit_lock)) {
> 		tasklet_schedule(&priv->tx_completion_tasklet);
> 		return;
> 	}
> 
> 	handle_tx_completion();
> 	spin_unlock(&dev->xmit_lock);
> 
> Where the TX completion tasklet would simply do
> 
> 	spin_lock(&dev->xmit_lock);
> 	handle_tx_completion();
> 	spin_unlock(&dev->xmit_lock);
> 
> What do you think?

Been done in the past, bad numbers especially in SMP for reasons of
latency and likelihood that a tasklet will run in a totally different
CPU.

Latency-wise: TX completion interrupt provides the best latency.
Processing in the poll() -aka softirq- was almost close to the hardirq
variant. So if you can make things run in a softirq such as transmit
one, then the numbers will likely stay the same.

Sorry, I havent been following discussions on netchannels[1] so i am not
qualified to comment on the "replacement" part Dave mentioned earlier.
What I can say is the tx processing doesnt have to be part of the NAPI
poll() and still use hardirq.

If you look at the earlier NAPI drivers such as the tulip or the
broadcom 1250, the TX EOL was always made an exception and was never
touched by the ->poll() code rather by the main interrupt routine. I do
prefer the scheme of leaving the TX EOL out of the NAPI poll because i
believe that it provides better performance. The caveat is there's a lot
of fscked hardware out there that does unconditional clear-on-read of
the int status register;-> I had a lot of fun with bcm1250 and ended
discovering that there were infact two status regs ;-> (it pays to know
people for undocumented things;->) one was for debug version which
doesnt clear on writing. So in one spot i would read the real register
and in the other the debug version. I had numbers which showed doing it
this way provided better performance than doing it in the poll() routine
(scouring the code just now it seems my version never made it in, so you
will see something along the lines of e1000/tg3).

BTW, Andi Kleen on CC is the person who posted some numbers on the LLTX
(as well as the patch) at some point.
I have also CCed Robert who may have comments on the use of tasklets. 

cheers,
jamal

[1] Such a shame, such an exciting topic, such few cycles. I will have
time RealSoonNow and you will probably see a_patch_from_me_too.

