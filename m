From: Joel Sing <jsing@google.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Fri, 7 Oct 2011 18:02:57 +1100
Message-ID: <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
References: <20111005202723.GE2479@zod.bos.redhat.com>
	<alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
	<20111006132353.GF2479@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21475 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1JGHDB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 03:03:01 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p97730Iu029146
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 00:03:00 -0700
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by wpaz33.hot.corp.google.com with ESMTP id p9771ZsK025099
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 00:02:59 -0700
Received: by pzk34 with SMTP id 34so12519600pzk.6
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 00:02:59 -0700 (PDT)
In-Reply-To: <20111006132353.GF2479@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 October 2011 00:23, Josh Boyer <jwboyer@redhat.com> wrote:
>
> On Thu, Oct 06, 2011 at 12:18:44AM +0300, Julian Anastasov wrote:
> >
> > =A0 =A0 =A0 Hello,
> >
> > On Wed, 5 Oct 2011, Josh Boyer wrote:
> >
> > > Hi All,
> > >
> > > We've had a report [1] of a change in behavior when trying to use=
 an IP
> > > alias to tftp from a loopback device. =A0Apparently the steps out=
lined in
> > > the bug worked in 2.6.35, and broke somewhere before 2.6.38.6.
> > >
> > > I can confirm the steps fail on a 3.0 based kernel and I'm trying=
 to do
> > > a git bisect to find the commit involved, but I thought I would s=
end
> > > this along to see if anyone might have an idea. =A0(Also, I'm not=
 really
> > > sure how valid of a usecase this was to begin with.)
> >
> > =A0 =A0 =A0 What about commit 9fc3bbb4a752f108cf096d96640f3b548bbbc=
e6c ?
> >
> > ipv4/route.c: respect prefsrc for local routes
> >
> > http://marc.info/?t=3D129412232500001&r=3D1&w=3D2
> >
> > > [1] https://bugzilla.redhat.com/show_bug.cgi?id=3D739534
>
> Yep. =A0That is exactly what my git bisect said too.
>
> So now we have a change in behavior since that commit for the usecase
> described in the bug above, but I'm unsure if that usecase was ever
> really valid or if the commit had unintentional side effects.
>
> Joel (or anyone else) can you take a look and comment?

Prior to this commit the src address in the local routing table was
completely ignored, so connecting to a local address always used the
same source and destination addresses. However, this is not what was
configured in the local routing table:

=A0 $ ifconfig lo:0 127.0.0.2
=A0 $ ip route show table local | grep 127.0.0.2
=A0 local 127.0.0.2 dev lo =A0proto kernel =A0scope host =A0src 127.0.0=
=2E1

When an interface has an alias configured, the source address
installed in the=A0local routing table=A0is always the primary address =
for
the interface.=A0The tftp use case you've described now breaks due to
the way that in.tftpd is determining the reply address (as documented
in the in.tftpd manual page). This means that it is now responding
from 127.0.0.1 even though the client connected to 127.0.0.2. Binding
inetd to a specific address will avoid this issue.

I have not yet looked to see if there is a specific reason for the
source address selection, however one way of restoring the previous
behaviour (whilst still respecting the configured source address)
would be to use a default source address which matches the configured
address (as is done for primary addresses). I cannot immediately think
of a reason not to do this, but I've not gone looking at the code.

Worst case scenario if you specifically need the original behaviour
then the source address can be changed in the local routing table:

  $ ip route change table local local 127.0.0.2 dev lo:0 proto kernel
scope host src 127.0.0.2
  $ ip route show table local | grep 127.0.0.2
  local 127.0.0.2 dev lo =A0proto kernel =A0scope host =A0src 127.0.0.2
