From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Fri, 07 Sep 2007 15:27:15 +0200
Message-ID: <1189171635.28781.134.camel@johannes.berg>
References: <E1ITGb2-0006Be-00@gondolin.me.apana.org.au>
	 <1189085815.28781.78.camel@johannes.berg>
	 <20070906154612.GD8030@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-imVPaHEyew32QsvR1ZR0"
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	flo-BCn6idZOOBwdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070906154612.GD8030-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-imVPaHEyew32QsvR1ZR0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-09-06 at 08:46 -0700, Paul E. McKenney wrote:

> Looks good to me from an RCU viewpoint.  I cannot claim familiarity with
> this code.  I therefore especially like the indications of where RTNL
> is held and not!!!

:)

> Some questions below based on a quick scan.  And a global question:
> should the comments about RTNL being held be replaced by ASSERT_RTNL()?

I don't like ASSERT_RTNL() much because it actually tries to lock it.
I'd be much happer if it was WARN_ON(!mutex_locked(&rtnl_mutex)) or
something equivalent.

In any case, I have an updated patch I'll be sending soon, and it
requires a new list walking primitive I'll also send.

> > -	write_lock_bh(&local->sub_if_lock);
> > +	/* we're under RTNL so all this is fine */
> >  	if (unlikely(local->reg_state =3D=3D IEEE80211_DEV_UNREGISTERED)) {
> > -		write_unlock_bh(&local->sub_if_lock);
> >  		__ieee80211_if_del(local, sdata);
> >  		return -ENODEV;
> >  	}
> > -	list_add(&sdata->list, &local->sub_if_list);
> > +	list_add_tail_rcu(&sdata->list, &local->interfaces);
>=20
> The _rcu is required because this list isn't protected by RTNL?

Yes, not all walkers of the list are protected by the RTNL.

> > @@ -226,22 +225,22 @@ void ieee80211_if_reinit(struct net_devi
> >  		/* Remove all virtual interfaces that use this BSS
> >  		 * as their sdata->bss */
> >  		struct ieee80211_sub_if_data *tsdata, *n;
> > -		LIST_HEAD(tmp_list);
> >=20
> > -		write_lock_bh(&local->sub_if_lock);
>=20
> This code is also protected by RTNL?

Yes.

> >  	ASSERT_RTNL();
>=20
> I -like- this!!!  ;-)

:)

johannes

--=-imVPaHEyew32QsvR1ZR0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG4VGz/ETPhpq3jKURAk4uAJ44/b4KhPZcg9DshBthgJxOqAeCsACfeQEB
OLpwbHwLWsKVa05IHgHA+Vk=
=VyBx
-----END PGP SIGNATURE-----

--=-imVPaHEyew32QsvR1ZR0--
