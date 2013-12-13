From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: stable privacy addresses
Date: Fri, 13 Dec 2013 12:50:33 +0100
Message-ID: <20131213115033.GA7332@order.stressinduktion.org>
References: <20131213085549.GA3685@order.stressinduktion.org> <52AAE273.7070806@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, fgont@si6networks.com
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52988 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806Ab3LMLuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 06:50:35 -0500
Content-Disposition: inline
In-Reply-To: <52AAE273.7070806@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 11:33:23AM +0100, Florent Fourcot wrote:
> Do you not provide a configuration via netlink for the secret?

I definitely will provide a netlink interface. I already have a patch here but
I am not sure how the interface will work out in the end. See below.

> > +config IPV6_ADDRESS_GEN_MODE_STABLE_PRIVACY_V1
> > +       bool "Stable privacy address generation v1"
> > +       help
> > +         Stable privacy address generation mode v1. Further
> > +         information can be found here:
> > +	 http://tools.ietf.org/html/draft-ietf-6man-stable-privacy-addresses-16
> > +
> > +	 This option may need support from distributions to install
> > +	 the stable secret early at boot up (otherwise link-local
> > +	 addresses will be generated too late). If you don't have
> > +	 services depending on link-local addresses on boot-up you can
> > +	 activate this mode and install the stable secret any time
> > +	 later by hand by writing it to
> > +	 /proc/sys/net/ipv6/stable_privacy_secret.
> > +
> 
> Here is your documentation inconsistent with before. The right file is
> probably /proc/sys/net/ipv6/stable_address_secret
> 
> You configuration is for all interfaces the same, isn't? I would like a
> configuration possibility per interface, to mix EUI64 and stable privacy
> addresses on the same device.

You mean like EUI-64 link-local and privacy-stable ones for global scope?
This indeed does sound useful.

> In the same way, the configuration of the secret per interface could be
> useful (simple example: two NIC on the same LAN).

Hmm, I thought about that too, but have not found a valid reason to support
it yet, given the numerous other configuration possibilities.

My current problem is how to make this interface as robust as possible to
use so that distributions can support it.

I just started coding support for tracking DAD-errors accross reboots so
e.g. if a privstbl address has two DAD conflicts before it stabilzes,
it should get the same one after reboot. Ideally we would serialize
this information into user-space and apply it on next boot. But what key
should we use to store the dad-conflicts (MAC or interface name etc. or
make it even configurable?). Should we store information on interfaces
which are not yet registered too, or always kick link-local generation by
hand? When should we store those numbers? If we only do that at shutdown
time we may have lost some manually destroyed interfaces already.

I have a similar problem with virtual interfaces. It would be better to
identify them by name and not by mac-address. Also we should include the name
in the hash, so we could have different kind of hashes per interface.

The hash itself needs to be stable and one particular hash version must not get
touched after release, otherwise we could change people's IPv6 addresses
accross upgrades.

The combination of all those options call for a very complex interface. In the
end I hoped to get basic support into the kernel and leave complex policies to
user-space (that's out of scope for this patch but I already have some ideas).

> > -static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
> > +static void addrconf_dad_stop(struct inet6_ifaddr *ifp, bool dad_failed)
> > 
> 
> The passage of dad_failed from int to bool is not directly connected
> with this feature, can you maybe split it in another patch?

I guess I should do that. But in the end I am almost always too lazy to
submit such patches then. ;)

I'll also improve the documentation in the next versions, thanks for the
corrections! It seems I did not update it regullary enough every time I did 
change in the code.

Thanks for review,

  Hannes
