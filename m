From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V3 net-next] net: hns3: Add support to change MTU in HNS3
 hardware
Date: Mon, 21 Aug 2017 13:32:19 +0300
Message-ID: <20170821103219.GK1724@mtr-leonro.local>
References: <20170821101223.111852-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="T4Djgzn3z2HSNnx0"
Cc: davem@davemloft.net, yisen.zhuang@huawei.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821101223.111852-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--T4Djgzn3z2HSNnx0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 21, 2017 at 11:12:23AM +0100, Salil Mehta wrote:
> This patch adds the following support to the HNS3 driver:
> 1. Support to change the Maximum Transmission Unit of a
>    of a port in the HNS NIC hardware.
> 2. Initializes the supported MTU range for the netdevice.
>
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> ---
> PATCH V3: Addressed some minor comments Leon Romanovsky
>           1. https://lkml.org/lkml/2017/8/20/27
> PATCH V2: Addresses comments given by Andrew Lunn
>           1. https://lkml.org/lkml/2017/8/18/282
> PATCH V1: Initial Submit
> ---
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 36 ++++++++++++++++++++++
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  1 +
>  2 files changed, 37 insertions(+)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> index e731f87..c087a9f 100644
> --- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> @@ -1278,11 +1278,44 @@ static int hns3_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan,
>  	return ret;
>  }
>
> +static int hns3_nic_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	bool if_running = netif_running(netdev);
> +	int ret;
> +
> +	if (!h->ae_algo->ops->set_mtu)
> +		return -ENOTSUPP;

Sorry for not spotting this before, but it should be -EOPNOTSUPP and not -ENOTSUPP.

> +
> +	/* if this was called with netdev up then bring netdevice down */
> +	if (if_running) {
> +		(void)hns3_nic_net_stop(netdev);
> +		msleep(100);
> +	}
> +
> +	ret = h->ae_algo->ops->set_mtu(h, new_mtu);
> +	if (ret) {
> +		netdev_err(netdev, "failed to change MTU in hardware %d\n",
> +			   ret);
> +		return ret;
> +	}
> +
> +	/* if the netdev was running earlier, bring it up again */
> +	if (if_running) {
> +		if (hns3_nic_net_open(netdev))
> +			ret = -EINVAL;
> +	}

Anyway, you will resubmit because of wrong error code.
	if (if_running && hns3_nic_net_open(netdev))
		ret = -EINVAL

Thanks

> +
> +	return ret;
> +}
> +
>  static const struct net_device_ops hns3_nic_netdev_ops = {
>  	.ndo_open		= hns3_nic_net_open,
>  	.ndo_stop		= hns3_nic_net_stop,
>  	.ndo_start_xmit		= hns3_nic_net_xmit,
>  	.ndo_set_mac_address	= hns3_nic_net_set_mac_address,
> +	.ndo_change_mtu		= hns3_nic_change_mtu,
>  	.ndo_set_features	= hns3_nic_set_features,
>  	.ndo_get_stats64	= hns3_nic_get_stats64,
>  	.ndo_setup_tc		= hns3_nic_setup_tc,
> @@ -2752,6 +2785,9 @@ static int hns3_client_init(struct hnae3_handle *handle)
>  		goto out_reg_netdev_fail;
>  	}
>
> +	/* MTU range: (ETH_MIN_MTU(kernel default) - 9706) */
> +	netdev->max_mtu = HNS3_MAX_MTU - (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
> +
>  	return ret;
>
>  out_reg_netdev_fail:
> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> index a6e8f15..7e87461 100644
> --- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> @@ -76,6 +76,7 @@ enum hns3_nic_state {
>  #define HNS3_RING_NAME_LEN			16
>  #define HNS3_BUFFER_SIZE_2048			2048
>  #define HNS3_RING_MAX_PENDING			32768
> +#define HNS3_MAX_MTU				9728
>
>  #define HNS3_BD_SIZE_512_TYPE			0
>  #define HNS3_BD_SIZE_1024_TYPE			1
> --
> 2.7.4
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--T4Djgzn3z2HSNnx0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmatrMACgkQ5GN7iDZy
WKf4iw//b9w6UT2ejC3U+RAOY0sn2DBCuqKhkFZZxnpZfAazMIcSu5nR4NUfajtK
D3fe3SyGrrqaQTq5uuklPce+D9eAV3+sEGgXUR+Qa5ZXK8q0cdSOePxHgfKqQYmu
qPLedOKHgnMR+pY38DsDxsjBKz8aQx/K4vJ9hvFXHX6Jz6WTtrm+Hht8v2ty1KIz
zVhjQ9DP61bZ/sIiKYC+C72jCPr7SnjNX3V0DrzqBqKUR9B4mRXX9jkFqWqGGy7j
cD2LfAjeRbmZ9BuHRHzubDibvyTbAyukr/WDBqCPAnwGHBwF6oTr6y3ntwkJ/a9E
f9H7CnVPyqXJQx7l5obeXm5oW9+Yn2YTF7iHIwoPI7Igrxjz/jey2EIqM9YKnC9D
wkanhe0QbjPLbB9b08K7j1xDpek+5iXo64rvbg4X5QEy5VAYcBqXn67SJEH/vuvY
TiMpFGirKbsHRrARQpF2450ts+EHEvBMwBxTbEjSSAfSeJ0FYrMfr+hua3rzGOw9
oA+C94W1cRaZNcKMEYGSo7/2g5jU7MQOZzWTN3fCR3Z33nVLMXPwcrQN50YaTjqD
ajrHwSmOpMq3sg/hG+6ZgYxkG+qgpI4rJOxMsrC9w2b6dRDBhq3YaR+J6Io2YjvV
yxARLy58LLjyB8j1BttHxMGfYVauBYnw7x/pivfta0NyXLOLgbU=
=Vob7
-----END PGP SIGNATURE-----

--T4Djgzn3z2HSNnx0--
