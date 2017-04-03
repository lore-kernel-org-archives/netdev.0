From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 3/3] virtio-net: clean tx descriptors from rx napi
Date: Mon, 3 Apr 2017 01:02:13 -0400
Message-ID: <CAF=yD-+tJxqvwvLU81=H7nwqDtiSWfAv8UdfncjPQiuNteJ6jQ@mail.gmail.com>
References: <20170402201012.76473-1-willemdebruijn.kernel@gmail.com>
 <20170402201012.76473-4-willemdebruijn.kernel@gmail.com> <20170403024751.GA21883@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34555 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdDCFCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 01:02:55 -0400
Received: by mail-qt0-f195.google.com with SMTP id x35so17479241qtc.1
        for <netdev@vger.kernel.org>; Sun, 02 Apr 2017 22:02:54 -0700 (PDT)
In-Reply-To: <20170403024751.GA21883@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 2, 2017 at 10:47 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Sun, Apr 02, 2017 at 04:10:12PM -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Amortize the cost of virtual interrupts by doing both rx and tx work
>> on reception of a receive interrupt if tx napi is enabled. With
>> VIRTIO_F_EVENT_IDX, this suppresses most explicit tx completion
>> interrupts for bidirectional workloads.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>>  drivers/net/virtio_net.c | 22 ++++++++++++++++++++++
>>  1 file changed, 22 insertions(+)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 95d938e82080..af830eb212bf 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1030,12 +1030,34 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
>>       return received;
>>  }
>>
>> +static void free_old_xmit_skbs(struct send_queue *sq);
>> +
>
> Could you pls re-arrange code to avoid forward declarations?

Okay. I'll do the move in a separate patch to simplify review.

>> +static void virtnet_poll_cleantx(struct receive_queue *rq)
>> +{
>> +     struct virtnet_info *vi = rq->vq->vdev->priv;
>> +     unsigned int index = vq2rxq(rq->vq);
>> +     struct send_queue *sq = &vi->sq[index];
>> +     struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, index);
>> +
>> +     if (!sq->napi.weight)
>> +             return;
>> +
>> +     __netif_tx_lock(txq, smp_processor_id());
>> +     free_old_xmit_skbs(sq);
>> +     __netif_tx_unlock(txq);
>> +
>> +     if (sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
>> +             netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
>> +}
>> +
>
> Looks very similar to virtnet_poll_tx.
>
> I think this might be waking the tx queue too early, so
> it will tend to stay almost full for long periods of time.
> Why not defer wakeup until queue is at least half empty?

I'll test that. Delaying wake-up longer than necessary can cause
queue build up at the qdisc and higher tail latency, I imagine. But
it may reduce the number of __netif_schedule calls.

> I wonder whether it's worth it to handle very short queues
> correctly - they previously made very slow progress,
> not they are never woken up.
>
> I'm a bit concerned about the cost of these wakeups
> and locking. I note that this wake is called basically
> every time queue is not full.
>
> Would it make sense to limit the amount of tx polling?
> Maybe use trylock to reduce the conflict with xmit?

Yes, that sounds good. I did test that previously and saw no
difference then. But when multiple cpus contend for a single
txq it should help.
