From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] virtio_net: XDP support for adjust_head
Date: Wed, 4 Jan 2017 10:58:39 -0800
Message-ID: <586D45DF.401@gmail.com>
References: <20170102194413.9089.39078.stgit@john-Precision-Tower-5810>
 <73715f7a-eeeb-679f-a7b8-7b1fefe1757e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32896 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934137AbdADS6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:58:55 -0500
Received: by mail-pf0-f194.google.com with SMTP id 127so17411790pfg.0
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 10:58:54 -0800 (PST)
In-Reply-To: <73715f7a-eeeb-679f-a7b8-7b1fefe1757e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

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

Alternatively moving the pull into the receive_small XDP handler also
removes the special case. I'll submit a patch shortly let me know what
you think.

>>           return XDP_PASS;
>>       case XDP_TX:
>>           qp = vi->curr_queue_pairs -
>>               vi->xdp_queue_pairs +
>>               smp_processor_id();
> 
> [...]
> 

.John
