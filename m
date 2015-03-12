From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [v2,04/11] soc/fman: Add the FMan port FLIB
Date: Thu, 12 Mar 2015 11:09:54 -0500
Message-ID: <DC69BFCB-B82B-4F29-8771-BE5DE266DD77@kernel.crashing.org>
References: <1426050295-12209-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com
To: "Igal.Liberman" <igal.liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426050295-12209-1-git-send-email-igal.liberman@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 11, 2015, at 12:04 AM, Igal.Liberman <igal.liberman@freescale.co=
m> wrote:

> From: Igal Liberman <Igal.Liberman@freescale.com>

commit message?

>=20
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> ---
> drivers/soc/fsl/fman/Kconfig          |   10 +
> drivers/soc/fsl/fman/Makefile         |    2 +
> drivers/soc/fsl/fman/port/Makefile    |    3 +
> drivers/soc/fsl/fman/port/fman_port.c | 1535 ++++++++++++++++++++++++=
+++++++++
> 4 files changed, 1550 insertions(+)
> create mode 100644 drivers/soc/fsl/fman/port/Makefile
> create mode 100644 drivers/soc/fsl/fman/port/fman_port.c

Should merge this with the header patch 3/11.

Docs for the =93public=94 functions would be good.

- k

>=20
> diff --git a/drivers/soc/fsl/fman/Kconfig b/drivers/soc/fsl/fman/Kcon=
fig
> index 6e8b0a6..b4c98ef 100644
> --- a/drivers/soc/fsl/fman/Kconfig
> +++ b/drivers/soc/fsl/fman/Kconfig
> @@ -5,3 +5,13 @@ menuconfig FSL_FMAN
> 	help
> 		Freescale Data-Path Acceleration Architecture Frame Manager
> 		(FMan) support
> +
> +if FSL_FMAN
> +
> +config FSL_FMAN_PORT
> +	bool "FMan port"
> +	default n
> +	help
> +		Freescale DPAA FMan port support
> +
> +endif	# FSL_FMAN
> diff --git a/drivers/soc/fsl/fman/Makefile b/drivers/soc/fsl/fman/Mak=
efile
> index e7a0575..437a325 100644
> --- a/drivers/soc/fsl/fman/Makefile
> +++ b/drivers/soc/fsl/fman/Makefile
> @@ -3,3 +3,5 @@ subdir-ccflags-$(CONFIG_FSL_FMAN) +=3D -I$(srctree)/d=
rivers/soc/fsl/fman/flib
> obj-$(CONFIG_FSL_FMAN)		+=3D fsl_fman.o
>=20
> fsl_fman-objs			:=3D fman.o
> +
> +obj-$(CONFIG_FSL_FMAN_PORT)	+=3D port/
> diff --git a/drivers/soc/fsl/fman/port/Makefile b/drivers/soc/fsl/fma=
n/port/Makefile
> new file mode 100644
> index 0000000..0062fed
> --- /dev/null
> +++ b/drivers/soc/fsl/fman/port/Makefile
> @@ -0,0 +1,3 @@
> +obj-$(CONFIG_FSL_FMAN_PORT)	+=3D fsl_fman_port.o
> +
> +fsl_fman_port-objs		:=3D fman_port.o
> diff --git a/drivers/soc/fsl/fman/port/fman_port.c b/drivers/soc/fsl/=
fman/port/fman_port.c
> new file mode 100644
> index 0000000..cc05dc0
> --- /dev/null
> +++ b/drivers/soc/fsl/fman/port/fman_port.c
> @@ -0,0 +1,1535 @@
> +/*
> + * Copyright 2008 - 2015 Freescale Semiconductor Inc.
> + *
> + * Redistribution and use in source and binary forms, with or withou=
t
> + * modification, are permitted provided that the following condition=
s are met:
> + *     * Redistributions of source code must retain the above copyri=
ght
> + *	 notice, this list of conditions and the following disclaimer.
> + *     * Redistributions in binary form must reproduce the above cop=
yright
> + *	 notice, this list of conditions and the following disclaimer in =
the
> + *	 documentation and/or other materials provided with the distribut=
ion.
> + *     * Neither the name of Freescale Semiconductor nor the
> + *	 names of its contributors may be used to endorse or promote prod=
ucts
> + *	 derived from this software without specific prior written permis=
sion.
> + *
> + * ALTERNATIVELY, this software may be distributed under the terms o=
f the
> + * GNU General Public License ("GPL") as published by the Free Softw=
are
> + * Foundation, either version 2 of that License or (at your option) =
any
> + * later version.
> + *
> + * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AN=
D ANY
> + * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE=
 IMPLIED
> + * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOS=
E ARE
> + * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE F=
OR ANY
> + * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIA=
L DAMAGES
> + * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS O=
R SERVICES;
> + * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER =
CAUSED AND
> + * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY=
, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE=
 USE OF THIS
> + * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +
> +#include "common/general.h"
> +
> +#include "fman_common.h"
> +#include "fsl_fman_port.h"
> +
> +/* problem Eyal: the following should not be here*/

??? Eyal ???

> +#define NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME	0x00000028
> +
> +static uint32_t get_no_pcd_nia_bmi_ac_enc_frame(struct fman_port_cfg=
 *cfg)
> +{
> +	if (cfg->errata_A006675)
> +		return NIA_ENG_FM_CTL |
> +		    NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME;
> +	else
> +		return NIA_ENG_BMI | NIA_BMI_AC_ENQ_FRAME;
> +}
> +
>=20

[snip]

> +int fman_port_add_congestion_grps(struct fman_port *port,
> +				  uint32_t grps_map[FMAN_PORT_CG_MAP_NUM])

Passing an array this way is usually bad form.

> +{
> +	int i;
> +	uint32_t __iomem *grp_map_reg;
> +	uint32_t tmp;
> +	uint8_t max_grp_map_num;
> +
> +	switch (port->type) {
> +	case E_FMAN_PORT_TYPE_RX:
> +	case E_FMAN_PORT_TYPE_RX_10G:
> +		if (port->fm_rev_maj =3D=3D 4)
> +			max_grp_map_num =3D 1;
> +		else
> +			max_grp_map_num =3D FMAN_PORT_CG_MAP_NUM;
> +		grp_map_reg =3D port->bmi_regs->rx.fmbm_rcgm;
> +		break;
> +	case E_FMAN_PORT_TYPE_OP:
> +		max_grp_map_num =3D 1;
> +		if (port->fm_rev_maj !=3D 4)
> +			return -EINVAL;
> +		grp_map_reg =3D &port->bmi_regs->oh.fmbm_ocgm;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	for (i =3D (max_grp_map_num - 1); i >=3D 0; i--) {
> +		if (grps_map[i] =3D=3D 0)
> +			continue;
> +		tmp =3D ioread32be(&grp_map_reg[i]);
> +		tmp |=3D grps_map[i];
> +		iowrite32be(tmp, &grp_map_reg[i]);
> +	}
> +
> +	return 0;
> +}
> +
> +int fman_port_remove_congestion_grps(struct fman_port *port,
> +				     uint32_t grps_map[FMAN_PORT_CG_MAP_NUM])
> +{
> +	int i;
> +	uint32_t __iomem *grp_map_reg;
> +	uint32_t tmp;
> +	uint8_t max_grp_map_num;
> +
> +	switch (port->type) {
> +	case E_FMAN_PORT_TYPE_RX:
> +	case E_FMAN_PORT_TYPE_RX_10G:
> +		if (port->fm_rev_maj =3D=3D 4)
> +			max_grp_map_num =3D 1;
> +		else
> +			max_grp_map_num =3D FMAN_PORT_CG_MAP_NUM;
> +		grp_map_reg =3D port->bmi_regs->rx.fmbm_rcgm;
> +		break;
> +	case E_FMAN_PORT_TYPE_OP:
> +		max_grp_map_num =3D 1;
> +		if (port->fm_rev_maj !=3D 4)
> +			return -EINVAL;
> +		grp_map_reg =3D &port->bmi_regs->oh.fmbm_ocgm;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	for (i =3D (max_grp_map_num - 1); i >=3D 0; i--) {
> +		if (grps_map[i] =3D=3D 0)
> +			continue;
> +		tmp =3D ioread32be(&grp_map_reg[i]);
> +		tmp &=3D ~grps_map[i];
> +		iowrite32be(tmp, &grp_map_reg[i]);
> +	}
> +	return 0;
> +}
> --=20
> 1.7.9.5
>=20
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
