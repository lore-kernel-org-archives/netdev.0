From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 19 Jan 2015 19:11:11 +0100
Message-ID: <54BD48BF.3050707@suse.de>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>, arnd@arndb.de,
	robh+dt@kernel.org, davem@davemloft.net, grant.likely@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60697 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924AbbASSLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 13:11:16 -0500
In-Reply-To: <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 07:34, Ding Tianhong wrote:
> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
>
> v13: Fix the problem of alignment parameters for function and checkpatch warming.
>
> v12: According Alex's suggestion, modify the changelog and add MODULE_DEVICE_TABLE
>       for hip04 ethernet.
>
> v11: Add ethtool support for tx coalecse getting and setting, the xmit_more
>       is not supported for this patch, but I think it could work for hip04,
>       will support it later after some tests for performance better.
>
>       Here are some performance test results by ping and iperf(add tx_coalesce_frames/users),
>       it looks that the performance and latency is more better by tx_coalesce_frames/usecs.
>
>       - Before:
>       $ ping 192.168.1.1 ...
>       === 192.168.1.1 ping statistics ===
>       24 packets transmitted, 24 received, 0% packet loss, time 22999ms
>       rtt min/avg/max/mdev = 0.180/0.202/0.403/0.043 ms
>
>       $ iperf -c 192.168.1.1 ...
>       [ ID] Interval       Transfer     Bandwidth
>       [  3]  0.0- 1.0 sec   115 MBytes   945 Mbits/sec
>
>       - After:
>       $ ping 192.168.1.1 ...
>       === 192.168.1.1 ping statistics ===
>       24 packets transmitted, 24 received, 0% packet loss, time 22999ms
>       rtt min/avg/max/mdev = 0.178/0.190/0.380/0.041 ms
>
>       $ iperf -c 192.168.1.1 ...
>       [ ID] Interval       Transfer     Bandwidth
>       [  3]  0.0- 1.0 sec   115 MBytes   965 Mbits/sec
>
> v10: According David Miller and Arnd Bergmann's suggestion, add some modification
>       for v9 version
>       - drop the workqueue
>       - batch cleanup based on tx_coalesce_frames/usecs for better throughput
>       - use a reasonable default tx timeout (200us, could be shorted
>         based on measurements) with a range timer
>       - fix napi poll function return value
>       - use a lockless queue for cleanup
>
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/ethernet/hisilicon/Makefile    |   2 +-
>   drivers/net/ethernet/hisilicon/hip04_eth.c | 969 +++++++++++++++++++++++++++++
>   2 files changed, 970 insertions(+), 1 deletion(-)
>   create mode 100644 drivers/net/ethernet/hisilicon/hip04_eth.c
>
> diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
> index 40115a7..6c14540 100644
> --- a/drivers/net/ethernet/hisilicon/Makefile
> +++ b/drivers/net/ethernet/hisilicon/Makefile
> @@ -3,4 +3,4 @@
>   #
>   
>   obj-$(CONFIG_HIX5HD2_GMAC) += hix5hd2_gmac.o
> -obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o
> +obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o hip04_eth.o

[...]

> +static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = (struct net_device *)dev_id;
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	u32 ists = readl_relaxed(priv->base + PPE_INTSTS);
> +
> +	if (!ists)
> +		return IRQ_NONE;
> +
> +	writel_relaxed(DEF_INT_MASK, priv->base + PPE_RINT);
> +
> +	if (unlikely(ists & DEF_INT_ERR)) {
> +		if (ists & (RCV_NOBUF | RCV_DROP))
> +			stats->rx_errors++;
> +			stats->rx_dropped++;
> +			netdev_err(ndev, "rx drop\n");

After hammering on the box a bit again, I'm in a situation where I get 
lots of

[302398.232603] hip04-ether e28b0000.ethernet eth0: rx drop
[302398.377309] hip04-ether e28b0000.ethernet eth0: rx drop
[302398.395198] hip04-ether e28b0000.ethernet eth0: rx drop
[302398.466118] hip04-ether e28b0000.ethernet eth0: rx drop
[302398.659009] hip04-ether e28b0000.ethernet eth0: rx drop
[302399.053389] hip04-ether e28b0000.ethernet eth0: rx drop
[302399.122067] hip04-ether e28b0000.ethernet eth0: rx drop
[302399.268192] hip04-ether e28b0000.ethernet eth0: rx drop
[302399.286081] hip04-ether e28b0000.ethernet eth0: rx drop
[302399.594201] hip04-ether e28b0000.ethernet eth0: rx drop
[302399.683416] hip04-ether e28b0000.ethernet eth0: rx drop
[302399.701307] hip04-ether e28b0000.ethernet eth0: rx drop

and I really am getting a lot of drops - I can't even ping the machine 
anymore.

However, as it is there's a good chance the machine is simply 
unreachable because it's busy writing to the UART, and even if not all 
useful messages indicating anything have scrolled out. I really don't 
think you should emit any message over and over again to the user. Once 
or twice is enough.

Please make sure to rate limit it.


Alex
