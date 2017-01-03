From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Tue, 3 Jan 2017 08:54:12 -0800
Message-ID: <586BD734.7020105@gmail.com>
References: <20170102194413.9089.39078.stgit@john-Precision-Tower-5810>
 <73715f7a-eeeb-679f-a7b8-7b1fefe1757e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33417 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752949AbdACQ4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:56:08 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so15934695pfg.0
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 08:54:29 -0800 (PST)
In-Reply-To: <73715f7a-eeeb-679f-a7b8-7b1fefe1757e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-02 10:01 PM, Jason Wang wrote:
> 
> 
> On 2017年01月03日 03:44, John Fastabend wrote:
>> Add support for XDP adjust head by allocating a 256B header region
>> that XDP programs can grow into. This is only enabled when a XDP
>> program is loaded.
>>
>> In order to ensure that we do not have to unwind queue headroom push
>> queue setup below bpf_prog_add. It reads better to do a prog ref
>> unwind vs another queue setup call.
>>
>> : There is a problem with this patch as is. When xdp prog is loaded
>>    the old buffers without the 256B headers need to be flushed so that
>>    the bpf prog has the necessary headroom. This patch does this by
>>    calling the virtqueue_detach_unused_buf() and followed by the
>>    virtnet_set_queues() call to reinitialize the buffers. However I
>>    don't believe this is safe per comment in virtio_ring this API
>>    is not valid on an active queue and the only thing we have done
>>    here is napi_disable/napi_enable wrappers which doesn't do anything
>>    to the emulation layer.
>>
>>    So the RFC is really to find the best solution to this problem.
>>    A couple things come to mind, (a) always allocate the necessary
>>    headroom but this is a bit of a waste (b) add some bit somewhere
>>    to check if the buffer has headroom but this would mean XDP programs
>>    would be broke for a cycle through the ring, (c) figure out how
>>    to deactivate a queue, free the buffers and finally reallocate.
>>    I think (c) is the best choice for now but I'm not seeing the
>>    API to do this so virtio/qemu experts anyone know off-hand
>>    how to make this work? I started looking into the PCI callbacks
>>    reset() and virtio_device_ready() or possibly hitting the right
>>    set of bits with vp_set_status() but my first attempt just hung
>>    the device.
> 
> Hi John:
> 
> AFAIK, disabling a specific queue was supported only by virtio 1.0 through
> queue_enable field in pci common cfg. But unfortunately, qemu does not emulate
> this at all and legacy device does not even support this. So the safe way is
> probably reset the device and redo the initialization here.
> 

OK, I'll draft up a fix with a full reset unless Michael has some idea in
the meantime.

>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   drivers/net/virtio_net.c |  106 +++++++++++++++++++++++++++++++++++-----------
>>   1 file changed, 80 insertions(+), 26 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 5deeda6..fcc5bd7 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -159,6 +159,9 @@ struct virtnet_info {
>>       /* Ethtool settings */
>>       u8 duplex;
>>       u32 speed;
>> +
>> +    /* Headroom allocated in RX Queue */
>> +    unsigned int headroom;
>>   };
>>     struct padded_vnet_hdr {
>> @@ -355,6 +358,7 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
>>       }
>>         if (vi->mergeable_rx_bufs) {
>> +        xdp->data -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
>>           /* Zero header and leave csum up to XDP layers */
>>           hdr = xdp->data;
>>           memset(hdr, 0, vi->hdr_len);
>> @@ -371,7 +375,7 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
>>           num_sg = 2;
>>           sg_init_table(sq->sg, 2);
>>           sg_set_buf(sq->sg, hdr, vi->hdr_len);
>> -        skb_to_sgvec(skb, sq->sg + 1, 0, skb->len);
>> +        skb_to_sgvec(skb, sq->sg + 1, vi->headroom, xdp->data_end - xdp->data);
> 
> vi->headroom look suspicious, should it be xdp->data - xdp->data_hard_start?
> 

Yep found this as well while testing small packet receive.

>>       }
>>       err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
>>                      data, GFP_ATOMIC);
>> @@ -393,34 +397,39 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
>>                  struct bpf_prog *xdp_prog,
>>                  void *data, int len)
>>   {
>> -    int hdr_padded_len;
>>       struct xdp_buff xdp;
>> -    void *buf;
>>       unsigned int qp;
>>       u32 act;
>>   +
>>       if (vi->mergeable_rx_bufs) {
>> -        hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
>> -        xdp.data = data + hdr_padded_len;
>> +        int desc_room = sizeof(struct virtio_net_hdr_mrg_rxbuf);
>> +
>> +        /* Allow consuming headroom but reserve enough space to push
>> +         * the descriptor on if we get an XDP_TX return code.
>> +         */
>> +        xdp.data_hard_start = data - vi->headroom + desc_room;
>> +        xdp.data = data + desc_room;
>>           xdp.data_end = xdp.data + (len - vi->hdr_len);
>> -        buf = data;
>>       } else { /* small buffers */
>>           struct sk_buff *skb = data;
>>   -        xdp.data = skb->data;
>> +        xdp.data_hard_start = skb->data;
>> +        xdp.data = skb->data + vi->headroom;
>>           xdp.data_end = xdp.data + len;
>> -        buf = skb->data;
>>       }
>>         act = bpf_prog_run_xdp(xdp_prog, &xdp);
>>       switch (act) {
>>       case XDP_PASS:
>> +        if (!vi->mergeable_rx_bufs)
>> +            __skb_pull((struct sk_buff *) data,
>> +                   xdp.data - xdp.data_hard_start);
> 
> Instead of doing things here and virtnet_xdp_xmit(). How about always making
> skb->data point to the buffer head like:
> 
> 1) reserve headroom in add_recvbuf_small()
> 2) skb_push(xdp->data - xdp_data_hard_start, skb) if we detect xdp->data was
> modified afer bpf_prog_run_xdp()
> 
> Then there's no special code in either XDP_PASS or XDP_TX?
> 

Sure. Works for me and avoids if/else code.

>>           return XDP_PASS;
>>       case XDP_TX:
>>           qp = vi->curr_queue_pairs -
>>               vi->xdp_queue_pairs +
>>               smp_processor_id();
> 
> [...]
> 
>> +#define VIRTIO_XDP_HEADROOM 256
>> +
>>   static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>>   {
>>       unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
>>       struct virtnet_info *vi = netdev_priv(dev);
>>       struct bpf_prog *old_prog;
>>       u16 xdp_qp = 0, curr_qp;
>> +    unsigned int old_hr;
>>       int i, err;
>>         if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>> @@ -1736,19 +1751,58 @@ static int virtnet_xdp_set(struct net_device *dev,
>> struct bpf_prog *prog)
>>           return -ENOMEM;
>>       }
>>   +    old_hr = vi->headroom;
>> +    if (prog) {
>> +        prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
>> +        if (IS_ERR(prog))
>> +            return PTR_ERR(prog);
>> +        vi->headroom = VIRTIO_XDP_HEADROOM;
>> +    } else {
>> +        vi->headroom = 0;
>> +    }
>> +
>> +    /* Changing the headroom in buffers is a disruptive operation because
>> +     * existing buffers must be flushed and reallocated. This will happen
>> +     * when a xdp program is initially added or xdp is disabled by removing
>> +     * the xdp program.
>> +     */
> 
> We probably need reset the device here, but maybe Michale has more ideas. And if
> we do this, another interesting thing to do is to disable EWMA and always use a
> single page for each packet, this could almost eliminate linearizing.

Well with normal MTU 1500 size we should not hit the linearizing case right? The
question is should we cap the MTU at GOOD_PACKET_LEN vs the current cap of
(PAGE_SIZE - overhead).

> 
> Thanks
