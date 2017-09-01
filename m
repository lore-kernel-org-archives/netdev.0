From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Fri, 1 Sep 2017 12:17:08 -0400
Message-ID: <CAF=yD-LZ4Abn8CFSQyuNnYSRZkHx4FTzK4hSi9WQaHO-28rsHQ@mail.gmail.com>
References: <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
 <20170822204015-mutt-send-email-mst@kernel.org> <1503498504.8694.26.camel@klaipeden.com>
 <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
 <20170824014553-mutt-send-email-mst@kernel.org> <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
 <20170824160748-mutt-send-email-mst@kernel.org> <CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
 <20170824234551-mutt-send-email-mst@kernel.org> <CAF=yD-+1wheMmC+HFKe_B_ULO0Mmh6HMSEbYY5D-HgqxVJee6A@mail.gmail.com>
 <20170826022744-mutt-send-email-mst@kernel.org> <CAF=yD-Lre0NATUVH8p0zS=G5CiY=WfKSefLmOZw940jZFgECgQ@mail.gmail.com>
 <CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com>
 <CAF=yD-+AjQLLUKdvnrwd2tqFtw4Hm81cR7WUJd65oLnziNGM8A@mail.gmail.com>
 <5ef7fcf3-d4f0-be16-6ddb-724d954cfc68@redhat.com> <CAF=yD-JREJqpsRdCi31qo1QNFEE2DDCaTGYw1f1waPgtov8WEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Koichiro Den <den@klaipeden.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35495 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbdIAQRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:17:50 -0400
Received: by mail-oi0-f42.google.com with SMTP id n18so5763955oig.2
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 09:17:50 -0700 (PDT)
In-Reply-To: <CAF=yD-JREJqpsRdCi31qo1QNFEE2DDCaTGYw1f1waPgtov8WEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> This is not a 50/50 split, which impliesTw that some packets from the
>>> large
>>> packet flow are still converted to copying. Without the change the rate
>>> without queue was 80k zerocopy vs 80k copy, so this choice of
>>> (vq->num >> 2) appears too conservative.
>>>
>>> However, testing with (vq->num >> 1) was not as effective at mitigating
>>> stalls. I did not save that data, unfortunately. Can run more tests on
>>> fine
>>> tuning this variable, if the idea sounds good.
>>
>>
>> Looks like there're still two cases were left:
>
> To be clear, this patch is not intended to fix all issues. It is a small
> improvement to avoid HoL blocking due to queued zerocopy skbs.
>
> The trade-off is that reverting to copying in these cases increases
> cycle cost. I think that that is a trade-off worth making compared to
> the alternative drop in throughput. It probably would be good to be
> able to measure this without kernel instrumentation: export
> counters similar to net->tx_zcopy_err and net->tx_packets (though
> without reset to zero, as in vhost_net_tx_packet).
>
>> 1) sndbuf is not INT_MAX
>
> You mean the case where the device stalls, later zerocopy notifications
> are queued, but these are never cleaned in free_old_xmit_skbs,
> because it requires a start_xmit and by now the (only) socket is out of
> descriptors?

Typo, sorry. I meant out of sndbuf.

> A watchdog would help somewhat. With tx-napi, this case cannot occur,
> either, as free_old_xmit_skbs no longer depends on a call to start_xmit.
>
>> 2) tx napi is used for virtio-net
>
> I am not aware of any issue specific to the use of tx-napi?
>
>> 1) could be a corner case, and for 2) what your suggest here may not solve
>> the issue since it still do in order completion.
>
> Somewhat tangential, but it might also help to break the in-order
> completion processing in vhost_zerocopy_signal_used. Complete
> all descriptors between done_idx and upend_idx. done_idx should
> then only be forward to the oldest still not-completed descriptor.
>
> In the test I ran, where the oldest descriptors are held in a queue and
> all newer ones are tail-dropped, this would avoid blocking a full ring
> of completions, when only a small number (or 1) is actually delayed.
>
> Dynamic switching between copy and zerocopy using zcopy_used
> already returns completions out-of-order, so this is not a huge leap.
