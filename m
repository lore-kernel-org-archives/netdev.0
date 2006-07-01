From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 22:59:45 -0400
Message-ID: <1151722785.5093.51.camel@jzny2>
References: <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2>
	 <20060630203034.GN14627@postel.suug.ch>
	 <20060630.133348.68039806.davem@davemloft.net>
	 <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch>
	 <1151703097.5270.307.camel@jzny2>  <20060630234512.GR14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:19408 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751420AbWGAC7s
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 22:59:48 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FwVi5-0001TJ-V0
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 22:59:53 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630234512.GR14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-01-07 at 01:45 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 17:31
> > Better to explain the reason for ifb first:
> > ifb exists initially as a replacement for IMQ. 
> > 1) qdiscs/policies that are per device as opposed to system wide.
> > This now allows for sharing.
> > 
> > 2) Allows for queueing incoming traffic for shaping instead of
> > dropping.
> > 
> > In other wise, the main use is for multiple devices to redirect to it.
> > Main desire is not for it to redirect to any other ifb device or eth
> > devices. I actually tried to get it to do that, but run into issues
> > of complexity and and came up with decision to drop instead of killing
> > the machine.
> > Other than that, it can redirect to any other devices - but may still
> > not be meaningful.
> 
> Last time I'm asking.

Then please listen carefully - because if you read my message with a
reasonable openness the answer is there. 

>  Why are packets dropped? 

When looping happens the only sane thing to do is to drop packets.

I mentioned this was a very tricky thing to achieve in all cases since
there are many behaviors and netdevices that have to be considered. As
an example i ended not submitting the code for looping from egress to
ingress because i felt it needed more testing. And i am certain i have
missed some other device combinations.
Loops could happen within ingress or egress. They could mostly happen
because of mirred or ifb. And some i have discovered via testing.

> You mentioned tc_verd is set to 0 leading to a invalid from verdict. 

yes, for ifb.

> Fact is that the from verdict is set to a meaningful value again at 
> dev_queue_xmit() or ing_filter() so ifb_xmit() only sees valid values. 

Ok, Thomas this is one of those places where we end up colliding for no
good reason - your statement above is accusatory. And sometimes i say 3
things and you pick one and use that as context. The ifb does clear the
field. So if you get redirected again, it will be 0.

> tx locks of individual ifb devices are independant, why would it deadlock? 

different instances of the same device do not deadlock. If however, you
have a series of devices in which A->B->C->D->A then you will have a
possible deadlock. In the case of the ifb i dissallowed it because it
was obvious from the testing. 

> Where is the packet exactly dropped?
> 

For the above in the ifb when they come in with from=0.

> > I have been thinking of Herberts change of qdisc_is_running and this may
> > help actually.
> 
> Help on what?

In the case of deadlocks. Now that it is impossible to contend for the
txlock twice (with that patch), a second redirect will end up just
enqueueing.

cheers,
jamal

