From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: Ensure clocks are enabled while using mdio bus
Date: Sun, 14 Jun 2015 08:07:12 +0000
Message-ID: <BLUPR03MB373E1D5EADCB4753C8D0F15F5B90@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1434123545-13549-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0147.outbound.protection.outlook.com ([157.56.111.147]:42720
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753199AbbFNIV2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 04:21:28 -0400
In-Reply-To: <1434123545-13549-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Friday, June 12, 2015 11:39 PM
> To: David Miller
> Cc: Duan Fugang-B38611; Cory Tusar; netdev; Andrew Lunn
> Subject: [PATCH] net: fec: Ensure clocks are enabled while using mdio bus
> 
> When a switch is attached to the mdio bus, the mdio bus can be used while
> the interface is not open. If the clocks are not enabled, MDIO
> reads/writes will simply time out. So enable the clocks before starting a
> transaction, and disable them afterwards. The CCF performs reference
> counting so the clocks will only be disabled if there are no other users.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---

NAK the patch.

i.MX series MDIO bus is a part of ENET controller. If the eth interface is not open, all clocks including MDIO bus clock are not enabled for power saving.
In general, if you want to use mdio bus net interface must be running status.

>  drivers/net/ethernet/freescale/fec_main.c | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index bf4cf3fbb5f2..122186b90cdb 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -65,6 +65,7 @@
> 
>  static void set_multicast_list(struct net_device *ndev);  static void
> fec_enet_itr_coal_init(struct net_device *ndev);
> +static int fec_enet_clk_enable(struct net_device *ndev, bool enable);
> 
>  #define DRIVER_NAME	"fec"
> 
> @@ -1764,6 +1765,11 @@ static int fec_enet_mdio_read(struct mii_bus *bus,
> int mii_id, int regnum)  {
>  	struct fec_enet_private *fep = bus->priv;
>  	unsigned long time_left;
> +	int ret;
> +
> +	ret = fec_enet_clk_enable(fep->netdev, true);
> +	if (ret)
> +		return 0xffff;
> 
>  	fep->mii_timeout = 0;
>  	init_completion(&fep->mdio_done);
> @@ -1779,11 +1785,14 @@ static int fec_enet_mdio_read(struct mii_bus *bus,
> int mii_id, int regnum)
>  	if (time_left == 0) {
>  		fep->mii_timeout = 1;
>  		netdev_err(fep->netdev, "MDIO read timeout\n");
> +		fec_enet_clk_enable(fep->netdev, false);
>  		return -ETIMEDOUT;
>  	}
> 
> -	/* return value */
> -	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> +	ret = FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> +	fec_enet_clk_enable(fep->netdev, false);
> +
> +	return ret;
>  }
> 
>  static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int
> regnum, @@ -1791,10 +1800,15 @@ static int fec_enet_mdio_write(struct
> mii_bus *bus, int mii_id, int regnum,  {
>  	struct fec_enet_private *fep = bus->priv;
>  	unsigned long time_left;
> +	int ret;
> 
>  	fep->mii_timeout = 0;
>  	init_completion(&fep->mdio_done);
> 
> +	ret = fec_enet_clk_enable(fep->netdev, true);
> +	if (ret)
> +		netdev_err(fep->netdev, "Unable to enable clks\n");
> +
>  	/* start a write op */
>  	writel(FEC_MMFR_ST | FEC_MMFR_OP_WRITE |
>  		FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) | @@ -1807,9
> +1821,12 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int
> mii_id, int regnum,
>  	if (time_left == 0) {
>  		fep->mii_timeout = 1;
>  		netdev_err(fep->netdev, "MDIO write timeout\n");
> +		fec_enet_clk_enable(fep->netdev, false);
>  		return -ETIMEDOUT;
>  	}
> 
> +	fec_enet_clk_enable(fep->netdev, false);
> +
>  	return 0;
>  }
> 
> --
> 2.1.4
