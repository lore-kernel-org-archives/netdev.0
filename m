From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: sched: do not acquire qdisc spinlock
 in qdisc/class stats dump
Date: Mon, 06 Jun 2016 16:53:19 -0700
Message-ID: <1465257199.24873.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465231036-10674-1-git-send-email-edumazet@google.com>
	 <1465231036-10674-3-git-send-email-edumazet@google.com>
	 <CAM_iQpURiYyBqpKG=u4qvbgToe4kQd4=8d_N0ohbfG_cONw_8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33549 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbcFFXxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:53:21 -0400
Received: by mail-pf0-f193.google.com with SMTP id u67so2828910pfu.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:53:21 -0700 (PDT)
In-Reply-To: <CAM_iQpURiYyBqpKG=u4qvbgToe4kQd4=8d_N0ohbfG_cONw_8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-06 at 16:15 -0700, Cong Wang wrote:
> On Mon, Jun 6, 2016 at 9:37 AM, Eric Dumazet <edumazet@google.com> wrote:
> >  void
> > -__gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
> > +__gnet_stats_copy_basic(const seqcount_t *running,
> > +                       struct gnet_stats_basic_packed *bstats,
> >                         struct gnet_stats_basic_cpu __percpu *cpu,
> >                         struct gnet_stats_basic_packed *b)
> >  {
> > +       unsigned int seq;
> > +
> >         if (cpu) {
> >                 __gnet_stats_copy_basic_cpu(bstats, cpu);
> > -       } else {
> > +               return;
> > +       }
> > +       do {
> > +               if (running)
> > +                       seq = read_seqcount_begin(running);
> >                 bstats->bytes = b->bytes;
> >                 bstats->packets = b->packets;
> > -       }
> > +       } while (running && read_seqcount_retry(running, seq));
> >  }
> 
> Why only these basic stats need to get read seqlock?

(seqcount)

> Queue stats (gnet_stats_copy_queue()) too, right?

All these values are 32bit values, right ?

struct gnet_stats_queue {
        __u32   qlen;
        __u32   backlog;
        __u32   drops;
        __u32   requeues;
        __u32   overlimits;
};

Really sounds overkill to care about these, as probably no one needs to
get a 'consistent view of all these counters in a snapshot'.

Even as of today, the qlen/backlog pair is wrong. No one ever used these
values in an SNMP agent.

Note that qlen/backlog is changed both by enqueue/dequeue, so the
seqcount protection would not work.

With the percpu stats thing, stats can not be fetched in a 'consistent'
way.
