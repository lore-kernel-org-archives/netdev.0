From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Mon, 2 Jan 2017 11:47:39 -0800
Message-ID: <586AAE5B.20708@gmail.com>
References: <20170102194413.9089.39078.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36497 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755492AbdABTrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 14:47:51 -0500
Received: by mail-pg0-f65.google.com with SMTP id n5so31228980pgh.3
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 11:47:51 -0800 (PST)
In-Reply-To: <20170102194413.9089.39078.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-02 11:44 AM, John Fastabend wrote:
> Add support for XDP adjust head by allocating a 256B header region
> that XDP programs can grow into. This is only enabled when a XDP
> program is loaded.
> 
> In order to ensure that we do not have to unwind queue headroom push
> queue setup below bpf_prog_add. It reads better to do a prog ref
> unwind vs another queue setup call.
> 
> : There is a problem with this patch as is. When xdp prog is loaded
>   the old buffers without the 256B headers need to be flushed so that
>   the bpf prog has the necessary headroom. This patch does this by
>   calling the virtqueue_detach_unused_buf() and followed by the
>   virtnet_set_queues() call to reinitialize the buffers. However I
>   don't believe this is safe per comment in virtio_ring this API
>   is not valid on an active queue and the only thing we have done
>   here is napi_disable/napi_enable wrappers which doesn't do anything
>   to the emulation layer.
> 
>   So the RFC is really to find the best solution to this problem.
>   A couple things come to mind, (a) always allocate the necessary
>   headroom but this is a bit of a waste (b) add some bit somewhere
>   to check if the buffer has headroom but this would mean XDP programs
>   would be broke for a cycle through the ring, (c) figure out how
>   to deactivate a queue, free the buffers and finally reallocate.
>   I think (c) is the best choice for now but I'm not seeing the
>   API to do this so virtio/qemu experts anyone know off-hand
>   how to make this work? I started looking into the PCI callbacks
>   reset() and virtio_device_ready() or possibly hitting the right
>   set of bits with vp_set_status() but my first attempt just hung
>   the device.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---


[...]

> +
> +	/* Changing the headroom in buffers is a disruptive operation because
> +	 * existing buffers must be flushed and reallocated. This will happen
> +	 * when a xdp program is initially added or xdp is disabled by removing
> +	 * the xdp program.
> +	 */
> +	if (old_hr != vi->headroom) {
> +		cancel_delayed_work_sync(&vi->refill);
> +		if (netif_running(vi->dev)) {
> +			for (i = 0; i < vi->max_queue_pairs; i++)
> +				napi_disable(&vi->rq[i].napi);
> +		}
> +		for (i = 0; i < vi->max_queue_pairs; i++) {
> +			struct virtqueue *vq = vi->rq[i].vq;
> +			void *buf;
> +
> +			while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Per API in virtio_ring.c queue must be deactivated to call this.


> +				if (vi->mergeable_rx_bufs) {
> +					unsigned long ctx = (unsigned long)buf;
> +					void *base = mergeable_ctx_to_buf_address(ctx);
> +					put_page(virt_to_head_page(base));
> +				} else if (vi->big_packets) {
> +					give_pages(&vi->rq[i], buf);
> +				} else {
> +					dev_kfree_skb(buf);
> +				}
> +			}
> +		}
> +		if (netif_running(vi->dev)) {
> +			for (i = 0; i < vi->max_queue_pairs; i++)
> +				virtnet_napi_enable(&vi->rq[i]);
> +		}
> +	}
> +

Hi Jason, Michael,

Any hints on how to solve the above kludge to flush the existing ring and
reallocate with correct headroom? The above doesn't look safe to me per commit
message.

Thanks!
John
