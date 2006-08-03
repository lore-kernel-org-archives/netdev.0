From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 18:08:38 -0400
Message-ID: <1154642918.5187.13.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	 <1154628302.3117.15.camel@rh4>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:13502 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030193AbWHCWIk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 18:08:40 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8lMz-0006dg-Ck
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 18:08:45 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1154628302.3117.15.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-03-08 at 11:05 -0700, Michael Chan wrote:
> On Thu, 2006-08-03 at 09:36 -0700, Brandeburg, Jesse wrote:
> 
> > I followed the example of tg3 when attempting to optimize this code.  For 
> > the normal case we remove a lock acquisition.  Jamals case is not normal. 
> > :-)
> > 
> > we specifically added this lock originally to fix a problem we saw where 
> > the netif_stop and netif_start would race, and we would end up with a 
> > queue that was stopped, and no way to restart it because we didn't have 
> > any more TX packets to clean up (even if we DID get an interrupt from a 
> > receive)
> > 
> Yep, I agree that the lock is necessary.  The reason is that
> hard_start_xmit and xmit_completion can be running concurrently and they
> can miss each other and cause the tx ring to be stopped forever.
> 

Logic is you are stopped, the tx path can _never_ be entered by the
core. If it is you have a bug somewhere else.
Tx and rx do run concurently but not when you are stopped.

> In the case of tg3's hard_start_xmit, after stopping the queue, we need
> to check if we should wake the queue right away in case xmit_completion
> just finished cleaning the tx ring and just missed the queue_stopped
> condition. 

Is this to protect against some hardware bug?

>  Because the netif_wake_queue can be called in 2 places, you
> need the lock.  Without the lock, the queue can be waken up at the wrong
> time and may cause hard_start_xmit to be called with an empty tx ring.
> 

Yes in your case you need to hold the lock but not in the e1000 case.
I dont understand though why you need to check for wake in the tx path.

cheers,
jamal

