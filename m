From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 15 Jan 2015 10:53:46 +0100
Message-ID: <1456101.oYxGUWa027@wuerfel>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com> <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ding Tianhong <dingtianhong@huawei.com>, robh+dt@kernel.org,
	davem@davemloft.net, grant.likely@linaro.org, agraf@suse.de,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk,
	sergei.shtylyov@cogentembedded.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xuwei5@hisilicon.com,
	zhangfei.gao@linaro.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:63198 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbAOJyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 04:54:47 -0500
In-Reply-To: <1421217254-12008-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 January 2015 14:34:14 Ding Tianhong wrote:
> +static int hip04_set_coalesce(struct net_device *netdev,
> +                             struct ethtool_coalesce *ec)
> +{
> +       struct hip04_priv *priv = netdev_priv(netdev);
> +
> +       /* Check not supported parameters  */
> +       if ((ec->rx_max_coalesced_frames) || (ec->rx_coalesce_usecs_irq) ||
> +           (ec->rx_max_coalesced_frames_irq) || (ec->tx_coalesce_usecs_irq) ||
> +           (ec->use_adaptive_rx_coalesce) || (ec->use_adaptive_tx_coalesce) ||
> +           (ec->pkt_rate_low) || (ec->rx_coalesce_usecs_low) ||
> +           (ec->rx_max_coalesced_frames_low) || (ec->tx_coalesce_usecs_high) ||
> +           (ec->tx_max_coalesced_frames_low) || (ec->pkt_rate_high) ||
> +           (ec->tx_coalesce_usecs_low) || (ec->rx_coalesce_usecs_high) ||
> +           (ec->rx_max_coalesced_frames_high) || (ec->rx_coalesce_usecs) ||
> +           (ec->tx_max_coalesced_frames_irq) ||
> +           (ec->stats_block_coalesce_usecs) ||
> +           (ec->tx_max_coalesced_frames_high) || (ec->rate_sample_interval))
> +               return -EOPNOTSUPP;
> +
> +       if ((ec->tx_coalesce_usecs > HIP04_MAX_TX_COALESCE_USECS ||
> +            ec->tx_coalesce_usecs < HIP04_MIN_TX_COALESCE_USECS) ||
> +           (ec->tx_max_coalesced_frames > HIP04_MAX_TX_COALESCE_FRAMES ||
> +            ec->tx_max_coalesced_frames < HIP04_MIN_TX_COALESCE_FRAMES))
> +               return -EINVAL;
> +
> +       priv->tx_coalesce_usecs = ec->tx_coalesce_usecs;
> +       priv->tx_coalesce_frames = ec->tx_max_coalesced_frames;
> +
> +       return 0;
> +}

I just looked at this again and noticed that you fail to actually use the
tx_coalesce_usecs value anywhere, since you don't call hrtimer_set_expires_range()
any more.

Also, I guess it would be nice use the rx_coalesce_usecs_low and
tx_coalesce_usecs_high numbers instead of just a single number, as
hrtimer_set_expires_range takes two values already. Just do something
like 

	hrtimer_set_expires_range(&priv->tx_coalesce_timer,
				   priv->rx_coalesce_usecs_low,
				   priv->rx_coalesce_usecs_high -
				   priv->rx_coalesce_usecs_low);

and make sure the 'low' value is smaller than the 'high' one.

> +       priv->tx_coalesce_frames = TX_DESC_NUM * 3 / 4;
> +       priv->tx_coalesce_usecs = 200;

Related, instead of putting the raw numbers here, how about
adding the defaults along with the other macros we talked about:

#define HIP04_MAX_TX_COALESCE_USECS		10000
#define HIP04_MIN_TX_COALESCE_USECS		1
#define HIP04_MAX_TX_COALESCE_FRAMES		(TX_DESC_NUM - 1)
#define HIP04_MIN_TX_COALESCE_FRAMES		1

#define HIP04_DEFAULT_TX_COALESCE_USECS_LOW	80
#define HIP04_DEFAULT_TX_COALESCE_USECS_HIGH	200
#define HIP04_DEFAULT_TX_COALESCE_FRAMES	(TX_DESC_NUM / 2)

	Arnd
