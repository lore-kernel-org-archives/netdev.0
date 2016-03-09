From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH net 1/3] net: mvneta: Fix spinlock usage
Date: Wed, 9 Mar 2016 14:42:54 +0800
Message-ID: <20160309144254.3fbf177f@xhacker>
References: <1457441826-6100-1-git-send-email-gregory.clement@free-electrons.com>
	<1457441826-6100-2-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Ofer Heifetz <oferh@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	"Marcin Wojtas" <mw@semihalf.com>,
	Dimitri Epshtein <dima@marvell.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:42634 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751101AbcCIGr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 01:47:26 -0500
In-Reply-To: <1457441826-6100-2-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Gregory,

On Tue, 8 Mar 2016 13:57:04 +0100 Gregory CLEMENT wrote:

> In the previous patch, the spinlock was not initialized. While it didn't
> cause any trouble yet it could be a problem to use it uninitialized.
> 
> The most annoying part was the critical section protected by the spinlock
> in mvneta_stop(). Some of the functions could sleep as pointed when
> activated CONFIG_DEBUG_ATOMIC_SLEEP. Actually, in mvneta_stop() we only
> need to protect the is_stopped flagged, indeed the code of the notifier
> for CPU online is protected by the same spinlock, so when we get the
> lock, the notifer work is done.
> 
> Reported-by: Patrick Uiterwijk <patrick@puiterwijk.org>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index b0ae69f84493..8dc7df2edff6 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3070,17 +3070,17 @@ static int mvneta_stop(struct net_device *dev)
>  	struct mvneta_port *pp = netdev_priv(dev);
>  
>  	/* Inform that we are stopping so we don't want to setup the
> -	 * driver for new CPUs in the notifiers
> +	 * driver for new CPUs in the notifiers. The code of the
> +	 * notifier for CPU online is protected by the same spinlock,
> +	 * so when we get the lock, the notifer work is done.
>  	 */
>  	spin_lock(&pp->lock);
>  	pp->is_stopped = true;
> +	spin_unlock(&pp->lock);

This fix sleep in atomic issue. But
I see race here. Let's assume is_stopped is false.

cpu0:                           	cpu1:
mvneta_percpu_notifier():		mvneta_stop():

if (pp->is_stopped) {
	spin_unlock(&pp->lock);
	break;
}

					pp->is_stopped = true;
					spin_unlock(&pp->lock);


netif_tx_stop_all_queues(pp->dev);
for_each_online_cpu(other_cpu) {
....

Thanks,
Jisheng

> +
>  	mvneta_stop_dev(pp);
>  	mvneta_mdio_remove(pp);
>  	unregister_cpu_notifier(&pp->cpu_notifier);
> -	/* Now that the notifier are unregistered, we can release le
> -	 * lock
> -	 */
> -	spin_unlock(&pp->lock);
>  	on_each_cpu(mvneta_percpu_disable, pp, true);
>  	free_percpu_irq(dev->irq, pp->ports);
>  	mvneta_cleanup_rxqs(pp);
> @@ -3612,6 +3612,7 @@ static int mvneta_probe(struct platform_device *pdev)
>  	dev->ethtool_ops = &mvneta_eth_tool_ops;
>  
>  	pp = netdev_priv(dev);
> +	spin_lock_init(&pp->lock);
>  	pp->phy_node = phy_node;
>  	pp->phy_interface = phy_mode;
>  
