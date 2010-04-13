From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Tue, 13 Apr 2010 12:19:02 +0200
Message-ID: <1271153942.16881.233.camel@edumazet-laptop>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	 <1271146112.16881.213.camel@edumazet-laptop>
	 <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:52324 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab0DMKTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:19:09 -0400
Received: by bwz19 with SMTP id 19so106634bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 03:19:07 -0700 (PDT)
In-Reply-To: <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 17:50 +0800, Changli Gao a =C3=A9crit :
> On Tue, Apr 13, 2010 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> >        Probably not necessary.
> >
> >> +     volatile bool           flush_processing_queue;
> >
> > Use of 'volatile' is strongly discouraged, I would say, forbidden.
> >
>=20
> volatile is used to avoid compiler optimization.

volatile might be used on special macros only, not to guard a variable.
volatile was pre SMP days. We need something better defined these days.

>=20
> > Its usually a sign of 'I dont exactly what memory ordering I need, =
so I
> > throw a volatile just in case'. We live in a world full of RCU, rea=
d ,
> > write, full barriers. And these apis are well documented.
> >
>=20
> There isn't memory accessing order problem.
>=20

Really ? If you persist using this volatile thing, then you'll have to
convince Mr Linus Torvald himself. Prepare your best guns, because in
fact you'll have to convince about one hundred people that know for sur=
e
how volatile is weak.

> >> @@ -2803,6 +2808,7 @@ static void flush_backlog(void *arg)
> >>                       __skb_unlink(skb, &queue->input_pkt_queue);
> >>                       kfree_skb(skb);
> >>               }
> >> +     queue->flush_processing_queue =3D true;
> >
> >        Probably not necessary
> >
>=20
> If flush_backlog() is called when there are still packets in
> processing_queue, there maybe some packets refer to the netdev gone,
> if we remove this line.

We dont need this "processing_queue". Once you remove it, there is no
extra work to perform.

>=20
> >>       rps_unlock(queue);
> >>  }
> >>
> >> @@ -3112,14 +3118,23 @@ static int process_backlog(struct napi_str=
uct *napi, int quota)
> >>       struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
> >>       unsigned long start_time =3D jiffies;
> >>
> >> +     if (queue->flush_processing_queue) {
> >
> > Really... this is bloat IMHO
>=20
>=20
> Any better idea?
>=20

Yes, I have explained it to you.

> >
> >>
> >
> > I advise to keep it simple.
> >
> > My suggestion would be to limit this patch only to process_backlog(=
).
> >
> > Really if you touch other areas, there is too much risk.
> >
> > Perform sort of skb_queue_splice_tail_init() into a local (stack) q=
ueue,
> > but the trick is to not touch input_pkt_queue.qlen, so that we dont=
 slow
> > down enqueue_to_backlog().
> >
> > Process at most 'quota' skbs (or jiffies limit).
> >
> > relock queue.
> > input_pkt_queue.qlen -=3D number_of_handled_skbs;
> >
>=20
> Oh no, in order to let latter packets in as soon as possible, we have
> to update qlen immediately.
>=20

Absolutely not. You missed something apparently.

You pay the price at each packet enqueue, because you have to compute
the sum of two lengthes, and guess what, if you do this you have a cach=
e
line miss in one of the operand. Your patch as is is suboptimal.

Remember : this batch mode should not change packet queueing at all,
only speed it because of less cache line misses.



