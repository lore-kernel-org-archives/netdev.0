From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH net-next V5 1/2] irq: Utility function to get affinity_hint
 by policy
Date: Tue, 11 Mar 2014 12:26:42 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403111018330.18573@ionos.tec.linutronix.de>
References: <1394523207-7338-1-git-send-email-amirv@mellanox.com> <1394523207-7338-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Govindarajulu Varadarajan <gvaradar@cisco.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394523207-7338-2-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Mar 2014, Amir Vadai wrote:
> +/**
> + * irq_set_mq_dev_affinit_hint - set affinity hint of a queue in multi queue
> + * device

The function is a complete misnomer. It calculates a cpu number and
sets that bit in the supplied cpumask. There is no connection to the
affinity hint at all. 

> + * @q: queue index number
> + * @numa_node: prefered numa_node
> + * @affinity_mask: the relevant cpu bit is set according to the policy
> + *
> + * This function sets the affinity_mask according to a numa aware policy.
> + * affinity_mask could be used as an affinity hint for the IRQ related to this
> + * queue.

So why is this not directly setting the affinity hint?

> + * The policy is to spread queues across cores - local cores first.
> + *
> + * Returns 0 on success, or a negative error code.

The ENOMEM error code is understandable, but what is the EINVAL for?

> + */
> +int irq_set_mq_dev_affinit_hint(int q, int numa_node,
> +				cpumask_t *affinity_mask)
> +{
> +	cpumask_var_t mask;
> +	int affinity_cpu;
> +	int ret = 0;
> +
> +	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	q %= num_online_cpus();
> +
> +	if (!cpumask_of_node(numa_node)) {
> +		cpumask_copy(mask, cpu_online_mask);
> +	} else {
> +		int n;
> +
> +		cpumask_and(mask,
> +			    cpumask_of_node(numa_node), cpu_online_mask);
> +
> +		n = cpumask_weight(mask);
> +		if (q >= n) {
> +			q -= n;
> +			cpumask_andnot(mask, cpu_online_mask, mask);
> +		}

This is completely uncommented magic hackery. What is this doing? And
what's the logic here?

If the node does not have enough cpus online to fulfill n > q then you
mask off all online cpus of that node from the online mask and use
some random cpu as target.

And this is true for every q which is larger/equal than the number of cpus
per node.

So lets assume 8 cpus per node and 16 online CPUs. Now you have a card
with 16 queues. So you want to put the first 8 on node 0 and the
second 8 on node 1.

For all q in 0..15

    q %= num_online_cpus() -> q

node 0, q 0  ->	 n = 8 -> cpu 0
node 0, q 1  ->	 n = 8 -> cpu 1
...
node 7, q 7  ->	 n = 8 -> cpu 7

So far so good. But

node 1, q 8  ->	 n = 8 -> cpu 0
node 1, q 9  ->	 n = 8 -> cpu 1
...
node 1, q 15 ->	 n = 8 -> cpu 7

I'm not so impressed by the node aware spread.

Thanks,

	tglx
