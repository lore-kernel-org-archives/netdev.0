From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V2 net-next] net: hns3: Add support to change MTU in HNS3
 hardware
Date: Sun, 20 Aug 2017 10:05:24 +0300
Message-ID: <20170820070524.GE18138@mtr-leonro.local>
References: <20170818165759.20152-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Oiv9uiLrevHtW1RS"
Cc: davem@davemloft.net, yisen.zhuang@huawei.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170818165759.20152-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Oiv9uiLrevHtW1RS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 18, 2017 at 05:57:59PM +0100, Salil Mehta wrote:
> This patch adds the following support to the HNS3 driver:
> 1. Support to change the Maximum Transmission Unit of a
>    of a port in the HNS NIC hardware .

Extra space before dot.

> 2. Initializes the supported MTU range for the netdevice.
>
> Signed-off-by: lipeng <lipeng321@huawei.com>

Does "lipeng" have name and surname?

> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> ---
> PATCH V2: Addresses comments given by Andrew Lunn
>           1. https://lkml.org/lkml/2017/8/18/282
> PATCH V1: Initial Submit
> ---
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 38 ++++++++++++++++++++++
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  1 +
>  2 files changed, 39 insertions(+)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> index e731f87..d905ea1 100644
> --- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> @@ -1278,11 +1278,46 @@ static int hns3_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan,
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
> +		if (hns3_nic_net_open(netdev)) {
> +			netdev_err(netdev, "MTU, couldnt up netdev again\n");

"couldnt" -> "couldn't"

and you don't actually need this print.
If the function hns3_nic_net_open fails, you will print this error there.

> +			ret = -EINVAL;
> +		}
> +	}
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
> @@ -2752,6 +2787,9 @@ static int hns3_client_init(struct hnae3_handle *handle)
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

--Oiv9uiLrevHtW1RS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmZNLIACgkQ5GN7iDZy
WKf+mxAAikUjC4iBFkoxXl4VwXDUlUz7Zd5n8xBSLUUpjsVrJ4tBs4QbQ3k94g4q
xi2X99o1sXnIfuJpKFQ/2Xy4a2EBTshEYgI7UH6jfk42DF0bNARfStAnr9G8nB9T
rUAM2Lh3jOkH6GwXpdMqHxKzuAU7EMuTksWWr7BwCENLmb8ieKoRq9OIhxmpWIK0
x7uJvgjrTYE6/5I19WqtQymujfen9LDvzYdK0DeTsRSEkusszELEJ99nHs8xG3JU
LKtQMHylNUsxG2LhmHl6TJj8UsIOtj45gAcoxz4PxES+ZTsA/bv3O3BOjeg3E/rn
iCY7fyo07FYSNy7vqiHYXIhkR0vnKRJOemtDNDXMljRbeHXDFN2Rw9LgesPcMGYr
O8LiqpublmL49rSQydHk3kKCxEhffGvEyZRJPL0dMLr4wLctf1QDN/nxNKRsDSUw
LQUyCt4UYnsHw4Gb6Qrm+HZ3BJDvLNRCKgL/d4oGs2jWdB865mUxWEvpJtyGx602
XWqEOvJjeCj8fb/JDljkNiFGhVUSaFl7L5ZBmljjTkwD+bbgKtbxjX8VuSrGY68S
EN1S4TILPUia1U+ONcpcFNiBoP07jNJhbOjWGqFtBxtSFLkveAKG3P9NwlnGsDfs
EitYZE61O4bpgJxqqto+l5eo6NLKfH8EgY8TPD7dW/uRmwGYbAQ=
=B6sM
-----END PGP SIGNATURE-----

--Oiv9uiLrevHtW1RS--
