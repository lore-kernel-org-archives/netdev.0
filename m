From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: efficient port randomisation
Date: Thu, 4 Nov 2004 10:01:04 -0800
Message-ID: <20041104100104.570e67cd@dxpl.pdx.osdl.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<200411011058.23141.michael.vittrup.larsen@ericsson.com>
	<20041101092027.2a741e82@zqx3.pdx.osdl.net>
	<200411020854.44745.michael.vittrup.larsen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
In-Reply-To: <200411020854.44745.michael.vittrup.larsen@ericsson.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Nov 2004 09:54:44 +0200
Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com> wrote:

> On Monday 01 November 2004 18:20, Stephen Hemminger wrote:
> > > * It is probably a good strategy to set 'tcp_rover_next' such that
> > > =A0 the next search is resumed from the previous port found to be f=
ree.
> > > =A0 (similar to the old algorithm). =A0I don't see this in your pat=
ch,
> > > =A0 but of course I could have missed it.
> >
> > It was intentional since it would require holding a lock around the s=
earch.
> > The tradeoff is better SMP performance in the sparsely filled port sp=
ace
> > (more typical) vs. better UP performance in the case of a mostly full=
 port
> > space.
>=20
> I think a typical scenario is many short-lived (e.g. minutes) TCP conne=
ctions,=20
> few long-lived (e.g. hours) connections and an ephemeral port wrap-arou=
nd=20
> probably also in hours - at least a long time compared to the life-time=
 of=20
> the short-lived connections.

But because of the hashing most ports will be scattered all over the port=
 space,
because they come from different hosts.

> This would result in a closely spaced 'group' of ports being occupied=20
> somewhere in the ephemeral port range, and 'tcp_rover_next' would point=
 at=20
> the uppermost extreme of this group and thus always guarantee a free po=
rt on=20
> first try (collisions will only happen with long-lived connections).  I=
f you=20
> don't update 'tcp_rover_next', and this somehow gets to lag behind this=
=20
> 'group' of ports (say point at the lower extreme) you will need to sear=
ch=20
> through this group first before you enter the unoccupied port space.

Also, Linux TCP will reuse ports if (saddr, daddr, sport) are different.
Look at __tcp_v4_check_established.  This means that the ports actually h=
ave
to be in use with real connections to the same host.

> Your scheme works initially because you do not lag behind the free port=
 space,=20
> but eventually you will, and I think this will result in less optimal=20
> performance compared to the old behaviour.

Free port space should be evenly distributed because of the hash function.

> Since updating the 'tcp_rover_next' practically always result in a free=
 port=20
> on first try, I think SMP performance will not suffer even though the l=
ock=20
> was held all through the port search (except when the port space is ver=
y=20
> crowded).

But by not having a global lock on port allocation, different cpu's can b=
e
searching different hash trees.  This would matter under Dos attack with
multiple interfaces.

> And yes, I do use Linux exclusively, so I do care :-))
>=20
> >From a statistically point of view, if the connection life-times are u=
niformly=20
> distributed from zero to infinite (theoretical scenario), it does not m=
atter=20
> what starting point you use. However, soon as life-times are not unifor=
mly=20
> distributed, this kind of search algorithm will benefit from good start=
ing=20
> point defining where the probability of used vs. unused port drop from =
high=20
> to low.
>=20
> The BSD solution with a pure random rover suffers similarly, especially=
 when=20
> the port space becomes crowded.
>=20
>=20
> > > * connect_port_offset() does not (at least from an algorithm point
> > > =A0 of view) need to return an u32, an u16 is sufficient.
> >
> > If it is truncated to u16, then compiler has to take extra effort to
> > truncate is unnecessary given later =A0modulo operation.
>=20
> I agree (in fact thats what I argued in the draft) - it probably depend=
s on=20
> your platform - you are assuming a 32-bit platform I guess.
