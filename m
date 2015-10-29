From: "Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad" <bro.devel@gmail.com>
Subject: Re: [PATCH RFC net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Thu, 29 Oct 2015 18:53:53 -0400
Message-ID: <3710572.sJUWpao1xp@bro-compal>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com> <C1235108-1DC2-408E-8CAC-65DBE628AB78@simula.no> <CAK6E8=fyY_kQ4ZpyC+q3fH-CFvwDt_=ro2Y7qB9bxgMCpkcC3g@mail.gmail.com>
Reply-To: bro.devel+kernel@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Petlund <apetlund@simula.no>,
	Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	linux-doc@vger.kern
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=fyY_kQ4ZpyC+q3fH-CFvwDt_=ro2Y7qB9bxgMCpkcC3g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, October 26, 2015 02:58:03 PM Yuchung Cheng wrote:
> On Mon, Oct 26, 2015 at 2:35 PM, Andreas Petlund <apetlund@simula.no>=
 wrote:
> > > On 26 Oct 2015, at 15:50, Neal Cardwell <ncardwell@google.com> wr=
ote:
> > >=20
> > > On Fri, Oct 23, 2015 at 4:50 PM, Bendik R=F8nning Opstad
> > >=20
> > > <bro.devel@gmail.com> wrote:
> > >> @@ -2409,6 +2412,15 @@ static int do_tcp_setsockopt(struct sock =
*sk,
> > >> int level,> >=20
> > > ...
> > >=20
> > >> +       case TCP_RDB:
> > >> +               if (val < 0 || val > 1) {
> > >> +                       err =3D -EINVAL;
> > >> +               } else {
> > >> +                       tp->rdb =3D val;
> > >> +                       tp->nonagle =3D val;
> > >=20
> > > The semantics of the tp->nonagle bits are already a bit complex. =
My
> > > sense is that having a setsockopt of TCP_RDB transparently modify=
 the
> > > nagle behavior is going to add more extra complexity and unantici=
pated
> > > behavior than is warranted given the slight possible gain in
> > > convenience to the app writer. What about a model where the
> > > application user just needs to remember to call
> > > setsockopt(TCP_NODELAY) if they want the TCP_RDB behavior to be
> > > sensible? I see your nice tests at
> > >=20
> > >   https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd04=
329d29b
> > >   7d8baf703b2c2ac1b> >=20
> > > are already doing that. And my sense is that likewise most
> > > well-engineered "thin stream" apps will already be using
> > > setsockopt(TCP_NODELAY). Is that workable?

This is definitely workable. I agree that it may not be an ideal soluti=
on to
have TCP_RDB disable Nagle, however, it would be useful with a way to e=
asily
enable RDB and disable Nagle.

> > We have been discussing this a bit back and forth. Your suggestion =
would
> > be the right thing to keep the nagle semantics less complex and to
> > educate developers in the intrinsics of the transport.
> >=20
> > We ended up choosing to implicitly disable nagle since it
> > 1) is incompatible with the logic of RDB.
> > 2) leaving it up to the developer to read the documentation and reg=
ister
> > the line saying that "failing to set TCP_NODELAY will void the RDB
> > latency gain" will increase the chance of misconfigurations leading=
 to
> > deployment with no effect.
> >=20
> > The hope was to help both the well-engineered thin-stream apps and =
the
> > ones deployed by developers with less detailed knowledge of the
> > transport.
> but would RDB be voided if this developer turns on RDB then turns on
> Nagle later?

It would (to a large degree), but I believe that's ok? The intention wi=
th also
disabling Nagle is not to remove control from the application writer, s=
o if
TCP_RDB disables Nagle, they should not be prevented from explicitly en=
abling
Nagle after enabling RDB.

The idea is to make it as easy as possible for the application writer, =
and
since Nagle is on by default, it makes sense to change this behavior wh=
en the
application has indicated that it values low latencies.

Would a solution with multiple option values to TCP_RDB be acceptable? =
E.g.
0 =3D Disable
1 =3D Enable RDB
2 =3D Enable RDB and disable Nagle

If the sysctl tcp_rdb accepts the same values, setting the sysctl to 2 =
would
allow to use and test RDB (with Nagle off) on applications that haven't
explicitly disabled Nagle, which would make the sysctl tcp_rdb even mor=
e useful.

Instead of having TCP_RDB modify Nagle, would it be better/acceptable t=
o have a
separate socket option (e.g. TCP_THIN/TCP_THIN_LOW_LATENCY) that enable=
s RDB and
disables Nagle? e.g.
0 =3D Use default system options?
1 =3D Enable RDB and disable Nagle

This would separate the modification of Nagle from the TCP_RDB socket o=
ption and
make it cleaner?

Such an option could also enable other latency-reducing options like
TCP_THIN_LINEAR_TIMEOUTS and TCP_THIN_DUPACK:
2 =3D Enable RDB, TCP_THIN_LINEAR_TIMEOUTS, TCP_THIN_DUPACK, and disabl=
e Nagle

Bendik
