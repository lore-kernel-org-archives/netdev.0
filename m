From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Fri, 07 Oct 2011 09:29:33 +0200
Message-ID: <1317972573.3457.55.camel@edumazet-laptop>
References: <20111005202723.GE2479@zod.bos.redhat.com>
	 <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
	 <20111006132353.GF2479@zod.bos.redhat.com>
	 <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Boyer <jwboyer@redhat.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Joel Sing <jsing@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60661 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab1JGH3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 03:29:41 -0400
Received: by wyg34 with SMTP id 34so3587028wyg.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 00:29:39 -0700 (PDT)
In-Reply-To: <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 octobre 2011 =C3=A0 18:02 +1100, Joel Sing a =C3=A9crit =
:
> On 7 October 2011 00:23, Josh Boyer <jwboyer@redhat.com> wrote:
> >
> > On Thu, Oct 06, 2011 at 12:18:44AM +0300, Julian Anastasov wrote:
> > >
> > >       Hello,
> > >
> > > On Wed, 5 Oct 2011, Josh Boyer wrote:
> > >
> > > > Hi All,
> > > >
> > > > We've had a report [1] of a change in behavior when trying to u=
se an IP
> > > > alias to tftp from a loopback device.  Apparently the steps out=
lined in
> > > > the bug worked in 2.6.35, and broke somewhere before 2.6.38.6.
> > > >
> > > > I can confirm the steps fail on a 3.0 based kernel and I'm tryi=
ng to do
> > > > a git bisect to find the commit involved, but I thought I would=
 send
> > > > this along to see if anyone might have an idea.  (Also, I'm not=
 really
> > > > sure how valid of a usecase this was to begin with.)
> > >
> > >       What about commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c =
?
> > >
> > > ipv4/route.c: respect prefsrc for local routes
> > >
> > > http://marc.info/?t=3D129412232500001&r=3D1&w=3D2
> > >
> > > > [1] https://bugzilla.redhat.com/show_bug.cgi?id=3D739534
> >
> > Yep.  That is exactly what my git bisect said too.
> >
> > So now we have a change in behavior since that commit for the useca=
se
> > described in the bug above, but I'm unsure if that usecase was ever
> > really valid or if the commit had unintentional side effects.
> >
> > Joel (or anyone else) can you take a look and comment?
>=20
> Prior to this commit the src address in the local routing table was
> completely ignored, so connecting to a local address always used the
> same source and destination addresses. However, this is not what was
> configured in the local routing table:
>=20
>   $ ifconfig lo:0 127.0.0.2
>   $ ip route show table local | grep 127.0.0.2
>   local 127.0.0.2 dev lo  proto kernel  scope host  src 127.0.0.1
>=20
> When an interface has an alias configured, the source address
> installed in the local routing table is always the primary address fo=
r
> the interface. The tftp use case you've described now breaks due to
> the way that in.tftpd is determining the reply address (as documented
> in the in.tftpd manual page). This means that it is now responding
> from 127.0.0.1 even though the client connected to 127.0.0.2. Binding
> inetd to a specific address will avoid this issue.
>=20
> I have not yet looked to see if there is a specific reason for the
> source address selection, however one way of restoring the previous
> behaviour (whilst still respecting the configured source address)
> would be to use a default source address which matches the configured
> address (as is done for primary addresses). I cannot immediately thin=
k
> of a reason not to do this, but I've not gone looking at the code.
>=20
> Worst case scenario if you specifically need the original behaviour
> then the source address can be changed in the local routing table:
>=20
>   $ ip route change table local local 127.0.0.2 dev lo:0 proto kernel
> scope host src 127.0.0.2
>   $ ip route show table local | grep 127.0.0.2
>   local 127.0.0.2 dev lo  proto kernel  scope host  src 127.0.0.2

Agreed.

The "table local" bit is really the key, because following naive setup
doesnt work.

# ip addr add 127.0.0.11/8 dev lo
# ip route add 127.0.0.11 dev lo src 127.0.0.11

since 127.0.0.1 will still be the src address selected for connections.

# ip ro show table local | grep 127.0.0.11
local 127.0.0.11 dev lo  proto kernel  scope host  src 127.0.0.1=20
