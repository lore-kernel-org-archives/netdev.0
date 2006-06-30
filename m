From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 16:15:31 +0200
Message-ID: <20060630141531.GG14627@postel.suug.ch>
References: <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:34997 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932486AbWF3OPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 10:15:11 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151675843.5270.18.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 09:57
> On Fri, 2006-30-06 at 15:08 +0200, Thomas Graf wrote:
> > That creates a nice loop on ingress. Upon reentering the
> > stack with skb->dev set to eth0 again we'll go through the
> > same ingress filters as the first time and we'll hit ifb0
> > again over and over. 
> 
> loops are taken care of by other metadata. 

Not really, assuming a simple setup such as:

	mirred attached to eth0 redirecting to ifb0
	mirred attached to ifb0 redirecting to ifb1

will result in:

eth0::tcf_mirred()     skb->dev = ifb0, input_dev = eth0
ifb0::tcf_mirred()     skb->dev = ifb1, input_dev = ifb0
ifb1::ifb_xmit()       skb->dev = ifb0, input_dev = ifb1, set ncls bit
ifb0::ifb_xmit()       skb->dev = ifb1, input_dev = ifb0
ifb1::ifb_xmit()       skb->dev = ifb0, input_dev = ifb1
...

Oh dear... and we don't even have a ttl to catch this.

> I am going to ignore the patch until we resolve the issue of iif vs
> input_dev. Why dont we discuss that?

It's starting to get useless to discuss with you. You agreed in
your last posting that the 3rd option, being that not caring about
whether a device might disappear but having a way to check for it,
is what we agreed on and what makes most sense, yet you fail to see
that using ifindex is exactly what reflects this descision.
