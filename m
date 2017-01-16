From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v4 6/6] virtio_net: XDP support for adjust_head
Date: Mon, 16 Jan 2017 13:48:20 +0800
Message-ID: <f88378df-e24e-27f0-8a08-9ecc653e547d@redhat.com>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
 <20170116000142.28980.22658.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750862AbdAPFs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 00:48:26 -0500
In-Reply-To: <20170116000142.28980.22658.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月16日 08:01, John Fastabend wrote:
> Add support for XDP adjust head by allocating a 256B header region
> that XDP programs can grow into. This is only enabled when a XDP
> program is loaded.
>
> In order to ensure that we do not have to unwind queue headroom push
> queue setup below bpf_prog_add. It reads better to do a prog ref
> unwind vs another queue setup call.
>
> At the moment this code must do a full reset to ensure old buffers
> without headroom on program add or with headroom on program removal
> are not used incorrectly in the datapath. Ideally we would only
> have to disable/enable the RX queues being updated but there is no
> API to do this at the moment in virtio so use the big hammer. In
> practice it is likely not that big of a problem as this will only
> happen when XDP is enabled/disabled changing programs does not
> require the reset. There is some risk that the driver may either
> have an allocation failure or for some reason fail to correctly
> negotiate with the underlying backend in this case the driver will
> be left uninitialized. I have not seen this ever happen on my test
> systems and for what its worth this same failure case can occur
> from probe and other contexts in virtio framework.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   drivers/net/virtio_net.c |  110 ++++++++++++++++++++++++++++++++++------------
>   1 file changed, 82 insertions(+), 28 deletions(-)
>

[...]

> -	vi->xdp_queue_pairs = xdp_qp;
>   	netif_set_real_num_rx_queues(dev, curr_qp + xdp_qp);
>   
>   	for (i = 0; i < vi->max_queue_pairs; i++) {
> @@ -1746,6 +1789,21 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>   	}
>   
>   	return 0;
> +
> +virtio_reset_err:
> +	/* On reset error do our best to unwind XDP changes inflight and return
> +	 * error up to user space for resolution. The underlying PCI reset hung
> +	 * on us so not much we can do here.

It should work with other transport, so let's remove "PCI" here.

> +	 */
> +	dev_warn(&dev->dev, "XDP reset failure and queues unstable\n");
> +	vi->xdp_queue_pairs = oxdp_qp;
> +virtio_queue_err:
> +	/* On queue set error we can unwind bpf ref count and user space can
> +	 * retry this is most likely an allocation failure.
> +	 */
> +	if (prog)
> +		bpf_prog_sub(prog, vi->max_queue_pairs - 1);
> +	return err;
>   }
>   
>   static bool virtnet_xdp_query(struct net_device *dev)
> @@ -2373,7 +2431,6 @@ static void virtnet_remove(struct virtio_device *vdev)
>   	free_netdev(vi->dev);
>   }
>   
> -#ifdef CONFIG_PM_SLEEP
>   static int virtnet_freeze(struct virtio_device *vdev)
>   {
>   	struct virtnet_info *vi = vdev->priv;
> @@ -2430,7 +2487,6 @@ static int virtnet_restore(struct virtio_device *vdev)
>   
>   	return 0;
>   }
> -#endif

If you do want to use virtio_device_reset(), it's better to squash this 
into patch 5/6.

Other looks good.

Thanks
