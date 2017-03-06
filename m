From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next RFC 4/4] virtio-net: clean tx descriptors from rx napi
Date: Mon, 6 Mar 2017 12:43:10 -0500
Message-ID: <CAF=yD-Lf3EtRptsL=qFnPV5jBiBTP9CFvfF0Xaatv6-PTiVy4w@mail.gmail.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-5-willemdebruijn.kernel@gmail.com> <b92b1e1f-d55d-c346-41a9-9abdb075cc5b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35676 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753261AbdCFSNK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 13:13:10 -0500
Received: by mail-wm0-f46.google.com with SMTP id v186so70938386wmd.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 10:13:09 -0800 (PST)
In-Reply-To: <b92b1e1f-d55d-c346-41a9-9abdb075cc5b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +static void virtnet_poll_cleantx(struct receive_queue *rq)
>> +{
>> +       struct virtnet_info *vi = rq->vq->vdev->priv;
>> +       unsigned int index = vq2rxq(rq->vq);
>> +       struct send_queue *sq = &vi->sq[index];
>> +       struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, index);
>> +
>> +       __netif_tx_lock(txq, smp_processor_id());
>> +       free_old_xmit_skbs(sq, sq->napi.weight);
>> +       __netif_tx_unlock(txq);
>
>
> Should we check tx napi weight here? Or this was treated as an independent
> optimization?

Good point. This was not intended to run in no-napi mode as is.
With interrupts disabled most of the time in that mode, I don't
expect it to be worthwhile using in that case. I'll add the check
for sq->napi.weight != 0.

>> +
>> +       if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
>> +               netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
>> +}
>> +
>>   static int virtnet_poll(struct napi_struct *napi, int budget)
>>   {
>>         struct receive_queue *rq =
>> @@ -1039,6 +1056,8 @@ static int virtnet_poll(struct napi_struct *napi,
>> int budget)
>>         received = virtnet_receive(rq, budget);
>>   +     virtnet_poll_cleantx(rq);
>> +
>
>
> Better to do the before virtnet_receive() consider refill may allocate
> memory for rx buffers.

Will do.

> Btw, if this is proved to be more efficient. In the future we may consider
> to:
>
> 1) use a single interrupt for both rx and tx
> 2) use a single napi to handle both rx and tx

Agreed, I think that's sensible.
