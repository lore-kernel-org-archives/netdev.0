From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v6 0/5] XDP for virtio_net
Date: Fri, 16 Dec 2016 01:17:44 +0200
Message-ID: <20161216011620-mutt-send-email-mst@kernel.org>
References: <20161215200712.23639.53043.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37288 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754412AbcLOXRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 18:17:46 -0500
Content-Disposition: inline
In-Reply-To: <20161215200712.23639.53043.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 12:12:04PM -0800, John Fastabend wrote:
> This implements virtio_net for the mergeable buffers and big_packet
> modes. I tested this with vhost_net running on qemu and did not see
> any issues. For testing num_buf > 1 I added a hack to vhost driver
> to only but 100 bytes per buffer.
> 
> There are some restrictions for XDP to be enabled and work well
> (see patch 3) for more details.
> 
>   1. GUEST_TSO{4|6} must be off
>   2. MTU must be less than PAGE_SIZE
>   3. queues must be available to dedicate to XDP
>   4. num_bufs received in mergeable buffers must be 1
>   5. big_packet mode must have all data on single page
> 
> To test this I used pktgen in the hypervisor and ran the XDP sample
> programs xdp1 and xdp2 from ./samples/bpf in the host. The default
> mode that is used with these patches with Linux guest and QEMU/Linux
> hypervisor is the mergeable buffers mode. I tested this mode for 2+
> days running xdp2 without issues. Additionally I did a series of
> driver unload/load tests to check the allocate/release paths.
> 
> To test the big_packets path I applied the following simple patch against
> the virtio driver forcing big_packets mode,
> 
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -2242,7 +2242,7 @@ static int virtnet_probe(struct virtio_device *vdev)
>                 vi->big_packets = true;
>  
>         if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
> -               vi->mergeable_rx_bufs = true;
> +               vi->mergeable_rx_bufs = false;
>  
>         if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||
>             virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
> 
> I then repeated the tests with xdp1 and xdp2. After letting them run
> for a few hours I called it good enough.
> 
> Testing the unexpected case where virtio receives a packet across
> multiple buffers required patching the hypervisor vhost driver to
> convince it to send these unexpected packets. Then I used ping with
> the -s option to trigger the case with multiple buffers. This mode
> is not expected to be used but as MST pointed out per spec it is
> not strictly speaking illegal to generate multi-buffer packets so we
> need someway to handle these. The following patch can be used to
> generate multiple buffers,
> 
> 
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1777,7 +1777,8 @@ static int translate_desc(struct vhost_virtqueue
> *vq, u64
> 
>                 _iov = iov + ret;
>                 size = node->size - addr + node->start;
> -               _iov->iov_len = min((u64)len - s, size);
> +               printk("%s: build 100 length headers!\n", __func__);
> +               _iov->iov_len = min((u64)len - s, (u64)100);//size);
>                 _iov->iov_base = (void __user *)(unsigned long)
>                         (node->userspace_addr + addr - node->start);
>                 s += size;
> 
> The qemu command I most frequently used for testing (although I did test
> various other combinations of devices) is the following,
> 
>  ./x86_64-softmmu/qemu-system-x86_64              \
>     -hda /var/lib/libvirt/images/Fedora-test0.img \
>     -m 4096  -enable-kvm -smp 2                   \
>     -netdev tap,id=hn0,queues=4,vhost=on          \
>     -device virtio-net-pci,netdev=hn0,mq=on,vectors=9,guest_tso4=off,guest_tso6=off \
>     -serial stdio
> 
> The options 'guest_tso4=off,guest_tso6=off' are required because we
> do not support LRO with XDP at the moment.
> 
> Please review any comments/feedback welcome as always.
> 
> Thanks,
> John
> 
> ---

OK, I think we can queue this for -next.

It's fairly limited in the kind of hardware supported, we can and
probably should extend it further with time.

Acked-by: Michael S. Tsirkin <mst@redhat.com>


> John Fastabend (5):
>       net: xdp: add invalid buffer warning
>       virtio_net: Add XDP support
>       virtio_net: add dedicated XDP transmit queues
>       virtio_net: add XDP_TX support
>       virtio_net: xdp, add slowpath case for non contiguous buffers
> 
> 
>  drivers/net/virtio_net.c |  365 +++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/filter.h   |    1 
>  net/core/filter.c        |    6 +
>  3 files changed, 365 insertions(+), 7 deletions(-)
> 
> --
> Signature
