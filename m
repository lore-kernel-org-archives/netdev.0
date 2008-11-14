From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv6 and link state transitions
Date: Fri, 14 Nov 2008 15:28:40 -0800
Message-ID: <20081114152840.41c0b6c6@extreme>
References: <78EAC2D97114034EB62AAA10FCC2510608047D83@USA7061MS01.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Tarr, Stephen F" <Stephen.Tarr@xerox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41194 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbYKNX2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 18:28:45 -0500
In-Reply-To: <78EAC2D97114034EB62AAA10FCC2510608047D83@USA7061MS01.na.xerox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008 14:59:27 -0800
"Tarr, Stephen F" <Stephen.Tarr@xerox.com> wrote:

> I'm using 2.6.27.4 on a powerpc with the gianfar Ethernet driver
> and an MII PHY.  If I boot the system with the Ethernet cable
> disconnected, wait 30 seconds or so, then plug in the cable, the
> interface comes up but I don't see the expected IPv6 DAD probe
> for the link-local address.
> 
> Adding some printfs in addrconf.c shows a NETDEV_UP when the
> interface is initialized but no NETDEV_CHANGE when the link comes
> up.  The transition is detected by the phy driver but filtered out
> by the test-and-clear in netif_carrier_on because
> (dev->state & NOCARRIER) is already clear.
> 
> With Brian Haley's patch to force a link state transition at
> startup, the behavior gets even more interesting.  In that case,
> I see the initial NETDEV_UP and an immediate NETDEV_CHANGE/link
> down.  When the cable's connected, I see a NETDEV_CHANGE/link up
> followed by an immediate MLDv2 announcement and a DAD probe.
> (These were apparently queued up by the NETDEV_UP event, but
> held off by the Ethernet driver.)  After the initialization
> timeout, I see the expected DAD probe, router solicitation and
> so on.
> 
> This patch to the gianfar driver fixes the problem, but only for
> that driver.  A better approach might be to set the initial link
> state in the phy driver, but I'd appreciate some suggestions for
> how and where to do that.
> 
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 3bc19b7..46566ba 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -533,6 +533,9 @@ static int init_phy(struct net_device *dev)
>         char phy_id[BUS_ID_SIZE];
>         phy_interface_t interface;
> 
> +       // assume link down until phy reports otherwise
> +       set_bit(__LINK_STATE_NOCARRIER, &dev->state);
> +
>         priv->oldlink = 0;
>         priv->oldspeed = 0;
>         priv->oldduplex = -1;
> 

Driver should not use set_bit directly.
The correct way for a driver that has carrier to work is

mydrvr_open(struct net_device *dev)
{
...
	if (mydrv_phy_isoffline(dev))
              netif_carrier_off(dev);
...
}

mydrv_phy_intr(...) {
    if (mydrv_phy_isoffline(dev))
          netif_carrier_off(dev);
    else
          netif_carrier_on(dev)
}
