From: Dan Williams <dcbw@redhat.com>
Subject: Re: [git patches] net driver fixes
Date: Fri, 14 Sep 2007 14:13:18 -0400
Message-ID: <1189793598.2508.4.camel@xo-3E-67-34.localdomain>
References: <20070913053022.GA16891@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757108AbXINSOx@vger.kernel.org>
In-Reply-To: <20070913053022.GA16891@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-13 at 01:30 -0400, Jeff Garzik wrote:
> Please pull from 'upstream-linus' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git up=
stream-linus
>=20
> to receive the following updates:
>=20
>  drivers/net/atl1/atl1_main.c |   19 +++++++------------
>  drivers/net/ehea/ehea.h      |    5 ++++-
>  drivers/net/ehea/ehea_main.c |   16 ++++++++++++++--
>  drivers/net/phy/phy.c        |    4 ++--
>  drivers/net/phy/phy_device.c |    4 ++--
>  drivers/net/sky2.c           |    9 ++++++++-
>  drivers/net/spider_net.c     |   12 ++++--------
>  7 files changed, 41 insertions(+), 28 deletions(-)
>=20
> Hans-J=C3=BCrgen Koch (1):
>       Fix a lock problem in generic phy code
>=20
> Ishizaki Kou (1):
>       spidernet: fix interrupt reason recognition
>=20
> Jan-Bernd Themann (2):
>       ehea: propagate physical port state
>       ehea: fix last_rx update
>=20
> Luca Tettamanti (1):
>       atl1: disable broken 64-bit DMA
>=20
> Stephen Hemminger (1):
>       sky2: restore multicast list on resume and other ops
>=20
> diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_mai=
n.c
> index 3c1984e..f23e13c 100644
> --- a/drivers/net/atl1/atl1_main.c
> +++ b/drivers/net/atl1/atl1_main.c
> @@ -2203,21 +2203,20 @@ static int __devinit atl1_probe(struct pci_de=
v *pdev,
>  	struct net_device *netdev;
>  	struct atl1_adapter *adapter;
>  	static int cards_found =3D 0;
> -	bool pci_using_64 =3D true;
>  	int err;
> =20
>  	err =3D pci_enable_device(pdev);
>  	if (err)
>  		return err;
> =20
> -	err =3D pci_set_dma_mask(pdev, DMA_64BIT_MASK);
> +	/*
> +	 * 64-bit DMA currently has data corruption problems, so let's just
> +	 * use 32-bit DMA for now.  This is a big hack that is probably wro=
ng.
> +	 */
> +	err =3D pci_set_dma_mask(pdev, DMA_32BIT_MASK);
>  	if (err) {
> -		err =3D pci_set_dma_mask(pdev, DMA_32BIT_MASK);
> -		if (err) {
> -			dev_err(&pdev->dev, "no usable DMA configuration\n");
> -			goto err_dma;
> -		}
> -		pci_using_64 =3D false;
> +		dev_err(&pdev->dev, "no usable DMA configuration\n");
> +		goto err_dma;
>  	}
>  	/* Mark all PCI regions associated with PCI device
>  	 * pdev as being reserved by owner atl1_driver_name
> @@ -2282,7 +2281,6 @@ static int __devinit atl1_probe(struct pci_dev =
*pdev,
> =20
>  	netdev->ethtool_ops =3D &atl1_ethtool_ops;
>  	adapter->bd_number =3D cards_found;
> -	adapter->pci_using_64 =3D pci_using_64;
> =20
>  	/* setup the private structure */
>  	err =3D atl1_sw_init(adapter);
> @@ -2299,9 +2297,6 @@ static int __devinit atl1_probe(struct pci_dev =
*pdev,
>  	 */
>  	/* netdev->features |=3D NETIF_F_TSO; */
> =20
> -	if (pci_using_64)
> -		netdev->features |=3D NETIF_F_HIGHDMA;
> -
>  	netdev->features |=3D NETIF_F_LLTX;
> =20
>  	/*
> diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
> index d67f97b..8d58be5 100644
> --- a/drivers/net/ehea/ehea.h
> +++ b/drivers/net/ehea/ehea.h
> @@ -39,7 +39,7 @@
>  #include <asm/io.h>
> =20
>  #define DRV_NAME	"ehea"
> -#define DRV_VERSION	"EHEA_0073"
> +#define DRV_VERSION	"EHEA_0074"
> =20
>  /* eHEA capability flags */
>  #define DLPAR_PORT_ADD_REM 1
> @@ -402,6 +402,8 @@ struct ehea_mc_list {
> =20
>  #define EHEA_PORT_UP 1
>  #define EHEA_PORT_DOWN 0
> +#define EHEA_PHY_LINK_UP 1
> +#define EHEA_PHY_LINK_DOWN 0
>  #define EHEA_MAX_PORT_RES 16
>  struct ehea_port {
>  	struct ehea_adapter *adapter;	 /* adapter that owns this port */
> @@ -427,6 +429,7 @@ struct ehea_port {
>  	u32 msg_enable;
>  	u32 sig_comp_iv;
>  	u32 state;
> +	u8 phy_link;
>  	u8 full_duplex;
>  	u8 autoneg;
>  	u8 num_def_qps;
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_mai=
n.c
> index db57474..717b129 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -53,17 +53,21 @@ static int rq3_entries =3D EHEA_DEF_ENTRIES_RQ3;
>  static int sq_entries =3D EHEA_DEF_ENTRIES_SQ;
>  static int use_mcs =3D 0;
>  static int num_tx_qps =3D EHEA_NUM_TX_QP;
> +static int prop_carrier_state =3D 0;
> =20
>  module_param(msg_level, int, 0);
>  module_param(rq1_entries, int, 0);
>  module_param(rq2_entries, int, 0);
>  module_param(rq3_entries, int, 0);
>  module_param(sq_entries, int, 0);
> +module_param(prop_carrier_state, int, 0);
>  module_param(use_mcs, int, 0);
>  module_param(num_tx_qps, int, 0);
> =20
>  MODULE_PARM_DESC(num_tx_qps, "Number of TX-QPS");
>  MODULE_PARM_DESC(msg_level, "msg_level");
> +MODULE_PARM_DESC(prop_carrier_state, "Propagate carrier state of phy=
sical "
> +		 "port to stack. 1:yes, 0:no.  Default =3D 0 ");

WTF?  why would the default be to _not_ propagate carrier state?  Are
there some mitigating circumstances that require this driver to not
notify the stack of carrier on/off?  Userspace stuff really should know
about the carrier state, and this disables it by default.

Dan

>  MODULE_PARM_DESC(rq3_entries, "Number of entries for Receive Queue 3=
 "
>  		 "[2^x - 1], x =3D [6..14]. Default =3D "
>  		 __MODULE_STRING(EHEA_DEF_ENTRIES_RQ3) ")");
> @@ -467,7 +471,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct ne=
t_device *dev,
>  			else
>  				netif_receive_skb(skb);
> =20
> -			dev->last_rx =3D jiffies;
> +			port->netdev->last_rx =3D jiffies;
>  		} else {
>  			pr->p_stats.poll_receive_errors++;
>  			port_reset =3D ehea_treat_poll_error(pr, rq, cqe,
> @@ -814,7 +818,9 @@ int ehea_set_portspeed(struct ehea_port *port, u3=
2 port_speed)
>  			ehea_error("Failed setting port speed");
>  		}
>  	}
> -	netif_carrier_on(port->netdev);
> +	if (!prop_carrier_state || (port->phy_link =3D=3D EHEA_PHY_LINK_UP)=
)
> +		netif_carrier_on(port->netdev);
> +
>  	kfree(cb4);
>  out:
>  	return ret;
> @@ -869,13 +875,19 @@ static void ehea_parse_eqe(struct ehea_adapter =
*adapter, u64 eqe)
>  			}
> =20
>  		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PORT_UP, eqe)) {
> +			port->phy_link =3D EHEA_PHY_LINK_UP;
>  			if (netif_msg_link(port))
>  				ehea_info("%s: Physical port up",
>  					  port->netdev->name);
> +			if (prop_carrier_state)
> +				netif_carrier_on(port->netdev);
>  		} else {
> +			port->phy_link =3D EHEA_PHY_LINK_DOWN;
>  			if (netif_msg_link(port))
>  				ehea_info("%s: Physical port down",
>  					  port->netdev->name);
> +			if (prop_carrier_state)
> +				netif_carrier_off(port->netdev);
>  		}
> =20
>  		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PRIMARY, eqe))
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index e323efd..0cc4369 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -755,7 +755,7 @@ out_unlock:
>   */
>  void phy_start(struct phy_device *phydev)
>  {
> -	spin_lock(&phydev->lock);
> +	spin_lock_bh(&phydev->lock);
> =20
>  	switch (phydev->state) {
>  		case PHY_STARTING:
> @@ -769,7 +769,7 @@ void phy_start(struct phy_device *phydev)
>  		default:
>  			break;
>  	}
> -	spin_unlock(&phydev->lock);
> +	spin_unlock_bh(&phydev->lock);
>  }
>  EXPORT_SYMBOL(phy_stop);
>  EXPORT_SYMBOL(phy_start);
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index e275df8..49328e0 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -644,7 +644,7 @@ static int phy_probe(struct device *dev)
>  	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
>  		phydev->irq =3D PHY_POLL;
> =20
> -	spin_lock(&phydev->lock);
> +	spin_lock_bh(&phydev->lock);
> =20
>  	/* Start out supporting everything. Eventually,
>  	 * a controller will attach, and may modify one
> @@ -658,7 +658,7 @@ static int phy_probe(struct device *dev)
>  	if (phydev->drv->probe)
>  		err =3D phydev->drv->probe(phydev);
> =20
> -	spin_unlock(&phydev->lock);
> +	spin_unlock_bh(&phydev->lock);
> =20
>  	return err;
> =20
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index e6d937e..5d812de 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -149,6 +149,8 @@ static const char *yukon2_name[] =3D {
>  	"FE",		/* 0xb7 */
>  };
> =20
> +static void sky2_set_multicast(struct net_device *dev);
> +
>  /* Access to external PHY */
>  static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, =
u16 val)
>  {
> @@ -2900,8 +2902,10 @@ static int sky2_set_settings(struct net_device=
 *dev, struct ethtool_cmd *ecmd)
>  	sky2->autoneg =3D ecmd->autoneg;
>  	sky2->advertising =3D ecmd->advertising;
> =20
> -	if (netif_running(dev))
> +	if (netif_running(dev)) {
>  		sky2_phy_reinit(sky2);
> +		sky2_set_multicast(dev);
> +	}
> =20
>  	return 0;
>  }
> @@ -2994,6 +2998,7 @@ static int sky2_nway_reset(struct net_device *d=
ev)
>  		return -EINVAL;
> =20
>  	sky2_phy_reinit(sky2);
> +	sky2_set_multicast(dev);
> =20
>  	return 0;
>  }
> @@ -4171,6 +4176,8 @@ static int sky2_resume(struct pci_dev *pdev)
>  				dev_close(dev);
>  				goto out;
>  			}
> +
> +			sky2_set_multicast(dev);
>  		}
>  	}
> =20
> diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
> index 590b12c..82d837a 100644
> --- a/drivers/net/spider_net.c
> +++ b/drivers/net/spider_net.c
> @@ -1441,17 +1441,14 @@ static void
>  spider_net_handle_error_irq(struct spider_net_card *card, u32 status=
_reg)
>  {
>  	u32 error_reg1, error_reg2;
> -	u32 mask_reg1, mask_reg2;
>  	u32 i;
>  	int show_error =3D 1;
> =20
>  	error_reg1 =3D spider_net_read_reg(card, SPIDER_NET_GHIINT1STS);
>  	error_reg2 =3D spider_net_read_reg(card, SPIDER_NET_GHIINT2STS);
> -	mask_reg1 =3D spider_net_read_reg(card, SPIDER_NET_GHIINT1MSK);
> -	mask_reg2 =3D spider_net_read_reg(card,SPIDER_NET_GHIINT2MSK);
> =20
> -	error_reg1 &=3D mask_reg1;
> -	error_reg2 &=3D mask_reg2;
> +	error_reg1 &=3D SPIDER_NET_INT1_MASK_VALUE;
> +	error_reg2 &=3D SPIDER_NET_INT2_MASK_VALUE;
> =20
>  	/* check GHIINT0STS ************************************/
>  	if (status_reg)
> @@ -1679,11 +1676,10 @@ spider_net_interrupt(int irq, void *ptr)
>  {
>  	struct net_device *netdev =3D ptr;
>  	struct spider_net_card *card =3D netdev_priv(netdev);
> -	u32 status_reg, mask_reg;
> +	u32 status_reg;
> =20
>  	status_reg =3D spider_net_read_reg(card, SPIDER_NET_GHIINT0STS);
> -	mask_reg =3D spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
> -	status_reg &=3D mask_reg;
> +	status_reg &=3D SPIDER_NET_INT0_MASK_VALUE;
> =20
>  	if (!status_reg)
>  		return IRQ_NONE;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
