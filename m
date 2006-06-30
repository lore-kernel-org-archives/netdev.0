From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 21:11:30 -0400
Message-ID: <1151629890.8922.121.camel@jzny2>
References: <20060627100309.GU1376@postel.suug.ch>
	 <1151413670.6516.57.camel@jzny2> <20060628101832.GW1376@postel.suug.ch>
	 <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch>
	 <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch>
	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>
	 <1151625826.8922.58.camel@jzny2>  <20060630004640.GC14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:15328 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751373AbWF3BLd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 21:11:33 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fw7Xn-0001xT-CR
	for netdev@vger.kernel.org; Thu, 29 Jun 2006 21:11:39 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630004640.GC14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 02:46 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-29 20:03
> > On Fri, 2006-30-06 at 01:39 +0200, Thomas Graf wrote:
> > > * jamal <hadi@cyberus.ca> 2006-06-29 19:23
> > 
> > > > not at all. Let me explain the design intent further below.
> > > 
> > > Then let me show you what your code does:
> > > 
> > >  [mirred attached to filter on eth0 redirecting to ifb0]
> > > 
> > > tcf_mirred():    skb2->input_dev = skb->dev; (skb2->input_dev=eth0)
> > > ifb_xmit():      skb->dev = skb->input_dev; (skb->dev=eth0)
> > >                  skb->input_dev = dev; (skb->input_dev=ifb0)
> > > 
> > > So when reentering the stack the skb looks like it would be
> > > on eth0 coming from ifb0. Is that what you wanted? 
> > 
> > ok, that looks like egress side of the stack, correct?
> 
> No, that's the ingress side leaving ifb again via netif_rx()
>
> skb->dev should represent the from/at= and not to=. 
> 

Heres what it would look at ingress:

step 0: coming from wire via eth0,
dev=eth0, input_dev=eth0

step 1: redirect to ifb0, leaving redirect
dev=ifb0, input_dev=eth0

step 2: leaving ifb0, coming back to ingress side of stack

dev= eth0, input_dev=ifb0

Again, it gets interesting when you have redirection multiple times
and create loops. It will get more interesting when i submit the code
for redirecting to ingress.
The good news is there is very strong consistency.
I dont know if "at" is the correct description. I visualize it as
hitting the stack just "at" the point.

when the packet first comes in both from/to point to eth0.
So the semantics are the same as in egress.

> For egress your code is correct although impossible to guess
> right due to total lack of a comment where it would make sense
> and naming that doesn't give any implications.
> 

There are some simple comments and  I have been trying very hard to
explain this for a long time.
Patrick was the last person who tortured me ;-> Perhaps i need to
write a document. 

> When leaving ifb0 you want for...
> ... egress:
>    skb->dev=to (eth0) skb->iif=from (ifb0)
> ... ingress:
>    skb->dev=at (ifb0) skb->iif=from (eth0)
> 

Yes, this is correct. I described the flow of the first one in the
earlier email and the ingress side.
Although lets not talk about iif yet. I posed a question earlier on
which scheme would be better.

> So we move the update to the tasklet and set skb->dev to
> skb->iif before dev_queue_xmit() and skb->dev = dev (ifb)
> before calling netif_rx()
> 
> Does that fullfil your requirements?

You lost me on what you are trying to achieve. Just restore the line you
removed in ifb and things would be fine. Lets then settle the issue of
iif vs input_dev.

cheers,
jamal



