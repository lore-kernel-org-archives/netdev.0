From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Thu, 13 Dec 2012 12:33:32 -0600
Message-ID: <1355423612.21918.34.camel@dcbw.foobar.com>
References: <20121212170520.GA3060@minipsycho.orion>
	 <20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
	 <20121212181017.GB3060@minipsycho.orion>
	 <20121212101208.361ccda0@nehalam.linuxnetplumber.net>
	 <20121212182556.GC3060@minipsycho.orion>
	 <20121212103632.2020efce@nehalam.linuxnetplumber.net>
	 <20121212184925.GD3060@minipsycho.orion>
	 <20121212105448.490aca5c@nehalam.linuxnetplumber.net>
	 <20121212190613.GE3060@minipsycho.orion>
	 <20121212113433.21c05614@nehalam.linuxnetplumber.net>
	 <20121213161750.GA1914@minipsycho.orion> <50CA0D3D.5000503@gmail.com>
	 <20121213155423.07c47307@obelix.rh>
	 <20121213100933.6d68a8e5@nehalam.linuxnetplumber.net>
	 <20121213161733.7bffe897@obelix.rh>
	 <20121213102051.72ad69aa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755661Ab2LMSc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 13:32:28 -0500
In-Reply-To: <20121213102051.72ad69aa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-13 at 10:20 -0800, Stephen Hemminger wrote:
> On Thu, 13 Dec 2012 16:17:33 -0200
> Flavio Leitner <fbl@redhat.com> wrote:
> 
> > On Thu, 13 Dec 2012 10:09:33 -0800
> > Stephen Hemminger <shemminger@vyatta.com> wrote:
> > 
> > > On Thu, 13 Dec 2012 15:54:23 -0200
> > > Flavio Leitner <fbl@redhat.com> wrote:
> > > 
> > > > I am saying this because people are used to and there are scripts out
> > > > there using something like:
> > > > # ethtool <iface> | grep 'Link'
> > > > to react an interface failure.
> > > 
> > > Then the script is broken. It is asking about hardware state.
> > 
> > I was talking about the team master interface, so it makes sense
> > to check its 'hardware' state. Just think on 'bond0' interface
> > with no slaves. It should report Link detected: no.
> > 
> > See bond_release(), what happens if bond->slave_cnt == 0, for instance.
> > 
> 
> I was thinking more that ethtool operation for reporting link on
> the team device should use the proper check rather than just using netif_carrier_ok(),
> the team ethtool operation for get_link should be check IFF_RUNNING flag
> in dev->flags which is controlled by operstate transistions.

That's not entirely sufficient, because not everything uses ethtool to
deterine whether the link/carrier is active.  eg, anything listenting to
netlink for IFF_RUNNING won't know anything about this.  I may have
missed previous conversation, but IFF_RUNNING is AFAIK the sole
mechanism to indicate to userspace that the link is operational and
ready for general traffic.  Can the team drivers simply not set
IFF_RUNNING until the interface is actually ready for general traffic?

I'd just caution people to be careful when it comes to carrier/link
states, as a lot of stuff relies on it, and people keep trying to
slightly change the meaning of it.  We need it to be consistent across
net interfaces and driver implementations, not have specific meanings to
certain drivers that don't apply to others.

If teamd needs to manage the carrier state of the teamX interface,
perhaps instead of munging the actual carrier state itself, it can flip
some team-private value that is one component of determining whether
IFF_RUNNING gets set or not?

Dan
