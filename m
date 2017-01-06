From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Fri, 6 Jan 2017 02:39:05 +0200
Message-ID: <20170106023825-mutt-send-email-mst@kernel.org>
References: <20170102194413.9089.39078.stgit@john-Precision-Tower-5810>
 <73715f7a-eeeb-679f-a7b8-7b1fefe1757e@redhat.com>
 <20170104001332-mutt-send-email-mst@kernel.org>
 <586ECF53.1070700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41370 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754921AbdAFAka (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 19:40:30 -0500
Content-Disposition: inline
In-Reply-To: <586ECF53.1070700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 05, 2017 at 02:57:23PM -0800, John Fastabend wrote:
> On 17-01-03 02:16 PM, Michael S. Tsirkin wrote:
> > On Tue, Jan 03, 2017 at 02:01:27PM +0800, Jason Wang wrote:
> >>
> >>
> >> On 2017年01月03日 03:44, John Fastabend wrote:
> >>> Add support for XDP adjust head by allocating a 256B header region
> >>> that XDP programs can grow into. This is only enabled when a XDP
> >>> program is loaded.
> >>>
> >>> In order to ensure that we do not have to unwind queue headroom push
> >>> queue setup below bpf_prog_add. It reads better to do a prog ref
> >>> unwind vs another queue setup call.
> >>>
> >>> : There is a problem with this patch as is. When xdp prog is loaded
> >>>    the old buffers without the 256B headers need to be flushed so that
> >>>    the bpf prog has the necessary headroom. This patch does this by
> >>>    calling the virtqueue_detach_unused_buf() and followed by the
> >>>    virtnet_set_queues() call to reinitialize the buffers. However I
> >>>    don't believe this is safe per comment in virtio_ring this API
> >>>    is not valid on an active queue and the only thing we have done
> >>>    here is napi_disable/napi_enable wrappers which doesn't do anything
> >>>    to the emulation layer.
> >>>
> >>>    So the RFC is really to find the best solution to this problem.
> >>>    A couple things come to mind, (a) always allocate the necessary
> >>>    headroom but this is a bit of a waste (b) add some bit somewhere
> >>>    to check if the buffer has headroom but this would mean XDP programs
> >>>    would be broke for a cycle through the ring, (c) figure out how
> >>>    to deactivate a queue, free the buffers and finally reallocate.
> >>>    I think (c) is the best choice for now but I'm not seeing the
> >>>    API to do this so virtio/qemu experts anyone know off-hand
> >>>    how to make this work? I started looking into the PCI callbacks
> >>>    reset() and virtio_device_ready() or possibly hitting the right
> >>>    set of bits with vp_set_status() but my first attempt just hung
> >>>    the device.
> >>
> >> Hi John:
> >>
> >> AFAIK, disabling a specific queue was supported only by virtio 1.0 through
> >> queue_enable field in pci common cfg.
> > 
> > In fact 1.0 only allows enabling queues selectively.
> > We can add disabling by a spec enhancement but
> > for now reset is the only way.
> > 
> > 
> >> But unfortunately, qemu does not
> >> emulate this at all and legacy device does not even support this. So the
> >> safe way is probably reset the device and redo the initialization here.
> > 
> > You will also have to re-apply rx filtering if you do this.
> > Probably sending notification uplink.
> > 
> 
> The following seems to hang the device on the next virtnet_send_command()
> I expected this to meet the reset requirements from the spec because I
> believe its the same flow coming out of restore(). For a real patch we
> don't actually need to kfree all the structs and reallocate them but
> I was expecting the below to work. Any ideas/hints?

Restore assumes device was previously reset.
You want to combine freeze+restore.

> static int virtnet_xdp_reset(struct virtnet_info *vi)
> {
>         int i, ret;
> 
>         netif_device_detach(vi->dev);
>         cancel_delayed_work_sync(&vi->refill);
>         if (netif_running(vi->dev)) {
>                 for (i = 0; i < vi->max_queue_pairs; i++)
>                         napi_disable(&vi->rq[i].napi);
>         }
> 
>         remove_vq_common(vi, false);
>         ret = init_vqs(vi);
>         if (ret)
>                 return ret;
>         virtio_device_ready(vi->vdev);
> 
>         if (netif_running(vi->dev)) {
>                 for (i = 0; i < vi->curr_queue_pairs; i++)
>                         if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
>                                 schedule_delayed_work(&vi->refill, 0);
> 
>                 for (i = 0; i < vi->max_queue_pairs; i++)
>                         virtnet_napi_enable(&vi->rq[i]);
>         }
>         netif_device_attach(vi->dev);
>         return 0;
> }
