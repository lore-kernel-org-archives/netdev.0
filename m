From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Wed, 7 Sep 2016 19:57:19 +0300
Message-ID: <CALzJLG9iVpS2qH5Ryc_DtEjrQMhcKD+qrLrGn=vet=_9N8eXPw@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-12-git-send-email-saeedm@mellanox.com> <1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com> <1473262379.10725.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36156 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933369AbcIGQ5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:57:47 -0400
Received: by mail-lf0-f54.google.com with SMTP id g62so2990118lfe.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 09:57:41 -0700 (PDT)
In-Reply-To: <1473262379.10725.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 6:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-09-07 at 18:08 +0300, Saeed Mahameed wrote:
>> On Wed, Sep 7, 2016 at 5:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Wed, 2016-09-07 at 15:42 +0300, Saeed Mahameed wrote:
>> >> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
>> >>
>> >> Here we introduce a xmit more like mechanism that will queue up more
>> >> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
>> >>
>> >> Once RX napi budget is consumed and we exit napi RX loop, we will
>> >> flush (doorbell) all XDP looped packets in case there are such.
>> >
>> > Why is this idea depends on XDP ?
>> >
>> > It looks like we could apply it to any driver having one IRQ servicing
>> > one RX and one TX, without XDP being involved.
>> >
>>
>> Yes but it is more complicated than XDP case, where the RX ring posts
>> the TX descriptors and once done
>> the RX ring hits the doorbell once for all the TX descriptors it
>> posted, and it is the only possible place to hit a doorbell
>> for XDP TX ring.
>>
>> For regular TX and RX ring sharing the same IRQ, there is no such
>> simple connection between them, and hitting a doorbell
>> from RX ring napi would race with xmit ndo function of the TX ring.
>>
>> How do you synchronize in such case ?
>> isn't the existing xmit more mechanism sufficient enough ?
>
> Only if a qdisc is present and pressure is high enough.
>
> But in a forwarding setup, we likely receive at a lower rate than the
> NIC can transmit.
>

Jesper has a similar Idea to make the qdisc think it is under
pressure, when the device
TX ring is idle most of the time, i think his idea can come in handy here.
I am not fully involved in the details, maybe he can elaborate more.

But if it works, it will be transparent to napi, and xmit more will
happen by design.

> A simple cmpxchg could be used to synchronize the thing, if we really
> cared about doorbell cost. (Ie if the cost of this cmpxchg() is way
> smaller than doorbell one)
>
