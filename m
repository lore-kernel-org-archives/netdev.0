From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Tue, 20 Jun 2006 10:42:06 -0400
Message-ID: <1150814526.5270.64.camel@jzny2>
References: <20060619121519.GA16031@gondor.apana.org.au>
	 <1150724031.5815.39.camel@jzny2>
	 <20060619134227.GA16662@gondor.apana.org.au>
	 <1150727009.5815.72.camel@jzny2>
	 <20060619142928.GA17191@gondor.apana.org.au>
	 <1150727810.5815.78.camel@jzny2>
	 <20060619223326.GA20354@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:54168 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751153AbWFTOmJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:42:09 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FshQi-00010H-Ie
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 10:42:12 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060619223326.GA20354@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,
Thanks for your patience.

On Tue, 2006-20-06 at 08:33 +1000, Herbert Xu wrote:

> First of all you could receive an IRQ in between dropping xmit_lock
> and regaining the queue lock.  

Indeed you could. Sorry, I overlooked that in my earlier email. This
issue has been there forever though - and i dont mean to dilute its
existence by saying the chances of it happening are very very slim. I
claim though that you will be _unable to reproduce this in an
experimental setup_ i.e thats how complex it is. 

> Secondly we now have lockless drivers where this assumption also 
> does not hold.

Ok, forgot about lockless drivers;
The chances are certainly much higher with lockless driver for a very
simple reason. We used to have lock ordering that is now changed for
lockless drivers. i.e we had:

1) grab qlock, 
2)  dq
3)  grab txlock, 
4) release qlock, 
5)    transmit, 
6) release txlock

to the new sequence #1,#2,#4,#3,#5,#6
and at times that same replacement txlock being also used in the rx path
to guard the tx DMA. 
A possible solution is to alias the tx lock to be dev->txlock
(DaveM had pointed out he didnt like this approach, I cant remember the
details.)

Heres where i am coming from (you may have suspected it already):
My concern is i am not sure what the performance implications are on 
this change (yes, there goes that soup^Wperformance nazi again) or what
the impact on how good the qos granularity is any longer[1].
If it is to make lock-less drivers happy, then someone oughta validate
if this performance benefit that lockless drivers give still exists. I
almost feel like we gained the 5% from lockless driving and lost 10% for
everyone else trying to fix the sins of lockless driving. So i am unsure
of the net gain. 

I apologize for hand-waving with % numbers above and using gut feeling
instead of experimental facts - I dont have time to chase it. I have
CCed Robert who may have time to see if this impacts forwarding
performance for one. I will have more peace of mind to find out there is
no impact.

cheers,
jamal

[1] By having both the forwarding path and tx softirq from multiple CPUs
enter this qdiscrun path, the chances that a packet will be dequeued
successfully and sent out within reasonable time are higher.
The tx_collision vs tx success are a good measure of how lucky you get.
This improves timeliness and granularity of qos for one. What your patch
does is reduce the granularity/possibility that we may enter
that region sooner.

