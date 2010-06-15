From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce u64_stats_sync
 infrastructure
Date: Tue, 15 Jun 2010 12:43:25 +0200
Message-ID: <1276598605.2541.96.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
	 <1276596856.2541.84.camel@edumazet-laptop>  <20100615102541.GH6138@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33480 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225Ab0FOKvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 06:51:39 -0400
Received: by wyb40 with SMTP id 40so4660419wyb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 03:51:38 -0700 (PDT)
In-Reply-To: <20100615102541.GH6138@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 20:25 +1000, Nick Piggin a =C3=A9crit :
> On Tue, Jun 15, 2010 at 12:14:16PM +0200, Eric Dumazet wrote:
> > Here is the followup patch to abstract things a bit, before upcomin=
g
> > conversions.
> >=20
> > Thanks !
> >=20
> > [PATCH net-next-2.6] net: Introduce u64_stats_sync infrastructure
> >=20
> > To properly implement 64bits network statistics on 32bit or 64bit h=
osts,
> > we provide one new type and four methods, to ease conversions.
> >=20
> > Stats producer should use following template granted it already got=
 an
> > exclusive access to counters (a previous lock is taken, or per cpu
> > data [used in a non preemptable context])
> >=20
> > Let me repeat : stats producers must be serialized by other means b=
efore
> > using this template. Preemption must be disabled too.
> >=20
> > u64_stats_update_begin(&stats->syncp);
> > stats->bytes +=3D len;
> > stats->packets++;
> > u64_stats_update_end(&stats->syncp);
> >=20
> > While a consumer should use following template to get consistent
> > snapshot :
> >=20
> > u64 tbytes, tpackets;
> > unsigned int start;
> >=20
> > do {
> > 	start =3D u64_stats_fetch_begin(&stats->syncp);
> > 	tbytes =3D stats->bytes;
> > 	tpackets =3D stats->packets;
> > } while (u64_stats_fetch_retry(&stats->lock, syncp));
> >=20
> > This patch uses this infrastructure in net loopback driver, instead=
 of
> > specific one added in commit 6b10de38f0ef (loopback: Implement 64bi=
t
> > stats on 32bit arches)
> >=20
> > Suggested by David Miller
>=20
> Cool, I don't mind this, but perhaps could you add some comments
> because it _will_ either be misused or copied and misused elsewhere :=
)
>=20
> Callers must:
> - write side must ensure mutual exclusion (even if it was previously =
OK
>   to have lost updates on the writer side, the seqlock will explodde =
if
>   it is taken concurrently for write)
> - write side must not sleep
> - readside and writeside must have local-CPU exclusion from one anoth=
er;
>   preempt, irq, bh as appropriate
> - will only protect 64-bit sizes from tearing -- eg updating 2 differ=
ent
>   stats under the same write side will not ensure they are both seen =
in
>   the same read side

Hmm, I am not sure I got this one, could you please give me a buggy
example ?

>=20
> But I do like the minimal design.

Thanks !

I'll submit a v2 patch after my lunch to add all your comments, because
all clarifications are indeed very very welcomed !



