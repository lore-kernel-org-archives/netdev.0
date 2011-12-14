From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] e100: power down PHY if WOL is not enabled
Date: Wed, 14 Dec 2011 20:30:36 +0000
Message-ID: <1323894636.2753.2.camel@bwh-desktop>
References: <1323830996-16388-1-git-send-email-Jiang.Wang@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ppanchamukhi@riverbed.com>,
	<clala@riverbed.com>, <Francis.St.Amant@riverbed.com>,
	<miles.ito@intel.com>
To: Jiang Wang <Jiang.Wang@riverbed.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323830996-16388-1-git-send-email-Jiang.Wang@riverbed.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-12-13 at 18:49 -0800, Jiang Wang wrote:
> Since the interface will not be used after being put down and WOL is disabled,
> just power it off.
> When bring up the interface, power on the PHY.

Don't you need to cover the case where WOL is enabled while the
interface is down?

Ben.

> Signed-off-by: Jiang Wang <Jiang.Wang@riverbed.com>
> ---
>  drivers/net/ethernet/intel/e100.c |   17 +++++++++++++++++
>  1 files changed, 17 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
> index 5a2fdf7..9824e0a 100644
> --- a/drivers/net/ethernet/intel/e100.c
> +++ b/drivers/net/ethernet/intel/e100.c
> @@ -1449,6 +1449,14 @@ static int e100_phy_init(struct nic *nic)
>  		netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
>  			     "phy_addr = %d\n", nic->mii.phy_id);
>  
> +	/* Make sure power to the PHY is enabled */
> +	if (!(nic->flags & wol_magic)) {
> +		uint16_t phy_data;
> +		phy_data = mdio_read(nic->netdev, nic->mii.phy_id, MII_BMCR);
> +		phy_data &= ~BMCR_PDOWN;
> +		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, phy_data);
> +	}
> +
>  	/* Get phy ID */
>  	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
>  	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
> @@ -2261,6 +2269,15 @@ static void e100_down(struct nic *nic)
>  	napi_disable(&nic->napi);
>  	netif_stop_queue(nic->netdev);
>  	e100_hw_reset(nic);
> +
> +	/* If wake on LAN is not enabled, power down the PHY */
> +	if (!(nic->flags & wol_magic)) {
> +		uint16_t phy_data;
> +		phy_data = mdio_read(nic->netdev, nic->mii.phy_id, MII_BMCR);
> +		phy_data |= BMCR_PDOWN;
> +		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, phy_data);
> +	}
> +
>  	free_irq(nic->pdev->irq, nic->netdev);
>  	del_timer_sync(&nic->watchdog);
>  	netif_carrier_off(nic->netdev);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
