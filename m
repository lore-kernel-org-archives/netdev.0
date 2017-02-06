From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Mon, 6 Feb 2017 15:24:37 +0800
Message-ID: <6af5d025-4b94-e3e2-1a98-efde69ec8be9@redhat.com>
References: <20170203061905.100283-1-serebrin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Ben Serebrin <serebrin@google.com>, netdev@vger.kernel.org,
        mst@redhat.com, davem@davemloft.net, willemb@google.com,
        venkateshs@google.com, jmattson@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750909AbdBFHYq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 02:24:46 -0500
In-Reply-To: <20170203061905.100283-1-serebrin@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年02月03日 14:19, Ben Serebrin wrote:
> From: Benjamin Serebrin <serebrin@google.com>
>
> If the number of virtio queue pairs is not equal to the
> number of VCPUs, the virtio guest driver doesn't assign
> any CPU affinity for the queue interrupts or the xps
> aggregation interrupt.

So this in fact is not a affinity fixing for #cpus > 32 but adding  
affinity for #cpus != #queue pairs.

> Google Compute Engine currently provides 1 queue pair for
> every VCPU, but limits that at a maximum of 32 queue pairs.
>
> This code assigns interrupt affinity even when there are more than
> 32 VCPUs.
>
> Tested:
>
> (on a 64-VCPU VM with debian 8, jessie-backports 4.9.2)
>
> Without the fix we see all queues affinitized to all CPUs:

[...]

>   
> +	/* If there are more cpus than queues, then assign the queues'
> +	 * interrupts to the first cpus until we run out.
> +	 */
>   	i = 0;
>   	for_each_online_cpu(cpu) {
> +		if (i == vi->max_queue_pairs)
> +			break;
>   		virtqueue_set_affinity(vi->rq[i].vq, cpu);
>   		virtqueue_set_affinity(vi->sq[i].vq, cpu);
> -		netif_set_xps_queue(vi->dev, cpumask_of(cpu), i);
>   		i++;
>   	}
>   
> +	/* Stripe the XPS affinities across the online CPUs.
> +	 * Hyperthread pairs are typically assigned such that Linux's
> +	 * CPU X and X + (numcpus / 2) are hyperthread twins, so we cause
> +	 * hyperthread twins to share TX queues, in the case where there are
> +	 * more cpus than queues.

Since we use combined queue pairs, why not use the same policy for RX?

Thanks

> +	 */
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
> +		struct cpumask mask;
> +		int skip = i;
> +
> +		cpumask_clear(&mask);
> +		for_each_online_cpu(cpu) {
> +			while (skip--)
> +				cpu = cpumask_next(cpu, cpu_online_mask);
> +			if (cpu < num_possible_cpus())
> +				cpumask_set_cpu(cpu, &mask);
> +			skip = vi->max_queue_pairs - 1;
> +		}
> +		netif_set_xps_queue(vi->dev, &mask, i);
> +	}
> +
>   	vi->affinity_hint_set = true;
>   }
>   
>
