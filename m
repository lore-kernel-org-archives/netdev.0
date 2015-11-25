From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 04/13] net: mvneta: enable suspend/resume support
Date: Wed, 25 Nov 2015 19:35:32 +0100
Message-ID: <87k2p67wqz.fsf@free-electrons.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
 <1448178839-3541-5-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, linux@arm.linux.org.uk,
 jason@lakedaemon.net, myair@marvell.com, netdev@vger.kernel.org,
 simon.guinot@sequanux.org, linux-kernel@vger.kernel.org, xswang@marvell.com,
 tn@semihalf.com, nadavh@marvell.com, alior@marvell.com, jaz@semihalf.com,
 nitroshift@yahoo.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1448178839-3541-5-git-send-email-mw@semihalf.com> (Marcin
 Wojtas's message of "Sun, 22 Nov 2015 08:53:50 +0100")
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On dim., nov. 22 2015, Marcin Wojtas <mw@semihalf.com> wrote:

> This commit introduces suspend/resume routines used for both in 'standby'
> and 'mem' modes. For the latter, in which registers' contents are lost,
> following steps are performed:
> * in suspend - update port statistics and, if interface is running,
>   detach netif, clean the queues, disable cpu notifier, shutdown
>   interface and reset port's link status;
> * in resume, for all interfaces, set default configuration of the port and
>   MBUS windows;
> * in resume, in case the interface is running, enable accepting packets in
>   legacy parser, power up the port, register cpu notifier and attach
> netif.

I don't have the hardware to use suspend to RAM on Armada XP but at
least in standby the network continue to work on wakeup.

>
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 70 +++++++++++++++++++++++++++++++++++
>  1 file changed, 70 insertions(+)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index d12b8c6..f079b13 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3442,6 +3442,72 @@ static int mvneta_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_PM_SLEEP
> +static int mvneta_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct mvneta_port *pp = netdev_priv(dev);
> +
> +	mvneta_ethtool_update_stats(pp);
> +
> +	if (!netif_running(dev))
> +		return 0;
> +
> +	netif_device_detach(dev);
> +
> +	mvneta_stop_dev(pp);
> +	unregister_cpu_notifier(&pp->cpu_notifier);
> +	mvneta_cleanup_rxqs(pp);
> +	mvneta_cleanup_txqs(pp);
> +
> +	/* Reset link status */
> +	pp->link = 0;
> +	pp->duplex = -1;
> +	pp->speed = 0;
> +

Would it be possible to add a kind of mvneta_port_power_down(pp,
pp->phy_interface) here ? It would allow to save power in standby mode
too.

> +	return 0;
> +}
> +
> +static int mvneta_resume(struct platform_device *pdev)
> +{
> +	const struct mbus_dram_target_info *dram_target_info;
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	int ret;
> +
> +	mvneta_defaults_set(pp);
> +	mvneta_port_power_up(pp, pp->phy_interface);
> +
> +	dram_target_info = mv_mbus_dram_info();
> +	if (dram_target_info)
> +		mvneta_conf_mbus_windows(pp, dram_target_info);
> +
> +	if (!netif_running(dev))
> +		return 0;
> +
> +	ret = mvneta_setup_rxqs(pp);
> +	if (ret) {
> +		netdev_err(dev, "unable to setup rxqs after resume\n");
> +		return ret;
> +	}
> +
> +	ret = mvneta_setup_txqs(pp);
> +	if (ret) {
> +		netdev_err(dev, "unable to setup txqs after resume\n");
> +		return ret;
> +	}
> +
> +	mvneta_set_rx_mode(dev);
> +	mvneta_percpu_elect(pp);
> +	register_cpu_notifier(&pp->cpu_notifier);
> +	mvneta_start_dev(pp);
> +
> +	netif_device_attach(dev);
> +
> +	return 0;
> +}
> +#endif /* CONFIG_PM_SLEEP */
> +
>  static const struct of_device_id mvneta_match[] = {
>  	{ .compatible = "marvell,armada-370-neta" },
>  	{ .compatible = "marvell,armada-xp-neta" },
> @@ -3452,6 +3518,10 @@ MODULE_DEVICE_TABLE(of, mvneta_match);
>  static struct platform_driver mvneta_driver = {
>  	.probe = mvneta_probe,
>  	.remove = mvneta_remove,
> +#ifdef CONFIG_PM_SLEEP
> +	.suspend = mvneta_suspend,
> +	.resume = mvneta_resume,
> +#endif
>  	.driver = {
>  		.name = MVNETA_DRIVER_NAME,
>  		.of_match_table = mvneta_match,
> -- 
> 1.8.3.1
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
