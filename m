From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] netlink: allocate group bitmaps dynamically
Date: Tue, 03 Jul 2007 16:09:00 +0200
Message-ID: <1183471741.3722.6.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>
	 <1183125924.4089.73.camel@johannes.berg>
	 <1183126739.4089.76.camel@johannes.berg>
	 <1183129006.4089.84.camel@johannes.berg>
	 <1183217536.5165.25.camel@localhost>
	 <1183365821.4089.94.camel@johannes.berg>  <4688F612.1060408@trash.net>
	 <1183386883.4089.120.camel@johannes.ber g>  <46890DF8.2020706@trash.net>
	 <1183387687.4089.124.camel@johannes.berg>
	 <1183414370.4089.141.camel@johannes.berg>
	 <1183457329.3841.0.camel@johannes.berg>  <468A3BA5.9050909@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-hRfo6ntxuv3IG13bJVnK"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60470 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755608AbXGCOJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 10:09:11 -0400
In-Reply-To: <468A3BA5.9050909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-hRfo6ntxuv3IG13bJVnK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-07-03 at 14:05 +0200, Patrick McHardy wrote:

> > --- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-03 00:10:31.6178=
89695 +0200
> > +++ wireless-dev/net/netlink/af_netlink.c	2007-07-03 00:31:30.267889695=
 +0200
> > @@ -316,8 +316,11 @@ netlink_update_listeners(struct sock *sk
> > =20
> >  	for (i =3D 0; i < NLGRPSZ(tbl->groups)/sizeof(unsigned long); i++) {
> >  		mask =3D 0;
> > -		sk_for_each_bound(sk, node, &tbl->mc_list)
> > -			mask |=3D nlk_sk(sk)->groups[i];
> > +		sk_for_each_bound(sk, node, &tbl->mc_list) {
> > +			if (nlk_sk(sk)->ngroups >=3D
> > +			    (i + 1) * sizeof(unsigned long))
>=20
>=20
> This condition implies that a socket can bind to a non-existant
> group, which shouldn't be possible.

Actually, it's the other way around, the socket can bind to group 10
only 32 groups are present (one unsigned long) and then some other code
goes to add groups increasing the limit to 64, and then the socket still
only has a bitmap with 32 bits (one unsigned long) and we shouldn't
access beyond that just because the number of groups was increased.

However, you can in fact bind non-existing groups as long as the group
number is lower than the maximum, i.e. if you start out with just one
group as genetlink does, the netlink code increases that to 32 and you
can bind group 25 even if generic netlink doesn't know about it yet. I
plan to fix that when it actually matters, i.e. when I introduce
per-group permission checks.

> > +				mask |=3D nlk_sk(sk)->groups[i];
> > +		}
> >  		tbl->listeners[i] =3D mask;
> >  	}
> >  	/* this function is only called with the netlink table "grabbed", whi=
ch
> > @@ -555,10 +558,11 @@ netlink_update_subscriptions(struct sock
> >  	nlk->subscriptions =3D subscriptions;
> >  }
> > =20
> > -static int netlink_alloc_groups(struct sock *sk)
> > +static int netlink_realloc_groups(struct sock *sk)
> >  {
> >  	struct netlink_sock *nlk =3D nlk_sk(sk);
> >  	unsigned int groups;
> > +	unsigned long *new_groups;
> >  	int err =3D 0;
> > =20
> >  	netlink_lock_table();
> > @@ -570,9 +574,15 @@ static int netlink_alloc_groups(struct s
> >  	if (err)
> >  		return err;
> > =20
> > -	nlk->groups =3D kzalloc(NLGRPSZ(groups), GFP_KERNEL);
> > -	if (nlk->groups =3D=3D NULL)
> > +	if (nlk->ngroups >=3D groups)
> > +		return 0;
> > +
> > +	new_groups =3D krealloc(nlk->groups, NLGRPSZ(groups), GFP_KERNEL);
> > +	if (new_groups =3D=3D NULL)
> >  		return -ENOMEM;
> > +	memset((char*)new_groups + NLGRPSZ(nlk->ngroups), 0,
> > +	       NLGRPSZ(groups) - NLGRPSZ(nlk->ngroups));
> > +	nlk->groups =3D new_groups;
>=20
>=20
> This should probably happen with the table grabbed to avoid races
> with concurrent broadcasts.

Hmm, possibly, I'll have to look again.

> > +int netlink_change_ngroups(int unit, unsigned int groups)
> > +{
> > +	unsigned long *listeners;
> > +	int err =3D 0;
> > +
> > +	netlink_table_grab();
>=20
>=20
> Unfortunately that doesn't prevent races with netlink_has_listeners
> since its lockless (and should really stay that way).

Uh huh. Good point, I guess I'll have to use RCU or such here when
changing the listeners bitmap size.

johannes

--=-hRfo6ntxuv3IG13bJVnK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGilh8/ETPhpq3jKURAieQAKCPEUiA4FB1oq6B9ubKCRIHk8kniwCggU3K
cgyfH5RUV9s6CDJDleAwHc8=
=UJwq
-----END PGP SIGNATURE-----

--=-hRfo6ntxuv3IG13bJVnK--

