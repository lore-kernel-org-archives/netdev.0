From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Fri, 7 Oct 2011 07:40:18 -0400
Message-ID: <20111007114017.GA1165@zod.bos.redhat.com>
References: <20111005202723.GE2479@zod.bos.redhat.com>
 <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
 <20111006132353.GF2479@zod.bos.redhat.com>
 <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
 <1317972573.3457.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joel Sing <jsing@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965366Ab1JGLkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 07:40:37 -0400
Content-Disposition: inline
In-Reply-To: <1317972573.3457.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 09:29:33AM +0200, Eric Dumazet wrote:
> Le vendredi 07 octobre 2011 =E0 18:02 +1100, Joel Sing a =E9crit :
> > > > > We've had a report [1] of a change in behavior when trying to=
 use an IP
> > > > > alias to tftp from a loopback device.  Apparently the steps o=
utlined in
> > > > > [1] https://bugzilla.redhat.com/show_bug.cgi?id=3D739534
> > >
> > > Yep.  That is exactly what my git bisect said too.
> > >
> > > So now we have a change in behavior since that commit for the use=
case
> > > described in the bug above, but I'm unsure if that usecase was ev=
er
> > > really valid or if the commit had unintentional side effects.
> > >
> > > Joel (or anyone else) can you take a look and comment?
> >=20
> > Prior to this commit the src address in the local routing table was
> > completely ignored, so connecting to a local address always used th=
e
> > same source and destination addresses. However, this is not what wa=
s
> > configured in the local routing table:
> >=20
> >   $ ifconfig lo:0 127.0.0.2
> >   $ ip route show table local | grep 127.0.0.2
> >   local 127.0.0.2 dev lo  proto kernel  scope host  src 127.0.0.1
> >=20
> > When an interface has an alias configured, the source address
> > installed in the local routing table is always the primary address =
for
> > the interface. The tftp use case you've described now breaks due to
> > the way that in.tftpd is determining the reply address (as document=
ed
> > in the in.tftpd manual page). This means that it is now responding
> > from 127.0.0.1 even though the client connected to 127.0.0.2. Bindi=
ng
> > inetd to a specific address will avoid this issue.
> >=20
> > I have not yet looked to see if there is a specific reason for the
> > source address selection, however one way of restoring the previous
> > behaviour (whilst still respecting the configured source address)
> > would be to use a default source address which matches the configur=
ed
> > address (as is done for primary addresses). I cannot immediately th=
ink
> > of a reason not to do this, but I've not gone looking at the code.
> >=20
> > Worst case scenario if you specifically need the original behaviour
> > then the source address can be changed in the local routing table:
> >=20
> >   $ ip route change table local local 127.0.0.2 dev lo:0 proto kern=
el
> > scope host src 127.0.0.2
> >   $ ip route show table local | grep 127.0.0.2
> >   local 127.0.0.2 dev lo  proto kernel  scope host  src 127.0.0.2
>=20
> Agreed.
>=20
> The "table local" bit is really the key, because following naive setu=
p
> doesnt work.
>=20
> # ip addr add 127.0.0.11/8 dev lo
> # ip route add 127.0.0.11 dev lo src 127.0.0.11
>=20
> since 127.0.0.1 will still be the src address selected for connection=
s.
>=20
> # ip ro show table local | grep 127.0.0.11
> local 127.0.0.11 dev lo  proto kernel  scope host  src 127.0.0.1=20

The original bug reporter explained the loopback testcase is simply a
trivial example to illustrate the problem.  The real setup seems to be:

"I have a hardware (Dell PC) booting over the network with PXE, this
hardware try to load it system from a tftp server. If I used the real
ip of the tftp server I have no problem, if I used an alias I have the
problem (I have to use an alias, because I have a Cluster).

What I think, the bios tftp client talk to the server with the IP alias
but the server reply with the real IP and the client reject the reply."

So in this case, because the alias is being used in a cluster, should h=
e
also setup the local routing table as you suggested?

I apologize for my lack of depth here.  I'm at the moment somewhat of a
go-between.  I do greatly appreciate the help!

josh
