From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Tue, 09 Oct 2007 09:43:11 -0400
Message-ID: <1191937391.4373.206.camel@localhost>
References: <20070917.190133.79431533.davem@davemloft.net>
	 <1190083728.4237.59.camel@localhost> <1190208832.4259.6.camel@localhost>
	 <20070919.090937.32177545.davem@davemloft.net>
	 <1190255605.4818.25.camel@localhost> <1190256183.4818.28.camel@localhost>
	 <20071009040037.GA15981@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.229]:54059 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbXJINnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 09:43:22 -0400
Received: by nz-out-0506.google.com with SMTP id s18so915123nze
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2007 06:43:20 -0700 (PDT)
In-Reply-To: <20071009040037.GA15981@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-10 at 12:00 +0800, Herbert Xu wrote:

> 
> OK, after waking up a bit more 

me too;-> 

> What I'm worried about is would we see worse behaviour with
> drivers that do all their TX clean-up with the TX lock held

Good point Herbert.
When i looked around i only found one driver that behaved like that;
some IBM mainframe one from the looks of it. That driver did a lot of
other obscure things (i think they maintain their own napi calls etc),
so it didnt worry me very much. 
IIRC, I think it could be fixed to do what tg3 and relatives like bnx do
(I really like the approach) - just didnt have the time to chase it. 
There are a _lot_ more drivers that have no respect for netif_tx_lock
and implement their own locking down in the driver. Those already suffer
from the phenomena you describe whether TX_LOCK is held or not.

> (which would cause qdisc_restart to spin while this is happening)?

Yes, with such a driver, we spin in the worst case. But that provides
opportunities for optimization of a driver behaving that way; two
approaches off top of my head:
a) we could prune the tx descriptors on the the tx path since it is safe
to do so and reduce the amount of time spent doing such work in the napi
poll
or
b) Have the napi side do a trylock (sort of what the e1000 attempts to
do) and reschedule the poll to retry.

#b is fair because the cost of a queue_lock goes up as the number of
cpus goes up (which is the case i was optimizing for). The cost of tx
lock is contention by two cpus in worst case. Thoughts?

cheers,
jamal

