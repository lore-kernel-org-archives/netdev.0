From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net-next] net: hns: bug fix about hisilicon TSO BD mode
Date: Mon, 18 Jan 2016 11:36:32 +0200
Message-ID: <1453109792.2521.73.camel@linux.intel.com>
References: <1453109056-161865-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yisen.zhuang@huawei.com, yankejian@huawei.com,
	liguozhu@hisilicon.com, salil.mehta@huawei.com,
	geliangtang@163.com, lipeng321@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kenneth-Lee-2012@foxmail.com
To: Daode Huang <huangdaode@hisilicon.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453109056-161865-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-01-18 at 17:24 +0800, Daode Huang wrote:
> The current upstreaming code fails to set the tso_mode register
> when initilizes, when processes large size packets, the default 4 bd
> is
> not enough, so this patch initilizes it and set the default value to
> 8 bds

Please, next time try to thin out the Cc list. I have no intention to
be in it.

>=20
> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> ---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 13 ++++++++=
+++--
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h |=C2=A0=C2=A0=
3 +++
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |=C2=A0=C2=A0=
5 +++++
> =C2=A03 files changed, 19 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> index d2263c7..1218880 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> @@ -369,8 +369,17 @@ int hns_rcb_common_init_hw(struct rcb_common_cb
> *rcb_common)
> =C2=A0	dsaf_write_dev(rcb_common, RCB_COM_CFG_ENDIAN_REG,
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0HNS_RCB_COMMON_ENDI=
AN);
> =C2=A0
> -	dsaf_write_dev(rcb_common, RCB_COM_CFG_FNA_REG, 0x0);
> -	dsaf_write_dev(rcb_common, RCB_COM_CFG_FA_REG, 0x1);
> +	if (AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver)) {
> +		dsaf_write_dev(rcb_common, RCB_COM_CFG_FNA_REG,
> 0x0);
> +		dsaf_write_dev(rcb_common, RCB_COM_CFG_FA_REG, 0x1);
> +	} else {
> +		dsaf_set_dev_bit(rcb_common, RCBV2_COM_CFG_USER_REG,
> +				=C2=A0RCB_COM_CFG_FNA_B, false);
> +		dsaf_set_dev_bit(rcb_common, RCBV2_COM_CFG_USER_REG,
> +				=C2=A0RCB_COM_CFG_FA_B, true);
> +		dsaf_set_dev_bit(rcb_common,
> RCBV2_COM_CFG_TSO_MODE_REG,
> +				=C2=A0RCB_COM_TSO_MODE_B,
> HNS_TSO_MODE_8BD_32K);
> +	}
> =C2=A0
> =C2=A0	return 0;
> =C2=A0}
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
> index 29041b1..81fe9f8 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
> @@ -54,6 +54,9 @@ struct rcb_common_cb;
> =C2=A0#define HNS_DUMP_REG_NUM			500
> =C2=A0#define HNS_STATIC_REG_NUM			12
> =C2=A0
> +#define HNS_TSO_MODE_8BD_32K			1
> +#define HNS_TSO_MDOE_4BD_16K			0

Typo: MDOE

> +
> =C2=A0enum rcb_int_flag {
> =C2=A0	RCB_INT_FLAG_TX =3D 0x1,
> =C2=A0	RCB_INT_FLAG_RX =3D (0x1 << 1),
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
> index 5d1b746..f0c4f9b 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
> @@ -363,6 +363,8 @@
> =C2=A0#define RCB_COM_CFG_FA_REG			0x3C
> =C2=A0#define RCB_COM_CFG_PKT_TC_BP_REG		0x40
> =C2=A0#define RCB_COM_CFG_PPE_TNL_CLKEN_REG		0x44
> +#define RCBV2_COM_CFG_USER_REG			0x30
> +#define RCBV2_COM_CFG_TSO_MODE_REG		0x50
> =C2=A0
> =C2=A0#define RCB_COM_INTMSK_TX_PKT_REG		0x3A0
> =C2=A0#define RCB_COM_RINT_TX_PKT_REG			0x3A8
> @@ -860,6 +862,9 @@
> =C2=A0
> =C2=A0#define PPE_COMMON_CNT_CLR_CE_B	0
> =C2=A0#define PPE_COMMON_CNT_CLR_SNAP_EN_B	1
> +#define RCB_COM_TSO_MODE_B	0
> +#define RCB_COM_CFG_FNA_B	1
> +#define RCB_COM_CFG_FA_B	0
> =C2=A0
> =C2=A0#define GMAC_DUPLEX_TYPE_B 0
> =C2=A0

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
