From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next RFC 4/4] virtio-net: clean tx descriptors from rx napi
Date: Mon, 6 Mar 2017 13:04:47 -0500
Message-ID: <CAF=yD-JHLjLY0x1i8Yz00GKyGbpNrye9zuLsCfqqO07F_WJeHw@mail.gmail.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-5-willemdebruijn.kernel@gmail.com> <b92b1e1f-d55d-c346-41a9-9abdb075cc5b@redhat.com>
 <CAF=yD-Lf3EtRptsL=qFnPV5jBiBTP9CFvfF0Xaatv6-PTiVy4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:33507 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752907AbdCFSGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 13:06:18 -0500
Received: by mail-wr0-f170.google.com with SMTP id u48so122563885wrc.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 10:05:29 -0800 (PST)
In-Reply-To: <CAF=yD-Lf3EtRptsL=qFnPV5jBiBTP9CFvfF0Xaatv6-PTiVy4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 6, 2017 at 12:43 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>>> +static void virtnet_poll_cleantx(struct receive_queue *rq)
>>> +{
>>> +       struct virtnet_info *vi = rq->vq->vdev->priv;
>>> +       unsigned int index = vq2rxq(rq->vq);
>>> +       struct send_queue *sq = &vi->sq[index];
>>> +       struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, index);
>>> +
>>> +       __netif_tx_lock(txq, smp_processor_id());
>>> +       free_old_xmit_skbs(sq, sq->napi.weight);
>>> +       __netif_tx_unlock(txq);
>>
>>
>> Should we check tx napi weight here? Or this was treated as an independent
>> optimization?
>
> Good point. This was not intended to run in no-napi mode as is.
> With interrupts disabled most of the time in that mode, I don't
> expect it to be worthwhile using in that case. I'll add the check
> for sq->napi.weight != 0.

I'm wrong here. Rx interrupts are not disabled, of course. It is
probably worth benchmarking, then.
