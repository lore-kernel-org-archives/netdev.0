From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 18:06:02 -0400
Message-ID: <1154642762.5187.9.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:16571 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030220AbWHCWGH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 18:06:07 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8lKV-0005m5-VK
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 18:06:11 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse,

On Thu, 2006-03-08 at 09:36 -0700, Brandeburg, Jesse wrote:
> On Fri, 4 Aug 2006, Herbert Xu wrote:
> > jamal <hadi@cyberus.ca> wrote:
> > > 
> > > There is no need for tx_locking if you are already netif stopped
> > > (transmit path will never be entered).
> > > With this change under high speed forwarding i see anywhere

> > Even if we get it wrong and wake up something that we shouldn't have,
> > the xmit function will simply bail out and stop the queue for us.
> 
> I followed the example of tg3 when attempting to optimize this code.


Well, the tg3 does try to netif_wake on the tx path as well; it would
need to hold the lock;-> The e1000 doesnt. 

>   For 
> the normal case we remove a lock acquisition.  Jamals case is not normal. 
> :-)

I didnt see the need to hold the lock but i may be missing the "normal"
case you refer to: I did the worst possible scenario and had transmit
path running concurently on one CPU while receive was running on another
(refer to the earlier explanation i posted).
 
The logic is you stop, the tx path will never be entered. If it is never
entered, you will never have to protect on the rx path. 

> we specifically added this lock originally to fix a problem we saw where 
> the netif_stop and netif_start would race, and we would end up with a 
> queue that was stopped, and no way to restart it because we didn't have 
> any more TX packets to clean up (even if we DID get an interrupt from a 
> receive)
> 

Of course if you call start after you stopped and there are still
packets sitting on the tx ring or qdisc, they will stay forever until
the next packet arrival. But if you do that you have a buggy driver.
But i dont see where you call start in the e1000 - was this some old
code?

> > Since this is exceedingly unlikely we should drop the locks rather
> > than bother about it.
> 
> I think that would be nice, but I still think the current driver solution 
> is a good stable solution that has made it through several rounds of 
> testing here, not to mention is in the tg3.c code.  Unless someone can 
> come up with a way to avoid the race between start and stop *inside* the 
> start and stop code (which would be ideal) then I think we have to have a 
> solution like this in the driver.

You should not call start if you are stopped. Is there some peripheral
code that does start?

cheers,
jamal



