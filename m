From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Tue, 5 Mar 2013 17:00:44 +0000
Message-ID: <1362502844.2791.32.camel@bwh-desktop.uk.solarflarecom.com>
References: <512F1534.9020404@asianux.com>
	    <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
	    <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com>
	   <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>
	   <51355936.3060307@asianux.com>
	  <1362453419.3768.380.camel@deadeye.wl.decadent.org.uk>
	  <51356735.4020405@asianux.com>
	 <1362454672.3768.383.camel@deadeye.wl.decadent.org.uk>
	 <51356FED.4070909@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	<venkat.x.venkatsubra@oracle.com>,
	David Miller <davem@davemloft.net>, <rds-devel@oss.oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29206 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756214Ab3CERBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 12:01:06 -0500
In-Reply-To: <51356FED.4070909@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 12:09 +0800, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B403=E6=9C=8805=E6=97=A5 11:37, Ben Hutchings =E5=
=86=99=E9=81=93:
> >>   I think what I have done is just like your choice "2."
> >> >   for me, I think they are equal:
> >> >=20
> >> > -		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
> >> > +		strlcpy(ctr.name, names[i], sizeof(ctr.name));
> >> >=20
> >> >=20
> >> > 		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
> >> > + 		ctr.name[sizeof(ctr.name) - 1] =3D '\0';
> > They are not.  strncpy() pads with zeroes to the end of the given b=
uffer
> > whereas strlcpy() adds only a single zero byte (and truncates if
> > necessary to fit the zero byte).
>=20
>   ok, thank you. they are really not the same (originally, I did not
> notice it)
>=20
>   could you supply the reason:
>     why need we zero all of ctr.name ?
>     (for me, I think, keeping ctr.name just a zero-based string is ok=
)

This function calls rds_copy_info() to copy the whole of ctr into
userland.

If ctr is not completely initialised, then the values of the
uninitialised bytes are left over from the local variables of an earlie=
r
system call.  If an attacker knows enough about the stack layout (easy
if this is a distribution kernel), they can make a series of system
calls that leak information about heap-allocated objects.  That can hel=
p
them to exploit other kernel bugs for privilege escalation.  So we
should initialise every bit of memory that is going to be copied to
userland.

(In fact, in general it's not even enough to initialise all fields of
the structure, because there may be padding bytes between them.  In thi=
s
case we know there isn't, because it's declared as packed.)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
