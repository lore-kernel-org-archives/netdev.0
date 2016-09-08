From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Thu, 8 Sep 2016 07:11:19 +0200
Message-ID: <20160908071119.776cce56@redhat.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
        <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
        <1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com>
        <1473262379.10725.42.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG9iVpS2qH5Ryc_DtEjrQMhcKD+qrLrGn=vet=_9N8eXPw@mail.gmail.com>
        <20160907202234.55e18ef3@redhat.com>
        <57D0D3EA.1090004@gmail.com>
        <CALx6S34vqa+13c_4m0CKqL_6U+37DQ15T=WRAdUZNL3iYo1J0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58020 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751542AbcIHFL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 01:11:27 -0400
In-Reply-To: <CALx6S34vqa+13c_4m0CKqL_6U+37DQ15T=WRAdUZNL3iYo1J0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 7 Sep 2016 20:21:24 -0700 Tom Herbert <tom@herbertland.com> wrote:

> On Wed, Sep 7, 2016 at 7:58 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> > On 16-09-07 11:22 AM, Jesper Dangaard Brouer wrote:  
> >>
> >> On Wed, 7 Sep 2016 19:57:19 +0300 Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:  
> >>> On Wed, Sep 7, 2016 at 6:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> >>>> On Wed, 2016-09-07 at 18:08 +0300, Saeed Mahameed wrote:  
> >>>>> On Wed, Sep 7, 2016 at 5:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> >>>>>> On Wed, 2016-09-07 at 15:42 +0300, Saeed Mahameed wrote:  
> >> [...]  
> >>>>
> >>>> Only if a qdisc is present and pressure is high enough.
> >>>>
> >>>> But in a forwarding setup, we likely receive at a lower rate than the
> >>>> NIC can transmit.  
> >>
> >> Yes, I can confirm this happens in my experiments.
> >>  
> >>>>  
> >>>
> >>> Jesper has a similar Idea to make the qdisc think it is under
> >>> pressure, when the device TX ring is idle most of the time, i think
> >>> his idea can come in handy here. I am not fully involved in the
> >>> details, maybe he can elaborate more.
> >>>
> >>> But if it works, it will be transparent to napi, and xmit more will
> >>> happen by design.  
> >>
> >> Yes. I have some ideas around getting more bulking going from the qdisc
> >> layer, by having the drivers provide some feedback to the qdisc layer
> >> indicating xmit_more should be possible.  This will be a topic at the
> >> Network Performance Workshop[1] at NetDev 1.2, I have will hopefully
> >> challenge people to come up with a good solution ;-)
> >>  
> >
> > One thing I've noticed but haven't yet actually analyzed much is if
> > I shrink the nic descriptor ring size to only be slightly larger than
> > the qdisc layer bulking size I get more bulking and better perf numbers.
> > At least on microbenchmarks. The reason being the nic pushes back more
> > on the qdisc. So maybe a case for making the ring size in the NIC some
> > factor of the expected number of queues feeding the descriptor ring.
> >  

I've also played with shrink the NIC descriptor ring size, it works,
but it is an ugly hack to get NIC pushes backs, and I foresee it will
hurt normal use-cases. (There are other reasons for shrinking the ring
size like cache usage, but that is unrelated to this).

 
> BQL is not helping with that?

Exactly. But the BQL _byte_ limit is not what is needed, what we need
to know is the _packets_ currently "in-flight".  Which Tom already have
a patch for :-)  Once we have that the algorithm is simple.

Qdisc dequeue look at BQL pkts-in-flight, if driver have "enough"
packets in-flight, the qdisc start it's bulk dequeue building phase,
before calling the driver. The allowed max qdisc bulk size should
likely be related to pkts-in-flight.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
