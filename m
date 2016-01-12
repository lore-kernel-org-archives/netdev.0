From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: turn carrier off on phy attach
Date: Tue, 12 Jan 2016 01:57:45 +0100
Message-ID: <20160112005745.GA7690@lunn.ch>
References: <1452365045-5364-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452365045-5364-1-git-send-email-sjoerd.simons@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 09, 2016 at 07:44:05PM +0100, Sjoerd Simons wrote:
> The operstate of a networking device initially IF_OPER_UNKNOWN aka
> "unknown", updated on carrier state changes (with carrier state being on
> by default). This means it will stay unknown unless the carrier state
> goes to off at some point, which is not the case if the phy is already
> up/connected at startup.
> 
> Explicitly turn off the carrier on phy attach, leaving the phy state
> machine to turn the carrier on when it has done the initial negotiation.

RFC 2863 says:

   Whenever an interface table entry is created (usually as a result
   of system initialization), the relevant instance of ifAdminStatus
   is set to down, and ifOperStatus will be down or notPresent.

and

   The notPresent state is a refinement on the down state which
   indicates that the relevant interface is down specifically because
   some component (typically, a hardware component) is not present in
   the managed system.

So if we have a PHY, setting it to down is correct with respect to the
RFC.

> Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
> 
> ---
> 
>  drivers/net/phy/phy_device.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 0bfbaba..a30ce1a 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -668,6 +668,11 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  
>  	phydev->state = PHY_READY;
>  
> +	/* Signal to the core network layer the phy supports
> +	 *  carrier detection
> +	 */

I don't agree with the comment. All we are doing is getting the core
state to agree with the phy state. The next thing we do with the phy
is reset it, so the carrier is going to be off.

Please rewrite the comment, and then i can give a reviewed-by.

Thanks
	Andrew

> +	netif_carrier_off(phydev->attached_dev);
> +
>  	/* Do initial configuration here, now that
>  	 * we have certain key parameters
>  	 * (dev_flags and interface)
> -- 
> 2.7.0.rc3
> 
