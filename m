From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 09:41:41 -0400
Message-ID: <1236865301.18739.18.camel@localhost.localdomain>
References: <200903121946.24847.rusty@rustcorp.com.au>
	 <1236858219.14863.18.camel@localhost.localdomain>
	 <1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com>
	 <20090312.055235.56926675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57700 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740AbZCLNno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 09:43:44 -0400
In-Reply-To: <20090312.055235.56926675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-03-12 at 05:52 -0700, David Miller wrote:
> From: Pantelis Koukousoulas <pktoss@gmail.com>
> Date: Thu, 12 Mar 2009 14:47:09 +0200
> 
> > > The problem is that there's no "my carrier detection is accurate" flag
> > > for drivers.  Drivers that don't support carrier detection (say, my
> > > Belkin PCMCIA NE2k card) always report "carrier on", but of course don't
> > > support carrier detection.  So when NetworkManager looks at the device
> > > and sees "hey, there's a carrier!" it will activate it, because a
> > > carrier means the cable is plugged in or the PHY *thinks* a cable is
> > > plugged in.
> > >
> > > So NetworkManager checks whether the device supports ethtool get_link or
> > > MII register carrier status in lieu of a general kernel driver flag for
> > > "I support carrier detection".
> > >
> > > Carrier is not on/off, it needs to be tristate, like on/off/unknown.  If
> > > it was unknown, NM could make an intelligent decision about this without
> > > resorting to ethtool/MII checks.  But we don't have that.
> > 
> > This looks like an independent problem imho, one of kernel<->userspace
> > API. The current 'defacto' way of finding out if detection is supported or
> > not (ethtool) seems to give the needed information even if somewhat ugly.
> > 
> > The issue discussed here as I understand it is whether virtio should or
> > should not support carrier status reporting. IMHO it should, since
> > it is useful functionality and doesn't cost much.
> > 
> > Dan, What is your opinion on that?
> 
> I think Dan is right.
> 
> If the driver doesn't provide an explicit carrier, there is no way to
> know for sure that it is on of off.  If NetworkManager decides that
> this means on, and it's really off, that isn't so nice.
> 
> And lots of very old drivers in the tree don't have a link indication
> handler, so this is a very real issue.
> 
> Not adding a link state handler to virtio_net for pompous reasons like
> some theoretical "clean design" claim is idiotic, and in the end bad
> for users who are using existing versions of NetworkManager.
> 
> I also think the NetworkManager change is wrong, lack of link
> indication support does not mean the link is always on, not by a
> country mile.  Tell that to all the ancient ethernet drivers in
> our tree.

Checking up more this morning in NetworkManager, here's the current
behavior with 0.7.x.

If the device doesn't support carrier detection (determined by checking
for ethtool or MII ioctl support), NetworkManager will *not* listen for
netlink carrier events.  These are triggered by
netif_carrier_on()/netif_carrier_off(), which even drivers that don't
support carrier detection will still sometimes send.

However, NetworkManager will assume carrier=on, because NM is designed
such that if the carrier is not on, the nothing can be done with the
device because there's no cable connected.

It will then try to automatically bring up any valid 'autoconnect'
ethernet connection.  This will obviously fail, and when NM runs out of
valid 'autoconnect' ethernet configs, the device will be dormant until
the user explicitly chooses to activate it from the UI.

This shouldn't be an issue, because NM supports multiple active devices,
and thus if you have a wifi connection as well, that will successfully
activate and wifi will get the default route while the ethernet device
is still trying its hardest to DHCP or whatever.

Of course, if you've configured a static IP address for your ethernet
interface, NM will happily bring up the non-carrier-capable ethernet
interface with the static IP, because there's no way to know whether or
not there's a cable plugged in when the driver reports carrier=on

Of course, if you've *not* selected "Connect automatically", then NM
will wait for you to do something before configuring the interface, as
expected.

This matches the behavior of most distro network systems where, if the
card didn't support carrier detection and since it would then report
IFF_UP/IFF_LOWER_UP/IFF_RUNNING/etc, the distro scripts would configure
the device anyway, because the driver reports carrier=on.

Dan


