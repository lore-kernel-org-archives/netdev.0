From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Wed, 14 Mar 2012 04:52:01 +0000
Message-ID: <CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
References: <1327570722.8191.46.camel@probook>
	<1331697865.2456.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jdb@comx.dk, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56340 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753518Ab2CNEwD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 00:52:03 -0400
Received: by wibhq7 with SMTP id hq7so1938997wib.1
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 21:52:01 -0700 (PDT)
In-Reply-To: <1331697865.2456.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 14, 2012 at 4:04 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> This reverts commit d47a0ac7b6 (sch_sfq: dont put new flow at the end=
 of
> flows)
>
> As Jesper found out, patch sounded great but has bad side effects.

Well under most circumstances it IS great.

As the depth of the sfq queue increases it gets increasingly hard to
trigger the problem. I've been using values in the 200-300 range, and
in combination with red, haven't seen it happen.

Also in part the sfq behavior observed is due to an interaction with
htb's 'capture' of a packet rather than peek. The situation that
jesper encountered this issue (trying to regulate flows to hundreds of
downstream clients on a very deterministic test) was different from
where I don't encounter it (trying to regulate flows up from a very
few clients)

=46or more details:

http://www.bufferbloat.net/issues/332

But I concur in reverting this for now. Sadly. wouldn't mind if there
was a way to keep it as is as an option...

>
> In stress situation, pushing new flows in front of the queue can prev=
ent
> old flows doing any progress. Packets can stay in SFQ queue for
> unlimited amount of time.
>
> It's possible to add heuristics to limit this problem, but this would
> add complexity outside of SFQ scope.
>
> A more sensible answer to Dave Taht concerns (who reported the issued=
 I
> tried to solve in original commit) is probably to use a qdisc hierarc=
hy
> so that high prio packets dont enter a potentially crowded SFQ qdisc.

Um, er, in today's port 80/433 world, there isn't any such thing as hig=
h
prio packets.

I am curious as to whether this problem can be made to happen with qfq.

> Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
> Cc: Dave Taht <dave.taht@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> I tried various tricks to avoid a revert but in the end it sounds bet=
ter
> to use a single queue.

I had some hope for a semi-random alternating queue

>
> =A0net/sched/sch_sfq.c | =A0 =A06 +++++-
> =A01 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 60d4718..02a21ab 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -469,11 +469,15 @@ enqueue:
> =A0 =A0 =A0 =A0if (slot->qlen =3D=3D 1) { =A0 =A0 =A0 =A0 =A0/* The f=
low is new */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (q->tail =3D=3D NULL) { =A0/* It is=
 the first flow */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->next =3D x;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->tail =3D slot;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->next =3D q->tail=
->next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->tail->next =3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We put this flow at the end of our f=
low list.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This might sound unfair for a new =
flow to wait after old ones,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* but we could endup servicing new f=
lows only, and freeze old ones.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->tail =3D slot;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* We could use a bigger initial quant=
um for new flows */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->allot =3D q->scaled_quantum;
> =A0 =A0 =A0 =A0}
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
