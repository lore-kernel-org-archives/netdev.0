From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 27 Jun 2006 09:01:02 -0400
Message-ID: <1151413263.6516.51.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>
	 <1150815375.5270.78.camel@jzny2>  <44980FA3.1000009@trash.net>
	 <1151001712.5392.47.camel@jzny2>  <449BFB82.9000008@trash.net>
	 <1151159997.6716.116.camel@jzny2>  <449FC329.7080609@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	russell-tcatm@stuart.id.au, hawk@diku.dk,
	Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:8632 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932189AbWF0NBV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 09:01:21 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FvDBt-00083n-E4
	for netdev@vger.kernel.org; Tue, 27 Jun 2006 09:01:17 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <449FC329.7080609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-26-06 at 13:21 +0200, Patrick McHardy wrote:
> jamal wrote:

> > scalability issues abound when you have a gazillion things to look at.
> > There used or may still be a way to tell from looking at netlink socket
> > that an error occurred since last time - such as "a message was lost".
> > You could use that to tell a message was lost and do scanning only
> > then.  
> 
> It returns -ENOBUFS on socket overrun. Without it netlink notifications
> wouldn't be very useable as you couldn't figure out when you missed
> some.
> 

I think you are probably right; it is -ENOBUFS. I recall something along
the lines of a socket->error flag somewhere. I will go and snoop on
code.

> >> but the ifi_change field will be different
> >>between notifications and dumps even if the object itself didn't
> >>change. "Lazy userspace" because looking at ifi_change is obviously
> >>only useful if it doesn't keep its last known state and tries to
> >>derive the change from update notifications alone .. which means it
> >>fails when notifications are lost.
> >>
> > 
> > 
> > But thats not the real intent for it. 
> 
> Then what is the intent, it doesn't carry any other information?

Generally it is a filter to what the ifi_flags reflect.
>From an event architecture scalability perspective, it is useful to be
able to look at what changed without having to query the source. That is
what ifi_change provides.  So it is not "Lazy userspace" rather it is an
effective optimization.
You keep less state and you have less message exchanges between user and
kernel.

> It includes information that are not available any other way from
> the kernel, yet the information is not transmitted reliably. How
> could a program that relies on this possibly work reliable?

Ok, so first lets separate them as two different issues:

- Any message to user space may be lost whether it has ifi_change or
not. You need some way to figure out a message was lost and declare your
state may be invalid. The -ENOBUFs is one way to discover stale state.
- by looking at ifi_change i can tell what changed from about 10 
other things reflected in the flags. If you get an ENOBUFS in this case
(or any other), it means your state is not consistent and to have
reliable info you need to query the kernel.

Hope that makes sense.

cheers,
jamal


