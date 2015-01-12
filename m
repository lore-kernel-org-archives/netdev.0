From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH net-next v11 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 12 Jan 2015 19:25:22 +0100
Message-ID: <54B41192.3030400@suse.de>
References: <1421049832-6224-1-git-send-email-dingtianhong@huawei.com> <1421049832-6224-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>, arnd@arndb.de,
	robh+dt@kernel.org, davem@davemloft.net, grant.likely@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53428 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837AbbALSZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 13:25:26 -0500
In-Reply-To: <1421049832-6224-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.15 09:03, Ding Tianhong wrote:
> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
> 
> v11: Add ethtool support for tx coalecse getting and setting, the xmit_more
> is not supported for this patch, but I think it could work for hip04,
> will support it later after some tests for performance better.
> 
> Here are some performance test results by ping and iperf(add tx_coalesce_frames/users),
> it looks that the performance and latency is more better by tx_coalesce_frames/usecs.
> 
> - Before:
> $ ping 192.168.1.1 ...
> --- 192.168.1.1 ping statistics ---

Writing --- directly into your patch description is usually a pretty bad
idea. Git am cuts off everything that comes after --- so your patch
description ends here without manual intervention ;).

> 24 packets transmitted, 24 received, 0% packet loss, time 22999ms
> rtt min/avg/max/mdev = 0.180/0.202/0.403/0.043 ms
> 
> $ iperf -c 192.168.1.1 ...
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0- 1.0 sec   115 MBytes   945 Mbits/sec
> 
> - After:
> $ ping 192.168.1.1 ...
> --- 192.168.1.1 ping statistics ---
> 24 packets transmitted, 24 received, 0% packet loss, time 22999ms
> rtt min/avg/max/mdev = 0.178/0.190/0.380/0.041 ms
> 
> $ iperf -c 192.168.1.1 ...
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0- 1.0 sec   115 MBytes   965 Mbits/sec
> 
> v10: According David Miller and Arnd Bergmann's suggestion, add some modification

Version history however should go after a --- line, so that it doesn't
show up in the patch description in the tree.

> for v9 version
> - drop the workqueue
> - batch cleanup based on tx_coalesce_frames/usecs for better throughput
> - use a reasonable default tx timeout (200us, could be shorted
>   based on measurements) with a range timer
> - fix napi poll function return value
> - use a lockless queue for cleanup
> 
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---


[...]

> +static int hip04_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	struct device *d = &pdev->dev;
> +
> +	if (priv->phy)
> +		phy_disconnect(priv->phy);
> +
> +	hip04_free_ring(ndev, d);
> +	unregister_netdev(ndev);
> +	free_irq(ndev->irq, ndev);
> +	of_node_put(priv->phy_node);
> +	cancel_work_sync(&priv->tx_timeout_task);
> +	free_netdev(ndev);
> +
> +	return 0;
> +}
> +
> +static const struct of_device_id hip04_mac_match[] = {
> +	{ .compatible = "hisilicon,hip04-mac" },
> +	{ }
> +};

This is missing

MODULE_DEVICE_TABLE(of, hip04_mac_match);

to enable automatic module loading, no?


Alex
