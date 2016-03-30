From: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Subject: Re: [PATCH 4/5] fsl/qe: Add QE TDM lib
Date: Wed, 30 Mar 2016 11:50:00 +0000
Message-ID: <1459338701.3538.17.camel@infinera.com>
References: <1459327830-19829-1-git-send-email-qiang.zhao@nxp.com>
	 <1459327830-19829-4-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"xiaobo.xie@nxp.com" <xiaobo.xie@nxp.com>,
	"oss@buserror.net" <oss@buserror.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"qiang.zhao@nxp.com" <qiang.zhao@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459327830-19829-4-git-send-email-qiang.zhao@nxp.com>
Content-Language: en-US
Content-ID: <15A85D9336B5D843B17BC2512C9F0B4D@infinera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-03-30 at 16:50 +0800, Zhao Qiang wrote:
> QE has module to support TDM, some other protocols
> supported by QE are based on TDM.
> add a qe-tdm lib, this lib provides functions to the protocols
> using TDM to configurate QE-TDM.
>=20
> Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
> ---
> =A0drivers/soc/fsl/qe/Kconfig=A0=A0=A0=A0|=A0=A0=A04 +
> =A0drivers/soc/fsl/qe/Makefile=A0=A0=A0|=A0=A0=A01 +
> =A0drivers/soc/fsl/qe/qe_tdm.c=A0=A0=A0| 271 ++++++++++++++++++++++++=
++++++++++++++++++
> =A0include/soc/fsl/qe/immap_qe.h |=A0=A0=A05 +-
> =A0include/soc/fsl/qe/qe_tdm.h=A0=A0=A0|=A0=A094 +++++++++++++++
> =A05 files changed, 371 insertions(+), 4 deletions(-)
> =A0create mode 100644 drivers/soc/fsl/qe/qe_tdm.c
> =A0create mode 100644 include/soc/fsl/qe/qe_tdm.h
>=20
> diff --git a/drivers/soc/fsl/qe/Kconfig b/drivers/soc/fsl/qe/Kconfig
> index 20978f2..463cf29 100644
> --- a/drivers/soc/fsl/qe/Kconfig
> +++ b/drivers/soc/fsl/qe/Kconfig
> @@ -31,6 +31,10 @@ config UCC
> =A0	bool
> =A0	default y if UCC_FAST || UCC_SLOW
> =A0
> +config QE_TDM
> +	bool
> +	select UCC_FAST
> +
> =A0config QE_USB
> =A0	bool
> =A0	default y if USB_FSL_QE
> diff --git a/drivers/soc/fsl/qe/Makefile b/drivers/soc/fsl/qe/Makefil=
e
> index ffac541..2031d38 100644
> --- a/drivers/soc/fsl/qe/Makefile
> +++ b/drivers/soc/fsl/qe/Makefile
> @@ -6,5 +6,6 @@ obj-$(CONFIG_CPM)	+=3D qe_common.o
> =A0obj-$(CONFIG_UCC)	+=3D ucc.o
> =A0obj-$(CONFIG_UCC_SLOW)	+=3D ucc_slow.o
> =A0obj-$(CONFIG_UCC_FAST)	+=3D ucc_fast.o
> +obj-$(CONFIG_QE_TDM)	+=3D qe_tdm.o
> =A0obj-$(CONFIG_QE_USB)	+=3D usb.o
> =A0obj-$(CONFIG_QE_GPIO)	+=3D gpio.o
> diff --git a/drivers/soc/fsl/qe/qe_tdm.c b/drivers/soc/fsl/qe/qe_tdm.=
c
> new file mode 100644
> index 0000000..9a2374d
> --- /dev/null
> +++ b/drivers/soc/fsl/qe/qe_tdm.c
> @@ -0,0 +1,271 @@
> +/*
> + * Copyright (C) 2015 Freescale Semiconductor, Inc. All rights reser=
ved.
> + *
> + * Authors:	Zhao Qiang <qiang.zhao@nxp.com>
> + *
> + * Description:
> + * QE TDM API Set - TDM specific routines implementations.
> + *
> + * This program is free software; you can redistribute=A0=A0it and/o=
r modify it
> + * under=A0=A0the terms of=A0=A0the GNU General=A0=A0Public License =
as published by the
> + * Free Software Foundation;=A0=A0either version 2 of the=A0=A0Licen=
se, or (at your
> + * option) any later version.
> + */
> +#include <linux/io.h>
> +#include <linux/kernel.h>
> +#include <linux/of_address.h>
> +#include <linux/of_irq.h>
> +#include <linux/of_platform.h>
> +#include <soc/fsl/qe/qe_tdm.h>
> +
> +static enum tdm_framer_t set_tdm_framer(const char *tdm_framer_type)
> +{
> +	if (strcmp(tdm_framer_type, "e1") =3D=3D 0)
> +		return TDM_FRAMER_E1;
> +	else
> +		return TDM_FRAMER_T1;
> +}
> +
> +static void set_si_param(struct ucc_tdm *utdm, struct ucc_tdm_info *=
ut_info)
> +{
> +	struct si_mode_info *si_info =3D &ut_info->si_info;
> +
> +	if (utdm->tdm_mode =3D=3D TDM_INTERNAL_LOOPBACK) {
> +		si_info->simr_crt =3D 1;
> +		si_info->simr_rfsd =3D 0;
> +	}
> +}
> +
> +int ucc_of_parse_tdm(struct device_node *np, struct ucc_tdm *utdm,
> +		=A0=A0=A0=A0=A0struct ucc_tdm_info *ut_info)
> +{
> +	const char *sprop;
> +	int ret =3D 0;
> +	u32 val;
> +	struct resource *res;
> +	struct device_node *np2;
> +	static int siram_init_flag;
> +	struct platform_device *pdev;
> +
> +	sprop =3D of_get_property(np, "fsl,rx-sync-clock", NULL);
> +	if (sprop) {
> +		ut_info->uf_info.rx_sync =3D qe_clock_source(sprop);
> +		if ((ut_info->uf_info.rx_sync < QE_CLK_NONE) ||
> +		=A0=A0=A0=A0(ut_info->uf_info.rx_sync > QE_RSYNC_PIN)) {
> +			pr_err("QE-TDM: Invalid rx-sync-clock property\n");
> +			return -EINVAL;
> +		}
> +	} else {
> +		pr_err("QE-TDM: Invalid rx-sync-clock property\n");
> +		return -EINVAL;
> +	}
> +
> +	sprop =3D of_get_property(np, "fsl,tx-sync-clock", NULL);
> +	if (sprop) {
> +		ut_info->uf_info.tx_sync =3D qe_clock_source(sprop);
> +		if ((ut_info->uf_info.tx_sync < QE_CLK_NONE) ||
> +		=A0=A0=A0=A0(ut_info->uf_info.tx_sync > QE_TSYNC_PIN)) {
> +			pr_err("QE-TDM: Invalid tx-sync-clock property\n");
> +		return -EINVAL;
> +		}
> +	} else {
> +		pr_err("QE-TDM: Invalid tx-sync-clock property\n");
> +		return -EINVAL;
> +	}
> +
> +	ret =3D of_property_read_u32_index(np, "fsl,tx-timeslot-mask", 0, &=
val);
> +	if (ret) {
> +		pr_err("QE-TDM: Invalid tx-timeslot-mask property\n");
> +		return -EINVAL;
> +	}
> +	utdm->tx_ts_mask =3D val;
> +
> +	ret =3D of_property_read_u32_index(np, "fsl,rx-timeslot-mask", 0, &=
val);
> +	if (ret) {
> +		ret =3D -EINVAL;
> +		pr_err("QE-TDM: Invalid rx-timeslot-mask property\n");
> +		return ret;
> +	}
> +	utdm->rx_ts_mask =3D val;
> +
> +	ret =3D of_property_read_u32_index(np, "fsl,tdm-id", 0, &val);
> +	if (ret) {
> +		ret =3D -EINVAL;
> +		pr_err("QE-TDM: No fsl,tdm-id property for this UCC\n");
> +		return ret;
> +	}
> +	utdm->tdm_port =3D val;
> +	ut_info->uf_info.tdm_num =3D utdm->tdm_port;
> +
> +	if (of_get_property(np, "fsl,tdm-internal-loopback", NULL))
> +		utdm->tdm_mode =3D TDM_INTERNAL_LOOPBACK;
> +	else
> +		utdm->tdm_mode =3D TDM_NORMAL;
> +
> +	sprop =3D of_get_property(np, "fsl,tdm-framer-type", NULL);
> +	if (!sprop) {
> +		ret =3D -EINVAL;
> +		pr_err("QE-TDM: No tdm-framer-type property for UCC\n");
> +		return ret;
> +	}
> +	utdm->tdm_framer_type =3D set_tdm_framer(sprop);
> +
> +	ret =3D of_property_read_u32_index(np, "fsl,siram-entry-id", 0, &va=
l);
> +	if (ret) {
> +		ret =3D -EINVAL;
> +		pr_err("QE-TDM: No siram entry id for UCC\n");
> +		return ret;
> +	}
> +	utdm->siram_entry_id =3D val;
> +
> +	set_si_param(utdm, ut_info);
> +
> +	np2 =3D of_find_compatible_node(NULL, NULL, "fsl,t1040-qe-si");

fsl,t1040-qe-si only? What about mpc83xx?
I recall QE is a little bit different compared to T1040 or will this wo=
rk(including the hdlc driver)
on 83xx as well?

=A0Jocke=A0
