From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Sun, 02 Jul 2006 09:59:32 -0400
Message-ID: <1151848772.5093.252.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>
	 <1150815375.5270.78.camel@jzny2>  <44980FA3.1000009@trash.net>
	 <1151001712.5392.47.camel@jzny2>  <449BFB82.9000008@trash.net>
	 <1151159997.6716.116.camel@jzny2>  <449FC329.7080609@trash.net>
	 <1151413263.6516.51.camel@jzny2>  <44A74A44.4000304@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, hawk@diku.dk,
	russell-tcatm@stuart.id.au, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:17295 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750889AbWGBN7i
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 09:59:38 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fx2U9-0005DW-1I
	for netdev@vger.kernel.org; Sun, 02 Jul 2006 09:59:41 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44A74A44.4000304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-02-07 at 06:23 +0200, Patrick McHardy wrote:
[..]
> > - Any message to user space may be lost whether it has ifi_change or
> > not. You need some way to figure out a message was lost and declare your
> > state may be invalid. The -ENOBUFs is one way to discover stale state.
> 
> Thats not the point. ifi_change doesn't inform you about updates, it
> informs you about specific changes. 

yes, 

> And you can't determine those in
> the case of lost notifications without keeping the old state yourself.

nod,

> It may save you some time _comparing_ (not searching) in case it wasn't
> lost, 

This is one of the points of where it has value.

Take a hypothetical example of when you have a gazillion events/sec
happening, this is an exageration in case of ifi_change, just assume it
so for illustration purposes. Assume no messages are lost. Assume you
are only interested in the netdevice becoming  promisc or un-promisc.
In such a case, you can quickly check if among the vector of events
that this just happened or not.

> but it only contains a very limited set of information and nothing
> saves you from searching the entry a message refers to based on the
> primary keys (which unfortunately aren't even defined for every message
> type, which means they're not even clearly defined inside the kernel.
> routing rules are one example). 

In some cases it does provide you with details - example in the case of
booleans where it will tell you something changed from 0->1 or 1->0.
Actually the promisc case i gave is a bad example because it falls under
such a category although i hope it still made the point i was trying to
make. 

But yes in general, it is just supposed to provide you with info of
"dude, you got a message from X and Y" - which is more useful than the
select() "dude, you got a message". You have then to go and read that
message if you are interested or if you are busy you can go later.

> Its a hack for some specific usage case,
> and since you're defending this so hard, I'm naturally wondering if
> you introduced it?
> 

No, i didnt - it has been there for years; it may/must have been Alexey
who introduced it.

The reason i am defending it is i find it useful and it is a classical
approach in event management; i have seen it used in a lot of middleware
as an optimization. When you have a vector of events that can be
reported, then as optimization you dont waste resources by sending
details about the event in case nobody is interested in hearing about
the details or is ready to process them.

BTW,theres a consistency bug/hack at the moment in iproute2 on its
usage.

> > - by looking at ifi_change i can tell what changed from about 10 
> > other things reflected in the flags. If you get an ENOBUFS in this case
> > (or any other), it means your state is not consistent and to have
> > reliable info you need to query the kernel.
> 
> The flags only reflect a single piece of information, one that userspace
> needs to be able to reconstruct anyway. Once again the point: netlink
> notifications are _update_ messages, not state change messages. This is
> a fundamental difference, misleading userspace (see tc monitor) to
> believing it is something different for very limited usage cases does
> nothing good. I hereby state my believe that 99% of netlink users
> are broken.
> 

yes, it would mislead users who dont use it appropriately such as ip mon
but that doesnt make it less valuable. I thought ip mon would bitch if
it received enobufs? 

cheers,
jamal

