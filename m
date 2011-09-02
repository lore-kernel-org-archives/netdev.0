From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: IP_TRANSPARENT requires CAP_NET_ADMIN - why?
Date: Fri, 02 Sep 2011 10:43:42 +0200
Message-ID: <1314953022.26692.182.camel@bzorp>
References: <CAHo-Ooz-0wt4-3oXZBeEmLTSom5qUxhXhP4MDUrSz322OTGa9A@mail.gmail.com>
	 <CAHo-OozTNa8gtCuhSZm+aBqK-J0-eGMyr5rJBfTV6SmPZNhQVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@balabit.hu>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq.balabit.com ([213.253.200.34]:42041 "EHLO mail.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932697Ab1IBIu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 04:50:27 -0400
In-Reply-To: <CAHo-OozTNa8gtCuhSZm+aBqK-J0-eGMyr5rJBfTV6SmPZNhQVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 2011-09-01 at 14:25 -0700, Maciej =C5=BBenczykowski wrote:
> > I'm curious why transparent sockets [setsockopt(IP{,V6}_TRANSPARENT=
),
> > ie. inet_sk(sk)->transparent bit] require CAP_NET_ADMIN privileges.
> >
> > Wouldn't CAP_NET_RAW be more appropriate?
> >
> > Looks to me like CAP_NET_RAW is all about raw sockets.
> > Transparent sockets are dangerous because they effectively allow sp=
oofing.
> > But this seems to be the same sort of thing that CAP_NET_RAW protec=
ts
> > against.
> >
> > Is there something I'm missing?
> > Is there any reason why having CAP_NET_RAW privs shouldn't allow on=
e
> > to set the transparent bit on a socket?
> >
> > Would people be opposed to relaxing the check on setting sk->transp=
arent
> > to be either CAP_NET_ADMIN or CAP_NET_RAW?

Well, the reason for choosing CAP_NET_ADMIN is that the original tproxy
functionality in Linux 2.2 required that cap, and we never questioned
it. Also, earlier the bits in the capability mask was a scarce resource
earlier. But see more info at the end of this email.

>=20
> Why am I even interested?  I have a couple of apps (dns servers, web
> servers, load balancers, web crawlers) that
> don't require any special permissions except the ability to use any i=
p
> as the source ip for a listening tcp, outgoing tcp, and/or udp socket=
=2E
> For example machines may receive arbitrary traffic over a tunnel (wit=
h
> absolutely any ip as the destination ip within the tunneled payload)
> and need to respond to it, hence they need to be able to respond with
> any ip as the source ip.  This can be achieved with combinations of
> routing tricks and/or ip non local bind and/or ip_transparent.
>=20
> The way I see it there are a couple possibilities.
>=20
> a) Leave as is: IP{,V6}_TRANSPARENT requires CAP_NET_ADMIN
>=20
>    This seems like the least desirable solution, we end up requiring =
a
> much more powerful privilege then necessary.
>=20
> b) Backward compatible: Make it require one of CAP_NET_ADMIN or CAP_N=
ET_RAW
>=20
>    Better, but kind of ugly in there being two permissions that allow=
 this.
>=20
> c) Not-backward compatible: Make it require CAP_NET_RAW instead of CA=
P_NET_ADMIN
>=20
>    Better, in that a less powerful privilege is required, but *does*
> break non-root software which uses CAP_NET_ADMIN to get TRANSPARENT
> sockets.
>    Also the gain isn't that great, in that we are still using a
> privilege which is a little too powerful.
>=20
> d) Add a new capability: Make it require CAP_NET_ADMIN or CAP_NET_TRA=
NSPARENT
>=20
>   Again backward compatible - ugly.
>=20
> e) Add a new capability: Make it require CAP_NET_ADMIN or CAP_NET_RAW
> or CAP_NET_TRANSPARENT
>=20
>   Again backward compatible - ugly.  The reason for allowing
> CAP_NET_RAW is that it effectively already allows this to be done wit=
h
> raw sockets in a less useful way.  ie. AFAICT CAP_NET_TRANSPARENT is =
a
> subset of CAP_NET_RAW
>=20
> f) Add a new capability: Make it require CAP_NET_TRANSPARENT instead
> of CAP_NET_ADMIN
>=20
>   Not backward compatible, introduces a new capability, however, long
> term this is probably the cleanest.
>=20
> My personal vote is for (f).  I figure the number of non-root-apps
> that have CAP_NET_ADMIN in order to get IP{,V6}_TRANSPARENT support i=
s
> very low, and they should be easy to fix to request
> CAP_NET_TRANSPARENT instead.

I was a bit involved in a capability change earlier, in the syslog-ng
context. It is quite ugly, but doable.

=46or a new capability to work correctly the following changes must
trickle down to distributions:

  1) new kernel
  2) very recent glibc
  3) new libcap (both devel & runtime)
  4) patched applications (compiled against a new libcap)

If any of those is not yet patched, it won't work. Users tend to upgrad=
e
the kernel and applications but rarely do so with the rest of the
userspace stack, e.g. libcap, which has caused some pain with syslog-ng=
=2E

The way that it was did for CAP_SYSLOG is that for a time CAP_SYSLOG
already worked, and the older cap CAP_SYS_ADMIN works too, but displays
an ugly oops-like kernel warning.

Certainly all of these can be worked around:

1) kernel

well, it's up to the user, but if the kernel is older than the one whic=
h
supports CAP_NET_TRANSPARENT, there's no issue.

2) glibc

The only way to detect if the kernel supports cap is to read the
capability bounding set, which uses a prctl() option that is defined by
a very new glibc (and kernel 2.6.25)

In syslog-ng, we had to define the value for PR_CAPBSET_READ in case it
wasn't defined.

3) libcap

The value for CAP_NET_TRANSPARENT is in the header file (e.g. devel
package), but that's not enough. We've seen distros, where the header
did contain the capability, but the runtime didn't know about the new
cap. I'm not sure why that happens, but it did on Fedora 15

https://bugzilla.balabit.com/show_bug.cgi?id=3D108#c24

The runtime needs to know about the new capability when transforming a
string representation to a bitset.

4) new apps

Well, the solution is not very easy to get right, and there's still som=
e
problems with syslog-ng even after a couple of rounds. (see the end of
the quoted bugzilla ticket).

All this described to say that it is certainly doable, but requires
effort to get right and will definitely need to define a grace period
for which it is backward compatible.=20

Somewhat less effort is needed if we reuse CAP_NET_RAW though, since
that is already in all kernels/libcap/glibc versions.

All that much said, I would vote for CAP_NET_RAW, and a grace period of
a couple of kernel releases, until the kernel displays a warning, like
it did with the CAP_SYSLOG case.

I'm a bit overwhelmed with stuff though, and would be happy if someone
else could prepare the necessary changes. But if someone does, I'd
recommend reading the CAP_SYSLOG related changes in kernel history to
avoid repeating the same mistakes.

--=20
Bazsi
