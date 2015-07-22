From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Wed, 22 Jul 2015 10:37:45 -0700
Message-ID: <1437586665.20787.24.camel@perches.com>
References: <1437581806-17420-1-git-send-email-madalin.bucur@freescale.com>
	 <1437581806-17420-2-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	igal.liberman@freescale.com, ppc@mindchasers.com,
	pebolle@tiscali.nl, joakim.tjernlund@transmode.se
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437581806-17420-2-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-22 at 19:16 +0300, Madalin Bucur wrote:
> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.

trivia:

> +static void __hot _dpa_tx_conf(struct net_device	*net_dev,
> +			       const struct dpa_priv_s	*priv,
> +			       struct dpa_percpu_priv_s	*percpu_priv,
> +			       const struct qm_fd	*fd,
> +			       u32			fqid)
> +{
[]
> +static struct dpa_bp * __cold
> +dpa_priv_bp_probe(struct device *dev)

Do the __hot and __cold markings really matter?
Some of them may be questionable.

> +static int __init dpa_load(void)
> +{
[]
> +	err = platform_driver_register(&dpa_driver);
> +	if (unlikely(err < 0)) {
> +		pr_err(KBUILD_MODNAME
> +			": %s:%hu:%s(): platform_driver_register() = %d\n",
> +			KBUILD_BASENAME ".c", __LINE__, __func__, err);
> +	}
> +
> +	pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
> +		 KBUILD_BASENAME ".c", __func__);

Perhaps these should use pr_fmt

> +static void __exit dpa_unload(void)
> +{
> +	pr_debug(KBUILD_MODNAME ": -> %s:%s()\n",
> +		 KBUILD_BASENAME ".c", __func__);

dynamic debug has __func__ available and perhaps
the function tracer might be used instead.

> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
[]
> +#define __hot

curious.

Maybe it'd be good to add a real __hot to compiler.h

> +struct dpa_buffer_layout_s {
> +	u16	priv_data_size;
> +	bool		parse_results;
> +	bool		time_stamp;
> +	bool		hash_results;
> +	u16	data_align;
> +};

> +struct dpa_fq {
> +	struct qman_fq		 fq_base;
> +	struct list_head	 list;
> +	struct net_device	*net_dev;

some inconsistent indentation here and there

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

Anonymous unions are relatively rare

> +	struct {
> +		/**

Maybe the /** style should be avoided

> +		 * All egress queues to a given net device belong to one
> +		 * (and the same) congestion group.
> +		 */
> +		struct qman_cgr cgr;
> +	} cgr_data;

[]

> +int dpa_stop(struct net_device *net_dev)
> +{
[]
> +	err = mac_dev->stop(mac_dev);
> +	if (unlikely(err < 0))
> +		netif_err(priv, ifdown, net_dev, "mac_dev->stop() = %d\n",
> +			  err);

Some of the likely/unlikely uses may not
be useful/necessary.
> +
> +	for_each_port_device(i, mac_dev->port_dev) {
> +		error = fm_port_disable(
> +				fm_port_drv_handle(mac_dev->port_dev[i]));
> +		err = error ? error : err;

		if (error)
			err = error;

is more obvious to me.
