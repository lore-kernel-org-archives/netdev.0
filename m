From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH RFC 02/11] dpaa_eth: add support for DPAA Ethernet
Date: Wed, 18 Mar 2015 11:30:14 -0500
Message-ID: <A5972108-80F3-44C0-A72A-8355BFF3E617@kernel.crashing.org>
References: <1426618709-19004-1-git-send-email-madalin.bucur@freescale.com> <1426618709-19004-2-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46351 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330AbbCRQae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 12:30:34 -0400
In-Reply-To: <1426618709-19004-2-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 17, 2015, at 1:58 PM, Madalin Bucur <madalin.bucur@Freescale.com=
> wrote:

> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.
>=20
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
> drivers/net/ethernet/freescale/Kconfig             |    2 +
> drivers/net/ethernet/freescale/Makefile            |    1 +
> drivers/net/ethernet/freescale/dpaa/Kconfig        |   49 +
> drivers/net/ethernet/freescale/dpaa/Makefile       |   14 +
> drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  837 +++++++++++=
++
> drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  446 +++++++
> .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  | 1288 +++++++++++=
+++++++++
> .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |  119 ++
> drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  |  428 +++++++
> 9 files changed, 3184 insertions(+)
> create mode 100644 drivers/net/ethernet/freescale/dpaa/Kconfig
> create mode 100644 drivers/net/ethernet/freescale/dpaa/Makefile
> create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_commo=
n.c
> create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_commo=
n.h
> create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
>=20
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/eth=
ernet/freescale/Kconfig
> index ba84c4a..dd485f1 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -95,4 +95,6 @@ config GIANFAR
> 	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
> 	  and MPC86xx family of chips, and the FEC on the 8540.
>=20
> +source "drivers/net/ethernet/freescale/dpaa/Kconfig"
> +
> endif # NET_VENDOR_FREESCALE
> diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/et=
hernet/freescale/Makefile
> index 71debd1..b6c10ab 100644
> --- a/drivers/net/ethernet/freescale/Makefile
> +++ b/drivers/net/ethernet/freescale/Makefile
> @@ -12,6 +12,7 @@ obj-$(CONFIG_FS_ENET) +=3D fs_enet/
> obj-$(CONFIG_FSL_PQ_MDIO) +=3D fsl_pq_mdio.o
> obj-$(CONFIG_FSL_XGMAC_MDIO) +=3D xgmac_mdio.o
> obj-$(CONFIG_GIANFAR) +=3D gianfar_driver.o
> +obj-$(if $(CONFIG_FSL_DPAA_ETH),y) +=3D dpaa/

Why isn=92t

obj-$(CONFIG_FSL_DPAA_ETH)	+=3D dpaa/=20

enough?

> obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) +=3D gianfar_ptp.o
> gianfar_driver-objs :=3D gianfar.o \
> 		gianfar_ethtool.o
> diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/ne=
t/ethernet/freescale/dpaa/Kconfig
> new file mode 100644
> index 0000000..7ef703c
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
> @@ -0,0 +1,49 @@
> +menuconfig FSL_DPAA_ETH
> +	tristate "DPAA Ethernet"
> +	depends on FSL_SOC && FSL_BMAN && FSL_QMAN && FSL_FMAN
> +	select PHYLIB
> +	select FSL_FMAN_MAC
> +	---help---
> +	  Data Path Acceleration Architecture Ethernet driver,
> +	  supporting the Freescale QorIQ chips.
> +	  Depends on Freescale Buffer Manager and Queue Manager
> +	  driver and Frame Manager Driver.
> +
> +if FSL_DPAA_ETH
> +
> +config FSL_DPAA_CS_THRESHOLD_1G
> +	hex "Egress congestion threshold on 1G ports"
> +	depends on FSL_DPAA_ETH
> +	range 0x1000 0x10000000
> +	default "0x06000000"
> +	---help---
> +	  The size in bytes of the egress Congestion State notification thr=
eshold on 1G ports.
> +	  The 1G dTSECs can quite easily be flooded by cores doing Tx in a =
tight loop
> +	  (e.g. by sending UDP datagrams at "while(1) speed"),
> +	  and the larger the frame size, the more acute the problem.
> +	  So we have to find a balance between these factors:
> +	       - avoiding the device staying congested for a prolonged time=
 (risking
> +                 the netdev watchdog to fire - see also the tx_timeo=
ut module param);
> +               - affecting performance of protocols such as TCP, whi=
ch otherwise
> +	         behave well under the congestion notification mechanism;
> +	       - preventing the Tx cores from tightly-looping (as if the co=
ngestion
> +	         threshold was too low to be effective);
> +	       - running out of memory if the CS threshold is set too high.
> +
> +config FSL_DPAA_CS_THRESHOLD_10G
> +	hex "Egress congestion threshold on 10G ports"
> +	depends on FSL_DPAA_ETH
> +	range 0x1000 0x20000000
> +	default "0x10000000"
> +	---help ---
> +	  The size in bytes of the egress Congestion State notification thr=
eshold on 10G ports.
> +
> +config FSL_DPAA_INGRESS_CS_THRESHOLD
> +	hex "Ingress congestion threshold on FMan ports"
> +	depends on FSL_DPAA_ETH
> +	default "0x10000000"
> +	---help---
> +	  The size in bytes of the ingress tail-drop threshold on FMan port=
s.
> +	  Traffic piling up above this value will be rejected by QMan and d=
iscarded by FMan.
> +

Do these thresholds really need to be kconfig options?  Are they not ch=
angeable at runtime?

> +endif # FSL_DPAA_ETH
> diff --git a/drivers/net/ethernet/freescale/dpaa/Makefile b/drivers/n=
et/ethernet/freescale/dpaa/Makefile
> new file mode 100644
> index 0000000..bdeb04e
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/Makefile
> @@ -0,0 +1,14 @@
> +#
> +# Makefile for the Freescale DPAA Ethernet controllers
> +#
> +ccflags-y +=3D -DVERSION=3D\=94\"

Is this really needed, if so we need to fix that.

> +#
> +# Include FMan headers
> +FMAN        =3D $(srctree)/drivers/soc/fsl/fman
> +ccflags-y +=3D -I$(FMAN)
> +ccflags-y +=3D -I$(FMAN)/inc
> +ccflags-y +=3D -I$(FMAN)/flib
> +
> +obj-$(CONFIG_FSL_DPAA_ETH) +=3D fsl_dpa.o
> +
> +fsl_dpa-objs +=3D dpaa_eth.o dpaa_eth_sg.o dpaa_eth_common.o
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers=
/net/ethernet/freescale/dpaa/dpaa_eth.c
> new file mode 100644
> index 0000000..96a7cee
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> @@ -0,0 +1,837 @@
> +/* Copyright 2008 - 2015 Freescale Semiconductor Inc.
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
> +#define pr_fmt(fmt) \
> +	KBUILD_MODNAME ": " fmt
> +
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_net.h>
> +#include <linux/kthread.h>
> +#include <linux/io.h>
> +#include <linux/if_arp.h>	/* arp_hdr_len() */
> +#include <linux/if_vlan.h>	/* VLAN_HLEN */
> +#include <linux/icmp.h>		/* struct icmphdr */
> +#include <linux/ip.h>		/* struct iphdr */
> +#include <linux/ipv6.h>		/* struct ipv6hdr */
> +#include <linux/udp.h>		/* struct udphdr */
> +#include <linux/tcp.h>		/* struct tcphdr */
> +#include <linux/net.h>		/* net_ratelimit() */
> +#include <linux/if_ether.h>	/* ETH_P_IP and ETH_P_IPV6 */
> +#include <linux/highmem.h>
> +#include <linux/percpu.h>
> +#include <linux/dma-mapping.h>
> +#include <soc/fsl/bman.h>
> +
> +#include "fsl_fman.h"
> +#include "fm_ext.h"
> +#include "fm_port_ext.h"
> +
> +#include "mac.h"
> +#include "dpaa_eth.h"
> +#include "dpaa_eth_common.h"
> +
> +#define DPA_NAPI_WEIGHT		64
> +
> +/* Valid checksum indication */
> +#define DPA_CSUM_VALID		0xFFFF
> +
> +#define DPA_DESCRIPTION "FSL DPAA Ethernet driver"
> +
> +MODULE_LICENSE("Dual BSD/GPL");
> +
> +MODULE_AUTHOR("Andy Fleming <afleming@freescale.com>");
> +
> +MODULE_DESCRIPTION(DPA_DESCRIPTION);

These are typically at the end of the file, and kept together (ie no bl=
ank lines between them)

> +
> +static u8 debug =3D -1;
> +module_param(debug, byte, S_IRUGO);
> +MODULE_PARM_DESC(debug, "Module/Driver verbosity level");
> +
> +/* This has to work in tandem with the DPA_CS_THRESHOLD_xxx values. =
*/
> +static u16 tx_timeout =3D 1000;
> +module_param(tx_timeout, ushort, S_IRUGO);
> +MODULE_PARM_DESC(tx_timeout, "The Tx timeout in ms");
> +
>=20

[snip]

> +
> +static struct platform_device_id dpa_devtype[] =3D {
> +	{
> +		.name =3D "dpaa-ethernet",
> +		.driver_data =3D 0,
> +	}, {
> +	}
> +};
> +MODULE_DEVICE_TABLE(platform, dpa_devtype);
> +
> +static struct platform_driver dpa_driver =3D {
> +	.driver =3D {
> +		.name		=3D KBUILD_MODNAME,
> +		.owner		=3D THIS_MODULE,
> +	},
> +	.id_table	=3D dpa_devtype,
> +	.probe		=3D dpaa_eth_priv_probe,
> +	.remove		=3D dpa_remove
> +};
> +
> +static int __init __cold dpa_load(void)
> +{
> +	int	 _errno;
> +
> +	pr_info(DPA_DESCRIPTION " (" VERSION ")\n");
> +
> +	/* initialise dpaa_eth mirror values */
> +	dpa_rx_extra_headroom =3D fm_get_rx_extra_headroom();
> +	dpa_max_frm =3D fm_get_max_frm();
> +
> +	_errno =3D platform_driver_register(&dpa_driver);
> +	if (unlikely(_errno < 0)) {
> +		pr_err(KBUILD_MODNAME
> +			": %s:%hu:%s(): platform_driver_register() =3D %d\n",
> +			KBUILD_BASENAME ".c", __LINE__, __func__, _errno);
> +	}
> +
> +	pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
> +		 KBUILD_BASENAME ".c", __func__);
> +
> +	return _errno;
> +}
> +module_init(dpa_load);
> +
> +static void __exit __cold dpa_unload(void)
> +{
> +	pr_debug(KBUILD_MODNAME ": -> %s:%s()\n",
> +		 KBUILD_BASENAME ".c", __func__);
> +
> +	platform_driver_unregister(&dpa_driver);
> +
> +	/* Only one channel is used and needs to be relased after all
> +	 * interfaces are removed
> +	 */
> +	dpa_release_channel();
> +
> +	pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
> +		 KBUILD_BASENAME ".c", __func__);
> +}
> +module_exit(dpa_unload);

What=92s the point of this dpa platform driver?

> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers=
/net/ethernet/freescale/dpaa/dpaa_eth.h
> new file mode 100644
> index 0000000..793491f
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> @@ -0,0 +1,446 @@
> +/* Copyright 2008 - 2015 Freescale Semiconductor Inc.
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
> +#ifndef __DPA_H
> +#define __DPA_H
> +
> +#include <linux/netdevice.h>
> +#include <soc/fsl/qman.h>	/* struct qman_fq */
> +
> +#include "fm_ext.h"
> +
> +extern int dpa_rx_extra_headroom;
> +extern int dpa_max_frm;
> +
> +#define dpa_get_rx_extra_headroom() dpa_rx_extra_headroom
> +#define dpa_get_max_frm() dpa_max_frm
> +
> +#define dpa_get_max_mtu()	\
> +	(dpa_get_max_frm() - (VLAN_ETH_HLEN + ETH_FCS_LEN))
> +
> +#define __hot
> +
> +/* Simple enum of FQ types - used for array indexing */
> +enum port_type {RX, TX};
> +
> +struct dpa_buffer_layout_s {
> +	u16	priv_data_size;
> +	bool		parse_results;
> +	bool		time_stamp;
> +	bool		hash_results;
> +	u16	data_align;
> +};
> +
> +#define DPA_ERR_ON(cond)
> +
> +#define DPA_TX_PRIV_DATA_SIZE	16
> +#define DPA_PARSE_RESULTS_SIZE sizeof(fm_prs_result)
> +#define DPA_TIME_STAMP_SIZE 8
> +#define DPA_HASH_RESULTS_SIZE 8
> +#define DPA_RX_PRIV_DATA_SIZE	(DPA_TX_PRIV_DATA_SIZE + \
> +					dpa_get_rx_extra_headroom())
> +
> +#define FM_FD_STAT_RX_ERRORS						\
> +	(FM_PORT_FRM_ERR_DMA | FM_PORT_FRM_ERR_PHYSICAL	| \
> +	 FM_PORT_FRM_ERR_SIZE | FM_PORT_FRM_ERR_CLS_DISCARD | \
> +	 FM_PORT_FRM_ERR_EXTRACTION | FM_PORT_FRM_ERR_NO_SCHEME	| \
> +	 FM_PORT_FRM_ERR_PRS_TIMEOUT | FM_PORT_FRM_ERR_PRS_ILL_INSTRUCT | \
> +	 FM_PORT_FRM_ERR_PRS_HDR_ERR)
> +
> +#define FM_FD_STAT_TX_ERRORS \
> +	(FM_PORT_FRM_ERR_UNSUPPORTED_FORMAT | \
> +	 FM_PORT_FRM_ERR_LENGTH | FM_PORT_FRM_ERR_DMA)
> +
> +/* The raw buffer size must be cacheline aligned.
> + * Normally we use 2K buffers.
> + */
> +#define DPA_BP_RAW_SIZE		2048
> +
> +/* This is what FMan is ever allowed to use.
> + * FMan-DMA requires 16-byte alignment for Rx buffers, but SKB_DATA_=
ALIGN is
> + * even stronger (SMP_CACHE_BYTES-aligned), so we just get away with=
 that,
> + * via SKB_WITH_OVERHEAD(). We can't rely on netdev_alloc_frag() giv=
ing us
> + * half-page-aligned buffers (can we?), so we reserve some more spac=
e
> + * for start-of-buffer alignment.
> + */
> +#define dpa_bp_size(buffer_layout)	(SKB_WITH_OVERHEAD(DPA_BP_RAW_SIZ=
E) - \
> +						SMP_CACHE_BYTES)
> +/* We must ensure that skb_shinfo is always cacheline-aligned. */
> +#define DPA_SKB_SIZE(size)	((size) & ~(SMP_CACHE_BYTES - 1))
> +
> +/* Largest value that the FQD's OAL field can hold.
> + * This is DPAA-1.x specific.
> + */
> +#define FSL_QMAN_MAX_OAL	127
> +
> +/* Default alignment for start of data in an Rx FD */
> +#define DPA_FD_DATA_ALIGNMENT  16
> +
> +/* Values for the L3R field of the FM Parse Results
> + */
> +/* L3 Type field: First IP Present IPv4 */
> +#define FM_L3_PARSE_RESULT_IPV4	0x8000
> +/* L3 Type field: First IP Present IPv6 */
> +#define FM_L3_PARSE_RESULT_IPV6	0x4000
> +
> +/* Values for the L4R field of the FM Parse Results
> + * See $8.8.4.7.20 - L4 HXS - L4 Results from DPAA-Rev2 Reference Ma=
nual.
> + */
> +/* L4 Type field: UDP */
> +#define FM_L4_PARSE_RESULT_UDP	0x40
> +/* L4 Type field: TCP */
> +#define FM_L4_PARSE_RESULT_TCP	0x20
> +
> +#define FM_FD_STAT_ERR_PHYSICAL	FM_PORT_FRM_ERR_PHYSICAL
> +
> +/* number of Tx queues to FMan */
> +#define DPAA_ETH_TX_QUEUES	NR_CPUS
> +
> +#define DPAA_ETH_RX_QUEUES	128
> +
> +#define FSL_DPAA_ETH_MAX_BUF_COUNT	128
> +#define FSL_DPAA_ETH_REFILL_THRESHOLD	80
> +
> +/* More detailed FQ types - used for fine-grained WQ assignments */
> +enum dpa_fq_type {
> +	FQ_TYPE_RX_DEFAULT =3D 1, /* Rx Default FQs */
> +	FQ_TYPE_RX_ERROR,	/* Rx Error FQs */
> +	FQ_TYPE_RX_PCD,		/* User-defined PCDs */
> +	FQ_TYPE_TX,		/* "Real" Tx FQs */
> +	FQ_TYPE_TX_CONFIRM,	/* Tx default Conf FQ (actually an Rx FQ) */
> +	FQ_TYPE_TX_CONF_MQ,	/* Tx conf FQs (one for each Tx FQ) */
> +	FQ_TYPE_TX_ERROR,	/* Tx Error FQs (these are actually Rx FQs) */
> +};
> +
> +struct dpa_fq {
> +	struct qman_fq		 fq_base;
> +	struct list_head	 list;
> +	struct net_device	*net_dev;
> +	bool			 init;
> +	u32 fqid;
> +	u32 flags;
> +	u16 channel;
> +	u8 wq;
> +	enum dpa_fq_type fq_type;
> +};
> +
> +struct dpa_fq_cbs_t {
> +	struct qman_fq rx_defq;
> +	struct qman_fq tx_defq;
> +	struct qman_fq rx_errq;
> +	struct qman_fq tx_errq;
> +	struct qman_fq egress_ern;
> +};
> +
> +struct fqid_cell {
> +	u32 start;
> +	u32 count;
> +};
> +
> +struct dpa_bp {
> +	struct bman_pool		*pool;
> +	u8				bpid;
> +	struct device			*dev;
> +	union {
> +		/* The buffer pools used for the private ports are initialized
> +		 * with target_count buffers for each CPU; at runtime the
> +		 * number of buffers per CPU is constantly brought back to this
> +		 * level
> +		 */
> +		int target_count;
> +		/* The configured value for the number of buffers in the pool,
> +		 * used for shared port buffer pools
> +		 */
> +		int config_count;
> +	};
> +	size_t				size;
> +	bool				seed_pool;
> +	/* physical address of the contiguous memory used by the pool to st=
ore
> +	 * the buffers
> +	 */
> +	dma_addr_t			paddr;
> +	/* virtual address of the contiguous memory used by the pool to sto=
re
> +	 * the buffers
> +	 */
> +	void __iomem			*vaddr;
> +	/* current number of buffers in the bpool alloted to this CPU */
> +	int __percpu *percpu_count;
> +	atomic_t refs;
> +	/* some bpools need to be seeded before use by this cb */
> +	int (*seed_cb)(struct dpa_bp *);
> +	/* some bpools need to be emptied before freeing; this cb is used
> +	 * for freeing of individual buffers taken from the pool
> +	 */
> +	void (*free_buf_cb)(void *addr);
> +};
> +
> +struct dpa_napi_portal {
> +	struct napi_struct napi;
> +	struct qman_portal *p;
> +};
> +
> +struct dpa_percpu_priv_s {
> +	struct net_device *net_dev;
> +	struct dpa_napi_portal *np;
> +	struct rtnl_link_stats64 stats;
> +};
> +
> +struct dpa_priv_s {
> +	struct dpa_percpu_priv_s	__percpu *percpu_priv;
> +	struct dpa_bp *dpa_bp;
> +	/* Store here the needed Tx headroom for convenience and speed
> +	 * (even though it can be computed based on the fields of buf_layou=
t)
> +	 */
> +	u16 tx_headroom;
> +	struct net_device *net_dev;
> +	struct mac_device	*mac_dev;
> +	struct qman_fq		*egress_fqs[DPAA_ETH_TX_QUEUES];
> +	struct qman_fq		*conf_fqs[DPAA_ETH_TX_QUEUES];
> +
> +	size_t bp_count;
> +
> +	u16 channel;	/* "fsl,qman-channel-id" */
> +	struct list_head	 dpa_fq_list;
> +
> +	u32 msg_enable;	/* net_device message level */
> +
> +	struct {
> +		/**
> +		 * All egress queues to a given net device belong to one
> +		 * (and the same) congestion group.
> +		 */
> +		struct qman_cgr cgr;
> +	} cgr_data;
> +	/* Use a per-port CGR for ingress traffic. */
> +	bool use_ingress_cgr;
> +	struct qman_cgr ingress_cgr;
> +
> +	struct dpa_buffer_layout_s *buf_layout;
> +	u16 rx_headroom;
> +};
> +
> +struct fm_port_fqs {
> +	struct dpa_fq *tx_defq;
> +	struct dpa_fq *tx_errq;
> +	struct dpa_fq *rx_defq;
> +	struct dpa_fq *rx_errq;
> +};
> +
> +int dpa_bp_priv_seed(struct dpa_bp *dpa_bp);
> +int dpaa_eth_refill_bpools(struct dpa_bp *dpa_bp, int *count_ptr);
> +void __hot _dpa_rx(struct net_device *net_dev,
> +		   struct qman_portal *portal,
> +		   const struct dpa_priv_s *priv,
> +		   struct dpa_percpu_priv_s *percpu_priv,
> +		   const struct qm_fd *fd,
> +		   u32 fqid,
> +		   int *count_ptr);
> +int __hot dpa_tx(struct sk_buff *skb, struct net_device *net_dev);
> +struct sk_buff *_dpa_cleanup_tx_fd(const struct dpa_priv_s *priv,
> +				   const struct qm_fd *fd);
> +
> +/* Turn on HW checksum computation for this outgoing frame.
> + * If the current protocol is not something we support in this regar=
d
> + * (or if the stack has already computed the SW checksum), we do not=
hing.
> + *
> + * Returns 0 if all goes well (or HW csum doesn't apply), and a nega=
tive value
> + * otherwise.
> + *
> + * Note that this function may modify the fd->cmd field and the skb =
data buffer
> + * (the Parse Results area).
> + */
> +int dpa_enable_tx_csum(struct dpa_priv_s *priv, struct sk_buff *skb,
> +		       struct qm_fd *fd, char *parse_results);
> +
> +static inline int dpaa_eth_napi_schedule(struct dpa_percpu_priv_s *p=
ercpu_priv,
> +					 struct qman_portal *portal)
> +{
> +	/* In case of threaded ISR for RT enable kernel,
> +	 * in_irq() does not return appropriate value, so use
> +	 * in_serving_softirq to distinguish softirq or irq context.
> +	 */
> +	if (unlikely(in_irq() || !in_serving_softirq())) {
> +		/* Disable QMan IRQ and invoke NAPI */
> +		int ret =3D qman_p_irqsource_remove(portal, QM_PIRQ_DQRI);
> +
> +		if (likely(!ret)) {
> +			const struct qman_portal_config *pc =3D
> +					qman_p_get_portal_config(portal);
> +			struct dpa_napi_portal *np =3D
> +					&percpu_priv->np[pc->channel];
> +
> +			np->p =3D portal;
> +			napi_schedule(&np->napi);
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +
> +static inline ssize_t __const __must_check __attribute__((nonnull))
> +dpa_fd_length(const struct qm_fd *fd)
> +{
> +	return fd->length20;
> +}
> +
> +static inline ssize_t __const __must_check __attribute__((nonnull))
> +dpa_fd_offset(const struct qm_fd *fd)
> +{
> +	return fd->offset;
> +}
> +
> +/* Verifies if the skb length is below the interface MTU */
> +static inline int dpa_check_rx_mtu(struct sk_buff *skb, int mtu)
> +{
> +	if (unlikely(skb->len > mtu))
> +		if ((skb->protocol !=3D ETH_P_8021Q) || (skb->len > mtu + 4))
> +			return -1;
> +
> +	return 0;
> +}
> +
> +static inline u16 dpa_get_headroom(struct dpa_buffer_layout_s *bl)
> +{
> +	u16 headroom;
> +	/* The frame headroom must accommodate:
> +	 * - the driver private data area
> +	 * - parse results, hash results, timestamp if selected
> +	 * If either hash results or time stamp are selected, both will
> +	 * be copied to/from the frame headroom, as TS is located between P=
R and
> +	 * HR in the IC and IC copy size has a granularity of 16bytes
> +	 * (see description of FMBM_RICP and FMBM_TICP registers in DPAARM)
> +	 *
> +	 * Also make sure the headroom is a multiple of data_align bytes
> +	 */
> +	headroom =3D (u16)(bl->priv_data_size +
> +		   (bl->parse_results ? DPA_PARSE_RESULTS_SIZE : 0) +
> +		   (bl->hash_results || bl->time_stamp ?
> +		    DPA_TIME_STAMP_SIZE + DPA_HASH_RESULTS_SIZE : 0));
> +
> +	return bl->data_align ? ALIGN(headroom, bl->data_align) : headroom;
> +}
> +
> +
> +void dpa_private_napi_del(struct net_device *net_dev);
> +
> +static inline void clear_fd(struct qm_fd *fd)
> +{
> +	fd->opaque_addr =3D 0;
> +	fd->opaque =3D 0;
> +	fd->cmd =3D 0;
> +}
> +
> +static inline struct qman_fq *_dpa_get_tx_conf_queue(
> +		const struct dpa_priv_s *priv,
> +		struct qman_fq *tx_fq)
> +{
> +	int i;
> +
> +	for (i =3D 0; i < DPAA_ETH_TX_QUEUES; i++)
> +		if (priv->egress_fqs[i] =3D=3D tx_fq)
> +			return priv->conf_fqs[i];
> +
> +	return NULL;
> +}
> +
> +static inline int __hot dpa_xmit(struct dpa_priv_s *priv,
> +				 struct rtnl_link_stats64 *percpu_stats,
> +				 int queue,
> +				 struct qm_fd *fd)

Is there a reason this isnt just in the .c file?

> +{
> +	int err, i;
> +	struct qman_fq *egress_fq;
> +
> +	egress_fq =3D priv->egress_fqs[queue];
> +	if (fd->bpid =3D=3D 0xff)
> +		fd->cmd |=3D qman_fq_fqid(
> +				_dpa_get_tx_conf_queue(priv, egress_fq)
> +				);
> +
> +	for (i =3D 0; i < 100000; i++) {
> +		err =3D qman_enqueue(egress_fq, fd, 0);
> +		if (err !=3D -EBUSY)
> +			break;
> +	}
> +
> +	if (unlikely(err < 0)) {
> +		percpu_stats->tx_errors++;
> +		percpu_stats->tx_fifo_errors++;
> +		return err;
> +	}
> +
> +	percpu_stats->tx_packets++;
> +	percpu_stats->tx_bytes +=3D dpa_fd_length(fd);
> +
> +	return 0;
> +}
> +
> +/* Use multiple WQs for FQ assignment:
> + *	- Tx Confirmation queues go to WQ1.
> + *	- Rx Default and Tx queues go to WQ3 (no differentiation between
> + *	  Rx and Tx traffic).
> + *	- Rx Error and Tx Error queues go to WQ2 (giving them a better ch=
ance
> + *	  to be scheduled, in case there are many more FQs in WQ3).
> + * This ensures that Tx-confirmed buffers are timely released. In pa=
rticular,
> + * it avoids congestion on the Tx Confirm FQs, which can pile up PFD=
Rs if they
> + * are greatly outnumbered by other FQs in the system, while
> + * dequeue scheduling is round-robin.
> + */
> +static inline void _dpa_assign_wq(struct dpa_fq *fq)
> +{
> +	switch (fq->fq_type) {
> +	case FQ_TYPE_TX_CONFIRM:
> +	case FQ_TYPE_TX_CONF_MQ:
> +		fq->wq =3D 1;
> +		break;
> +	case FQ_TYPE_RX_DEFAULT:
> +	case FQ_TYPE_TX:
> +		fq->wq =3D 3;
> +		break;
> +	case FQ_TYPE_RX_ERROR:
> +	case FQ_TYPE_TX_ERROR:
> +		fq->wq =3D 2;
> +		break;
> +	default:
> +		WARN(1, "Invalid FQ type %d for FQID %d!\n",
> +		     fq->fq_type, fq->fqid);
> +	}
> +}
> +
> +/* Use the queue selected by XPS */
> +#define dpa_get_queue_mapping(skb) \
> +	skb_get_queue_mapping(skb)
> +
> +static inline void _dpa_bp_free_pf(void *addr)
> +{
> +	put_page(virt_to_head_page(addr));
> +}
> +
> +#endif	/* __DPA_H */
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/=
drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
> new file mode 100644
> index 0000000..7094a45
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
> @@ -0,0 +1,1288 @@
> +/* Copyright 2008 - 2015 Freescale Semiconductor, Inc.
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
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/of_platform.h>
> +#include <linux/of_net.h>
> +#include <linux/etherdevice.h>
> +#include <linux/kthread.h>
> +#include <linux/percpu.h>
> +#include <linux/highmem.h>
> +#include <linux/sort.h>
> +#include <soc/fsl/qman.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/if_vlan.h>	/* vlan_eth_hdr */
> +#include "dpaa_eth.h"
> +#include "dpaa_eth_common.h"
> +#include "mac.h"
> +
> +/* Size in bytes of the FQ taildrop threshold */
> +#define DPA_FQ_TD		0x200000
> +
> +static struct dpa_bp *dpa_bp_array[64];
> +
> +int dpa_max_frm;
> +EXPORT_SYMBOL(dpa_max_frm);
> +
> +int dpa_rx_extra_headroom;
> +EXPORT_SYMBOL(dpa_rx_extra_headroom);
> +
> +static const struct fqid_cell tx_confirm_fqids[] =3D {
> +	{0, DPAA_ETH_TX_QUEUES}
> +};
> +
> +static const struct fqid_cell default_fqids[][3] =3D {
> +	[RX] =3D { {0, 1}, {0, 1}, {0, DPAA_ETH_RX_QUEUES} },
> +	[TX] =3D { {0, 1}, {0, 1}, {0, DPAA_ETH_TX_QUEUES} }
> +};
> +
> +int dpa_netdev_init(struct net_device *net_dev,
> +		    const u8 *mac_addr,
> +		    u16 tx_timeout)
> +{
> +	int err;
> +	struct dpa_priv_s *priv =3D netdev_priv(net_dev);
> +	struct device *dev =3D net_dev->dev.parent;
> +
> +	net_dev->priv_flags |=3D IFF_LIVE_ADDR_CHANGE;
> +
> +	net_dev->features |=3D net_dev->hw_features;
> +	net_dev->vlan_features =3D net_dev->features;
> +
> +	memcpy(net_dev->perm_addr, mac_addr, net_dev->addr_len);
> +	memcpy(net_dev->dev_addr, mac_addr, net_dev->addr_len);
> +
> +	net_dev->needed_headroom =3D priv->tx_headroom;
> +	net_dev->watchdog_timeo =3D msecs_to_jiffies(tx_timeout);
> +
> +	err =3D register_netdev(net_dev);
> +	if (err < 0) {
> +		dev_err(dev, "register_netdev() =3D %d\n", err);
> +		return err;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpa_netdev_init);
> +
> +int __cold dpa_start(struct net_device *net_dev)
> +{
> +	int err, i;
> +	struct dpa_priv_s *priv;
> +	struct mac_device *mac_dev;
> +
> +	priv =3D netdev_priv(net_dev);
> +	mac_dev =3D priv->mac_dev;
> +
> +	err =3D mac_dev->init_phy(net_dev, priv->mac_dev);
> +	if (err < 0) {
> +		if (netif_msg_ifup(priv))
> +			netdev_err(net_dev, "init_phy() =3D %d\n", err);
> +		return err;
> +	}
> +
> +	for_each_port_device(i, mac_dev->port_dev) {
> +		err =3D fm_port_enable(mac_dev->port_dev[i]);
> +		if (err)
> +			goto mac_start_failed;
> +	}
> +
> +	err =3D priv->mac_dev->start(mac_dev);
> +	if (err < 0) {
> +		if (netif_msg_ifup(priv))
> +			netdev_err(net_dev, "mac_dev->start() =3D %d\n", err);
> +		goto mac_start_failed;
> +	}
> +
> +	netif_tx_start_all_queues(net_dev);
> +
> +	return 0;
> +
> +mac_start_failed:
> +	for_each_port_device(i, mac_dev->port_dev)
> +		fm_port_disable(mac_dev->port_dev[i]);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(dpa_start);
> +
> +int __cold dpa_stop(struct net_device *net_dev)
> +{
> +	int _errno, i, err;
> +	struct dpa_priv_s *priv;
> +	struct mac_device *mac_dev;
> +
> +	priv =3D netdev_priv(net_dev);
> +	mac_dev =3D priv->mac_dev;
> +
> +	netif_tx_stop_all_queues(net_dev);
> +	/* Allow the Fman (Tx) port to process in-flight frames before we
> +	 * try switching it off.
> +	 */
> +	usleep_range(5000, 10000);
> +
> +	_errno =3D mac_dev->stop(mac_dev);
> +	if (unlikely(_errno < 0))
> +		if (netif_msg_ifdown(priv))
> +			netdev_err(net_dev, "mac_dev->stop() =3D %d\n",
> +				   _errno);
> +
> +	for_each_port_device(i, mac_dev->port_dev) {
> +		err =3D fm_port_disable(mac_dev->port_dev[i]);
> +		_errno =3D err ? err : _errno;
> +	}
> +
> +	if (mac_dev->phy_dev)
> +		phy_disconnect(mac_dev->phy_dev);
> +	mac_dev->phy_dev =3D NULL;
> +
> +	return _errno;
> +}
> +EXPORT_SYMBOL(dpa_stop);
> +
> +void __cold dpa_timeout(struct net_device *net_dev)
> +{
> +	const struct dpa_priv_s	*priv;
> +	struct dpa_percpu_priv_s *percpu_priv;
> +
> +	priv =3D netdev_priv(net_dev);
> +	percpu_priv =3D raw_cpu_ptr(priv->percpu_priv);
> +
> +	if (netif_msg_timer(priv))
> +		netdev_crit(net_dev, "Transmit timeout latency: %u ms\n",
> +			    jiffies_to_msecs(jiffies - net_dev->trans_start));
> +
> +	percpu_priv->stats.tx_errors++;
> +}
> +EXPORT_SYMBOL(dpa_timeout);
> +
> +/* net_device */
> +
> +/**
> + * @param net_dev the device for which statistics are calculated
> + * @param stats the function fills this structure with the device's =
statistics
> + * @return the address of the structure containing the statistics
> + *
> + * Calculates the statistics for the given device by adding the stat=
istics
> + * collected by each CPU.
> + */
> +struct rtnl_link_stats64 * __cold
> +dpa_get_stats64(struct net_device *net_dev,
> +		struct rtnl_link_stats64 *stats)
> +{
> +	struct dpa_priv_s *priv =3D netdev_priv(net_dev);
> +	u64 *cpustats;
> +	u64 *netstats =3D (u64 *)stats;
> +	int i, j;
> +	struct dpa_percpu_priv_s	*percpu_priv;
> +	int numstats =3D sizeof(struct rtnl_link_stats64) / sizeof(u64);
> +
> +	for_each_possible_cpu(i) {
> +		percpu_priv =3D per_cpu_ptr(priv->percpu_priv, i);
> +
> +		cpustats =3D (u64 *)&percpu_priv->stats;
> +
> +		for (j =3D 0; j < numstats; j++)
> +			netstats[j] +=3D cpustats[j];
> +	}
> +
> +	return stats;
> +}
> +EXPORT_SYMBOL(dpa_get_stats64);
> +
> +int dpa_change_mtu(struct net_device *net_dev, int new_mtu)
> +{
> +	const int max_mtu =3D dpa_get_max_mtu();
> +
> +	/* Make sure we don't exceed the Ethernet controller's MAXFRM */
> +	if (new_mtu < 68 || new_mtu > max_mtu) {
> +		netdev_err(net_dev, "Invalid L3 mtu %d (must be between %d and %d)=
=2E\n",
> +			   new_mtu, 68, max_mtu);
> +		return -EINVAL;
> +	}
> +	net_dev->mtu =3D new_mtu;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpa_change_mtu);
> +
> +/* .ndo_init callback */
> +int dpa_ndo_init(struct net_device *net_dev)
> +{
> +	/* If fsl_fm_max_frm is set to a higher value than the all-common 1=
500,
> +	 * we choose conservatively and let the user explicitly set a highe=
r
> +	 * MTU via ifconfig. Otherwise, the user may end up with different =
MTUs
> +	 * in the same LAN.
> +	 * If on the other hand fsl_fm_max_frm has been chosen below 1500,
> +	 * start with the maximum allowed.
> +	 */
> +	int init_mtu =3D min(dpa_get_max_mtu(), ETH_DATA_LEN);
> +
> +	pr_debug("Setting initial MTU on net device: %d\n", init_mtu);
> +	net_dev->mtu =3D init_mtu;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpa_ndo_init);
> +
> +int dpa_set_features(struct net_device *dev, netdev_features_t featu=
res)
> +{
> +	/* Not much to do here for now */
> +	dev->features =3D features;
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpa_set_features);
> +
> +netdev_features_t dpa_fix_features(struct net_device *dev,
> +				   netdev_features_t features)
> +{
> +	netdev_features_t unsupported_features =3D 0;
> +
> +	/* In theory we should never be requested to enable features that
> +	 * we didn't set in netdev->features and netdev->hw_features at pro=
be
> +	 * time, but double check just to be on the safe side.
> +	 * We don't support enabling Rx csum through ethtool yet
> +	 */
> +	unsupported_features |=3D NETIF_F_RXCSUM;
> +
> +	features &=3D ~unsupported_features;
> +
> +	return features;
> +}
> +EXPORT_SYMBOL(dpa_fix_features);
> +
> +int __cold dpa_remove(struct platform_device *pdev)
> +{
> +	int			err;
> +	struct device		*dev;
> +	struct net_device	*net_dev;
> +	struct dpa_priv_s	*priv;
> +
> +	dev =3D &pdev->dev;
> +	net_dev =3D dev_get_drvdata(dev);
> +
> +	priv =3D netdev_priv(net_dev);
> +
> +	dev_set_drvdata(dev, NULL);
> +	unregister_netdev(net_dev);
> +
> +	err =3D dpa_fq_free(dev, &priv->dpa_fq_list);
> +
> +	qman_delete_cgr_safe(&priv->ingress_cgr);
> +	qman_release_cgrid(priv->ingress_cgr.cgrid);
> +	qman_delete_cgr_safe(&priv->cgr_data.cgr);
> +	qman_release_cgrid(priv->cgr_data.cgr.cgrid);
> +
> +	dpa_private_napi_del(net_dev);
> +
> +	dpa_bp_free(priv);
> +
> +	if (priv->buf_layout)
> +		devm_kfree(dev, priv->buf_layout);
> +
> +	free_netdev(net_dev);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(dpa_remove);
> +
> +struct mac_device * __cold __must_check
> +__attribute__((nonnull))
> +dpa_mac_dev_get(struct platform_device *pdev)
> +{
> +	struct device		*dpa_dev, *dev;
> +	struct device_node	*mac_node;
> +	struct platform_device	*of_dev;
> +	struct mac_device	*mac_dev;
> +	struct dpaa_eth_data	*eth_data;
> +
> +	dpa_dev =3D &pdev->dev;
> +	eth_data =3D dpa_dev->platform_data;
> +	if (!eth_data)
> +		return ERR_PTR(-ENODEV);
> +
> +	mac_node =3D eth_data->mac_node;
> +
> +	of_dev =3D of_find_device_by_node(mac_node);
> +	if (unlikely(!of_dev)) {
> +		dev_err(dpa_dev, "of_find_device_by_node(%s) failed\n",
> +			mac_node->full_name);
> +		of_node_put(mac_node);
> +		return ERR_PTR(-EINVAL);
> +	}
> +	of_node_put(mac_node);
> +
> +	dev =3D &of_dev->dev;
> +
> +	mac_dev =3D dev_get_drvdata(dev);
> +	if (unlikely(!mac_dev)) {
> +		dev_err(dpa_dev, "dev_get_drvdata(%s) failed\n",
> +			dev_name(dev));
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	return mac_dev;
> +}
> +EXPORT_SYMBOL(dpa_mac_dev_get);

why is this exported?

> +
> +int dpa_mac_hw_index_get(struct platform_device *pdev)
> +{
> +	struct device		*dpa_dev;
> +	struct dpaa_eth_data	*eth_data;
> +
> +	dpa_dev =3D &pdev->dev;
> +	eth_data =3D dpa_dev->platform_data;
> +
> +	return eth_data->mac_hw_id;
> +}
> +
> +int dpa_mac_fman_index_get(struct platform_device *pdev)
> +{
> +	struct device		*dpa_dev;
> +	struct dpaa_eth_data	*eth_data;
> +
> +	dpa_dev =3D &pdev->dev;
> +	eth_data =3D dpa_dev->platform_data;
> +
> +	return eth_data->fman_hw_id;
> +}
> +
> +int dpa_set_mac_address(struct net_device *net_dev, void *addr)
> +{
> +	const struct dpa_priv_s	*priv;
> +	int			 _errno;
> +	struct mac_device	*mac_dev;
> +
> +	priv =3D netdev_priv(net_dev);
> +
> +	_errno =3D eth_mac_addr(net_dev, addr);
> +	if (_errno < 0) {
> +		if (netif_msg_drv(priv))
> +			netdev_err(net_dev,
> +				   "eth_mac_addr() =3D %d\n",
> +				   _errno);
> +		return _errno;
> +	}
> +
> +	mac_dev =3D priv->mac_dev;
> +
> +	_errno =3D mac_dev->change_addr(mac_dev->get_mac_handle(mac_dev),
> +				      (enet_addr_t *)net_dev->dev_addr);
> +	if (_errno < 0) {
> +		if (netif_msg_drv(priv))
> +			netdev_err(net_dev,
> +				   "mac_dev->change_addr() =3D %d\n",
> +				   _errno);
> +		return _errno;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpa_set_mac_address);
> +
> +void dpa_set_rx_mode(struct net_device *net_dev)
> +{
> +	int			 _errno;
> +	const struct dpa_priv_s	*priv;
> +
> +	priv =3D netdev_priv(net_dev);
> +
> +	if (!!(net_dev->flags & IFF_PROMISC) !=3D priv->mac_dev->promisc) {
> +		priv->mac_dev->promisc =3D !priv->mac_dev->promisc;
> +		_errno =3D priv->mac_dev->set_promisc(
> +				priv->mac_dev->get_mac_handle(priv->mac_dev),
> +				priv->mac_dev->promisc);
> +		if (unlikely(_errno < 0) && netif_msg_drv(priv))
> +			netdev_err(net_dev,
> +				   "mac_dev->set_promisc() =3D %d\n",
> +				   _errno);
> +	}
> +
> +	_errno =3D priv->mac_dev->set_multi(net_dev, priv->mac_dev);
> +	if (unlikely(_errno < 0) && netif_msg_drv(priv))
> +		netdev_err(net_dev, "mac_dev->set_multi() =3D %d\n", _errno);
> +}
> +EXPORT_SYMBOL(dpa_set_rx_mode);
> +
> +void dpa_set_buffers_layout(struct mac_device *mac_dev,
> +			    struct dpa_buffer_layout_s *layout)
> +{
> +	struct fm_port_params params;
> +
> +	/* Rx */
> +	layout[RX].priv_data_size =3D (u16)DPA_RX_PRIV_DATA_SIZE;
> +	layout[RX].parse_results =3D true;
> +	layout[RX].hash_results =3D true;
> +
> +	fm_port_get_buff_layout_ext_params(mac_dev->port_dev[RX], &params);
> +	/* a value of zero for data alignment means "don't care", so align =
to
> +	 * a non-zero value to prevent FMD from using its own default
> +	 */
> +	layout[RX].data_align =3D params.data_align ? : DPA_FD_DATA_ALIGNME=
NT;
> +
> +	/* Tx */
> +	layout[TX].priv_data_size =3D DPA_TX_PRIV_DATA_SIZE;
> +	layout[TX].parse_results =3D true;
> +	layout[TX].hash_results =3D true;
> +
> +	fm_port_get_buff_layout_ext_params(mac_dev->port_dev[TX], &params);
> +	layout[TX].data_align =3D params.data_align ? : DPA_FD_DATA_ALIGNME=
NT;
> +}
> +EXPORT_SYMBOL(dpa_set_buffers_layout);
> +
> +int __attribute__((nonnull))
> +dpa_bp_alloc(struct dpa_bp *dpa_bp)
> +{
> +	int err;
> +	struct bman_pool_params	 bp_params;
> +	struct platform_device *pdev;
> +
> +	if (dpa_bp->size =3D=3D 0 || dpa_bp->config_count =3D=3D 0) {
> +		pr_err("Buffer pool is not properly initialized! Missing size or i=
nitial number of buffers");
> +		return -EINVAL;
> +	}
> +
> +	memset(&bp_params, 0, sizeof(struct bman_pool_params));
> +
> +	/* If the pool is already specified, we only create one per bpid */
> +	if (dpa_bpid2pool_use(dpa_bp->bpid))
> +		return 0;
> +
> +	if (dpa_bp->bpid =3D=3D 0)
> +		bp_params.flags |=3D BMAN_POOL_FLAG_DYNAMIC_BPID;
> +	else
> +		bp_params.bpid =3D dpa_bp->bpid;
> +
> +	dpa_bp->pool =3D bman_new_pool(&bp_params);
> +	if (unlikely(!dpa_bp->pool)) {
> +		pr_err("bman_new_pool() failed\n");
> +		return -ENODEV;
> +	}
> +
> +	dpa_bp->bpid =3D (u8)bman_get_params(dpa_bp->pool)->bpid;
> +
> +	pdev =3D platform_device_register_simple("DPAA_bpool",
> +					       dpa_bp->bpid, NULL, 0);
> +	if (IS_ERR(pdev)) {
> +		err =3D PTR_ERR(pdev);
> +		goto pdev_register_failed;
> +	}
> +
> +	err =3D dma_set_mask(&pdev->dev, DMA_BIT_MASK(40));
> +	if (err)
> +		goto pdev_mask_failed;
> +
> +	dpa_bp->dev =3D &pdev->dev;
> +
> +	if (dpa_bp->seed_cb) {
> +		err =3D dpa_bp->seed_cb(dpa_bp);
> +		if (err)
> +			goto pool_seed_failed;
> +	}
> +
> +	dpa_bpid2pool_map(dpa_bp->bpid, dpa_bp);
> +
> +	return 0;
> +
> +pool_seed_failed:
> +pdev_mask_failed:
> +	platform_device_unregister(pdev);
> +pdev_register_failed:
> +	bman_free_pool(dpa_bp->pool);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(dpa_bp_alloc);
> +
> +void dpa_bp_drain(struct dpa_bp *bp)
> +{
> +	int ret;
> +	u8 num =3D 8;
> +
> +	do {
> +		struct bm_buffer bmb[8];
> +		int i;
> +
> +		ret =3D bman_acquire(bp->pool, bmb, num, 0);
> +		if (ret < 0) {
> +			if (num =3D=3D 8) {
> +				/* we have less than 8 buffers left;
> +				 * drain them one by one
> +				 */
> +				num =3D 1;
> +				ret =3D 1;
> +				continue;
> +			} else {
> +				/* Pool is fully drained */
> +				break;
> +			}
> +		}
> +
> +		for (i =3D 0; i < num; i++) {
> +			dma_addr_t addr =3D bm_buf_addr(&bmb[i]);
> +
> +			dma_unmap_single(bp->dev, addr, bp->size,
> +					 DMA_BIDIRECTIONAL);
> +
> +			bp->free_buf_cb(phys_to_virt(addr));
> +		}
> +	} while (ret > 0);
> +}
> +
> +static void __cold __attribute__((nonnull))
> +_dpa_bp_free(struct dpa_bp *dpa_bp)
> +{
> +	struct dpa_bp *bp =3D dpa_bpid2pool(dpa_bp->bpid);
> +
> +	/* the mapping between bpid and dpa_bp is done very late in the
> +	 * allocation procedure; if something failed before the mapping, th=
e bp
> +	 * was not configured, therefore we don't need the below instructio=
ns
> +	 */
> +	if (!bp)
> +		return;
> +
> +	if (!atomic_dec_and_test(&bp->refs))
> +		return;
> +
> +	if (bp->free_buf_cb)
> +		dpa_bp_drain(bp);
> +
> +	dpa_bp_array[bp->bpid] =3D NULL;
> +	bman_free_pool(bp->pool);
> +
> +	if (bp->dev)
> +		platform_device_unregister(to_platform_device(bp->dev));
> +}
> +
> +void __cold __attribute__((nonnull))
> +dpa_bp_free(struct dpa_priv_s *priv)
> +{
> +	int i;
> +
> +	for (i =3D 0; i < priv->bp_count; i++)
> +		_dpa_bp_free(&priv->dpa_bp[i]);
> +}
> +EXPORT_SYMBOL(dpa_bp_free);
> +
> +struct dpa_bp *dpa_bpid2pool(int bpid)
> +{
> +	return dpa_bp_array[bpid];
> +}
> +EXPORT_SYMBOL(dpa_bpid2pool);
> +
> +void dpa_bpid2pool_map(int bpid, struct dpa_bp *dpa_bp)
> +{
> +	dpa_bp_array[bpid] =3D dpa_bp;
> +	atomic_set(&dpa_bp->refs, 1);
> +}
> +
> +bool dpa_bpid2pool_use(int bpid)
> +{
> +	if (dpa_bpid2pool(bpid)) {
> +		atomic_inc(&dpa_bp_array[bpid]->refs);
> +		return true;
> +	}
> +
> +	return false;
> +}
> +
> +struct dpa_fq *dpa_fq_alloc(struct device *dev,
> +			    const struct fqid_cell *fqids,
> +			    struct list_head *list,
> +			    enum dpa_fq_type fq_type)
> +{
> +	int i;
> +	struct dpa_fq *dpa_fq;
> +
> +	dpa_fq =3D devm_kzalloc(dev, sizeof(*dpa_fq) * fqids->count, GFP_KE=
RNEL);
> +	if (!dpa_fq)
> +		return NULL;
> +
> +	for (i =3D 0; i < fqids->count; i++) {
> +		dpa_fq[i].fq_type =3D fq_type;
> +		dpa_fq[i].fqid =3D fqids->start ? fqids->start + i : 0;
> +		list_add_tail(&dpa_fq[i].list, list);
> +	}
> +
> +	for (i =3D 0; i < fqids->count; i++)
> +		_dpa_assign_wq(dpa_fq + i);
> +
> +	return dpa_fq;
> +}
> +EXPORT_SYMBOL(dpa_fq_alloc);
> +
> +int dpa_fq_probe_mac(struct device *dev, struct list_head *list,
> +		     struct fm_port_fqs *port_fqs,
> +		     bool alloc_tx_conf_fqs,
> +		     enum port_type ptype)
> +{
> +	const struct fqid_cell *fqids;
> +	struct dpa_fq *dpa_fq;
> +	int num_ranges;
> +	int i;
> +
> +	if (ptype =3D=3D TX && alloc_tx_conf_fqs) {
> +		if (!dpa_fq_alloc(dev, tx_confirm_fqids, list,
> +				  FQ_TYPE_TX_CONF_MQ))
> +			goto fq_alloc_failed;
> +	}
> +
> +	fqids =3D default_fqids[ptype];
> +	num_ranges =3D 3;
> +
> +	for (i =3D 0; i < num_ranges; i++) {
> +		switch (i) {
> +		case 0:
> +			/* The first queue is the error queue */
> +			if (fqids[i].count !=3D 1)
> +				goto invalid_error_queue;
> +
> +			dpa_fq =3D dpa_fq_alloc(dev, &fqids[i], list,
> +					      ptype =3D=3D RX ?
> +						FQ_TYPE_RX_ERROR :
> +						FQ_TYPE_TX_ERROR);
> +			if (!dpa_fq)
> +				goto fq_alloc_failed;
> +
> +			if (ptype =3D=3D RX)
> +				port_fqs->rx_errq =3D &dpa_fq[0];
> +			else
> +				port_fqs->tx_errq =3D &dpa_fq[0];
> +			break;
> +		case 1:
> +			/* the second queue is the default queue */
> +			if (fqids[i].count !=3D 1)
> +				goto invalid_default_queue;
> +
> +			dpa_fq =3D dpa_fq_alloc(dev, &fqids[i], list,
> +					      ptype =3D=3D RX ?
> +						FQ_TYPE_RX_DEFAULT :
> +						FQ_TYPE_TX_CONFIRM);
> +			if (!dpa_fq)
> +				goto fq_alloc_failed;
> +
> +			if (ptype =3D=3D RX)
> +				port_fqs->rx_defq =3D &dpa_fq[0];
> +			else
> +				port_fqs->tx_defq =3D &dpa_fq[0];
> +			break;
> +		default:
> +			/* all subsequent queues are Tx */
> +			if (!dpa_fq_alloc(dev, &fqids[i], list, FQ_TYPE_TX))
> +				goto fq_alloc_failed;
> +			break;
> +		}
> +	}
> +
> +	return 0;
> +
> +fq_alloc_failed:
> +	dev_err(dev, "dpa_fq_alloc() failed\n");
> +	return -ENOMEM;
> +
> +invalid_default_queue:
> +invalid_error_queue:
> +	dev_err(dev, "Too many default or error queues\n");
> +	return -EINVAL;
> +}
> +EXPORT_SYMBOL(dpa_fq_probe_mac);
> +
> +static u32 rx_pool_channel;
> +static DEFINE_SPINLOCK(rx_pool_channel_init);
> +
> +int dpa_get_channel(void)
> +{
> +	spin_lock(&rx_pool_channel_init);
> +	if (!rx_pool_channel) {
> +		u32 pool;
> +		int ret =3D qman_alloc_pool(&pool);
> +
> +		if (!ret)
> +			rx_pool_channel =3D pool;
> +	}
> +	spin_unlock(&rx_pool_channel_init);
> +	if (!rx_pool_channel)
> +		return -ENOMEM;
> +	return rx_pool_channel;
> +}
> +EXPORT_SYMBOL(dpa_get_channel);
> +
> +void dpa_release_channel(void)
> +{
> +	qman_release_pool(rx_pool_channel);
> +}
> +EXPORT_SYMBOL(dpa_release_channel);
> +
> +int dpaa_eth_add_channel(void *__arg)
> +{
> +	const cpumask_t *cpus =3D qman_affine_cpus();
> +	u32 pool =3D QM_SDQCR_CHANNELS_POOL_CONV((u16)(unsigned long)__arg)=
;
> +	int cpu;
> +	struct qman_portal *portal;
> +
> +	for_each_cpu(cpu, cpus) {
> +		portal =3D (struct qman_portal *)qman_get_affine_portal(cpu);
> +		qman_p_static_dequeue_add(portal, pool);
> +	}
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpaa_eth_add_channel);
> +
> +/**
> + * Congestion group state change notification callback.
> + * Stops the device's egress queues while they are congested and
> + * wakes them upon exiting congested state.
> + * Also updates some CGR-related stats.
> + */
> +static void dpaa_eth_cgscn(struct qman_portal *qm, struct qman_cgr *=
cgr,
> +			   int congested)
> +{
> +	struct dpa_priv_s *priv =3D (struct dpa_priv_s *)container_of(cgr,
> +		struct dpa_priv_s, cgr_data.cgr);
> +
> +	if (congested)
> +		netif_tx_stop_all_queues(priv->net_dev);
> +	else
> +		netif_tx_wake_all_queues(priv->net_dev);
> +}
> +
> +int dpaa_eth_cgr_init(struct dpa_priv_s *priv)
> +{
> +	struct qm_mcc_initcgr initcgr;
> +	u32 cs_th;
> +	int err;
> +
> +	err =3D qman_alloc_cgrid(&priv->cgr_data.cgr.cgrid);
> +	if (err < 0) {
> +		pr_err("Error %d allocating CGR ID\n", err);
> +		goto out_error;
> +	}
> +	priv->cgr_data.cgr.cb =3D dpaa_eth_cgscn;
> +
> +	/* Enable Congestion State Change Notifications and CS taildrop */
> +	initcgr.we_mask =3D QM_CGR_WE_CSCN_EN | QM_CGR_WE_CS_THRES;
> +	initcgr.cgr.cscn_en =3D QM_CGR_EN;
> +
> +	/* Set different thresholds based on the MAC speed.
> +	 * This may turn suboptimal if the MAC is reconfigured at a speed
> +	 * lower than its max, e.g. if a dTSEC later negotiates a 100Mbps l=
ink.
> +	 * In such cases, we ought to reconfigure the threshold, too.
> +	 */
> +	if (priv->mac_dev->if_support & SUPPORTED_10000baseT_Full)
> +		cs_th =3D CONFIG_FSL_DPAA_CS_THRESHOLD_10G;
> +	else
> +		cs_th =3D CONFIG_FSL_DPAA_CS_THRESHOLD_1G;
> +	qm_cgr_cs_thres_set64(&initcgr.cgr.cs_thres, cs_th, 1);
> +
> +	initcgr.we_mask |=3D QM_CGR_WE_CSTD_EN;
> +	initcgr.cgr.cstd_en =3D QM_CGR_EN;
> +
> +	err =3D qman_create_cgr(&priv->cgr_data.cgr, QMAN_CGR_FLAG_USE_INIT=
,
> +			      &initcgr);
> +	if (err < 0) {
> +		pr_err("Error %d creating CGR with ID %d\n", err,
> +		       priv->cgr_data.cgr.cgrid);
> +		qman_release_cgrid(priv->cgr_data.cgr.cgrid);
> +		goto out_error;
> +	}
> +	pr_debug("Created CGR %d for netdev with hwaddr %pM on QMan channel=
 %d\n",
> +		 priv->cgr_data.cgr.cgrid, priv->mac_dev->addr,
> +		 priv->cgr_data.cgr.chan);
> +
> +out_error:
> +	return err;
> +}
> +EXPORT_SYMBOL(dpaa_eth_cgr_init);
> +
> +static inline void dpa_setup_ingress(const struct dpa_priv_s *priv,
> +				     struct dpa_fq *fq,
> +				     const struct qman_fq *template)
> +{
> +	fq->fq_base =3D *template;
> +	fq->net_dev =3D priv->net_dev;
> +
> +	fq->flags =3D QMAN_FQ_FLAG_NO_ENQUEUE;
> +	fq->channel =3D priv->channel;
> +}
> +
> +static inline void dpa_setup_egress(const struct dpa_priv_s *priv,
> +				    struct dpa_fq *fq,
> +				    struct fm_port *port,
> +				    const struct qman_fq *template)
> +{
> +	fq->fq_base =3D *template;
> +	fq->net_dev =3D priv->net_dev;
> +
> +	if (port) {
> +		fq->flags =3D QMAN_FQ_FLAG_TO_DCPORTAL;
> +		fq->channel =3D (u16)fm_get_tx_port_channel(port);
> +	} else {
> +		fq->flags =3D QMAN_FQ_FLAG_NO_MODIFY;
> +	}
> +}
> +
> +void dpa_fq_setup(struct dpa_priv_s *priv, const struct dpa_fq_cbs_t=
 *fq_cbs,
> +		  struct fm_port *tx_port)
> +{
> +	struct dpa_fq *fq;
> +	u16 portals[NR_CPUS];
> +	int cpu, num_portals =3D 0;
> +	const cpumask_t *affine_cpus =3D qman_affine_cpus();
> +	int egress_cnt =3D 0, conf_cnt =3D 0;
> +
> +	for_each_cpu(cpu, affine_cpus)
> +		portals[num_portals++] =3D qman_affine_channel(cpu);
> +	if (num_portals =3D=3D 0)
> +		dev_err(priv->net_dev->dev.parent,
> +			"No Qman software (affine) channels found");
> +
> +	/* Initialize each FQ in the list */
> +	list_for_each_entry(fq, &priv->dpa_fq_list, list) {
> +		switch (fq->fq_type) {
> +		case FQ_TYPE_RX_DEFAULT:
> +			BUG_ON(!priv->mac_dev);
> +			dpa_setup_ingress(priv, fq, &fq_cbs->rx_defq);
> +			break;
> +		case FQ_TYPE_RX_ERROR:
> +			BUG_ON(!priv->mac_dev);
> +			dpa_setup_ingress(priv, fq, &fq_cbs->rx_errq);
> +			break;
> +		case FQ_TYPE_TX:
> +			dpa_setup_egress(priv, fq, tx_port,
> +					 &fq_cbs->egress_ern);
> +			/* If we have more Tx queues than the number of cores,
> +			 * just ignore the extra ones.
> +			 */
> +			if (egress_cnt < DPAA_ETH_TX_QUEUES)
> +				priv->egress_fqs[egress_cnt++] =3D &fq->fq_base;
> +			break;
> +		case FQ_TYPE_TX_CONFIRM:
> +			BUG_ON(!priv->mac_dev);
> +			dpa_setup_ingress(priv, fq, &fq_cbs->tx_defq);
> +			break;
> +		case FQ_TYPE_TX_CONF_MQ:
> +			BUG_ON(!priv->mac_dev);
> +			dpa_setup_ingress(priv, fq, &fq_cbs->tx_defq);
> +			priv->conf_fqs[conf_cnt++] =3D &fq->fq_base;
> +			break;
> +		case FQ_TYPE_TX_ERROR:
> +			BUG_ON(!priv->mac_dev);
> +			dpa_setup_ingress(priv, fq, &fq_cbs->tx_errq);
> +			break;
> +		default:
> +			dev_warn(priv->net_dev->dev.parent,
> +				 "Unknown FQ type detected!\n");
> +			break;
> +		}
> +	}
> +
> +	/* The number of Tx queues may be smaller than the number of cores,=
 if
> +	 * the Tx queue range is specified in the device tree instead of be=
ing
> +	 * dynamically allocated.
> +	 * Make sure all CPUs receive a corresponding Tx queue.
> +	 */
> +	while (egress_cnt < DPAA_ETH_TX_QUEUES) {
> +		list_for_each_entry(fq, &priv->dpa_fq_list, list) {
> +			if (fq->fq_type !=3D FQ_TYPE_TX)
> +				continue;
> +			priv->egress_fqs[egress_cnt++] =3D &fq->fq_base;
> +			if (egress_cnt =3D=3D DPAA_ETH_TX_QUEUES)
> +				break;
> +		}
> +	}
> +}
> +EXPORT_SYMBOL(dpa_fq_setup);
> +
> +int dpa_fq_init(struct dpa_fq *dpa_fq, bool td_enable)
> +{
> +	int			 _errno;
> +	const struct dpa_priv_s	*priv;
> +	struct device		*dev;
> +	struct qman_fq		*fq;
> +	struct qm_mcc_initfq	 initfq;
> +	struct qman_fq		*confq;
> +
> +	priv =3D netdev_priv(dpa_fq->net_dev);
> +	dev =3D dpa_fq->net_dev->dev.parent;
> +
> +	if (dpa_fq->fqid =3D=3D 0)
> +		dpa_fq->flags |=3D QMAN_FQ_FLAG_DYNAMIC_FQID;
> +
> +	dpa_fq->init =3D !(dpa_fq->flags & QMAN_FQ_FLAG_NO_MODIFY);
> +
> +	_errno =3D qman_create_fq(dpa_fq->fqid, dpa_fq->flags, &dpa_fq->fq_=
base);
> +	if (_errno) {
> +		dev_err(dev, "qman_create_fq() failed\n");
> +		return _errno;
> +	}
> +	fq =3D &dpa_fq->fq_base;
> +
> +	if (dpa_fq->init) {
> +		initfq.we_mask =3D QM_INITFQ_WE_FQCTRL;
> +		/* FIXME: why would we want to keep an empty FQ in cache? */
> +		initfq.fqd.fq_ctrl =3D QM_FQCTRL_PREFERINCACHE;
> +
> +		/* Try to reduce the number of portal interrupts for
> +		 * Tx Confirmation FQs.
> +		 */
> +		if (dpa_fq->fq_type =3D=3D FQ_TYPE_TX_CONFIRM)
> +			initfq.fqd.fq_ctrl |=3D QM_FQCTRL_HOLDACTIVE;
> +
> +		/* FQ placement */
> +		initfq.we_mask |=3D QM_INITFQ_WE_DESTWQ;
> +
> +		initfq.fqd.dest.channel	=3D dpa_fq->channel;
> +		initfq.fqd.dest.wq =3D dpa_fq->wq;
> +
> +		/* Put all egress queues in a congestion group of their own.
> +		 * Sensu stricto, the Tx confirmation queues are Rx FQs,
> +		 * rather than Tx - but they nonetheless account for the
> +		 * memory footprint on behalf of egress traffic. We therefore
> +		 * place them in the netdev's CGR, along with the Tx FQs.
> +		 */
> +		if (dpa_fq->fq_type =3D=3D FQ_TYPE_TX ||
> +		    dpa_fq->fq_type =3D=3D FQ_TYPE_TX_CONFIRM ||
> +		    dpa_fq->fq_type =3D=3D FQ_TYPE_TX_CONF_MQ) {
> +			initfq.we_mask |=3D QM_INITFQ_WE_CGID;
> +			initfq.fqd.fq_ctrl |=3D QM_FQCTRL_CGE;
> +			initfq.fqd.cgid =3D (u8)priv->cgr_data.cgr.cgrid;
> +			/* Set a fixed overhead accounting, in an attempt to
> +			 * reduce the impact of fixed-size skb shells and the
> +			 * driver's needed headroom on system memory. This is
> +			 * especially the case when the egress traffic is
> +			 * composed of small datagrams.
> +			 * Unfortunately, QMan's OAL value is capped to an
> +			 * insufficient value, but even that is better than
> +			 * no overhead accounting at all.
> +			 */
> +			initfq.we_mask |=3D QM_INITFQ_WE_OAC;
> +			initfq.fqd.oac_init.oac =3D QM_OAC_CG;
> +			initfq.fqd.oac_init.oal =3D
> +				(signed char)(min(sizeof(struct sk_buff) +
> +						  priv->tx_headroom,
> +						  (size_t)FSL_QMAN_MAX_OAL));
> +		}
> +
> +		if (td_enable) {
> +			initfq.we_mask |=3D QM_INITFQ_WE_TDTHRESH;
> +			qm_fqd_taildrop_set(&initfq.fqd.td,
> +					    DPA_FQ_TD, 1);
> +			initfq.fqd.fq_ctrl =3D QM_FQCTRL_TDE;
> +		}
> +
> +		/* Configure the Tx confirmation queue, now that we know
> +		 * which Tx queue it pairs with.
> +		 */
> +		if (dpa_fq->fq_type =3D=3D FQ_TYPE_TX) {
> +			confq =3D _dpa_get_tx_conf_queue(priv, &dpa_fq->fq_base);
> +			if (confq) {
> +				initfq.we_mask |=3D QM_INITFQ_WE_CONTEXTA;
> +			/* ContextA: OVOM=3D1 (use contextA2 bits instead of ICAD)
> +			 *	     A2V=3D1 (contextA A2 field is valid)
> +			 *	     A0V=3D1 (contextA A0 field is valid)
> +			 * ContextA A2: EBD=3D1 (deallocate buffers inside FMan)
> +			 */
> +				initfq.fqd.context_a.hi =3D 0x1a000000;
> +				initfq.fqd.context_a.lo =3D 0x80000000;
> +			}
> +		}
> +
> +		/* Put all *private* ingress queues in our "ingress CGR". */
> +		if (priv->use_ingress_cgr &&
> +		    (dpa_fq->fq_type =3D=3D FQ_TYPE_RX_DEFAULT ||
> +		     dpa_fq->fq_type =3D=3D FQ_TYPE_RX_ERROR)) {
> +			initfq.we_mask |=3D QM_INITFQ_WE_CGID;
> +			initfq.fqd.fq_ctrl |=3D QM_FQCTRL_CGE;
> +			initfq.fqd.cgid =3D (u8)priv->ingress_cgr.cgrid;
> +			/* Set a fixed overhead accounting, just like for the
> +			 * egress CGR.
> +			 */
> +			initfq.we_mask |=3D QM_INITFQ_WE_OAC;
> +			initfq.fqd.oac_init.oac =3D QM_OAC_CG;
> +			initfq.fqd.oac_init.oal =3D
> +				(signed char)(min(sizeof(struct sk_buff) +
> +				priv->tx_headroom, (size_t)FSL_QMAN_MAX_OAL));
> +		}
> +
> +		/* Initialization common to all ingress queues */
> +		if (dpa_fq->flags & QMAN_FQ_FLAG_NO_ENQUEUE) {
> +			initfq.we_mask |=3D QM_INITFQ_WE_CONTEXTA;
> +			initfq.fqd.fq_ctrl |=3D
> +				QM_FQCTRL_CTXASTASHING | QM_FQCTRL_AVOIDBLOCK;
> +			initfq.fqd.context_a.stashing.exclusive =3D
> +				QM_STASHING_EXCL_DATA | QM_STASHING_EXCL_CTX |
> +				QM_STASHING_EXCL_ANNOTATION;
> +			initfq.fqd.context_a.stashing.data_cl =3D 2;
> +			initfq.fqd.context_a.stashing.annotation_cl =3D 1;
> +			initfq.fqd.context_a.stashing.context_cl =3D
> +				DIV_ROUND_UP(sizeof(struct qman_fq), 64);
> +		}
> +
> +		_errno =3D qman_init_fq(fq, QMAN_INITFQ_FLAG_SCHED, &initfq);
> +		if (_errno < 0) {
> +			dev_err(dev, "qman_init_fq(%u) =3D %d\n",
> +				qman_fq_fqid(fq), _errno);
> +			qman_destroy_fq(fq, 0);
> +			return _errno;
> +		}
> +	}
> +
> +	dpa_fq->fqid =3D qman_fq_fqid(fq);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpa_fq_init);
> +
> +static int __cold __attribute__((nonnull))
> +_dpa_fq_free(struct device *dev, struct qman_fq *fq)
> +{
> +	int			 _errno, __errno;
> +	struct dpa_fq		*dpa_fq;
> +	const struct dpa_priv_s	*priv;
> +
> +	_errno =3D 0;
> +
> +	dpa_fq =3D container_of(fq, struct dpa_fq, fq_base);
> +	priv =3D netdev_priv(dpa_fq->net_dev);
> +
> +	if (dpa_fq->init) {
> +		_errno =3D qman_retire_fq(fq, NULL);
> +		if (unlikely(_errno < 0) && netif_msg_drv(priv))
> +			dev_err(dev, "qman_retire_fq(%u) =3D %d\n",
> +				qman_fq_fqid(fq), _errno);
> +
> +		__errno =3D qman_oos_fq(fq);
> +		if (unlikely(__errno < 0) && netif_msg_drv(priv)) {
> +			dev_err(dev, "qman_oos_fq(%u) =3D %d\n",
> +				qman_fq_fqid(fq), __errno);
> +			if (_errno >=3D 0)
> +				_errno =3D __errno;
> +		}
> +	}
> +
> +	qman_destroy_fq(fq, 0);
> +	list_del(&dpa_fq->list);
> +
> +	return _errno;
> +}
> +
> +int __cold __attribute__((nonnull))
> +dpa_fq_free(struct device *dev, struct list_head *list)
> +{
> +	int		 _errno, __errno;
> +	struct dpa_fq	*dpa_fq, *tmp;
> +
> +	_errno =3D 0;
> +	list_for_each_entry_safe(dpa_fq, tmp, list, list) {
> +		__errno =3D _dpa_fq_free(dev, (struct qman_fq *)dpa_fq);
> +		if (unlikely(__errno < 0) && _errno >=3D 0)
> +			_errno =3D __errno;
> +	}
> +
> +	return _errno;
> +}
> +EXPORT_SYMBOL(dpa_fq_free);
> +
> +static void
> +dpaa_eth_init_tx_port(struct fm_port *port, struct dpa_fq *errq,
> +		      struct dpa_fq *defq,
> +		      struct dpa_buffer_layout_s *buf_layout)
> +{
> +	struct fm_port_params tx_port_param;
> +
> +	memset(&tx_port_param, 0, sizeof(tx_port_param));
> +	dpaa_eth_init_port(tx, port, tx_port_param, errq->fqid, defq->fqid,
> +			   buf_layout, false);
> +}
> +
> +static void
> +dpaa_eth_init_rx_port(struct fm_port *port, struct dpa_bp *bp, size_=
t count,
> +		      struct dpa_fq *errq, struct dpa_fq *defq,
> +		      struct dpa_buffer_layout_s *buf_layout)
> +{
> +	struct fm_port_params rx_port_param;
> +	int i;
> +
> +	memset(&rx_port_param, 0, sizeof(rx_port_param));
> +	count =3D min(ARRAY_SIZE(rx_port_param.pool_param), count);
> +	rx_port_param.num_pools =3D (u8)count;
> +	for (i =3D 0; i < count; i++) {
> +		if (i >=3D rx_port_param.num_pools)
> +			break;
> +		rx_port_param.pool_param[i].id =3D bp[i].bpid;
> +		rx_port_param.pool_param[i].size =3D (u16)bp[i].size;
> +	}
> +
> +	dpaa_eth_init_port(rx, port, rx_port_param, errq->fqid, defq->fqid,
> +			   buf_layout, false);
> +}
> +
> +void dpaa_eth_init_ports(struct mac_device *mac_dev,
> +			 struct dpa_bp *bp, size_t count,
> +			 struct fm_port_fqs *port_fqs,
> +			 struct dpa_buffer_layout_s *buf_layout,
> +			 struct device *dev)
> +{
> +	struct fm_port *rxport =3D mac_dev->port_dev[RX];
> +	struct fm_port *txport =3D mac_dev->port_dev[TX];
> +
> +	dpaa_eth_init_tx_port(txport, port_fqs->tx_errq,
> +			      port_fqs->tx_defq, &buf_layout[TX]);
> +	dpaa_eth_init_rx_port(rxport, bp, count, port_fqs->rx_errq,
> +			      port_fqs->rx_defq, &buf_layout[RX]);
> +}
> +EXPORT_SYMBOL(dpaa_eth_init_ports);
> +
> +void __attribute__((nonnull))
> +dpa_fd_release(const struct net_device *net_dev, const struct qm_fd =
*fd)
> +{
> +	struct dpa_bp			*_dpa_bp;
> +	struct bm_buffer		 _bmb;
> +
> +	_bmb.hi	=3D fd->addr_hi;
> +	_bmb.lo	=3D fd->addr_lo;
> +
> +	_dpa_bp =3D dpa_bpid2pool(fd->bpid);
> +	DPA_ERR_ON(!_dpa_bp);
> +
> +	DPA_ERR_ON(fd->format =3D=3D qm_fd_sg);
> +
> +	while (bman_release(_dpa_bp->pool, &_bmb, 1, 0))
> +		cpu_relax();
> +}
> +EXPORT_SYMBOL(dpa_fd_release);
> +
> +/**
> + * Turn on HW checksum computation for this outgoing frame.
> + * If the current protocol is not something we support in this regar=
d
> + * (or if the stack has already computed the SW checksum), we do not=
hing.
> + *
> + * Returns 0 if all goes well (or HW csum doesn't apply), and a nega=
tive value
> + * otherwise.
> + *
> + * Note that this function may modify the fd->cmd field and the skb =
data buffer
> + * (the Parse Results area).
> + */
> +int dpa_enable_tx_csum(struct dpa_priv_s *priv,
> +		       struct sk_buff *skb,
> +		       struct qm_fd *fd,
> +		       char *parse_results)
> +{
> +	fm_prs_result *parse_result;
> +	struct iphdr *iph;
> +	struct ipv6hdr *ipv6h =3D NULL;
> +	int l4_proto;
> +	int ethertype =3D ntohs(skb->protocol);
> +	int retval =3D 0;
> +
> +	if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
> +		return 0;
> +
> +	/* Note: L3 csum seems to be already computed in sw, but we can't c=
hoose
> +	 * L4 alone from the FM configuration anyway.
> +	 */
> +
> +	/* Fill in some fields of the Parse Results array, so the FMan
> +	 * can find them as if they came from the FMan Parser.
> +	 */
> +	parse_result =3D (fm_prs_result *)parse_results;
> +
> +	/* If we're dealing with VLAN, get the real Ethernet type */
> +	if (ethertype =3D=3D ETH_P_8021Q) {
> +		/* We can't always assume the MAC header is set correctly
> +		 * by the stack, so reset to beginning of skb->data
> +		 */
> +		skb_reset_mac_header(skb);
> +		ethertype =3D ntohs(vlan_eth_hdr(skb)->h_vlan_encapsulated_proto);
> +	}
> +
> +	/* Fill in the relevant L3 parse result fields
> +	 * and read the L4 protocol type
> +	 */
> +	switch (ethertype) {
> +	case ETH_P_IP:
> +		parse_result->l3r =3D FM_L3_PARSE_RESULT_IPV4;
> +		iph =3D ip_hdr(skb);
> +		DPA_ERR_ON(!iph);
> +		l4_proto =3D ntohs(iph->protocol);
> +		break;
> +	case ETH_P_IPV6:
> +		parse_result->l3r =3D FM_L3_PARSE_RESULT_IPV6;
> +		ipv6h =3D ipv6_hdr(skb);
> +		DPA_ERR_ON(!ipv6h);
> +		l4_proto =3D ntohs(ipv6h->nexthdr);
> +		break;
> +	default:
> +		/* We shouldn't even be here */
> +		if (netif_msg_tx_err(priv) && net_ratelimit())
> +			netdev_alert(priv->net_dev,
> +				     "Can't compute HW csum for L3 proto 0x%x\n",
> +				     ntohs(skb->protocol));
> +		retval =3D -EIO;
> +		goto return_error;
> +	}
> +
> +	/* Fill in the relevant L4 parse result fields */
> +	switch (l4_proto) {
> +	case IPPROTO_UDP:
> +		parse_result->l4r =3D FM_L4_PARSE_RESULT_UDP;
> +		break;
> +	case IPPROTO_TCP:
> +		parse_result->l4r =3D FM_L4_PARSE_RESULT_TCP;
> +		break;
> +	default:
> +		/* This can as well be a BUG() */
> +		if (netif_msg_tx_err(priv) && net_ratelimit())
> +			netdev_alert(priv->net_dev,
> +				     "Can't compute HW csum for L4 proto 0x%x\n",
> +				     l4_proto);
> +		retval =3D -EIO;
> +		goto return_error;
> +	}
> +
> +	/* At index 0 is IPOffset_1 as defined in the Parse Results */
> +	parse_result->ip_off[0] =3D (u8)skb_network_offset(skb);
> +	parse_result->l4_off =3D (u8)skb_transport_offset(skb);
> +
> +	/* Enable L3 (and L4, if TCP or UDP) HW checksum. */
> +	fd->cmd |=3D FM_FD_CMD_RPD | FM_FD_CMD_DTC;
> +
> +	/* On P1023 and similar platforms fd->cmd interpretation could
> +	 * be disabled by setting CONTEXT_A bit ICMD; currently this bit
> +	 * is not set so we do not need to check; in the future, if/when
> +	 * using context_a we need to check this bit
> +	 */
> +
> +return_error:
> +	return retval;
> +}
> +EXPORT_SYMBOL(dpa_enable_tx_csum);
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h b/=
drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
> new file mode 100644
> index 0000000..96bc63e
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
> @@ -0,0 +1,119 @@
> +/* Copyright 2008 - 2015 Freescale Semiconductor, Inc.
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
> +#ifndef __DPAA_ETH_COMMON_H
> +#define __DPAA_ETH_COMMON_H
> +
> +#include <linux/etherdevice.h>	/* struct net_device */
> +#include <soc/fsl/bman.h>	/* struct bm_buffer */
> +#include <linux/of_platform.h>	/* struct platform_device */
> +#include <linux/net_tstamp.h>	/* struct hwtstamp_config */
> +
> +#include "dpaa_eth.h"
> +#include "fsl_fman_drv.h"
> +
> +#define dpaa_eth_init_port(type, port, param, errq_id, defq_id, buf_=
layout,\
> +			   frag_enabled) \
> +{ \
> +	param.errq =3D errq_id; \
> +	param.defq =3D defq_id; \
> +	param.priv_data_size =3D buf_layout->priv_data_size; \
> +	param.parse_results =3D buf_layout->parse_results; \
> +	param.hash_results =3D buf_layout->hash_results; \
> +	param.time_stamp =3D buf_layout->time_stamp; \
> +	param.data_align =3D buf_layout->data_align; \
> +	fm_set_##type##_port_params(port, &param); \
> +}
> +
> +#define DPA_BUFF_RELEASE_MAX 8 /* maximum number of buffers released=
 at once */
> +
> +/* used in napi related functions */
> +extern u16 qman_portal_max;
> +
> +int dpa_netdev_init(struct net_device *net_dev,
> +		    const u8 *mac_addr,
> +		    u16 tx_timeout);
> +int __cold dpa_start(struct net_device *net_dev);
> +int __cold dpa_stop(struct net_device *net_dev);
> +void __cold dpa_timeout(struct net_device *net_dev);
> +struct rtnl_link_stats64 * __cold
> +dpa_get_stats64(struct net_device *net_dev,
> +		struct rtnl_link_stats64 *stats);
> +int dpa_change_mtu(struct net_device *net_dev, int new_mtu);
> +int dpa_ndo_init(struct net_device *net_dev);
> +int dpa_set_features(struct net_device *dev, netdev_features_t featu=
res);
> +netdev_features_t dpa_fix_features(struct net_device *dev,
> +				   netdev_features_t features);
> +int __cold dpa_remove(struct platform_device *pdev);
> +struct mac_device * __cold __must_check
> +__attribute__((nonnull)) dpa_mac_dev_get(struct platform_device *pde=
v);
> +int dpa_mac_hw_index_get(struct platform_device *pdev);
> +int dpa_mac_fman_index_get(struct platform_device *pdev);
> +int dpa_set_mac_address(struct net_device *net_dev, void *addr);
> +void dpa_set_rx_mode(struct net_device *net_dev);
> +void dpa_set_buffers_layout(struct mac_device *mac_dev,
> +			    struct dpa_buffer_layout_s *layout);
> +int __attribute__((nonnull))
> +dpa_bp_alloc(struct dpa_bp *dpa_bp);
> +void __cold __attribute__((nonnull))
> +dpa_bp_free(struct dpa_priv_s *priv);
> +struct dpa_bp *dpa_bpid2pool(int bpid);
> +void dpa_bpid2pool_map(int bpid, struct dpa_bp *dpa_bp);
> +bool dpa_bpid2pool_use(int bpid);
> +void dpa_bp_drain(struct dpa_bp *bp);
> +struct dpa_fq *dpa_fq_alloc(struct device *dev,
> +			    const struct fqid_cell *fqids,
> +			    struct list_head *list,
> +			    enum dpa_fq_type fq_type);
> +int dpa_fq_probe_mac(struct device *dev, struct list_head *list,
> +		     struct fm_port_fqs *port_fqs,
> +		     bool tx_conf_fqs_per_core,
> +		     enum port_type ptype);
> +int dpa_get_channel(void);
> +void dpa_release_channel(void);
> +int dpaa_eth_add_channel(void *__arg);
> +int dpaa_eth_cgr_init(struct dpa_priv_s *priv);
> +void dpa_fq_setup(struct dpa_priv_s *priv, const struct dpa_fq_cbs_t=
 *fq_cbs,
> +		  struct fm_port *tx_port);
> +int dpa_fq_init(struct dpa_fq *dpa_fq, bool td_enable);
> +int __cold __attribute__((nonnull))
> +dpa_fq_free(struct device *dev, struct list_head *list);
> +void dpaa_eth_init_ports(struct mac_device *mac_dev,
> +			 struct dpa_bp *bp, size_t count,
> +			 struct fm_port_fqs *port_fqs,
> +			 struct dpa_buffer_layout_s *buf_layout,
> +			 struct device *dev);
> +void __attribute__((nonnull))
> +dpa_fd_release(const struct net_device *net_dev, const struct qm_fd =
*fd);
> +int dpa_enable_tx_csum(struct dpa_priv_s *priv,
> +		       struct sk_buff *skb,
> +		       struct qm_fd *fd,
> +		       char *parse_results);
> +#endif	/* __DPAA_ETH_COMMON_H */
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c b/driv=
ers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
> new file mode 100644
> index 0000000..ef3117e
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
> @@ -0,0 +1,428 @@
> +/* Copyright 2012 - 2015 Freescale Semiconductor Inc.
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
> +#define pr_fmt(fmt) \
> +	KBUILD_MODNAME ": " fmt
> +
> +#include <linux/init.h>
> +#include <linux/skbuff.h>
> +#include <linux/highmem.h>
> +#include <soc/fsl/bman.h>
> +
> +#include "dpaa_eth.h"
> +#include "dpaa_eth_common.h"
> +
> +/* Convenience macros for storing/retrieving the skb back-pointers.
> + *
> + * NB: @off is an offset from a (struct sk_buff **) pointer!
> + */
> +#define DPA_WRITE_SKB_PTR(skb, skbh, addr, off) \
> +	{ \
> +		skbh =3D (struct sk_buff **)addr; \
> +		*(skbh + (off)) =3D skb; \
> +	}
> +#define DPA_READ_SKB_PTR(skb, skbh, addr, off) \
> +	{ \
> +		skbh =3D (struct sk_buff **)addr; \
> +		skb =3D *(skbh + (off)); \
> +	}
> +
> +static int _dpa_bp_add_8_bufs(const struct dpa_bp *dpa_bp)
> +{
> +	struct bm_buffer bmb[8];
> +	void *new_buf;
> +	dma_addr_t addr;
> +	u8 i;
> +	struct device *dev =3D dpa_bp->dev;
> +	struct sk_buff *skb, **skbh;
> +
> +	for (i =3D 0; i < 8; i++) {
> +		/* We'll prepend the skb back-pointer; can't use the DPA
> +		 * priv space, because FMan will overwrite it (from offset 0)
> +		 * if it ends up being the second, third, etc. fragment
> +		 * in a S/G frame.
> +		 *
> +		 * We only need enough space to store a pointer, but allocate
> +		 * an entire cacheline for performance reasons.
> +		 */
> +		new_buf =3D netdev_alloc_frag(SMP_CACHE_BYTES + DPA_BP_RAW_SIZE);
> +		if (unlikely(!new_buf))
> +			goto netdev_alloc_failed;
> +		new_buf =3D PTR_ALIGN(new_buf + SMP_CACHE_BYTES, SMP_CACHE_BYTES);
> +
> +		skb =3D build_skb(new_buf, DPA_SKB_SIZE(dpa_bp->size) +
> +			SKB_DATA_ALIGN(sizeof(struct skb_shared_info)));
> +		if (unlikely(!skb)) {
> +			put_page(virt_to_head_page(new_buf));
> +			goto build_skb_failed;
> +		}
> +		DPA_WRITE_SKB_PTR(skb, skbh, new_buf, -1);
> +
> +		addr =3D dma_map_single(dev, new_buf,
> +				      dpa_bp->size, DMA_BIDIRECTIONAL);
> +		if (unlikely(dma_mapping_error(dev, addr)))
> +			goto dma_map_failed;
> +
> +		bm_buffer_set64(&bmb[i], addr);
> +	}
> +
> +release_bufs:
> +	/* Release the buffers. In case bman is busy, keep trying
> +	 * until successful. bman_release() is guaranteed to succeed
> +	 * in a reasonable amount of time
> +	 */
> +	while (unlikely(bman_release(dpa_bp->pool, bmb, i, 0)))
> +		cpu_relax();
> +	return i;
> +
> +dma_map_failed:
> +	kfree_skb(skb);
> +
> +build_skb_failed:
> +netdev_alloc_failed:
> +	net_err_ratelimited("dpa_bp_add_8_bufs() failed\n");
> +	WARN_ONCE(1, "Memory allocation failure on Rx\n");
> +
> +	bm_buffer_set64(&bmb[i], 0);
> +	/* Avoid releasing a completely null buffer; bman_release() require=
s
> +	 * at least one buffer.
> +	 */
> +	if (likely(i))
> +		goto release_bufs;
> +
> +	return 0;
> +}
> +
> +/* Cold path wrapper over _dpa_bp_add_8_bufs(). */
> +static void dpa_bp_add_8_bufs(const struct dpa_bp *dpa_bp, int cpu)
> +{
> +	int *count_ptr =3D per_cpu_ptr(dpa_bp->percpu_count, cpu);
> +	*count_ptr +=3D _dpa_bp_add_8_bufs(dpa_bp);
> +}
> +
> +int dpa_bp_priv_seed(struct dpa_bp *dpa_bp)
> +{
> +	int i;
> +
> +	/* Give each CPU an allotment of "config_count" buffers */
> +	for_each_possible_cpu(i) {
> +		int j;
> +
> +		/* Although we access another CPU's counters here
> +		 * we do it at boot time so it is safe
> +		 */
> +		for (j =3D 0; j < dpa_bp->config_count; j +=3D 8)
> +			dpa_bp_add_8_bufs(dpa_bp, i);
> +	}
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpa_bp_priv_seed);
> +
> +/* Add buffers/(pages) for Rx processing whenever bpool count falls =
below
> + * REFILL_THRESHOLD.
> + */
> +int dpaa_eth_refill_bpools(struct dpa_bp *dpa_bp, int *countptr)
> +{
> +	int count =3D *countptr;
> +	int new_bufs;
> +
> +	if (unlikely(count < FSL_DPAA_ETH_REFILL_THRESHOLD)) {
> +		do {
> +			new_bufs =3D _dpa_bp_add_8_bufs(dpa_bp);
> +			if (unlikely(!new_bufs)) {
> +				/* Avoid looping forever if we've temporarily
> +				 * run out of memory. We'll try again at the
> +				 * next NAPI cycle.
> +				 */
> +				break;
> +			}
> +			count +=3D new_bufs;
> +		} while (count < FSL_DPAA_ETH_MAX_BUF_COUNT);
> +
> +		*countptr =3D count;
> +		if (unlikely(count < FSL_DPAA_ETH_MAX_BUF_COUNT))
> +			return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(dpaa_eth_refill_bpools);
> +
> +/* Cleanup function for outgoing frame descriptors that were built o=
n Tx path,
> + * either contiguous frames or scatter/gather ones.
> + * Skb freeing is not handled here.
> + *
> + * This function may be called on error paths in the Tx function, so=
 guard
> + * against cases when not all fd relevant fields were filled in.
> + *
> + * Return the skb backpointer, since for S/G frames the buffer conta=
ining it
> + * gets freed here.
> + */
> +struct sk_buff *_dpa_cleanup_tx_fd(const struct dpa_priv_s *priv,
> +				   const struct qm_fd *fd)
> +{
> +	struct dpa_bp *dpa_bp =3D priv->dpa_bp;
> +	dma_addr_t addr =3D qm_fd_addr(fd);
> +	struct sk_buff **skbh;
> +	struct sk_buff *skb =3D NULL;
> +	const enum dma_data_direction dma_dir =3D DMA_TO_DEVICE;
> +	int nr_frags;
> +
> +	dma_unmap_single(dpa_bp->dev, addr, dpa_bp->size, dma_dir);
> +
> +	/* retrieve skb back pointer */
> +	DPA_READ_SKB_PTR(skb, skbh, phys_to_virt(addr), 0);
> +	nr_frags =3D skb_shinfo(skb)->nr_frags;
> +
> +	return skb;
> +}
> +
> +/* Build a linear skb around the received buffer.
> + * We are guaranteed there is enough room at the end of the data buf=
fer to
> + * accommodate the shared info area of the skb.
> + */
> +static struct sk_buff *__hot contig_fd_to_skb(const struct dpa_priv_=
s *priv,
> +	const struct qm_fd *fd)
> +{
> +	struct sk_buff *skb =3D NULL, **skbh;
> +	ssize_t fd_off =3D dpa_fd_offset(fd);
> +	dma_addr_t addr =3D qm_fd_addr(fd);
> +	void *vaddr;
> +
> +	vaddr =3D phys_to_virt(addr);
> +	DPA_ERR_ON(!IS_ALIGNED((unsigned long)vaddr, SMP_CACHE_BYTES));
> +
> +	/* Retrieve the skb and adjust data and tail pointers, to make sure
> +	 * forwarded skbs will have enough space on Tx if extra headers
> +	 * are added.
> +	 */
> +	DPA_READ_SKB_PTR(skb, skbh, vaddr, -1);
> +
> +	DPA_ERR_ON(fd_off !=3D priv->rx_headroom);
> +	skb_reserve(skb, fd_off);
> +	skb_put(skb, dpa_fd_length(fd));
> +
> +	skb->ip_summed =3D CHECKSUM_NONE;
> +
> +	return skb;
> +}
> +
> +void __hot _dpa_rx(struct net_device *net_dev,
> +		   struct qman_portal *portal,
> +		   const struct dpa_priv_s *priv,
> +		   struct dpa_percpu_priv_s *percpu_priv,
> +		   const struct qm_fd *fd,
> +		   u32 fqid,
> +		   int *count_ptr)
> +{
> +	struct dpa_bp *dpa_bp;
> +	struct sk_buff *skb;
> +	dma_addr_t addr =3D qm_fd_addr(fd);
> +	u32 fd_status =3D fd->status;
> +	unsigned int skb_len;
> +	struct rtnl_link_stats64 *percpu_stats =3D &percpu_priv->stats;
> +
> +	if (unlikely(fd_status & FM_FD_STAT_RX_ERRORS) !=3D 0) {
> +		if (netif_msg_hw(priv) && net_ratelimit())
> +			netdev_warn(net_dev, "FD status =3D 0x%08x\n",
> +				    fd_status & FM_FD_STAT_RX_ERRORS);
> +
> +		percpu_stats->rx_errors++;
> +		goto _release_frame;
> +	}
> +
> +	dpa_bp =3D priv->dpa_bp;
> +	DPA_ERR_ON(dpa_bp !=3D dpa_bpid2pool(fd->bpid));
> +
> +	/* prefetch the first 64 bytes of the frame */
> +	dma_unmap_single(dpa_bp->dev, addr, dpa_bp->size, DMA_BIDIRECTIONAL=
);
> +	prefetch(phys_to_virt(addr) + dpa_fd_offset(fd));
> +
> +	/* The only FD type that we may receive is contig */
> +	DPA_ERR_ON((fd->format !=3D qm_fd_contig));
> +
> +	skb =3D contig_fd_to_skb(priv, fd);
> +
> +	/* Account for the contig buffer
> +	 * having been removed from the pool.
> +	 */
> +	(*count_ptr)--;
> +	skb->protocol =3D eth_type_trans(skb, net_dev);
> +
> +	/* IP Reassembled frames are allowed to be larger than MTU */
> +	if (unlikely(dpa_check_rx_mtu(skb, net_dev->mtu) &&
> +		     !(fd_status & FM_FD_IPR))) {
> +		percpu_stats->rx_dropped++;
> +		goto drop_bad_frame;
> +	}
> +
> +	skb_len =3D skb->len;
> +
> +	if (unlikely(netif_receive_skb(skb) =3D=3D NET_RX_DROP))
> +		goto packet_dropped;
> +
> +	percpu_stats->rx_packets++;
> +	percpu_stats->rx_bytes +=3D skb_len;
> +
> +packet_dropped:
> +	return;
> +
> +drop_bad_frame:
> +	dev_kfree_skb(skb);
> +	return;
> +
> +_release_frame:
> +	dpa_fd_release(net_dev, fd);
> +}
> +
> +static int __hot skb_to_contig_fd(struct dpa_priv_s *priv,
> +				  struct sk_buff *skb, struct qm_fd *fd,
> +				  int *count_ptr, int *offset)
> +{
> +	struct sk_buff **skbh;
> +	dma_addr_t addr;
> +	struct dpa_bp *dpa_bp =3D priv->dpa_bp;
> +	struct net_device *net_dev =3D priv->net_dev;
> +	int err;
> +	enum dma_data_direction dma_dir;
> +	unsigned char *buffer_start;
> +
> +	{
> +		/* We are guaranteed to have at least tx_headroom bytes
> +		 * available, so just use that for offset.
> +		 */
> +		fd->bpid =3D 0xff;
> +		buffer_start =3D skb->data - priv->tx_headroom;
> +		fd->offset =3D priv->tx_headroom;
> +		dma_dir =3D DMA_TO_DEVICE;
> +
> +		DPA_WRITE_SKB_PTR(skb, skbh, buffer_start, 0);
> +	}
> +
> +	/* Enable L3/L4 hardware checksum computation.
> +	 *
> +	 * We must do this before dma_map_single(DMA_TO_DEVICE), because we=
 may
> +	 * need to write into the skb.
> +	 */
> +	err =3D dpa_enable_tx_csum(priv, skb, fd,
> +				 ((char *)skbh) + DPA_TX_PRIV_DATA_SIZE);
> +	if (unlikely(err < 0)) {
> +		if (netif_msg_tx_err(priv) && net_ratelimit())
> +			netdev_err(net_dev, "HW csum error: %d\n", err);
> +		return err;
> +	}
> +
> +	/* Fill in the rest of the FD fields */
> +	fd->format =3D qm_fd_contig;
> +	fd->length20 =3D skb->len;
> +	fd->cmd |=3D FM_FD_CMD_FCO;
> +
> +	/* Map the entire buffer size that may be seen by FMan, but no more=
 */
> +	addr =3D dma_map_single(dpa_bp->dev, skbh,
> +			      skb_end_pointer(skb) - buffer_start, dma_dir);
> +	if (unlikely(dma_mapping_error(dpa_bp->dev, addr))) {
> +		if (netif_msg_tx_err(priv) && net_ratelimit())
> +			netdev_err(net_dev, "dma_map_single() failed\n");
> +		return -EINVAL;
> +	}
> +	fd->addr_hi =3D (u8)upper_32_bits(addr);
> +	fd->addr_lo =3D lower_32_bits(addr);
> +
> +	return 0;
> +}
> +
> +int __hot dpa_tx(struct sk_buff *skb, struct net_device *net_dev)
> +{
> +	struct dpa_priv_s	*priv;
> +	struct qm_fd		 fd;
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	struct rtnl_link_stats64 *percpu_stats;
> +	const int queue_mapping =3D dpa_get_queue_mapping(skb);
> +	int *countptr, offset =3D 0;
> +
> +	priv =3D netdev_priv(net_dev);
> +	/* Non-migratable context, safe to use raw_cpu_ptr */
> +	percpu_priv =3D raw_cpu_ptr(priv->percpu_priv);
> +	percpu_stats =3D &percpu_priv->stats;
> +	countptr =3D raw_cpu_ptr(priv->dpa_bp->percpu_count);
> +
> +	clear_fd(&fd);
> +
> +	/* Make sure we have enough headroom to accommodate private
> +	 * data, parse results, etc. Normally this shouldn't happen if
> +	 * we're here via the standard kernel stack.
> +	 */
> +	if (unlikely(skb_headroom(skb) < priv->tx_headroom)) {
> +		struct sk_buff *skb_new;
> +
> +		skb_new =3D skb_realloc_headroom(skb, priv->tx_headroom);
> +		if (unlikely(!skb_new)) {
> +			dev_kfree_skb(skb);
> +			percpu_stats->tx_errors++;
> +			return NETDEV_TX_OK;
> +		}
> +		dev_kfree_skb(skb);
> +		skb =3D skb_new;
> +	}
> +
> +	/* We're going to store the skb backpointer at the beginning
> +	 * of the data buffer, so we need a privately owned skb
> +	 */
> +
> +	/* Code borrowed from skb_unshare(). */
> +	if (skb_cloned(skb)) {
> +		struct sk_buff *nskb =3D skb_copy(skb, GFP_ATOMIC);
> +
> +		/* Finally, create a contig FD from this skb */
> +		skb_to_contig_fd(priv, skb, &fd, countptr, &offset);
> +
> +		kfree_skb(skb);
> +		skb =3D nskb;
> +		/* skb_copy() has now linearized the skbuff. */
> +	}
> +
> +	if (unlikely(dpa_xmit(priv, percpu_stats, queue_mapping, &fd) < 0))
> +		goto xmit_failed;
> +
> +	net_dev->trans_start =3D jiffies;
> +	return NETDEV_TX_OK;
> +
> +xmit_failed:
> +	if (fd.cmd & FM_FD_CMD_FCO) {
> +		(*countptr)--;
> +		dpa_fd_release(net_dev, &fd);
> +		percpu_stats->tx_errors++;
> +		return NETDEV_TX_OK;
> +	}
> +	_dpa_cleanup_tx_fd(priv, &fd);
> +	percpu_stats->tx_errors++;
> +	dev_kfree_skb(skb);
> +	return NETDEV_TX_OK;
> +}
> --=20
> 1.7.11.7
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
