From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] [ver3 PATCH 3/6] virtio_net: virtio_net driver changes
Date: Fri, 18 Nov 2011 01:08:08 +0000
Message-ID: <1321578488.2749.66.camel@bwh-desktop>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
	 <20111111130420.9878.19729.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <rusty@rustcorp.com.au>, <mst@redhat.com>,
	<netdev@vger.kernel.org>, <kvm@vger.kernel.org>,
	<davem@davemloft.net>, <virtualization@lists.linux-foundation.org>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111111130420.9878.19729.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-11-11 at 18:34 +0530, Krishna Kumar wrote:
> Changes for multiqueue virtio_net driver.
[...]
> @@ -677,25 +730,35 @@ static struct rtnl_link_stats64 *virtnet
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	int cpu;
> -	unsigned int start;
>  
>  	for_each_possible_cpu(cpu) {
> -		struct virtnet_stats __percpu *stats
> -			= per_cpu_ptr(vi->stats, cpu);
> -		u64 tpackets, tbytes, rpackets, rbytes;
> -
> -		do {
> -			start = u64_stats_fetch_begin(&stats->syncp);
> -			tpackets = stats->tx_packets;
> -			tbytes   = stats->tx_bytes;
> -			rpackets = stats->rx_packets;
> -			rbytes   = stats->rx_bytes;
> -		} while (u64_stats_fetch_retry(&stats->syncp, start));
> -
> -		tot->rx_packets += rpackets;
> -		tot->tx_packets += tpackets;
> -		tot->rx_bytes   += rbytes;
> -		tot->tx_bytes   += tbytes;
> +		int qpair;
> +
> +		for (qpair = 0; qpair < vi->num_queue_pairs; qpair++) {
> +			struct virtnet_send_stats __percpu *tx_stat;
> +			struct virtnet_recv_stats __percpu *rx_stat;

While you're at it, you can drop the per-CPU stats and make them only
per-queue.  There is unlikely to be any benefit in maintaining them
per-CPU while receive and transmit processing is serialised per-queue.

[...]
> +static int invoke_find_vqs(struct virtnet_info *vi)
> +{
> +	vq_callback_t **callbacks;
> +	struct virtqueue **vqs;
> +	int ret = -ENOMEM;
> +	int i, total_vqs;
> +	char **names;
> +
> +	/*
> +	 * We expect 1 RX virtqueue followed by 1 TX virtqueue, followed
> +	 * by the same 'vi->num_queue_pairs-1' more times, and optionally
> +	 * one control virtqueue.
> +	 */
> +	total_vqs = vi->num_queue_pairs * 2 +
> +		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
> +
> +	/* Allocate space for find_vqs parameters */
> +	vqs = kmalloc(total_vqs * sizeof(*vqs), GFP_KERNEL);
> +	callbacks = kmalloc(total_vqs * sizeof(*callbacks), GFP_KERNEL);
> +	names = kmalloc(total_vqs * sizeof(*names), GFP_KERNEL);
> +	if (!vqs || !callbacks || !names)
> +		goto err;
> +
> +	/* Allocate/initialize parameters for recv virtqueues */
> +	for (i = 0; i < vi->num_queue_pairs * 2; i += 2) {
> +		callbacks[i] = skb_recv_done;
> +		names[i] = kasprintf(GFP_KERNEL, "input.%d", i / 2);
> +		if (!names[i])
> +			goto err;
> +	}
> +
> +	/* Allocate/initialize parameters for send virtqueues */
> +	for (i = 1; i < vi->num_queue_pairs * 2; i += 2) {
> +		callbacks[i] = skb_xmit_done;
> +		names[i] = kasprintf(GFP_KERNEL, "output.%d", i / 2);
> +		if (!names[i])
> +			goto err;
> +	}
[...]

The RX and TX interrupt names for a multiqueue device should follow the
formats "<device>-rx-<index>" and "<device>-tx-<index>".

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

