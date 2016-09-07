From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Wed, 07 Sep 2016 08:32:59 -0700
Message-ID: <1473262379.10725.42.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
         <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
         <1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
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
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35843 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcIGPdC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 11:33:02 -0400
Received: by mail-pf0-f177.google.com with SMTP id 128so7732506pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 08:33:02 -0700 (PDT)
In-Reply-To: <CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 18:08 +0300, Saeed Mahameed wrote:
> On Wed, Sep 7, 2016 at 5:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2016-09-07 at 15:42 +0300, Saeed Mahameed wrote:
> >> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
> >>
> >> Here we introduce a xmit more like mechanism that will queue up more
> >> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
> >>
> >> Once RX napi budget is consumed and we exit napi RX loop, we will
> >> flush (doorbell) all XDP looped packets in case there are such.
> >
> > Why is this idea depends on XDP ?
> >
> > It looks like we could apply it to any driver having one IRQ servicing
> > one RX and one TX, without XDP being involved.
> >
> 
> Yes but it is more complicated than XDP case, where the RX ring posts
> the TX descriptors and once done
> the RX ring hits the doorbell once for all the TX descriptors it
> posted, and it is the only possible place to hit a doorbell
> for XDP TX ring.
> 
> For regular TX and RX ring sharing the same IRQ, there is no such
> simple connection between them, and hitting a doorbell
> from RX ring napi would race with xmit ndo function of the TX ring.
> 
> How do you synchronize in such case ?
> isn't the existing xmit more mechanism sufficient enough ?

Only if a qdisc is present and pressure is high enough.

But in a forwarding setup, we likely receive at a lower rate than the
NIC can transmit.

A simple cmpxchg could be used to synchronize the thing, if we really
cared about doorbell cost. (Ie if the cost of this cmpxchg() is way
smaller than doorbell one)
