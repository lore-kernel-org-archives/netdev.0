From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Fri, 3 Feb 2017 17:07:47 +0200
Message-ID: <20170203170512-mutt-send-email-mst@kernel.org>
References: <20170203061905.100283-1-serebrin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com, davem@davemloft.net,
        willemb@google.com, venkateshs@google.com, jmattson@google.com
To: Ben Serebrin <serebrin@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51920 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750808AbdBCPHt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 10:07:49 -0500
Content-Disposition: inline
In-Reply-To: <20170203061905.100283-1-serebrin@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 10:19:05PM -0800, Ben Serebrin wrote:
> From: Benjamin Serebrin <serebrin@google.com>
> 
> If the number of virtio queue pairs is not equal to the
> number of VCPUs, the virtio guest driver doesn't assign
> any CPU affinity for the queue interrupts or the xps
> aggregation interrupt.
> 
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
> 
> cd /proc/irq
> for i in `seq 24 92` ; do sudo grep ".*" $i/smp_affinity_list;  done
> 0-63
> [...]
> 0-63
> 
> and we see all TX queues' xps_cpus affinitzed to no cores:
> 
> for i in `seq 0 31` ; do sudo grep ".*" tx-$i/xps_cpus; done
> 00000000,00000000
> [...]
> 00000000,00000000
> 
> With the fix, we see each queue assigned to the a single core,
> and xps affinity set to 1 unique cpu per TX queue.
> 
> 64 VCPU:
> 
> cd /proc/irq
> for i in `seq 24 92` ; do sudo grep ".*" $i/smp_affinity_list;  done
> 
> 0-63
> 0
> 0
> 1
> 1
> 2
> 2
> 3
> 3
> 4
> 4
> 5
> 5
> 6
> 6
> 7
> 7
> 8
> 8
> 9
> 9
> 10
> 10
> 11
> 11
> 12
> 12
> 13
> 13
> 14
> 14
> 15
> 15
> 16
> 16
> 17
> 17
> 18
> 18
> 19
> 19
> 20
> 20
> 21
> 21
> 22
> 22
> 23
> 23
> 24
> 24
> 25
> 25
> 26
> 26
> 27
> 27
> 28
> 28
> 29
> 29
> 30
> 30
> 31
> 31
> 0-63
> 0-63
> 0-63
> 0-63
> 
> cd /sys/class/net/eth0/queues
> for i in `seq 0 31` ; do sudo grep ".*" tx-$i/xps_cpus;  done
> 
> 00000001,00000001
> 00000002,00000002
> 00000004,00000004
> 00000008,00000008
> 00000010,00000010
> 00000020,00000020
> 00000040,00000040
> 00000080,00000080
> 00000100,00000100
> 00000200,00000200
> 00000400,00000400
> 00000800,00000800
> 00001000,00001000
> 00002000,00002000
> 00004000,00004000
> 00008000,00008000
> 00010000,00010000
> 00020000,00020000
> 00040000,00040000
> 00080000,00080000
> 00100000,00100000
> 00200000,00200000
> 00400000,00400000
> 00800000,00800000
> 01000000,01000000
> 02000000,02000000
> 04000000,04000000
> 08000000,08000000
> 10000000,10000000
> 20000000,20000000
> 40000000,40000000
> 80000000,80000000
> 
> 48 VCPU:
> 
> cd /proc/irq
> for i in `seq 24 92` ; do sudo grep ".*" $i/smp_affinity_list;  done
> 0-47
> 0
> 0
> 1
> 1
> 2
> 2
> 3
> 3
> 4
> 4
> 5
> 5
> 6
> 6
> 7
> 7
> 8
> 8
> 9
> 9
> 10
> 10
> 11
> 11
> 12
> 12
> 13
> 13
> 14
> 14
> 15
> 15
> 16
> 16
> 17
> 17
> 18
> 18
> 19
> 19
> 20
> 20
> 21
> 21
> 22
> 22
> 23
> 23
> 24
> 24
> 25
> 25
> 26
> 26
> 27
> 27
> 28
> 28
> 29
> 29
> 30
> 30
> 31
> 31
> 0-47
> 0-47
> 0-47
> 0-47
> 
> cd /sys/class/net/eth0/queues
> for i in `seq 0 31` ; do sudo grep ".*" tx-$i/xps_cpus;  done
> 
> 0001,00000001
> 0002,00000002
> 0004,00000004
> 0008,00000008
> 0010,00000010
> 0020,00000020
> 0040,00000040
> 0080,00000080
> 0100,00000100
> 0200,00000200
> 0400,00000400
> 0800,00000800
> 1000,00001000
> 2000,00002000
> 4000,00004000
> 8000,00008000
> 0000,00010000
> 0000,00020000
> 0000,00040000
> 0000,00080000
> 0000,00100000
> 0000,00200000
> 0000,00400000
> 0000,00800000
> 0000,01000000
> 0000,02000000
> 0000,04000000
> 0000,08000000
> 0000,10000000
> 0000,20000000
> 0000,40000000
> 0000,80000000
> 
> Signed-off-by: Ben Serebrin <serebrin@google.com>
> Acked-by: Willem de Bruijn <willemb@google.com>
> Acked-by: Jim Mattson <jmattson@google.com>
> Acked-by: Venkatesh Srinivas <venkateshs@google.com>

I wonder why not just do it in userspace though.
It would be nice to mention this in the commit log.
Are we sure this distribution is best for all workloads?
While irqbalancer is hardly a perfect oracle it does
manage to balance the load somewhat, and IIUC kernel
affinities would break that.
Thoughts?


> Effort: kvm
> ---
>  drivers/net/virtio_net.c | 30 +++++++++++++++++++++++++++---
>  1 file changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 765c2d6358da..0dc3a102bfc4 100644
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
