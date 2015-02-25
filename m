From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Wed, 25 Feb 2015 01:15:34 +0100
Message-ID: <20150225001534.GB15633@lunn.ch>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
 <20150224223039.GC1332@gospo.home.greyhouse.net>
 <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
 <54ED017E.6000902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rafa?? Mi??ecki <zajec5@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48766 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbbBYASi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 19:18:38 -0500
Content-Disposition: inline
In-Reply-To: <54ED017E.6000902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 02:55:58PM -0800, Florian Fainelli wrote:
> On 24/02/15 14:50, Rafa?? Mi??ecki wrote:
> > On 24 February 2015 at 23:30, Andy Gospodarek <gospo@cumulusnetworks.com> wrote:
> >> On Tue, Feb 24, 2015 at 06:42:07PM +0100, Rafa?? Mi??ecki wrote:
> >>> BCM53xx is series of Broadcom Ethernet switches that can be found in
> >>> various (mostly home) routers.
> >>> They are quite simple switches with mainly just support for:
> >>> 1) Tagging incoming packets (PVID)
> >>> 2) Untagging outgoing packets
> >>> 3) Forwarding all packets across a single VLAN
> >>>
> >>> This driver is split into common code (module) and bus specific code.
> >>> Right now only PHY (MDIO) support is included, other could follow after
> >>> accepting this driver. It was successfully tested on BCM4706 SoC with
> >>> BCM53125.
> >>>
> >>> You could notice it's yet another try of submitting b53 driver. This
> >>> time it was modified to use recently introduced switchdev API which
> >>> hopefully make it possible to accept it mainline.
> >>
> >> I must confess I do not know the entire history of this driver, but I
> >> have a few comments....
> > 
> > I guess previous discussions were mostly focusing on API (like
> > swconfig), so a good review of b53 is still highly wanted!
> > 
> > 
> >>> diff --git a/drivers/net/phy/b53/b53_common.c b/drivers/net/phy/b53/b53_common.c
> >>> new file mode 100644
> >>> index 0000000..fce6b71
> >>> --- /dev/null
> >>> +++ b/drivers/net/phy/b53/b53_common.c
> >> [...]
> >>> +
> >>> +/*****************
> >>> + * Net device ops
> >>> + *****************/
> >>> +
> >>> +static netdev_tx_t b53_port_xmit(struct sk_buff *skb, struct net_device *dev)
> >>> +{
> >>> +     dev_kfree_skb(skb);
> >>> +     dev->stats.tx_dropped++;
> >>> +
> >>> +     return NETDEV_TX_OK;
> >>> +}
> >>> +
> >>> (...)
> >>> +
> >>> +static const struct net_device_ops b53_port_netdev_ops = {
> >>> +     .ndo_start_xmit                 = b53_port_xmit,
> >>> +     .ndo_vlan_rx_add_vid            = b53_port_vlan_rx_add_vid,
> >>> +     .ndo_vlan_rx_kill_vid           = b53_port_vlan_rx_kill_vid,
> >>> +     .ndo_switch_parent_id_get       = b53_port_switch_parent_id_get,
> >>> +     .ndo_bridge_setlink             = b53_port_bridge_setlink,
> >>> +};
> >>
> >> I see there is an xmit function, but no napi registration at all.
> >>
> >> Is this simply because the SoC ethernet dev is doing all the frame rx?
> >> Is is able to demux the frames correctly, so it is clear which swXpY
> >> received the frame?  That will be necessary to ensure that standard
> >> applications that want to open sockets directly on the needed interfaces
> >> can still function properly.
> > 
> > If you take a look at b53_port_xmit you'll start understanding why
> > there is no NAPI ;)
> > 
> > As said in the commit message, these switches are really simple
> > devices. We can't actually send packets to the particular ports
> > (unless something has changed in the more recent hardware).
> 
> These switches all support Broadcom tags, so you could use your host CPU
> Ethernet MAC to send/receive packets to/from specific ports of the
> switch, and then this is just like DSA, but everything that you say
> below is true.

If this hardware does support the concept of tags compatible to the
existing Broadcom Starfighter 2, should we not do that? Is there a
good reason these chips should use a difference abstraction than
Starfighter 2 and the Marvell devices?

	    Andrew
