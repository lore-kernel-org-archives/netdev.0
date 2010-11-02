From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Mon, 01 Nov 2010 21:54:19 -0500
Message-ID: <1288666459.4003.47.camel@dcbw.foobar.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
	 <20101025213841.635b9a15@nehalam>
	 <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
	 <20101026082832.4c5af2ef@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083Ab0KBCzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 22:55:36 -0400
In-Reply-To: <20101026082832.4c5af2ef@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-10-26 at 08:28 -0700, Stephen Hemminger wrote:
> On Mon, 25 Oct 2010 22:44:03 -0700
> Lorenzo Colitti <lorenzo@google.com> wrote:
> 
> > On Mon, Oct 25, 2010 at 9:38 PM, Stephen Hemminger
> > <shemminger@vyatta.com> wrote:
> > > This is incorrect. When link is lost, routes and address should not be
> > > flushed. They should be marked as tentative and then go through DAD again
> > > on the new network.
> > 
> > That won't help the case I am trying to fix, which is the case where
> > the new link has a global prefix different than the old link. Marking
> > the addresses as tentative will simply make them pass DAD and come
> > back as soon as link comes back. But since they don't match the prefix
> > that is assigned to the new link, they are unusable, because packets
> > can't be routed back to them.
> 
> For IPv4 this is already handled by network manager.
> Why couldn't the same apply to IPv6?

For this sort of thing, I tend to think that only higher-level network
management daemons like NM have the *possibility* to get this sort of
thing right, because only they have overall knowledge of the networking
situation, like whether you've actually connected to a different network
or not.  Specifically in the case of wifi, only the connection manager
(or wpa_supplicant) knows whether you're on a different network or  not,
anything else is a layering violation.

Remember that carrier loss does *not* indicate that you've switched
networks, both for wired and especially for wifi.  The only way you know
that you've really switched is when you've reconnected (or timed out the
reconnect) and inspected the new network situation.  It seems only
appropriate that the policy gets applied from higher levels based on a
more nuanced view of network state.

Dan

> 
> > > If you do it this way, you break routing protocols when link is brought
> > > down and back up.
> > 
> > The only addresses and routes flushed in this way should be ones that
> > aren't manually configured, i.e., the ones created by autoconf
> > (addrconf.c:2720 onwards). These won't be used by routing protocols,
> > except for link-local addresses. So I assume you're talking about
> > link-local here.
> 
> Not sure, let me do test it.
> 
> > Link-local addresses are immediately recreated in a tentative state as
> > soon as link comes back, because on NETDEV_UP addrconf_notify calls
> > addrconf_dev_config. So, this patch only makes it so that they become
> > tentative when link goes away and comes back. In that time, the router
> > that temporarily loses link is unable to send packets for the brief
> > period of time that the link is performing DAD, but if the router has
> > lost link, it will also fail to send the packet while link is lost.
> > What's the additional failure scenario? Will it help if I make it so
> > that link-local addresses aren't touched at all?
> 
> Link-local works fine.
> 


