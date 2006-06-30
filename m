From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 20:03:46 -0400
Message-ID: <1151625826.8922.58.camel@jzny2>
References: <20060626184424.GT1376@postel.suug.ch>
	 <44A05FE0.7070203@trash.net> <20060627100309.GU1376@postel.suug.ch>
	 <1151413670.6516.57.camel@jzny2> <20060628101832.GW1376@postel.suug.ch>
	 <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch>
	 <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch>
	 <1151623394.8922.27.camel@jzny2>  <20060629233933.GB14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:5799 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932645AbWF3ADt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:03:49 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fw6UF-00014n-KW
	for netdev@vger.kernel.org; Thu, 29 Jun 2006 20:03:55 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060629233933.GB14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 01:39 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-29 19:23

> > not at all. Let me explain the design intent further below.
> 
> Then let me show you what your code does:
> 
>  [mirred attached to filter on eth0 redirecting to ifb0]
> 
> tcf_mirred():    skb2->input_dev = skb->dev; (skb2->input_dev=eth0)
> ifb_xmit():      skb->dev = skb->input_dev; (skb->dev=eth0)
>                  skb->input_dev = dev; (skb->input_dev=ifb0)
> 
> So when reentering the stack the skb looks like it would be
> on eth0 coming from ifb0. Is that what you wanted? 

ok, that looks like egress side of the stack, correct?
 
indeed thats what i meant earlier i.e above looks right. Another way to
look at it, is that on the stack, the "dev" part acts as a "to" label of
the direction and the "input_dev" maps to the "from". 


step 0: Packet arriving at egress of eth0 
It will have skb->dev pointing to "eth0" and skb->input_dev will depend
on whether it is coming from the local path (in which it will be NULL)
or it was being routed (in which case it will reflect the netdevice it
last passed on input.

Step 1: when it leaves redirect
As you note it will have indev("from") = eth0 and dev("to") still "ifb0"

Step 2: when it leaves ifb going back to eth0
it will have input_dev("from") = ifb0 and dev("to")  "eth0"

Of course this gets more interesting if you had say redirected to
another device like lo which redirected to ifb1. Or when you try to
create loops etc.

And if you look at ingress, it will be slightly different; however,
in both cases (ingress/egress) things are consistent in the labeling of
from/to to be input_dev/dev

> Shouldn't
> it be skb->dev=ifb0 skb->input_dev=eth0? That's what my patch
> would change it to.
> 

yes, that would change the semantics

> > I know your intent is noble in trying to save the 32 bits on 64 bit
> > machines (at least thats where your patch seems to have started) but the
> > cost:benefit ratio as i have pointed out is unreasonable. 
> 
> Did I ever claim this? You made this up right now. As of now
> it doesn't save a single bit.

Ok, I apologize - i assumed it has something to do with skb diet. 

cheers,
jamal

