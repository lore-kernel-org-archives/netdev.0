From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 02:46:40 +0200
Message-ID: <20060630004640.GC14627@postel.suug.ch>
References: <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2> <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56740 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751366AbWF3AqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 20:46:19 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151625826.8922.58.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-29 20:03
> On Fri, 2006-30-06 at 01:39 +0200, Thomas Graf wrote:
> > * jamal <hadi@cyberus.ca> 2006-06-29 19:23
> 
> > > not at all. Let me explain the design intent further below.
> > 
> > Then let me show you what your code does:
> > 
> >  [mirred attached to filter on eth0 redirecting to ifb0]
> > 
> > tcf_mirred():    skb2->input_dev = skb->dev; (skb2->input_dev=eth0)
> > ifb_xmit():      skb->dev = skb->input_dev; (skb->dev=eth0)
> >                  skb->input_dev = dev; (skb->input_dev=ifb0)
> > 
> > So when reentering the stack the skb looks like it would be
> > on eth0 coming from ifb0. Is that what you wanted? 
> 
> ok, that looks like egress side of the stack, correct?

No, that's the ingress side leaving ifb again via netif_rx()
skb->dev should represent the from/at= and not to=. 

For egress your code is correct although impossible to guess
right due to total lack of a comment where it would make sense
and naming that doesn't give any implications.

When leaving ifb0 you want for...
... egress:
   skb->dev=to (eth0) skb->iif=from (ifb0)
... ingress:
   skb->dev=at (ifb0) skb->iif=from (eth0)

So we move the update to the tasklet and set skb->dev to
skb->iif before dev_queue_xmit() and skb->dev = dev (ifb)
before calling netif_rx()

Does that fullfil your requirements?
