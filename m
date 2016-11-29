From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to
 PHY tunables
Date: Tue, 29 Nov 2016 16:32:48 +0100
Message-ID: <20161129153247.GB16626@microsemi.com>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
 <20161128141410.GF4379@lunn.ch>
 <20161128192306.GA11474@microsemi.com>
 <20161128202114.GM17704@lunn.ch>
 <fabb91cd-9fc5-d935-727e-ff57e441e919@gmail.com>
 <20161129004653.GA24782@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <raju.lakkaraju@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0052.outbound.protection.outlook.com ([104.47.41.52]:25280
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757879AbcK2PdN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 10:33:13 -0500
Content-Disposition: inline
In-Reply-To: <20161129004653.GA24782@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 28/11/16 21:21, Andrew Lunn wrote:
> On Mon, Nov 28, 2016 at 08:23:06PM +0100, Allan W. Nielsen wrote:
> > On 28/11/16 15:14, Andrew Lunn wrote:
> > > On Mon, Nov 28, 2016 at 02:24:30PM +0100, Allan W. Nielsen wrote:
> > > > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > > > 3 types of PHY loopback are supported.
> > > > i.e. Near-End Loopback, Far-End Loopback and External Loopback.
> > > Is this integrated with ethtool --test? You only want the PHY to go
> > > into loopback mode when running ethtool --test external_lb or maybe
> > > ethtool --test offline.
> > There are other use-cases for enabling PHY loopback:
> > 1) If the PHY is connected to a switch then a loop-port is sometime
> >    used to "force/enable" one or more extra pass through the switch
> >    core. This "hack" can sometime be used to achieve new functionality
> >    with existing silicon.
> With Linux, switches are managed via switchdev, or DSA. You will have
> to teach this infrastructure that something really odd is going on
> with one of its ports before you do anything like this in the PHY
> layer. I suggest you leave this use case alone until somebody
> really-really wants it. From my knowledge of the Marvell DSA driver,
> this is not easy.
> > 2) Existing user-space application may expect to be able to do the
> >    testing on its own (generate/validate the test traffic).
> Please can you reference some existing user-space application and the
> kernel API it uses to put the PHY into loopback mode?
The application I had in mind, is the switch application that I'm normally
working on (a product of MSCC). This application was originally written for
eCos, but is now moved to Linux. The application is currently doing almost
all drivers in user-space (reaching the HW through a UIO driver). This
means that we have an existing set of APIs and associated applications which
among many other things tests the PHYs using loopback facilities. There are
also cases where the loopports are being used as I described earlier.

We are looking at moving some of the drivers into the kernel, and that
require us to find a solution to such issues (nothing have been decided,
and nothing will be decided anytime soon).

I also understand your point of view, you have presented pretty good
arguments, and I do not expect this to change your view on this topic.

On 29/11/16 01:46, Andrew Lunn wrote:
> > > If you really do what to do this, you should look at NETIF_F_LOOPBACK
> > > and consider how this concept can be applied at the PHY, not the MAC.
> > > But you need the full concept, so you see things like:
> > >
> > > 2: eth0: <LOOPBACK,BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
> > >     link/ether 80:ee:73:83:60:27 brd ff:ff:ff:ff:ff:ff
> > >
> > > Humm, i've no idea how you actually enable the MAC loopback
> > > NETIF_F_LOOPBACK represents. I don't see anything with ip link set.
> >
> > I am afraid you lost me on this, NETIF_F_LOOPBACK is a netdev_features_t
> > bit, so it tells ethtool that this is a potential feature to be turned
> > on with ethtool -K <iface>.
> Yep, i'm talking rubbish after jumping to a wrong conclusion.
> > The semantics of this loopack feature are
> > not defined AFAICT, but a reasonable behavior from the driver is to put
> > itself in a mode where packets send by a socket-level application are
> > looped through the Ethernet adapter itself. Whether this happens at the
> > DMA level, the MII signals, or somewhere in the PHY, is driver specific
> > unfortunately.
> 
> Yes, the interesting one might be forcedeth which writes to the PHY
> BMCR_LOOPBACK | BMCR_FULLDPLX | BMCR_SPEED1000;
> when the NETIF_F_LOOPBACK feature is set.
> 
> Maybe this could be generalised and made available for all MACs which
> don't support MAC loopback?
> 
> What needs considering is the correct duplex and speed. We need to
> ensure the MAC and PHY agree on this.
> 
> > Now, there is another way to toggle a loopback for a given Ethernet
> > adapter which is to actually set IFF_LOOPBACK in dev->flags for this
> > interface. Some drivers seem to be able to properly react to that as
> > well, although I see no way this can be done looking at the iproute2 or
> > ifconfig man pages..
> 
> I prefer this one, since i expect this will set LOOPBACK in
> 
> 2: eth0: <LOOPBACK,BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
> 
> making it lot more obvious something funny is going on.
Raju and I will need to dive deeper into this to understand the details of
what you are suggesting. But I think it points in a different direction...

The approach you are describing is to use existing flags (which will make
the loop-back state visible to the user, which is a good thing) to set the
loopback state. Where/how the frames are looped depends on the drivers. The
suggested tunable could be kept, but it will only allow the user to say,
"if the frames are looped in the PHY, then this is how I want them to be
looped".

Also, it does not make a lot of sense for the "FAR" loopback patch (which I
admit is a bit strange...).

The facility we are seeking is much more specific: "Allow the user to bring
the PHY in and out of specific loopback modes" assuming that the user have
reasons to do so.

I'm not sure if your main dislike with this feature is the lack of
transparency/visibility to the end-user, or if is the concept of allowing
the user to control where and how frames are looped (or both).

Best regards
Allan W. Nielsen
