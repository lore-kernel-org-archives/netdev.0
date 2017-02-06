From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Mon, 6 Feb 2017 11:06:36 +0100
Message-ID: <32571aa5-532c-6cda-b084-610f6b0fbc76@de.ibm.com>
References: <20170203061905.100283-1-serebrin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Ben Serebrin <serebrin@google.com>, netdev@vger.kernel.org,
        mst@redhat.com, jasowang@redhat.com, davem@davemloft.net,
        willemb@google.com, venkateshs@google.com, jmattson@google.com,
        linux-s390 <linux-s390@vger.kernel.org>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170203061905.100283-1-serebrin@google.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/2017 07:19 AM, Ben Serebrin wrote:
[...]
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1502,20 +1502,44 @@ static void virtnet_set_affinity(struct virtnet_info *vi)
>  	 * queue pairs, we let the queue pairs to be private to one cpu by
>  	 * setting the affinity hint to eliminate the contention.
>  	 */
> -	if (vi->curr_queue_pairs == 1 ||
> -	    vi->max_queue_pairs != num_online_cpus()) {
> +	if (vi->curr_queue_pairs == 1) {
>  		virtnet_clean_affinity(vi, -1);
>  		return;
>  	}
> 
> +	/* If there are more cpus than queues, then assign the queues'
> +	 * interrupts to the first cpus until we run out.
> +	 */
>  	i = 0;
>  	for_each_online_cpu(cpu) {
> +		if (i == vi->max_queue_pairs)
> +			break;
>  		virtqueue_set_affinity(vi->rq[i].vq, cpu);
>  		virtqueue_set_affinity(vi->sq[i].vq, cpu);
> -		netif_set_xps_queue(vi->dev, cpumask_of(cpu), i);
>  		i++;
>  	}
> 
> +	/* Stripe the XPS affinities across the online CPUs.
> +	 * Hyperthread pairs are typically assigned such that Linux's
> +	 * CPU X and X + (numcpus / 2) are hyperthread twins, so we cause
> +	 * hyperthread twins to share TX queues, in the case where there are
> +	 * more cpus than queues.
> +	 */

This is not always true. E.g. on s390 the SMT threads are usually paired even/odd.

e.g.

[cborntra@s38lp08 linux]$ lscpu -e
CPU NODE BOOK SOCKET CORE L1d:L1i:L2d:L2i ONLINE CONFIGURED POLARIZATION ADDRESS
0   0    0    0      0    0:0:0:0         yes    yes        horizontal   0
1   0    0    0      0    1:1:1:1         yes    yes        horizontal   1
2   0    0    0      1    2:2:2:2         yes    yes        horizontal   2
3   0    0    0      1    3:3:3:3         yes    yes        horizontal   3
4   0    0    0      2    4:4:4:4         yes    yes        horizontal   4
5   0    0    0      2    5:5:5:5         yes    yes        horizontal   5
6   0    0    0      3    6:6:6:6         yes    yes        horizontal   6

This does not matter yet for s390 (as virtio is usally doen via the ccw bus)
but maybe we should consider an future patch to provide some arch-specific
striping hints.

Or would it make sense to change the s390 layout for SMT twins because there
is more code that expects all threads 0 at the front and all threads 1 at the
end?


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
>  	vi->affinity_hint_set = true;
>  }
> 
> 
