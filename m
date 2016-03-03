From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net] net: hns: fix the bug about loopback
Date: Thu, 03 Mar 2016 15:39:45 +0200
Message-ID: <1457012385.13244.243.camel@linux.intel.com>
References: <1457006579-236479-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: haifeng.wei@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxarm@huawei.com
To: Kejian Yan <yankejian@huawei.com>, davem@davemloft.net,
	yisen.zhuang@huawei.com, salil.mehta@huawei.com,
	liguozhu@huawei.com, huangdaode@hisilicon.com, arnd@arndb.de,
	andrew@lunn.ch, chenny.xu@huawei.com, ivecera@redhat.com,
	lisheng011@huawei.com, fengguang.wu@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457006579-236479-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-03-03 at 20:02 +0800, Kejian Yan wrote:
> It will always be passed if the soc is tested the loopback cases.
> This
> patch will fix this bug.

=46ew style related comments.

> @@ -686,6 +690,10 @@ static int hns_ae_config_loopback(struct
> hnae_handle *handle,
> =C2=A0	default:
> =C2=A0		ret =3D -EINVAL;
> =C2=A0	}
> +
> +	if (!ret)
> +		hns_dsaf_set_inner_lb(mac_cb->dsaf_dev, mac_cb-
> >mac_id, en);
> +
> =C2=A0	return ret;

if (ret)
=C2=A0return ret;

whatever();
return 0;

> =C2=A0}

--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> @@ -230,6 +230,30 @@ static void hns_dsaf_mix_def_qid_cfg(struct
> dsaf_device *dsaf_dev)
> =C2=A0	}
> =C2=A0}
> =C2=A0
> +static void hns_dsaf_inner_qid_cfg(struct dsaf_device *dsaf_dev)
> +{
> +	u16 max_q_per_vf, max_vfn;
> +	u32 q_id =3D 0, q_num_per_port;
> +	u32 mac_id;
> +
> +	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
> +		return;
> +
> +	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0HNS_DSAF_COMM_SERVICE_N=
W_IDX,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0&max_vfn, &max_q_per_vf=
);
> +	q_num_per_port =3D max_vfn * max_q_per_vf;
> +
> +	for (mac_id =3D 0, q_id =3D 0; mac_id < DSAF_SERVICE_NW_NUM;=20

q_id is already assigned to 0. Get rid of either.

> mac_id++) {
> +		dsaf_set_dev_field(dsaf_dev,
> +				=C2=A0=C2=A0=C2=A0DSAFV2_SERDES_LBK_0_REG + 0x4 *
> mac_id,
> +				=C2=A0=C2=A0=C2=A0DSAFV2_SERDES_LBK_QID_M,
> +				=C2=A0=C2=A0=C2=A0DSAFV2_SERDES_LBK_QID_S,
> +				=C2=A0=C2=A0=C2=A0q_id);
> +		q_id +=3D q_num_per_port;
> +	}
> +}

=C2=A0
> +void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id,
> u32 en)
> +{
> +	if (AE_IS_VER1(dsaf_dev->dsaf_ver) ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0dsaf_dev->mac_cb[mac_id].mac_type =3D=3D HN=
AE_PORT_DEBUG)
> +		return;
> +
> +	dsaf_set_dev_bit(dsaf_dev, DSAFV2_SERDES_LBK_0_REG + 0x4 *
> mac_id,

0x4 -> 4 (it's about register width, right?)

> +			=C2=A0DSAFV2_SERDES_LBK_EN_B, !!en);
> +}

> =C2=A0#define PPEV2_CFG_RSS_TBL_4N3_S	24
> =C2=A0#define PPEV2_CFG_RSS_TBL_4N3_M	(((1UL << 5) - 1) <<
> PPEV2_CFG_RSS_TBL_4N3_S)
> =C2=A0
> +#define DSAFV2_SERDES_LBK_EN_B=C2=A0=C2=A08
> +#define DSAFV2_SERDES_LBK_QID_S 0
> +#define DSAFV2_SERDES_LBK_QID_M \
> +	(((1UL << DSAFV2_SERDES_LBK_EN_B) - 1) <<
> DSAFV2_SERDES_LBK_QID_S)

Why not like above?

#define DSAFV2_SERDES_LBK_QID_M	(((1UL << 8) - 1)
<<=C2=A0DSAFV2_SERDES_LBK_QID_S)

> +static void __lb_fill_txt_skb_buff(struct net_device *ndev,
> +				=C2=A0=C2=A0=C2=A0struct sk_buff *skb)
> +{
> +	struct hns_nic_priv *priv =3D netdev_priv(ndev);
> +	struct hnae_handle *h =3D priv->ae_handle;
> +	u32 frame_size;
> +
> +	frame_size =3D skb->len;
> +	memset(skb->data, 0xFF, frame_size);
> +
> +	if ((!AE_IS_VER1(priv->enet_ver)) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0(h->port_type =3D=3D HNAE_PORT_SERVICE)) {
> +		memcpy(skb->data, ndev->dev_addr, 6);

ether_addr_copy() ?

> +		skb->data[5] +=3D 0x1f;

This has to be explained.

> +	}
> +
> +	frame_size &=3D ~1ul;

And how 1ul is different to plain 1 here?

> +	memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 -
> 1);
> +	memset(&skb->data[frame_size / 2 + 10], 0xBE, frame_size / 2
> - 11);
> +	memset(&skb->data[frame_size / 2 + 12], 0xAF, frame_size / 2
> - 13);

Magic numbers have to be explained.
Also, what is the logic to overwrite the data if frame_size is big
enough?

> +}
> +

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
