From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: gen_kill_estimator() rcu fixes
Date: Wed, 09 Jun 2010 15:05:57 +0200
Message-ID: <1276088757.2442.128.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
	 <1276076415.2442.92.camel@edumazet-laptop>
	 <1276077416.2442.97.camel@edumazet-laptop>
	 <20100609104100.GB7308@ff.dom.local>
	 <1276085363.2442.125.camel@edumazet-laptop>
	 <20100609125035.GD7308@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:64850 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761Ab0FINGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 09:06:04 -0400
Received: by wwb31 with SMTP id 31so221404wwb.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 06:06:01 -0700 (PDT)
In-Reply-To: <20100609125035.GD7308@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 juin 2010 =C3=A0 12:50 +0000, Jarek Poplawski a =C3=A9cr=
it :
> On Wed, Jun 09, 2010 at 02:09:23PM +0200, Eric Dumazet wrote:
> > Le mercredi 09 juin 2010 ?? 10:41 +0000, Jarek Poplawski a =C3=A9cr=
it :
> >=20
> > > Spelling suggestion: xt_rateest_free_rcu?
> > >=20
> > > Since it's only 3 places I'd consider adding little comments,
> > > who needs this call_rcu (like in qdisc_destroy).
> > >=20
> > > Anyway this patch looks OK to me.
> > >=20
> >=20
> > Thanks for reviewing, you are right about typo and adding some comm=
ents.
> >=20
> > What about following ?
>=20
> Very nice! (But let's remember these comments aren't very precise
> wrt. bstats at the moment ;-)

Yes, I anticipated a bit next patch ;)

BTW, I think using qdisc spinlock to update stats or reading them is no=
t
really needed, particularly in xt_rateest/xt_RATEEST case, where
per_cpu bstats would be good

We could have one seqcount_t used by (bytes/packets) bstats producer,
and one seqcount_t used by est_timer when computing rates.


bstats updates :


write_seqcount_begin(&bstats->abs_seq);
bstats->bytes +=3D len;
bstats->packets++;
write_seqcount_end(&bstats->abs_seq);


est_timer() would really run lockless, only rcu protected.

(No more spinlock, only the actual rcu_read_lock())


do {
	seq =3D read_seqcount_begin(&bstats->abs_seq);
	abs_bytes =3D bstats->bytes;
	abs_packets =3D bstats->packets;
} while (read_seqcount_retry(&bstats->abs_seq, seq));

write_seqcount_begin(&s->rate_seq);
/* compute rate estimation and store it */
=2E..
write_seqcount_end(&s->rate_seq);

This would mean bstats should be rcu protected too...



