From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 09:57:23 -0400
Message-ID: <1151675843.5270.18.camel@jzny2>
References: <20060628101832.GW1376@postel.suug.ch>
	 <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch>
	 <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch>
	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>
	 <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch>
	 <1151629890.8922.121.camel@jzny2>  <20060630130811.GE14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:36824 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932711AbWF3N50
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 09:57:26 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwJUu-0007Tv-Q8
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 09:57:28 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630130811.GE14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 15:08 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-29 21:11
> > Heres what it would look at ingress:
> > 
> > step 0: coming from wire via eth0,
> > dev=eth0, input_dev=eth0
> > 
> > step 1: redirect to ifb0, leaving redirect
> > dev=ifb0, input_dev=eth0
> > 
> > step 2: leaving ifb0, coming back to ingress side of stack
> > 
> > dev= eth0, input_dev=ifb0
> 
> That creates a nice loop on ingress. Upon reentering the
> stack with skb->dev set to eth0 again we'll go through the
> same ingress filters as the first time and we'll hit ifb0
> again over and over. 

loops are taken care of by other metadata. 

> Are you suggesting everyone has to
> insert a pass action matching input_dev in order to escape
> the loop when using ifb?
> 

This works, there are no loops. If you use a meta setter and changed
input_dev to something that creates a loop it will still be caught when
ttls expire.

> > > When leaving ifb0 you want for...
> > > ... egress:
> > >    skb->dev=to (eth0) skb->iif=from (ifb0)
> > > ... ingress:
> > >    skb->dev=at (ifb0) skb->iif=from (eth0)
> > > 
> > 
> > Yes, this is correct. I described the flow of the first one in the
> > earlier email and the ingress side.
> 
> How can it be correct if it differs from your description
> above? What I described is what the patch changes it to.

Double check again: it works as described above; your change messes it.

> Looking closer at ifb it contains a race when updating
> skb->dev. Preempt has to be disabled when updating skb->dev
> before calling netif_rx() otherwise the device might disappear.
> 

I am going to ignore the patch until we resolve the issue of iif vs
input_dev. Why dont we discuss that?

cheers,
jamal

