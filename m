From: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
Subject: Re: [PATCH] tcp: efficient port randomisation
Date: Tue, 2 Nov 2004 09:54:44 +0200
Message-ID: <200411020854.44745.michael.vittrup.larsen@ericsson.com>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net> <200411011058.23141.michael.vittrup.larsen@ericsson.com> <20041101092027.2a741e82@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041101092027.2a741e82@zqx3.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 01 November 2004 18:20, Stephen Hemminger wrote:
> > * It is probably a good strategy to set 'tcp_rover_next' such that
> > =A0 the next search is resumed from the previous port found to be fre=
e.
> > =A0 (similar to the old algorithm). =A0I don't see this in your patch=
,
> > =A0 but of course I could have missed it.
>
> It was intentional since it would require holding a lock around the sea=
rch.
> The tradeoff is better SMP performance in the sparsely filled port spac=
e
> (more typical) vs. better UP performance in the case of a mostly full p=
ort
> space.

I think a typical scenario is many short-lived (e.g. minutes) TCP connect=
ions,=20
few long-lived (e.g. hours) connections and an ephemeral port wrap-around=
=20
probably also in hours - at least a long time compared to the life-time o=
f=20
the short-lived connections.

This would result in a closely spaced 'group' of ports being occupied=20
somewhere in the ephemeral port range, and 'tcp_rover_next' would point a=
t=20
the uppermost extreme of this group and thus always guarantee a free port=
 on=20
first try (collisions will only happen with long-lived connections).  If =
you=20
don't update 'tcp_rover_next', and this somehow gets to lag behind this=20
'group' of ports (say point at the lower extreme) you will need to search=
=20
through this group first before you enter the unoccupied port space.

Your scheme works initially because you do not lag behind the free port s=
pace,=20
but eventually you will, and I think this will result in less optimal=20
performance compared to the old behaviour.

Since updating the 'tcp_rover_next' practically always result in a free p=
ort=20
on first try, I think SMP performance will not suffer even though the loc=
k=20
was held all through the port search (except when the port space is very=20
crowded).

And yes, I do use Linux exclusively, so I do care :-))

>From a statistically point of view, if the connection life-times are unif=
ormly=20
distributed from zero to infinite (theoretical scenario), it does not mat=
ter=20
what starting point you use. However, soon as life-times are not uniforml=
y=20
distributed, this kind of search algorithm will benefit from good startin=
g=20
point defining where the probability of used vs. unused port drop from hi=
gh=20
to low.

The BSD solution with a pure random rover suffers similarly, especially w=
hen=20
the port space becomes crowded.


> > * connect_port_offset() does not (at least from an algorithm point
> > =A0 of view) need to return an u32, an u16 is sufficient.
>
> If it is truncated to u16, then compiler has to take extra effort to
> truncate is unnecessary given later =A0modulo operation.

I agree (in fact thats what I argued in the draft) - it probably depends =
on=20
your platform - you are assuming a 32-bit platform I guess.
