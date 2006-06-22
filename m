From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Thu, 22 Jun 2006 15:31:22 -0400
Message-ID: <1151004682.5392.97.camel@jzny2>
References: <20060619121519.GA16031@gondor.apana.org.au>
	 <1150724031.5815.39.camel@jzny2>
	 <20060619134227.GA16662@gondor.apana.org.au>
	 <1150727009.5815.72.camel@jzny2>
	 <20060619142928.GA17191@gondor.apana.org.au>
	 <1150727810.5815.78.camel@jzny2>
	 <20060619223326.GA20354@gondor.apana.org.au>
	 <1150814526.5270.64.camel@jzny2>
	 <20060620235207.GA31493@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:40612 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932288AbWFVTb1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 15:31:27 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtUtk-00006t-PA
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 15:31:28 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060620235207.GA31493@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-21-06 at 09:52 +1000, Herbert Xu wrote:

> Well my gut feeling is that multiple qdisc_run's on the same dev can't
> be good for perfomance.  The reason is that SMP is only good when the
> CPUs work on different tasks.  If you get two or more CPUs to work on
> qdisc_run at the same time they can still only supply one skb to the
> device at any time.  What's worse is that they will now have to fight
> over the two spin locks involved which means that their cache lines
> will bounce back and forth.

1) If the CPUs collide all the time it is without a doubt
it is a bad thing (you can tell from tx_collission stats).
 
2) If on the other hand, the iota that a CPU enters that path in the
softirq it gets the txlock then there is benefit to not serialize
at the level you have done with that patch - you are enlarging the
granularity of the serialization so much so that the CPU wont even
get the opportunity to try and grab tx lock because it finds qdisc is
already running.

Your gut feeling is for #1 and my worry is for #2 ;->
I actually think your change is obviously valuable for scenarios where
the bus is slower and therefore transmits take longer - my feeling is it
may not be beneficial for fast buses like PCI-E or high speed PCI/X
where the possibility of getting access tx collision is lower.

The other reason I mentioned earlier as justification to leave the
granularity at the level where it was is for good qos clocking. i.e
to allow incoming packets to be used to clock the tx path - otherwise
you will be dependent on HZ for your egress rate accuracy. I am not sure
if this later point made sense - I could elaborate.

The experiment needed to prove things is not hard: one needs to get a 2
or 4way machine and create a "funneling" effect to one NIC. 
For forwarding, the best setup will be to have 3 NICs. packets coming in
on 2 NICs are forwarded to a third. The incoming-packet NICS are tied to
different CPUs. In a 4way, the outgoing as well is tied to its own CPU.
You then pummel the two incoming CPUs with pktgen or otherwise
at something like 1Mpps (which is higher than the wire rate the third
nic can handle).


cheers,
jamal

