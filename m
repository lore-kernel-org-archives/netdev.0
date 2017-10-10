From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 0/3] tun zerocopy stats
Date: Tue, 10 Oct 2017 11:29:33 -0400
Message-ID: <CAF=yD-Jc_ikdYLydYwkw+h_+izVEg2Qp66=5+URokyqM=E=zJg@mail.gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com> <20171009.205228.714368596112967819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:56566 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932424AbdJJPaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 11:30:15 -0400
Received: by mail-oi0-f68.google.com with SMTP id v9so33609419oif.13
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 08:30:15 -0700 (PDT)
In-Reply-To: <20171009.205228.714368596112967819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 9, 2017 at 11:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Fri,  6 Oct 2017 18:25:13 -0400
>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Add zerocopy transfer statistics to the vhost_net/tun zerocopy path.
>>
>> I've been using this to verify recent changes to zerocopy tuning [1].
>> Sharing more widely, as it may be useful in similar future work.
>>
>> Use ethtool stats as interface, as these are defined per device
>> driver and can easily be extended.
>>
>> Make the zerocopy release callback take an extra hop through the tun
>> driver to allow the driver to increment its counters.
>>
>> Care must be taken to avoid adding an alloc/free to this hot path.
>> Since the caller already must allocate a ubuf_info, make it allocate
>> two at a time and grant one to the tun device.
>>
>>  1/3: introduce ethtool stats (`ethtool -S $DEV`) for tun devices
>>  2/3: add zerocopy tx and tx_err counters
>>  3/3: convert vhost_net to pass a pair of ubuf_info to tun
>>
>> [1] http://patchwork.ozlabs.org/patch/822613/
>
> This looks mostly fine to me, but I don't know enough about how vhost
> and tap interact to tell whether this makes sense to upstream.

Thanks for taking a look. The need for monitoring these stats has
come up in a couple of patch evaluation discussions, so I wanted
to share at least one implementation to get the data.

Because the choice to use zerocopy is based on heuristics and
there is a cost if it mispredicts, I think we even want to being able
to continuously monitor this in production.

The implementation is probably not ready for that as is.

> What are the runtime costs for these new statistics?

It currently doubles the size of the ubuf_info memory pool. That can be
fixed, as the current size is UIO_MAXIOV (1024), but the number of
zerocopy packets in flight is bound by VHOST_MAX_PEND (128).

It also adds an indirect function call to call to each zerocopy skb free
path, though.

If there is a way to expose these stats through vhost_net directly,
instead of through tun, that may be better. But I did not see a
suitable interface. Perhaps debugfs.
