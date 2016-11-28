From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to
 PHY tunables
Date: Mon, 28 Nov 2016 21:21:14 +0100
Message-ID: <20161128202114.GM17704@lunn.ch>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
 <20161128141410.GF4379@lunn.ch>
 <20161128192306.GA11474@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60739 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751154AbcK1UVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 15:21:16 -0500
Content-Disposition: inline
In-Reply-To: <20161128192306.GA11474@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 08:23:06PM +0100, Allan W. Nielsen wrote:
> Hi Andrew and Florian,
> 
> On 28/11/16 15:14, Andrew Lunn wrote:
> > On Mon, Nov 28, 2016 at 02:24:30PM +0100, Allan W. Nielsen wrote:
> > > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > >
> > > 3 types of PHY loopback are supported.
> > > i.e. Near-End Loopback, Far-End Loopback and External Loopback.
> > Is this integrated with ethtool --test? You only want the PHY to go
> > into loopback mode when running ethtool --test external_lb or maybe
> > ethtool --test offline.
> There are other use-cases for enabling PHY loopback:
> 
> 1) If the PHY is connected to a switch then a loop-port is sometime
>    used to "force/enable" one or more extra pass through the switch
>    core. This "hack" can sometime be used to achieve new functionality
>    with existing silicon.

With Linux, switches are managed via switchdev, or DSA. You will have
to teach this infrastructure that something really odd is going on
with one of its ports before you do anything like this in the PHY
layer. I suggest you leave this use case alone until somebody
really-really wants it. From my knowledge of the Marvell DSA driver,
this is not easy.

> 2) Existing user-space application may expect to be able to do the
>    testing on its own (generate/validate the test traffic).

Please can you reference some existing user-space application and the
kernel API it uses to put the PHY into loopback mode?

> We are always happy to integrate with any existing functionality, but
> as I understand "ethtool --test" then intention is to perform a test
> and then bring back the PHY in to a "normal" state (I may be
> wrong...).

Correct.

> The idea with this patch is to allow configuring loopback more
> "permanently" (userspace can decide when to activate and when to
> de-activate). I should properly have made that clear in the cover
> letter.

Leaving it in loopback is a really bad idea. I've spent days once
working out why an Ethernet did not work. Turned out the PHY powered
up in loopback mode, and the embedded OS running on it did not
initialise it to sensible defaults on probe. Packets we going out,
dhcp server was replying but all incoming packets were discarded.

It is really not obvious when everything looks O.K, but nothing works,
because the PHY is in loopback. There needs to be a big red flag to
warn you.

If you really do what to do this, you should look at NETIF_F_LOOPBACK
and consider how this concept can be applied at the PHY, not the MAC.
But you need the full concept, so you see things like:

2: eth0: <PHY_LOOPBACK,BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 80:ee:73:83:60:27 brd ff:ff:ff:ff:ff:ff

Humm, i've no idea how you actually enable the MAC loopback
NETIF_F_LOOPBACK represents. I don't see anything with ip link set.

     Andrew
