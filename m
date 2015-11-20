From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V3 net-next 4/5] net:hns: Add support of ethtool TSO set
 option for Hip06 in HNS
Date: Fri, 20 Nov 2015 17:07:17 +0300
Message-ID: <564F2915.1090507@cogentembedded.com>
References: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com>
 <1447966706-16219-5-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Salil Mehta <salil.mehta@huawei.com>, davem@davemloft.net,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	paul.gortmaker@windriver.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, catalin.marinas@arm.com, will.deacon@arm.com,
	arnd@arndb.de, liguozhu@hisilicon.com, yisen.zhuang@huawei.com,
	dingtianhong@huawei.com, zhangfei.gao@linaro.org,
	huangdaode@hisilicon.com, kenneth-lee-2012@foxmail.com,
	mehta.salil.lnk@gmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linuxarm@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:32824 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759851AbbKTOHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 09:07:22 -0500
Received: by lbbkw15 with SMTP id kw15so62636687lbb.0
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 06:07:20 -0800 (PST)
In-Reply-To: <1447966706-16219-5-git-send-email-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2015 11:58 PM, Salil Mehta wrote:

> From: Salil <salil.mehta@huawei.com>
>
> This patch adds the support of ethtool TSO option to V1 patch,
> meant to add support of Hip06 SoC to HNS
>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> Signed-off-by: lisheng <lisheng011@huawei.com>
> ---
>   drivers/net/ethernet/hisilicon/hns/hns_enet.c |   47 +++++++++++++++++++++++++
>   1 file changed, 47 insertions(+)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> index 055e14c..a0763ab 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> @@ -1386,6 +1386,51 @@ static int hns_nic_change_mtu(struct net_device *ndev, int new_mtu)
>   	return ret;
>   }
>
> +static int hns_nic_set_features(struct net_device *netdev,
> +				netdev_features_t features)
> +{
> +	struct hns_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae_handle *h = priv->ae_handle;
> +
> +	switch (priv->enet_ver) {
> +	case AE_VERSION_1:
> +		if ((features & NETIF_F_TSO) || (features & NETIF_F_TSO6))

		if ((features & (NETIF_F_TSO| NETIF_F_TSO6))

> +			netdev_info(netdev, "enet v1 do not support tso!\n");
> +	break;

    The *break* should have the same indentation level as *if*.

> +	default:
> +		if ((features & NETIF_F_TSO) || (features & NETIF_F_TSO6)) {

	if ((features & (NETIF_F_TSO| NETIF_F_TSO6))

> +			priv->ops.fill_desc = fill_tso_desc;
> +			priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tso;
> +			/* The chip only support 7*4096 */
> +			netif_set_gso_max_size(netdev, 7 * 4096);
> +			h->dev->ops->set_tso_stats(h, 1);
> +		} else {
> +			priv->ops.fill_desc = fill_v2_desc;
> +			priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tx;
> +			h->dev->ops->set_tso_stats(h, 0);
> +		}
> +	break;

    Same here.

> +	}
> +	netdev->features = features;
> +	return 0;
> +}
> +
> +static netdev_features_t hns_nic_fix_features(
> +		struct net_device *netdev, netdev_features_t features)
> +{
> +	struct hns_nic_priv *priv = netdev_priv(netdev);
> +
> +	switch (priv->enet_ver) {
> +	case AE_VERSION_1:
> +		features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
> +				NETIF_F_HW_VLAN_CTAG_FILTER);
> +		break;
> +	default:
> +		break;
> +	}

    Here it's indented correctly.

> +	return features;
> +}
> +
>   /**
>    * nic_set_multicast_list - set mutl mac address
>    * @netdev: net device
[...]

MBR, Sergei
