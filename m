From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 4 Aug 2006 11:08:29 -0700
Message-ID: <20060804110829.62136ebb@dxpl.pdx.osdl.net>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	<Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	<1154628302.3117.15.camel@rh4>
	<1154642918.5187.13.camel@jzny2>
	<1154650197.3117.32.camel@rh4>
	<20060804011027.GC12085@gondor.apana.org.au>
	<20060804083734.GA16082@gondor.apana.org.au>
	<20060804101017.GA17393@gondor.apana.org.au>
	<1154712532.3117.43.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, davem@davemloft.net,
	hadi@cyberus.ca, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54665 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161359AbWHDSJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 14:09:06 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1154712532.3117.43.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 04 Aug 2006 10:28:52 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> On Fri, 2006-08-04 at 20:10 +1000, Herbert Xu wrote:
> 
> > 1) netif_wake_queue is about to occur.  In this case it doesn't really
> > matter what we do as netif_wake_queue will always wake the queue for us.
> > In the worst case, it'll wake up the queue with too little room but that's
> > really uncommon and we can cope with that anyway.
> > 
> In a lot of other drivers including tg3, waking the tx queue when there
> is not enough room in the tx ring is considered a bug and will trigger a
> BUG message:
> 
> BUG! Tx Ring full when queue awake!
> 
> May be David can explain why it is undesirable to wake up the queue when
> it is full?

Because it means that there was a race hole in the normal sleep/wakeup code.
Some drivers just spin (see acenic.c) but that's ugly.

The real risk is that the transmit routine will decide it's busy, but
at the same time an IRQ on another CPU will clean up the whole ring
and make the queue available again. Then the transmit routine exits and
says its busy, and the higher level will decide it is permanently stopped.

-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
