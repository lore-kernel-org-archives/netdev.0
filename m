From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net v2] r8169:fix "rtl_counters_cond == 1 (loop: 1000,
 delay: 10)" log spam.
Date: Tue, 23 Feb 2016 00:13:01 +0100
Message-ID: <20160222231301.GA17876@electric-eye.fr.zoreil.com>
References: <1456153794-2028-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456153794-2028-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 537974c..a645f8d 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7730,10 +7730,13 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  	void __iomem *ioaddr = tp->mmio_addr;
> +	struct pci_dev *pdev = tp->pci_dev;

+ 	struct device *d = &tp->pci_dev->dev;

(the patch does not use pdev alone)

[...]
> @@ -7761,7 +7764,8 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>  	 * Fetch additonal counter values missing in stats collected by driver
>  	 * from tally counters.
>  	 */
> -	rtl8169_update_counters(dev);
> +	if (pm_runtime_active(&pdev->dev))
> +		rtl8169_update_counters(dev);

pm_runtime_active() won't change after pm_runtime_get_noresume(). You may
set a boolean active = pm_runtime_active(d) before testing netif_running().

[...]
> @@ -7842,6 +7848,12 @@ static int rtl8169_runtime_suspend(struct device *device)
>  	struct pci_dev *pdev = to_pci_dev(device);
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct rtl8169_private *tp = netdev_priv(dev);
> +	void __iomem *ioaddr = tp->mmio_addr;
> +
> +	/* Update counters before going runtime suspend */
> +	if (netif_running(dev))
> +		rtl8169_rx_missed(dev, ioaddr);
> +	rtl8169_update_counters(dev);
>  
>  	if (!tp->TxDescArray)
>  		return 0;

Nits:

- the tp->TxDescArray test provides the required synchronization: see
  rtl8169_{open/close} and their pm_runtime_{get / put}.

- ioaddr is not really needed : tp->mmio_addr appears only once and it does
  not mess the 72..80 cols limit.

- even if the device can only be automatically runtime suspended some time
  after a link down event, you may address davem's point regarding stats
  reliability and move rtl8169_rx_missed + rtl8169_update_counters after
  rtl8169_net_suspend.

-- 
Ueimor
