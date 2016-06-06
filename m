From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Mon, 06 Jun 2016 07:29:30 -0700
Message-ID: <1465223370.2968.59.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160604190301.GA8857@strlen.de>
	 <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
	 <1465160087.2968.51.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465160123.2968.52.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXMwT20nhWW4Pd2yy6nkeXkSNdxV9wAEGzGd22PcyePmg@mail.gmail.com>
	 <57555536.1090801@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34564 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbcFFO3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 10:29:34 -0400
Received: by mail-pf0-f177.google.com with SMTP id 62so67518285pfd.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 07:29:34 -0700 (PDT)
In-Reply-To: <57555536.1090801@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-06 at 06:49 -0400, Jamal Hadi Salim wrote:
> On 16-06-05 07:30 PM, Cong Wang wrote:
> 
> > Potentially all of the following:
> >
> > net/sched/sch_choke.c:  return NET_XMIT_CN;
> > net/sched/sch_fifo.c:   return NET_XMIT_CN;
> > net/sched/sch_generic.c:        return NET_XMIT_CN;
> > net/sched/sch_gred.c:   return NET_XMIT_CN;
> > net/sched/sch_hhf.c:            return NET_XMIT_CN;
> > net/sched/sch_red.c:    return NET_XMIT_CN;
> > net/sched/sch_sfb.c:    return NET_XMIT_CN;
> > net/sched/sch_sfq.c:            return NET_XMIT_CN;
> >
> 
> As long as we are not loosing the stat that the packet
> is dropped. Some qdiscs have a counter which indicates
> congestion drops(look at RED variants of early drops);
> maybe codel needs one. The parent also must account for
> childs drops.
> BTW, returning NET_XMIT_CN could be confusing to tcp;
> it does not mean that the packet that we are getting return
> code for was dropped; it could mean _another_ packet in
> the queue was dropped.

NET_XMIT_CN does not confuse TCP at all.

Look, the issue here is the accuracy of byte backlog in upper qdiscs,
after Cong patch.

When at enqueue(sch, P2) we drop P1, but enqueue P2, we need to take
care of reporting to upper qdisc qdisc_pkt_len(P2) - qdisc_pkt_len(P1)

We used to not call qdisc_tree_reduce_backlog() in this case, since it
was qdisc_tree_decrease_qlen(sch, delta_packets) before Cong patch.

We now need to call qdisc_tree_reduce_backlog(sch, 0, delta_bytes)
