From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: Re: [ipv6] valid_lft and active connections
Date: Tue, 14 Jun 2011 14:27:50 +0200
Message-ID: <4DF753C6.1000700@samba.org>
References: <4DF73A6D.1050809@samba.org> <1308051710.3424.15.camel@takos>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE249601641A5130FB6FB8111"
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:55898 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab1FNM1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 08:27:55 -0400
In-Reply-To: <1308051710.3424.15.camel@takos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE249601641A5130FB6FB8111
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: quoted-printable

Am 14.06.2011 13:41, schrieb YOSHIFUJI Hideaki:
> Hello.
>=20
> Stefan (metze) Metzmacher wrote:
>> If I use ipv6 addresses with valid_lft !=3D forever, the ipv6 addresse=
s
>> are removed from the interface if the valid_lft expires, even if there=
're
>> established connection which use with address.
>>
>> Would it be possible keep the address until the last active connection=

>> is closed? Otherwise the usable of the privacy extensions will make
>> very long living tcp connections impossible.
>>
>=20
> I cannot imagine why you do not hear RAs before the address expires.

They do not reset the valid lifetime counter for temporary addresses.

And I think that valid_lft and preferred_lft should work with a manual
configured setup in a similar way.

> And well, I don't think it is a good idea because it is not what
> "valid lifetime" means.
>=20
> We have 3 states:
>=20
> 1) time <=3D preferred lifetime
> 2) preferred lifetime < time <=3D valid lifetime
> 3) valid lifetime < lifetime
>=20
> You can make new connection during the period of 1 and you can continue=

> using that connection during the period of 1 and 2.

But it means tcp connection can not last longer than the valid lifetime o=
f
a temporary address, which is very ugly as the application layer will
run into
timeouts instead of getting an immediate error when the kernel drops the
related ip.

> Ask network administrator to advertise longer "valid" lifetime, if
> needed, and you may want to make net.ipv6.conf.*.max_addresses larger.

My aim is to have a preferred lifetime of say 4 hours, in order to have
no limit
on the lifetime of tcp connections, I'd have to set valid lifetime to
forever,
which means that I'll have about 180 addresses on an interface after
a month (8760 after a year) which are mostly all unused.

I think there should be some autocleanup based on the usage
of addresses, maybe there's a different solution for the problem.

Maybe RAs should reset the valid_lft of temporary addresses (from
autoconfiguration)
if the ip is in use? In which case I would accept that I need to do the
cleanup
in user space via cron, if I assign dynamic addresses also via cron.

>> It would be also ok to add a new special value "used" similar to "fore=
ver",
>> which triggers the modified behavior.

ip -6 addr add $addr valid_lft used preferred_lft  14400
would be nice to have.

It will add $addr which will be used for new connections for the next 4
hours,
if it's unused then it gets deleted, if not it stays until the last
connection went away.

But I would preferr if such a bahavior would be the default, so that
I can use:

ip -6 addr add $addr valid_lft  28800 preferred_lft  14400,
which mean that $addr will be used for new connections during the next 4
hours,
$addr will stay at least for the next 8 hours, if they're still active
connections
and the same interface has an other ip with the same prefix it stays unti=
l
the last connection went away.

And the same logic would apply to addresses assigned via autoconfiguratio=
n.

Do you know a better solution?

metze


--------------enigE249601641A5130FB6FB8111
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk33U8YACgkQm70gjA5TCD9dzwCgt0DX1wxdwbpw/GywCtF6DQNt
4z0An3gWKpLWODTR/hg3+quZ13ckc4lx
=8NZ7
-----END PGP SIGNATURE-----

--------------enigE249601641A5130FB6FB8111--
