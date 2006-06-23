From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Fri, 23 Jun 2006 16:32:34 +0200
Message-ID: <449BFB82.9000008@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>	 <1150815375.5270.78.camel@jzny2>  <44980FA3.1000009@trash.net> <1151001712.5392.47.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, hawk@diku.dk,
	russell-tcatm@stuart.id.au, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64675 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750788AbWFWOch
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 10:32:37 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151001712.5392.47.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-20-06 at 17:09 +0200, Patrick McHardy wrote:
> 
>>The thing I'm not sure about is whether this wouldn't be handled better
>>by userspace, 
> 
> 
> If you do it in user space you will need a daemon of some form; this is
> my preference but it seems a lot of people hate daemons - the standard
> claim is it is counter-usability. Such people are forgiving if you built
> the daemon into the kernel as a thread. Perhaps the netcarrier that
> Stefan Rompf has added could be extended to handle this)

I absolutely disagree, in my opinion we currently have too few
specialized daemons and a lot too much wild shell scripting with
seding, awking, grepping. I'm actually working on a daemon that
provides a small scripting language to express networking configuration
states and react to result set changes and state transitions.
Its far from complete, but already allows you to express things like
"on transition from { none, link flags !up } to { link flags up }
execute /etc/network/link/$LINK_NAME up" (same for routes, addresses,
basically all object types) or "for each link with flags lowerup,up
execute add-to-bridge.sh". The value of each expression is dumped
into the environment on execution, so you can comfortably use
$LINK_NAME or $LINK_MTU instead of having to cut it out the
"ip link list" output. Should be trivial to support link speed changes
once we have notifications for that.

>>if the link layer speed changes you might not want
>>proportional scaling but prefer to still give a fixed amount of that
>>bandwidth to some class, for example VoIP traffic. Do we have netlink
>>notifications for link speed changes?
> 
> 
> Not there at the moment - but we do emit event for other link layer
> stuff like carrier on/off - so adding this should be trivial and a
> reasonable thing to have; with a caveat: it will be link-layer specific;
> so whoever ends up adding will have to be careful to make sure it is not
> hard-coded to be specific to ethernet-like netdevices. It could probably
> be reported together with link state as a TLV like ETHER_SPEED_CHANGED
> which carries probably old speed and new speed
> and maybe even reason why it changed.

I don't think it should carry both old and new speed. Netlink
notifications usually provide a snapshot of the new state, but
no indication what changed, with one notable exception, the
ifi_change field, which IMO is a hack for lazy userspace. Since
notifications can get lost, userspace needs to resync occasionally.
The naiive approach (works for every other object) to determine if
the object state changed from my last known state is to compare
all attributes .. but the ifi_change field will be different
between notifications and dumps even if the object itself didn't
change. "Lazy userspace" because looking at ifi_change is obviously
only useful if it doesn't keep its last known state and tries to
derive the change from update notifications alone .. which means it
fails when notifications are lost.

