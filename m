From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 6/6] tilegx network driver: initial support
Date: Mon, 30 Apr 2012 14:35:08 +0000
Message-ID: <201204301435.08810.arnd@arndb.de>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204291856.q3TIusXq007168@farm-0027.internal.tilera.com> <201204291859.q3TIxIWB007275@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204291859.q3TIxIWB007275@farm-0027.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 06 April 2012, Chris Metcalf wrote:
> This change adds support for the tilegx network driver based on the
> GXIO IORPC support in the tilegx software stack, using the on-chip
> mPIPE packet processing engine.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

All my previous comments have been addressed. A few more details
that I noticed only now:


> +/* A mutex for "tile_net_devs_for_channel". */
> +static struct mutex tile_net_devs_for_channel_mutex;

static DEFINE_MUTEX()

> +/* The per-cpu info. */
> +static DEFINE_PER_CPU(struct tile_net_info, per_cpu_info);
> +
> +/* Access to "per_cpu_info". */
> +static struct tile_net_info *infos[NR_CPUS];

The arrays should not be needed. Using per_cpu() on the variable
in front of it does the same.

> +static int __init network_cpus_setup(char *str)
> +{
> +	int rc = cpulist_parse_crop(str, &network_cpus_map);
> +	if (rc != 0) {
> +		pr_warning("network_cpus=%s: malformed cpu list\n",
> +		       str);
> +	} else {
> +
> +		/* Remove dedicated cpus. */
> +		cpumask_and(&network_cpus_map, &network_cpus_map,
> +			    cpu_possible_mask);
> +
> +
> +		if (cpumask_empty(&network_cpus_map)) {
> +			pr_warning("Ignoring network_cpus='%s'.\n", str);
> +		} else {
> +			char buf[1024];
> +			cpulist_scnprintf(buf, sizeof(buf), &network_cpus_map);
> +			pr_info("Linux network CPUs: %s\n", buf);
> +			network_cpus_used = true;
> +		}
> +	}
> +
> +	return 0;
> +}
> +__setup("network_cpus=", network_cpus_setup);

In device drivers, use module_param() instead of __setup() so that you can
set the arguments on the kernel command line and using modprobe with the
same syntax.

> +/* This function takes "skb", consisting of a header template and a
> + * (presumably) huge payload, and egresses it as one or more segments
> + * (aka packets), each consisting of a (possibly modified) copy of the
> + * header plus a piece of the payload, via "tcp segmentation offload".
> + *
> + * Usually, "data" will contain the header template, of size "sh_len",
> + * and "sh->frags" will contain "skb->data_len" bytes of payload, and
> + * there will be "sh->gso_segs" segments.
> + *
> + * Sometimes, if "sendfile()" requires copying, we will be called with
> + * "data" containing the header and payload, with "frags" being empty.
> + *
> + * Sometimes, for example when using NFS over TCP, a single segment can
> + * span 3 fragments.  This requires special care below.
> + *
> + * See "emulate_large_send_offload()" for some reference code, which
> + * does not handle checksumming.
> + */
> +static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)
> +{

This function seems too long to be readable. I would suggest splitting
out some of the loop bodies in it into separate functions.

	Arnd
