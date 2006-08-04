From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 21:16:04 -0400
Message-ID: <1154654164.5187.28.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
	 <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com>
	 <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2>
	 <1154650197.3117.32.camel@rh4>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:15325 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751412AbWHDBQL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 21:16:11 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G8oIQ-0007j3-V2
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 21:16:14 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1154650197.3117.32.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-03-08 at 17:09 -0700, Michael Chan wrote:
> On Thu, 2006-08-03 at 18:08 -0400, jamal wrote:
> 
> > 
> > Yes in your case you need to hold the lock but not in the e1000 case.
> > I dont understand though why you need to check for wake in the tx path.
> > 
> 
> tg3_start_xmit()
> 
> 	if (tx_ring_empty)
> 				<-  tg3_tx()
> 		netif_stop_queue()
> 
> 
> At the arrow, tg3_tx() can come in and clean up the entire ring but will
> not see that the queue is stopped and therefore will not call
> netif_wake_queue().  As a result, the tx_queue is stopped forever.
> 

Indeed - if you do it that way. 
What about (actually e1000 is not exactly like this but closer than tg3
is):

    tg3_start_xmit():
    
      prepare skb                       
      grab ring tx lock irq safe
      put skb on ring
      if (full-ring)
          stop
      release ring tx lock and restore flags blah 

and in tg3_tx():

     if likely(stopped) {  
       // essentially no lock needed here ....
       prune tx ring
       if prunned > threshold
           wake
     } else if not stopped { 
          // need a lock here ...
         grab ring tx lock irq safe
         prune tx ring
         release ring tx lock
     }

The above is safe to run tg3_start_xmit on one CPU and tg3_tx an
another.

And you can then take advantage of asynchronous wakes and remove the
paranoia checks you have on tx.

cheers,
jamal

