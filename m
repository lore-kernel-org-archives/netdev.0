From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH net-next-2.6] net: Introduce u64_stats_sync
 infrastructure
Date: Tue, 15 Jun 2010 21:04:13 +1000
Message-ID: <20100615110413.GJ6138@laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
 <20100614.231412.39191304.davem@davemloft.net>
 <1276596856.2541.84.camel@edumazet-laptop>
 <20100615102541.GH6138@laptop>
 <1276598605.2541.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41009 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756988Ab0FOLES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 07:04:18 -0400
Content-Disposition: inline
In-Reply-To: <1276598605.2541.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 12:43:25PM +0200, Eric Dumazet wrote:
> Le mardi 15 juin 2010 =E0 20:25 +1000, Nick Piggin a =E9crit :
> > On Tue, Jun 15, 2010 at 12:14:16PM +0200, Eric Dumazet wrote:
> > > Here is the followup patch to abstract things a bit, before upcom=
ing
> > > conversions.
> > >=20
> > > Thanks !
> > >=20
> > > [PATCH net-next-2.6] net: Introduce u64_stats_sync infrastructure
> > >=20
> > > To properly implement 64bits network statistics on 32bit or 64bit=
 hosts,
> > > we provide one new type and four methods, to ease conversions.
> > >=20
> > > Stats producer should use following template granted it already g=
ot an
> > > exclusive access to counters (a previous lock is taken, or per cp=
u
> > > data [used in a non preemptable context])
> > >=20
> > > Let me repeat : stats producers must be serialized by other means=
 before
> > > using this template. Preemption must be disabled too.
> > >=20
> > > u64_stats_update_begin(&stats->syncp);
> > > stats->bytes +=3D len;
> > > stats->packets++;
> > > u64_stats_update_end(&stats->syncp);
> > >=20
> > > While a consumer should use following template to get consistent
> > > snapshot :
> > >=20
> > > u64 tbytes, tpackets;
> > > unsigned int start;
> > >=20
> > > do {
> > > 	start =3D u64_stats_fetch_begin(&stats->syncp);
> > > 	tbytes =3D stats->bytes;
> > > 	tpackets =3D stats->packets;
> > > } while (u64_stats_fetch_retry(&stats->lock, syncp));
> > >=20
> > > This patch uses this infrastructure in net loopback driver, inste=
ad of
> > > specific one added in commit 6b10de38f0ef (loopback: Implement 64=
bit
> > > stats on 32bit arches)
> > >=20
> > > Suggested by David Miller
> >=20
> > Cool, I don't mind this, but perhaps could you add some comments
> > because it _will_ either be misused or copied and misused elsewhere=
 :)
> >=20
> > Callers must:
> > - write side must ensure mutual exclusion (even if it was previousl=
y OK
> >   to have lost updates on the writer side, the seqlock will explodd=
e if
> >   it is taken concurrently for write)
> > - write side must not sleep
> > - readside and writeside must have local-CPU exclusion from one ano=
ther;
> >   preempt, irq, bh as appropriate
> > - will only protect 64-bit sizes from tearing -- eg updating 2 diff=
erent
> >   stats under the same write side will not ensure they are both see=
n in
> >   the same read side
>=20
> Hmm, I am not sure I got this one, could you please give me a buggy
> example ?

So if you have a regular seqlock, the sequence:

write_seqcount_begin
stat1++
stat2--
write_seqcount_end

do read_seqcount_begin
  sum =3D stat1+stat2;
while (read_seqcount_retry)
BUG_ON(sum !=3D 0);

This code is OK. But if it is using your stat sync, then it is buggy.
This is obvious to you of course, but someone who doesn't consider
the implementation might get caught out.

I guess all my other points are properties of seqcount code itself,
but they are not documented really well with the seqlock API
unfortunately.


> > But I do like the minimal design.
>=20
> Thanks !
>=20
> I'll submit a v2 patch after my lunch to add all your comments, becau=
se
> all clarifications are indeed very very welcomed !

Thanks!
