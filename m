From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 08:50:36 -0400
Message-ID: <1154955036.5246.32.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2>
	 <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:23466 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932095AbWHGMul
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 08:50:41 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GA4Z9-0000Fh-9d
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 08:50:43 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-08 at 16:16 -0700, Jesse Brandeburg wrote:
[..]
> 
> As for specifics, for TX_WAKE_THRESHOLD, i noticed that we were
> starting the queue after every packet was cleaned, so when the ring
> went full there was a lot of queue thrash.

indeed this is what used to happen and was bad.... So this is a huge
improvement.
What happens now under steady state at high traffic transmits is,
instead of 1, you see E1000_TX_WEIGHT in between queue sleep/wakes. I
assume this is a given since E1000_TX_WEIGHT is higher than
TX_WAKE_THRESHOLD.  I am not sure if i can vouch for even more
improvement by mucking around with values of E1000_TX_WEIGHT.

Can you please take a look at the patch i posted? I would like to submit
that for inclusion. It does two things
a) make pruning available to be invoked from elsewhere (I tried to do it
from the tx path but it gave me non-good results)
b) makes E1000_TX_WEIGHT and TX_WAKE_THRESHOLD relative to the size
of the transmit ring. I think this is a sane thing to do.

You could either extract the bits or i could resend to you as two
different patches. I have tested it and it works.

>   tg3 seemed to fix it in a
> smart way and so I did a similar fix.  Note we should have at least
> MAX_SKB_FRAGS (usually 32) + a few descriptors free before we should
> start the tx again, otherwise we run the risk of a maximum fragmented
> packet being unable to fit in the tx ring.

I noticed you check for that in the tx path.

> now, for E1000_TX_WEIGHT, that was more of an experiment as i noticed
> we could stay in transmit clean up forEVER (okay not literally) which
> would really violate our NAPI timeslice.  

Interesting. The only time i have seen the NAPI time slice kick in is in
slow hardware or emulators (like UML). 
I wonder if the pruning path could be made faster? What is the most
consuming item? I realize there will be a substantial amount of cache
misses. Maybe in addition to prunning E1000_TX_WEIGHT descriptors also
fire a timer to clean up the rest (to avoid it being accounted for in
the napi timeslice;->). Essentially i think you have some thing in the
pruning path that needs to be optimized. Profiling and improving that
would help.

> I messed with some values
> and 64 didn't really seem like too bad a compromise (it does slow
> things down just a tad in the general case) while really helping a
> couple of tests where there were lots of outstanding transmits
> happening at the same time as lots of receives.
> 

The later are the kind of tests i am running. If you are a router or a
busy server they apply. In slow machines a ping flood also applies etc. 

> This need for a tx weight is yet another global (design) problem with
> NAPI enabled drivers, 

oh yes, the Intel cabal - blame NAPI first;-> 
IMO, the problem is you are consuming too many cycles in the receive
path. NAPI has to be fair to all netdevices and cant hog all the CPU
because a certain netdevice uses too many cycles to process a packet. 

> but someday I'll try to document some of the issues I've seen.

I think it would be invaluable. Just dont jump to blame Canada^WNAPI
conclusion because it distracts; 

cheers,
jamal

