From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Wed, 28 Jun 2006 08:22:43 -0400
Message-ID: <1151497363.5203.47.camel@jzny2>
References: <44A05FE0.7070203@trash.net> <44A0647A.1070209@trash.net>
	 <20060626145446.948105000@postel.suug.ch>
	 <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net>
	 <20060626.104654.98552111.davem@davemloft.net>
	 <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net>
	 <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2>
	 <20060628101832.GW1376@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:65425 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1423314AbWF1MWu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 08:22:50 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FvZ4G-0000ij-7h
	for netdev@vger.kernel.org; Wed, 28 Jun 2006 08:22:52 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060628101832.GW1376@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-28-06 at 12:18 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-27 09:07
[..]
> > Note the meta-setter (been sitting on it for too long) also set the
> > input_dev.
> 
> Could you share that piece of code so I don't have to duplicate
> that effort?
> 

I will look it up and send it your way - it is not complete (I have
changed machines twice since i first wrote it). Or maybe the intent of
your question was to ask how was the setting of input_dev was done?

> > BTW, in regards to the VLANs, what is wrong with using the
> > netdev->iflink to figure the real device? 
> 
> 
> vlan1
>           ifb1
> vlan2
> vlan3
>           ifb2
> vlan4
> 
> dhcp daemon would bind to ifb1 and use pktinfo cmsg to figure
> out whether the packet was received on vlan1 or vlan2, the
> actual physical device is of no interest anymore.
> 

Let me see if i understood correctly:
you have a device from both vlan1 and vlan2 both being redirected to
ifb1? and vlan 3, 4=> ifb2?
And i take it to make it interesting vlan1,2 on eth0 and vlan3,4 ontop
of eth1? note the iflink would/should reflect eth1/2. If you had bonding
or bridging in between it gets more interesting. But you are saying
you are no longer interested in the info that it came via eth1/2 at some
point, correct? 
Note, in such a case: iflink rewriting will do it just fine
but then you loose the original info (I think it would be good to not
loose such info to know the origin). I dont know if cmsg uses iflink at
all - they probably look at the ifindex.

Ok, now question: why are you binding on top of ifb? we could have
redirected this to ipip, or tun0 or loopback or eql etc where it may
equally not have made sense to bind to. I can see something like this
making sense for bonding or bridging but not as a generic answer for all
netdevices.

> Looking at your ifb code I see that you set skb->dev based on
> iif and update iif unconditionally. I see a lot of problems
> with this, firstly iif is already updated in the mirred action,
> secondly iif doesn't necessarily point to the device the packet
> was last seen on. Could you maybe explain the policy of iif
> you have in mind, it doesn't seem very consistent.
> 

The concept is to use ifb as a transitionary device. Packets come into
it from either the ingress side of the stack or egress and get returned
on the same side/spot they were found - with ifb represented as the
input device. What ifb does is independent of what mirred does (we could
redirect to other devices other than ifb).
 
Now that i pay attention to your patch i think i see the complications
it is introducing (i am not done yet)- and i did warn about this in the
discussion _and_ didnt we agree to leave this stuff alone? Can we drop
this change please?

> BTW, why does ifb have a hard header length? The resulting
> push and pull only slows things down.

Good question. I know there were a lot of oddities i had to deal with
when different link layers cross over (some have smaller headers than
other and yet others had none ;->)
I will have to go and look at my notes test cases and get back to you; 

It does work as it is right now (I only notice a pull - there is no
push).

cheers,
jamal 

