From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH v2 net-next 10/10] net: hns3: Add mqprio support when
 interacting with network stack
Date: Tue, 26 Sep 2017 06:43:41 +0000
Message-ID: <AM0PR0502MB3683C922A7D87D3E1F64B93EBF7B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1506392718-50463-1-git-send-email-linyunsheng@huawei.com>
 <1506392718-50463-11-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
        "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
        "Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "john.garry@huawei.com" <john.garry@huawei.com>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>,
        "yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
        "salil.mehta@huawei.com" <salil.mehta@huawei.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506392718-50463-11-git-send-email-linyunsheng@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> When using tc qdisc to configure DCB parameter, dcb_ops->setup_tc
> is used to tell hclge_dcb module to do the setup.

While this might be a step in the right direction, this causes an inconsist=
ency
in user experience - Some [well, most] vendors didn't allow the mqprio
priority mapping to affect DCB, instead relying on the dcbnl functionality
to control that configuration.

A couple of options to consider:
  - Perhaps said logic shouldn't be contained inside the driver but rather
     in mqprio logic itself. I.e., rely on DCBNL functionality [if availabl=
e] from
     within mqprio and try changing the configuration.=20
  - Add a new TC_MQPRIO_HW_OFFLOAD_ value to explicitly reflect user
     request to allow this configuration to affect DCB.

> When using lldptool to configure DCB parameter, hclge_dcb module
> call the client_ops->setup_tc to tell network stack which queue
> and priority is using for specific tc.

You're basically bypassing the mqprio logic.
Since you're configuring the prio->queue mapping from DCB flow,
you'll get an mqprio-like behavior [meaning a transmitted packet
would reach a transmission queue associated with its priority] even
if device wasn't grated with an mqprio qdisc.
Why should your user even use mqprio? What benefit does he get from it?

...

> +static int hns3_nic_set_real_num_queue(struct net_device *netdev)
> +{
> +	struct hns3_nic_priv *priv =3D netdev_priv(netdev);
> +	struct hnae3_handle *h =3D priv->ae_handle;
> +	struct hnae3_knic_private_info *kinfo =3D &h->kinfo;
> +	unsigned int queue_size =3D kinfo->rss_size * kinfo->num_tc;
> +	int ret;
> +
> +	ret =3D netif_set_real_num_tx_queues(netdev, queue_size);
> +	if (ret) {
> +		netdev_err(netdev,
> +			   "netif_set_real_num_tx_queues fail, ret=3D%d!\n",
> +			   ret);
> +		return ret;
> +	}
> +
> +	ret =3D netif_set_real_num_rx_queues(netdev, queue_size);

I don't think you're changing the driver behavior, but why are you setting
the real number of rx queues based on the number of TCs?
Do you actually open (TC x RSS) Rx queues?
