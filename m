From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2/2] tg3: Add code to allow ethtool to
 enable/disable loopback.
Date: Thu, 28 Apr 2011 17:28:55 -0700
Message-ID: <20110429002855.GC19665@mcarlson.broadcom.com>
References: <1304033599-8395-1-git-send-email-maheshb@google.com>
 <1304033599-8395-2-git-send-email-maheshb@google.com>
 <1304033599-8395-3-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Micha? Miros?aw" <mirq-linux@rere.qmqm.pl>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3333 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758211Ab1D2APp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 20:15:45 -0400
In-Reply-To: <1304033599-8395-3-git-send-email-maheshb@google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2011 at 04:33:19PM -0700, Mahesh Bandewar wrote:
> ---
>  drivers/net/tg3.c |   32 ++++++++++++++++++++++++++++++++
>  1 files changed, 32 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index fa57e3d..208884d 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -6319,6 +6319,33 @@ static u32 tg3_fix_features(struct net_device *dev, u32 features)
>  	return features;
>  }
>  
> +static int tg3_set_features(struct net_device *dev, u32 features)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +	u32 cur_mode = 0;
> +	int err = 0;
> +
> +	spin_lock_bh(&tp->lock);
> +	cur_mode = tr32(MAC_MODE);
> +
> +	if (features & NETIF_F_LOOPBACK) {
> +		/* Enable internal MAC loopback mode */
> +		tw32(MAC_MODE, cur_mode | MAC_MODE_PORT_INT_LPBACK);
> +		netif_carrier_on(tp->dev);
> +		netdev_info(dev, "Internal MAC loopback mode enabled.\n");
> +	} else {
> +		/* Disable internal MAC loopback mode */
> +		tw32(MAC_MODE, cur_mode & ~MAC_MODE_PORT_INT_LPBACK);
> +		/* Force link status check */
> +		if (netif_running(dev))
> +			tg3_setup_phy(tp, 1);
> +		netdev_info(dev, "Internal MAC loopback mode disabled.\n");
> +	}

I think we should be checking netif_running() before touching the
hardware at all.  It might be in a low power state.

Also, wouldn't it be better to verify this particular bit changed before
doing any of these operations?

> +	spin_unlock_bh(&tp->lock);
> +
> +	return err;
> +}
> +
>  static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
>  			       int new_mtu)
>  {
> @@ -15028,6 +15055,7 @@ static const struct net_device_ops tg3_netdev_ops = {
>  	.ndo_tx_timeout		= tg3_tx_timeout,
>  	.ndo_change_mtu		= tg3_change_mtu,
>  	.ndo_fix_features	= tg3_fix_features,
> +	.ndo_set_features	= tg3_set_features,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= tg3_poll_controller,
>  #endif
> @@ -15044,6 +15072,7 @@ static const struct net_device_ops tg3_netdev_ops_dma_bug = {
>  	.ndo_do_ioctl		= tg3_ioctl,
>  	.ndo_tx_timeout		= tg3_tx_timeout,
>  	.ndo_change_mtu		= tg3_change_mtu,
> +	.ndo_set_features	= tg3_set_features,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= tg3_poll_controller,
>  #endif
> @@ -15241,6 +15270,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>  	dev->features |= hw_features;
>  	dev->vlan_features |= hw_features;
>  
> +	/* Add the loopback capability */
> +	dev->hw_features |= NETIF_F_LOOPBACK;

Not all tg3 devices can do MAC loopback.  I'd suggest qualifying this
with:

		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 ||
		    (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))

But that will exclude a lot of our newer devices.  Does it matter what
type of loopback is used?  Newer devices prefer internal phy loopback
over MAC loopback.

>  	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
>  	    !tg3_flag(tp, TSO_CAPABLE) &&
>  	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
> -- 
> 1.7.3.1
> 
> 

