From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Sun, 02 Jul 2006 06:23:32 +0200
Message-ID: <44A74A44.4000304@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>	 <1150815375.5270.78.camel@jzny2>  <44980FA3.1000009@trash.net>	 <1151001712.5392.47.camel@jzny2>  <449BFB82.9000008@trash.net>	 <1151159997.6716.116.camel@jzny2>  <449FC329.7080609@trash.net> <1151413263.6516.51.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	russell-tcatm@stuart.id.au, hawk@diku.dk,
	Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65518 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932228AbWGBEXf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 00:23:35 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151413263.6516.51.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, missed your reply so far.

>>Then what is the intent, it doesn't carry any other information?
> 
> 
> Generally it is a filter to what the ifi_flags reflect.
>>From an event architecture scalability perspective, it is useful to be
> able to look at what changed without having to query the source. That is
> what ifi_change provides.  So it is not "Lazy userspace" rather it is an
> effective optimization.
> You keep less state and you have less message exchanges between user and
> kernel.

It might have been, but the situation is a bit more complicated today,
and special case solutions (aka hacks) don't work very well for the
huge diversity of interest in update messages. Besides that, it is
flawed.

>>It includes information that are not available any other way from
>>the kernel, yet the information is not transmitted reliably. How
>>could a program that relies on this possibly work reliable?
> 
> 
> Ok, so first lets separate them as two different issues:
> 
> - Any message to user space may be lost whether it has ifi_change or
> not. You need some way to figure out a message was lost and declare your
> state may be invalid. The -ENOBUFs is one way to discover stale state.

Thats not the point. ifi_change doesn't inform you about updates, it
informs you about specific changes. And you can't determine those in
the case of lost notifications without keeping the old state yourself.
It may save you some time _comparing_ (not searching) in case it wasn't
lost, but it only contains a very limited set of information and nothing
saves you from searching the entry a message refers to based on the
primary keys (which unfortunately aren't even defined for every message
type, which means they're not even clearly defined inside the kernel.
routing rules are one example). Its a hack for some specific usage case,
and since you're defending this so hard, I'm naturally wondering if
you introduced it?

> - by looking at ifi_change i can tell what changed from about 10 
> other things reflected in the flags. If you get an ENOBUFS in this case
> (or any other), it means your state is not consistent and to have
> reliable info you need to query the kernel.

The flags only reflect a single piece of information, one that userspace
needs to be able to reconstruct anyway. Once again the point: netlink
notifications are _update_ messages, not state change messages. This is
a fundamental difference, misleading userspace (see tc monitor) to
believing it is something different for very limited usage cases does
nothing good. I hereby state my believe that 99% of netlink users
are broken.

> Hope that makes sense.

Me too :)

