From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Wed, 29 Jul 2015 14:15:48 +0000
Message-ID: <1438179348.3120.10.camel@transmode.se>
References: <1437581806-17420-1-git-send-email-madalin.bucur@freescale.com>
	 <1437581806-17420-2-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"scottwood@freescale.com" <scottwood@freescale.com>,
	"igal.liberman@freescale.com" <igal.liberman@freescale.com>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"joe@perches.com" <joe@perches.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"madalin.bucur@freescale.com" <madalin.bucur@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437581806-17420-2-git-send-email-madalin.bucur@freescale.com>
Content-Language: en-US
Content-ID: <B81B282048B33F43802884590B4CA15C@transmode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-22 at 19:16 +0300, Madalin Bucur wrote:
> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
>  drivers/net/ethernet/freescale/Kconfig             |    2 +
>  drivers/net/ethernet/freescale/Makefile            |    1 +
>  drivers/net/ethernet/freescale/dpaa/Kconfig        |   46 +
>  drivers/net/ethernet/freescale/dpaa/Makefile       |   13 +
>  drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  827 +++++++++++++
>  drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  447 +++++++
>  .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  | 1254 ++++++++++++++++++++
>  .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |  119 ++
>  drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  |  406 +++++++
>  9 files changed, 3115 insertions(+)
>  create mode 100644 drivers/net/ethernet/freescale/dpaa/Kconfig
>  create mode 100644 drivers/net/ethernet/freescale/dpaa/Makefile
>  create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
>  create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
>  create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
>  create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
>  create mode 100644 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
> 
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
> index f3f89cc..92198be 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -92,4 +92,6 @@ config GIANFAR
>  	  and MPC86xx family of chips, the eTSEC on LS1021A and the FEC
>  	  on the 8540.
>  
> +source "drivers/net/ethernet/freescale/dpaa/Kconfig"
> +
>  endif # NET_VENDOR_FREESCALE
> diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
> index 4097c58..ae13dc5 100644
> --- a/drivers/net/ethernet/freescale/Makefile
> +++ b/drivers/net/ethernet/freescale/Makefile
> @@ -12,6 +12,7 @@ obj-$(CONFIG_FS_ENET) += fs_enet/
>  obj-$(CONFIG_FSL_PQ_MDIO) += fsl_pq_mdio.o
>  obj-$(CONFIG_FSL_XGMAC_MDIO) += xgmac_mdio.o
>  obj-$(CONFIG_GIANFAR) += gianfar_driver.o
> +obj-$(CONFIG_FSL_DPAA_ETH) += dpaa/
>  obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
>  gianfar_driver-objs := gianfar.o \
>  		gianfar_ethtool.o
> diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/net/ethernet/freescale/dpaa/Kconfig
> new file mode 100644
> index 0000000..1f3a203
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
> @@ -0,0 +1,46 @@
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
> +	range 0x1000 0x10000000
> +	default "0x06000000"
> +	---help---
> +	  The size in bytes of the egress Congestion State notification threshold on 1G ports.
> +	  The 1G dTSECs can quite easily be flooded by cores doing Tx in a tight loop
> +	  (e.g. by sending UDP datagrams at "while(1) speed"),
> +	  and the larger the frame size, the more acute the problem.
> +	  So we have to find a balance between these factors:
> +	       - avoiding the device staying congested for a prolonged time (risking
> +                 the netdev watchdog to fire - see also the tx_timeout module param);
> +               - affecting performance of protocols such as TCP, which otherwise
> +	         behave well under the congestion notification mechanism;
> +	       - preventing the Tx cores from tightly-looping (as if the congestion
> +	         threshold was too low to be effective);
> +	       - running out of memory if the CS threshold is set too high.
> +
> +config FSL_DPAA_CS_THRESHOLD_10G
> +	hex "Egress congestion threshold on 10G ports"
> +	range 0x1000 0x20000000
> +	default "0x10000000"
> +	---help ---
> +	  The size in bytes of the egress Congestion State notification threshold on 10G ports.
> +
> +config FSL_DPAA_INGRESS_CS_THRESHOLD
> +	hex "Ingress congestion threshold on FMan ports"
> +	default "0x10000000"
> +	---help---
> +	  The size in bytes of the ingress tail-drop threshold on FMan ports.
> +	  Traffic piling up above this value will be rejected by QMan and discarded by FMan.
> +
> +endif # FSL_DPAA_ETH
> diff --git a/drivers/net/ethernet/freescale/dpaa/Makefile b/drivers/net/ethernet/freescale/dpaa/Makefile
> new file mode 100644
> index 0000000..cf126dd
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/Makefile
> @@ -0,0 +1,13 @@
> +#
> +# Makefile for the Freescale DPAA Ethernet controllers
> +#
> +
> +# Include FMan headers
> +FMAN        = $(srctree)/drivers/net/ethernet/freescale/fman
> +ccflags-y += -I$(FMAN)
> +ccflags-y += -I$(FMAN)/inc
> +ccflags-y += -I$(FMAN)/flib
> +
> +obj-$(CONFIG_FSL_DPAA_ETH) += fsl_dpa.o
> +
> +fsl_dpa-objs += dpaa_eth.o dpaa_eth_sg.o dpaa_eth_common.o
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> new file mode 100644
> index 0000000..500d0e3
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> @@ -0,0 +1,827 @@
> +/* Copyright 2008 - 2015 Freescale Semiconductor Inc.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions are met:
> + *     * Redistributions of source code must retain the above copyright
> + *	 notice, this list of conditions and the following disclaimer.
> + *     * Redistributions in binary form must reproduce the above copyright
> + *	 notice, this list of conditions and the following disclaimer in the
> + *	 documentation and/or other materials provided with the distribution.
> + *     * Neither the name of Freescale Semiconductor nor the
> + *	 names of its contributors may be used to endorse or promote products
> + *	 derived from this software without specific prior written permission.
> + *
> + * ALTERNATIVELY, this software may be distributed under the terms of the
> + * GNU General Public License ("GPL") as published by the Free Software
> + * Foundation, either version 2 of that License or (at your option) any
> + * later version.
> + *
> + * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
> + * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
> + * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> + * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
> + * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
> + * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
> + * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
> + * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> + * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_net.h>
> +#include <linux/kthread.h>
> +#include <linux/io.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_vlan.h>
> +#include <linux/icmp.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/udp.h>
> +#include <linux/tcp.h>
> +#include <linux/net.h>
> +#include <linux/if_ether.h>
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
> +static u8 debug = -1;
> +module_param(debug, byte, S_IRUGO);
> +MODULE_PARM_DESC(debug, "Module/Driver verbosity level");
> +
> +/* This has to work in tandem with the DPA_CS_THRESHOLD_xxx values. */
> +static u16 tx_timeout = 1000;
> +module_param(tx_timeout, ushort, S_IRUGO);
> +MODULE_PARM_DESC(tx_timeout, "The Tx timeout in ms");
> +
> +/* BM */
> +
> +#define DPAA_ETH_MAX_PAD (L1_CACHE_BYTES * 8)
> +
> +static u8 dpa_priv_common_bpid;
> +
> +static void _dpa_rx_error(struct net_device *net_dev,
> +			  const struct dpa_priv_s	*priv,
> +			  struct dpa_percpu_priv_s *percpu_priv,
> +			  const struct qm_fd *fd,
> +			  u32 fqid)
> +{
> +	/* limit common, possibly innocuous Rx FIFO Overflow errors'
> +	 * interference with zero-loss convergence benchmark results.
> +	 */
> +	if (likely(fd->status & FM_FD_STAT_ERR_PHYSICAL))
> +		pr_warn_once("non-zero error counters in fman statistics (sysfs)\n");
> +	else
> +		if (net_ratelimit())
> +			netif_err(priv, hw, net_dev, "Err FD status = 0x%08x\n",
> +				  fd->status & FM_FD_STAT_RX_ERRORS);
> +
> +	percpu_priv->stats.rx_errors++;
> +
> +	dpa_fd_release(net_dev, fd);
> +}
> +
> +static void _dpa_tx_error(struct net_device		*net_dev,
> +			  const struct dpa_priv_s	*priv,
> +			  struct dpa_percpu_priv_s	*percpu_priv,
> +			  const struct qm_fd		*fd,
> +			  u32				 fqid)
> +{
> +	struct sk_buff *skb;
> +
> +	if (net_ratelimit())
> +		netif_warn(priv, hw, net_dev, "FD status = 0x%08x\n",
> +			   fd->status & FM_FD_STAT_TX_ERRORS);
> +
> +	percpu_priv->stats.tx_errors++;
> +
> +	/* If we intended the buffers from this frame to go into the bpools
> +	 * when the FMan transmit was done, we need to put it in manually.
> +	 */
> +	if (fd->bpid != 0xff) {
> +		dpa_fd_release(net_dev, fd);
> +		return;
> +	}
> +
> +	skb = _dpa_cleanup_tx_fd(priv, fd);
> +	dev_kfree_skb(skb);
> +}
> +
> +static int dpaa_eth_poll(struct napi_struct *napi, int budget)
> +{
> +	struct dpa_napi_portal *np =
> +			container_of(napi, struct dpa_napi_portal, napi);
> +
> +	int cleaned = qman_p_poll_dqrr(np->p, budget);
> +
> +	if (cleaned < budget) {
> +		int tmp;
> +
> +		napi_complete(napi);
> +		tmp = qman_p_irqsource_add(np->p, QM_PIRQ_DQRI);
> +		DPA_ERR_ON(tmp);
> +	}
> +
> +	return cleaned;
> +}
> +
> +static void __hot _dpa_tx_conf(struct net_device	*net_dev,
> +			       const struct dpa_priv_s	*priv,
> +			       struct dpa_percpu_priv_s	*percpu_priv,
> +			       const struct qm_fd	*fd,
> +			       u32			fqid)
> +{
> +	struct sk_buff	*skb;
> +
> +	if (unlikely(fd->status & FM_FD_STAT_TX_ERRORS) != 0) {
> +		if (net_ratelimit())
> +			netif_warn(priv, hw, net_dev, "FD status = 0x%08x\n",
> +				   fd->status & FM_FD_STAT_TX_ERRORS);
> +
> +		percpu_priv->stats.tx_errors++;
> +	}
> +
> +	skb = _dpa_cleanup_tx_fd(priv, fd);
> +
> +	dev_kfree_skb(skb);
> +}
> +
> +static enum qman_cb_dqrr_result
> +priv_rx_error_dqrr(struct qman_portal		*portal,
> +		   struct qman_fq		*fq,
> +		   const struct qm_dqrr_entry	*dq)
> +{
> +	struct net_device		*net_dev;
> +	struct dpa_priv_s		*priv;
> +	struct dpa_percpu_priv_s	*percpu_priv;
> +	int				*count_ptr;
> +
> +	net_dev = ((struct dpa_fq *)fq)->net_dev;
> +	priv = netdev_priv(net_dev);
> +
> +	percpu_priv = raw_cpu_ptr(priv->percpu_priv);
> +	count_ptr = raw_cpu_ptr(priv->dpa_bp->percpu_count);
> +
> +	if (dpaa_eth_napi_schedule(percpu_priv, portal))
> +		return qman_cb_dqrr_stop;
> +
> +	if (unlikely(dpaa_eth_refill_bpools(priv->dpa_bp, count_ptr)))
> +		/* Unable to refill the buffer pool due to insufficient
> +		 * system memory. Just release the frame back into the pool,
> +		 * otherwise we'll soon end up with an empty buffer pool.
> +		 */
> +		dpa_fd_release(net_dev, &dq->fd);
> +	else
> +		_dpa_rx_error(net_dev, priv, percpu_priv, &dq->fd, fq->fqid);
> +
> +	return qman_cb_dqrr_consume;
> +}
> +
> +static enum qman_cb_dqrr_result __hot
> +priv_rx_default_dqrr(struct qman_portal		*portal,
> +		     struct qman_fq		*fq,
> +		     const struct qm_dqrr_entry	*dq)
> +{
> +	struct net_device		*net_dev;
> +	struct dpa_priv_s		*priv;
> +	struct dpa_percpu_priv_s	*percpu_priv;
> +	int				*count_ptr;
> +	struct dpa_bp			*dpa_bp;
> +
> +	net_dev = ((struct dpa_fq *)fq)->net_dev;
> +	priv = netdev_priv(net_dev);
> +	dpa_bp = priv->dpa_bp;
> +
> +	/* IRQ handler, non-migratable; safe to use raw_cpu_ptr here */
> +	percpu_priv = raw_cpu_ptr(priv->percpu_priv);
> +	count_ptr = raw_cpu_ptr(dpa_bp->percpu_count);
> +
> +	if (unlikely(dpaa_eth_napi_schedule(percpu_priv, portal)))
> +		return qman_cb_dqrr_stop;
> +
> +	/* Vale of plenty: make sure we didn't run out of buffers */
> +
> +	if (unlikely(dpaa_eth_refill_bpools(dpa_bp, count_ptr)))
> +		/* Unable to refill the buffer pool due to insufficient
> +		 * system memory. Just release the frame back into the pool,
> +		 * otherwise we'll soon end up with an empty buffer pool.
> +		 */
> +		dpa_fd_release(net_dev, &dq->fd);
> +	else
> +		_dpa_rx(net_dev, portal, priv, percpu_priv, &dq->fd, fq->fqid,
> +			count_ptr);
> +
> +	return qman_cb_dqrr_consume;
> +}
> +
> +static enum qman_cb_dqrr_result
> +priv_tx_conf_error_dqrr(struct qman_portal		*portal,
> +			struct qman_fq			*fq,
> +			const struct qm_dqrr_entry	*dq)
> +{
> +	struct net_device		*net_dev;
> +	struct dpa_priv_s		*priv;
> +	struct dpa_percpu_priv_s	*percpu_priv;
> +
> +	net_dev = ((struct dpa_fq *)fq)->net_dev;
> +	priv = netdev_priv(net_dev);
> +
> +	percpu_priv = raw_cpu_ptr(priv->percpu_priv);
> +
> +	if (dpaa_eth_napi_schedule(percpu_priv, portal))
> +		return qman_cb_dqrr_stop;
> +
> +	_dpa_tx_error(net_dev, priv, percpu_priv, &dq->fd, fq->fqid);
> +
> +	return qman_cb_dqrr_consume;
> +}
> +
> +static enum qman_cb_dqrr_result __hot
> +priv_tx_conf_default_dqrr(struct qman_portal		*portal,
> +			  struct qman_fq		*fq,
> +			  const struct qm_dqrr_entry	*dq)
> +{
> +	struct net_device		*net_dev;
> +	struct dpa_priv_s		*priv;
> +	struct dpa_percpu_priv_s	*percpu_priv;
> +
> +	net_dev = ((struct dpa_fq *)fq)->net_dev;
> +	priv = netdev_priv(net_dev);
> +
> +	/* Non-migratable context, safe to use raw_cpu_ptr */
> +	percpu_priv = raw_cpu_ptr(priv->percpu_priv);
> +
> +	if (dpaa_eth_napi_schedule(percpu_priv, portal))
> +		return qman_cb_dqrr_stop;
> +
> +	_dpa_tx_conf(net_dev, priv, percpu_priv, &dq->fd, fq->fqid);
> +
> +	return qman_cb_dqrr_consume;
> +}
> +
> +static void priv_ern(struct qman_portal		*portal,
> +		     struct qman_fq		*fq,
> +		     const struct qm_mr_entry	*msg)
> +{
> +	struct net_device	*net_dev;
> +	const struct dpa_priv_s	*priv;
> +	struct sk_buff *skb;
> +	struct dpa_percpu_priv_s	*percpu_priv;
> +	const struct qm_fd *fd = &msg->ern.fd;
> +
> +	net_dev = ((struct dpa_fq *)fq)->net_dev;
> +	priv = netdev_priv(net_dev);
> +	/* Non-migratable context, safe to use raw_cpu_ptr */
> +	percpu_priv = raw_cpu_ptr(priv->percpu_priv);
> +
> +	percpu_priv->stats.tx_dropped++;
> +	percpu_priv->stats.tx_fifo_errors++;
> +
> +	/* If we intended this buffer to go into the pool
> +	 * when the FM was done, we need to put it in
> +	 * manually.
> +	 */
> +	if (msg->ern.fd.bpid != 0xff) {
> +		dpa_fd_release(net_dev, fd);
> +		return;
> +	}
> +
> +	skb = _dpa_cleanup_tx_fd(priv, fd);
> +	dev_kfree_skb_any(skb);
> +}
> +
> +static const struct dpa_fq_cbs_t private_fq_cbs = {
> +	.rx_defq = { .cb = { .dqrr = priv_rx_default_dqrr } },
> +	.tx_defq = { .cb = { .dqrr = priv_tx_conf_default_dqrr } },
> +	.rx_errq = { .cb = { .dqrr = priv_rx_error_dqrr } },
> +	.tx_errq = { .cb = { .dqrr = priv_tx_conf_error_dqrr } },
> +	.egress_ern = { .cb = { .ern = priv_ern } }
> +};
> +
> +static void dpaa_eth_napi_enable(struct dpa_priv_s *priv)
> +{
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int i, j;
> +
> +	for_each_possible_cpu(i) {
> +		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
> +
> +		for (j = 0; j < qman_portal_max; j++)
> +			napi_enable(&percpu_priv->np[j].napi);
> +	}
> +}
> +
> +static void dpaa_eth_napi_disable(struct dpa_priv_s *priv)
> +{
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int i, j;
> +
> +	for_each_possible_cpu(i) {
> +		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
> +
> +		for (j = 0; j < qman_portal_max; j++)
> +			napi_disable(&percpu_priv->np[j].napi);
> +	}
> +}
> +
> +static int dpa_eth_priv_start(struct net_device *net_dev)
> +{
> +	int err;
> +	struct dpa_priv_s *priv;
> +
> +	priv = netdev_priv(net_dev);
> +
> +	dpaa_eth_napi_enable(priv);
> +
> +	err = dpa_start(net_dev);
> +	if (err < 0)
> +		dpaa_eth_napi_disable(priv);
> +
> +	return err;
> +}
> +
> +static int dpa_eth_priv_stop(struct net_device *net_dev)
> +{
> +	int err;
> +	struct dpa_priv_s *priv;
> +
> +	err = dpa_stop(net_dev);
> +	/* Allow NAPI to consume any frame still in the Rx/TxConfirm
> +	 * ingress queues. This is to avoid a race between the current
> +	 * context and ksoftirqd which could leave NAPI disabled while
> +	 * in fact there's still Rx traffic to be processed.
> +	 */
> +	usleep_range(5000, 10000);
> +
> +	priv = netdev_priv(net_dev);
> +	dpaa_eth_napi_disable(priv);
> +
> +	return err;
> +}
> +
> +static const struct net_device_ops dpa_private_ops = {
> +	.ndo_open = dpa_eth_priv_start,
> +	.ndo_start_xmit = dpa_tx,
> +	.ndo_stop = dpa_eth_priv_stop,
> +	.ndo_tx_timeout = dpa_timeout,
> +	.ndo_get_stats64 = dpa_get_stats64,
> +	.ndo_set_mac_address = dpa_set_mac_address,
> +	.ndo_validate_addr = eth_validate_addr,
> +	.ndo_change_mtu = dpa_change_mtu,
> +	.ndo_set_rx_mode = dpa_set_rx_mode,
> +	.ndo_init = dpa_ndo_init,
> +	.ndo_set_features = dpa_set_features,
> +	.ndo_fix_features = dpa_fix_features,
> +};
> +
> +static int dpa_private_napi_add(struct net_device *net_dev)
> +{
> +	struct dpa_priv_s *priv = netdev_priv(net_dev);
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int i, cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		percpu_priv = per_cpu_ptr(priv->percpu_priv, cpu);
> +
> +		percpu_priv->np = devm_kzalloc(net_dev->dev.parent,
> +			qman_portal_max * sizeof(struct dpa_napi_portal),
> +			GFP_KERNEL);
> +
> +		if (unlikely(!percpu_priv->np))
> +			return -ENOMEM;
> +
> +		for (i = 0; i < qman_portal_max; i++)
> +			netif_napi_add(net_dev, &percpu_priv->np[i].napi,
> +				       dpaa_eth_poll, DPA_NAPI_WEIGHT);
> +	}
> +
> +	return 0;
> +}
> +
> +void dpa_private_napi_del(struct net_device *net_dev)
> +{
> +	struct dpa_priv_s *priv = netdev_priv(net_dev);
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int i, cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		percpu_priv = per_cpu_ptr(priv->percpu_priv, cpu);
> +
> +		if (percpu_priv->np) {
> +			for (i = 0; i < qman_portal_max; i++)
> +				netif_napi_del(&percpu_priv->np[i].napi);
> +
> +			devm_kfree(net_dev->dev.parent, percpu_priv->np);
> +		}
> +	}
> +}
> +
> +static int dpa_private_netdev_init(struct net_device *net_dev)
> +{
> +	int i;
> +	struct dpa_priv_s *priv = netdev_priv(net_dev);
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	const u8 *mac_addr;
> +
> +	/* Although we access another CPU's private data here
> +	 * we do it at initialization so it is safe
> +	 */
> +	for_each_possible_cpu(i) {
> +		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
> +		percpu_priv->net_dev = net_dev;
> +	}
> +
> +	net_dev->netdev_ops = &dpa_private_ops;
> +	mac_addr = priv->mac_dev->addr;
> +
> +	net_dev->mem_start = priv->mac_dev->res->start;
> +	net_dev->mem_end = priv->mac_dev->res->end;
> +
> +	net_dev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_LLTX);
> +
> +	net_dev->features |= NETIF_F_GSO;
> +
> +	return dpa_netdev_init(net_dev, mac_addr, tx_timeout);
> +}
> +
> +static struct dpa_bp * __cold
> +dpa_priv_bp_probe(struct device *dev)
> +{
> +	struct dpa_bp *dpa_bp;
> +
> +	dpa_bp = devm_kzalloc(dev, sizeof(*dpa_bp), GFP_KERNEL);
> +	if (unlikely(!dpa_bp))
> +		return ERR_PTR(-ENOMEM);
> +
> +	dpa_bp->percpu_count = devm_alloc_percpu(dev, *dpa_bp->percpu_count);
> +	dpa_bp->target_count = FSL_DPAA_ETH_MAX_BUF_COUNT;
> +
> +	dpa_bp->seed_cb = dpa_bp_priv_seed;
> +	dpa_bp->free_buf_cb = _dpa_bp_free_pf;
> +
> +	return dpa_bp;
> +}
> +
> +/* Place all ingress FQs (Rx Default, Rx Error) in a dedicated CGR.
> + * We won't be sending congestion notifications to FMan; for now, we just use
> + * this CGR to generate enqueue rejections to FMan in order to drop the frames
> + * before they reach our ingress queues and eat up memory.
> + */
> +static int dpaa_eth_priv_ingress_cgr_init(struct dpa_priv_s *priv)
> +{
> +	struct qm_mcc_initcgr initcgr;
> +	u32 cs_th;
> +	int err;
> +
> +	err = qman_alloc_cgrid(&priv->ingress_cgr.cgrid);
> +	if (err < 0) {
> +		pr_err("Error %d allocating CGR ID\n", err);
> +		goto out_error;
> +	}
> +
> +	/* Enable CS TD, but disable Congestion State Change Notifications. */
> +	initcgr.we_mask = QM_CGR_WE_CS_THRES;
> +	initcgr.cgr.cscn_en = QM_CGR_EN;
> +	cs_th = CONFIG_FSL_DPAA_INGRESS_CS_THRESHOLD;
> +	qm_cgr_cs_thres_set64(&initcgr.cgr.cs_thres, cs_th, 1);
> +
> +	initcgr.we_mask |= QM_CGR_WE_CSTD_EN;
> +	initcgr.cgr.cstd_en = QM_CGR_EN;
> +
> +	/* This is actually a hack, because this CGR will be associated with
> +	 * our affine SWP. However, we'll place our ingress FQs in it.
> +	 */
> +	err = qman_create_cgr(&priv->ingress_cgr, QMAN_CGR_FLAG_USE_INIT,
> +			      &initcgr);
> +	if (err < 0) {
> +		pr_err("Error %d creating ingress CGR with ID %d\n", err,
> +		       priv->ingress_cgr.cgrid);
> +		qman_release_cgrid(priv->ingress_cgr.cgrid);
> +		goto out_error;
> +	}
> +	pr_debug("Created ingress CGR %d for netdev with hwaddr %pM\n",
> +		 priv->ingress_cgr.cgrid, priv->mac_dev->addr);
> +
> +	/* struct qman_cgr allows special cgrid values (i.e. outside the 0..255
> +	 * range), but we have no common initialization path between the
> +	 * different variants of the DPAA Eth driver, so we do it here rather
> +	 * than modifying every other variant than "private Eth".
> +	 */
> +	priv->use_ingress_cgr = true;
> +
> +out_error:
> +	return err;
> +}
> +
> +static int dpa_priv_bp_create(struct net_device *net_dev, struct dpa_bp *dpa_bp,
> +			      size_t count)
> +{
> +	struct dpa_priv_s *priv = netdev_priv(net_dev);
> +	int i;
> +
> +	netif_dbg(priv, probe, net_dev,
> +		  "Using private BM buffer pools\n");
> +
> +	priv->bp_count = count;
> +
> +	for (i = 0; i < count; i++) {
> +		int err;
> +
> +		err = dpa_bp_alloc(&dpa_bp[i]);
> +		if (err < 0) {
> +			dpa_bp_free(priv);
> +			priv->dpa_bp = NULL;
> +			return err;
> +		}
> +
> +		priv->dpa_bp = &dpa_bp[i];
> +	}
> +
> +	dpa_priv_common_bpid = priv->dpa_bp->bpid;
> +	return 0;
> +}
> +
> +static const struct of_device_id dpa_match[];
> +
> +static int
> +dpaa_eth_priv_probe(struct platform_device *pdev)
> +{
> +	int err = 0, i, channel;
> +	struct device *dev;
> +	struct dpa_bp *dpa_bp;
> +	struct dpa_fq *dpa_fq, *tmp;
> +	size_t count = 1;
> +	struct net_device *net_dev = NULL;
> +	struct dpa_priv_s *priv = NULL;
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	struct fm_port_fqs port_fqs;
> +	struct dpa_buffer_layout_s *buf_layout = NULL;
> +	struct mac_device *mac_dev;
> +	struct task_struct *kth;
> +
> +	dev = &pdev->dev;
> +
> +	/* Get the buffer pool assigned to this interface;
> +	 * run only once the default pool probing code
> +	 */
> +	dpa_bp = (dpa_bpid2pool(dpa_priv_common_bpid)) ? :
> +			dpa_priv_bp_probe(dev);
> +	if (IS_ERR(dpa_bp))
> +		return PTR_ERR(dpa_bp);
> +
> +	/* Allocate this early, so we can store relevant information in
> +	 * the private area
> +	 */
> +	net_dev = alloc_etherdev_mq(sizeof(*priv), DPAA_ETH_TX_QUEUES);
> +	if (!net_dev) {
> +		dev_err(dev, "alloc_etherdev_mq() failed\n");
> +		goto alloc_etherdev_mq_failed;
> +	}
> +
> +	snprintf(net_dev->name, IFNAMSIZ, "fm%d-mac%d",
> +		 dpa_mac_fman_index_get(pdev),
> +		 dpa_mac_hw_index_get(pdev));

Still think the driver should not set I/F name, this is best left to
udev or similar. 

 Jocke