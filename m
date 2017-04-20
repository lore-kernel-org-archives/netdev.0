From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v2 2/5] virtio-net: transmit napi
Date: Thu, 20 Apr 2017 12:02:45 -0400
Message-ID: <CAF=yD-KzHo1jVugrZKq_CmyrsqCR1zmM4Jo12OjacreKm74P8w@mail.gmail.com>
References: <20170418202108.61920-1-willemdebruijn.kernel@gmail.com>
 <20170418202108.61920-3-willemdebruijn.kernel@gmail.com> <9f57a790-9157-db4d-621d-cf359c8f0718@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34326 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032994AbdDTQDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 12:03:32 -0400
Received: by mail-qk0-f195.google.com with SMTP id d80so3484660qke.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 09:03:31 -0700 (PDT)
In-Reply-To: <9f57a790-9157-db4d-621d-cf359c8f0718@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>   static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>>   {
>>         struct virtio_net_hdr_mrg_rxbuf *hdr;
>> @@ -1130,9 +1172,11 @@ static netdev_tx_t start_xmit(struct sk_buff *skb,
>> struct net_device *dev)
>>         int err;
>>         struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
>>         bool kick = !skb->xmit_more;
>> +       bool use_napi = sq->napi.weight;
>>         /* Free up any pending old buffers before queueing new ones. */
>> -       free_old_xmit_skbs(sq);
>> +       if (!use_napi)
>> +               free_old_xmit_skbs(sq);
>
>
> I'm not sure this is best or even correct. Consider we clean xmit packets
> speculatively in virtnet_poll_tx(), we need call free_old_xmit_skbs()
> unconditionally. This can also help to reduce the possible of napi
> rescheduling in virtnet_poll_tx().

Because of the use of trylock there. Absolutely, thanks! Perhaps I should
only use trylock in the opportunistic clean path from the rx softirq and
full locking in the tx softirq.

I previously observed that cleaning here would, counterintuitively,
reduce efficiency. It reverted the improvements of cleaning transmit
completions from the receive softirq. Going through my data, I did
not observe this regression anymore on the latest patchset.

Let me test again, with and without the new
virtqueue_enable_cb_delayed patch. Perhaps that made a
difference.
