From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] net: usb: rtl8150: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 14 Mar 2017 19:12:59 +0200
Message-ID: <20170314171259.p5ag5a5656elqdg7@p310>
References: <1489356985-24117-1-git-send-email-tremyfr@gmail.com>
 <20170313150020.25ibsslebcscmngb@p310>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170313150020.25ibsslebcscmngb@p310>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-03-13 17:00:20, Petko Manolov wrote:
> On 17-03-12 23:16:25, Philippe Reynes wrote:
> > The ethtool api {get|set}_settings is deprecated. We move this driver to new 
> > api {get|set}_link_ksettings.
> > 
> > As I don't have the hardware, I'd be very pleased if someone may test this 
> > patch.
> 
> I've got some old adapters around and will drop you a line when i test the 
> patch.

The adapter is working fine with your patch.  You may add:

Acked-by: Petko Manolov <petkan@nucleusys.com>


cheers,
Petko


> > Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> > ---
> >  drivers/net/usb/rtl8150.c |   35 ++++++++++++++++++++---------------
> >  1 files changed, 20 insertions(+), 15 deletions(-)
> > 
> > diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> > index c81c791..daaa88a 100644
> > --- a/drivers/net/usb/rtl8150.c
> > +++ b/drivers/net/usb/rtl8150.c
> > @@ -791,47 +791,52 @@ static void rtl8150_get_drvinfo(struct net_device *netdev, struct ethtool_drvinf
> >  	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
> >  }
> >  
> > -static int rtl8150_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
> > +static int rtl8150_get_link_ksettings(struct net_device *netdev,
> > +				      struct ethtool_link_ksettings *ecmd)
> >  {
> >  	rtl8150_t *dev = netdev_priv(netdev);
> >  	short lpa, bmcr;
> > +	u32 supported;
> >  
> > -	ecmd->supported = (SUPPORTED_10baseT_Half |
> > +	supported = (SUPPORTED_10baseT_Half |
> >  			  SUPPORTED_10baseT_Full |
> >  			  SUPPORTED_100baseT_Half |
> >  			  SUPPORTED_100baseT_Full |
> >  			  SUPPORTED_Autoneg |
> >  			  SUPPORTED_TP | SUPPORTED_MII);
> > -	ecmd->port = PORT_TP;
> > -	ecmd->transceiver = XCVR_INTERNAL;
> > -	ecmd->phy_address = dev->phy;
> > +	ecmd->base.port = PORT_TP;
> > +	ecmd->base.phy_address = dev->phy;
> >  	get_registers(dev, BMCR, 2, &bmcr);
> >  	get_registers(dev, ANLP, 2, &lpa);
> >  	if (bmcr & BMCR_ANENABLE) {
> >  		u32 speed = ((lpa & (LPA_100HALF | LPA_100FULL)) ?
> >  			     SPEED_100 : SPEED_10);
> > -		ethtool_cmd_speed_set(ecmd, speed);
> > -		ecmd->autoneg = AUTONEG_ENABLE;
> > +		ecmd->base.speed = speed;
> > +		ecmd->base.autoneg = AUTONEG_ENABLE;
> >  		if (speed == SPEED_100)
> > -			ecmd->duplex = (lpa & LPA_100FULL) ?
> > +			ecmd->base.duplex = (lpa & LPA_100FULL) ?
> >  			    DUPLEX_FULL : DUPLEX_HALF;
> >  		else
> > -			ecmd->duplex = (lpa & LPA_10FULL) ?
> > +			ecmd->base.duplex = (lpa & LPA_10FULL) ?
> >  			    DUPLEX_FULL : DUPLEX_HALF;
> >  	} else {
> > -		ecmd->autoneg = AUTONEG_DISABLE;
> > -		ethtool_cmd_speed_set(ecmd, ((bmcr & BMCR_SPEED100) ?
> > -					     SPEED_100 : SPEED_10));
> > -		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ?
> > +		ecmd->base.autoneg = AUTONEG_DISABLE;
> > +		ecmd->base.speed = ((bmcr & BMCR_SPEED100) ?
> > +					     SPEED_100 : SPEED_10);
> > +		ecmd->base.duplex = (bmcr & BMCR_FULLDPLX) ?
> >  		    DUPLEX_FULL : DUPLEX_HALF;
> >  	}
> > +
> > +	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
> > +						supported);
> > +
> >  	return 0;
> >  }
> >  
> >  static const struct ethtool_ops ops = {
> >  	.get_drvinfo = rtl8150_get_drvinfo,
> > -	.get_settings = rtl8150_get_settings,
> > -	.get_link = ethtool_op_get_link
> > +	.get_link = ethtool_op_get_link,
> > +	.get_link_ksettings = rtl8150_get_link_ksettings,
> >  };
> >  
> >  static int rtl8150_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
> > -- 
> > 1.7.4.4
> > 
> > 
