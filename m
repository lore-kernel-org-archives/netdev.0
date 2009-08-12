From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Wed, 12 Aug 2009 13:50:31 +1000
Message-ID: <20090812135031.a38be3f6.sfr@canb.auug.org.au>
References: <1249985224.13065.11.camel@HunTEr>
	<1250035061.30166.42.camel@localhost.localdomain>
	<20090811202459.7f98e496@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__12_Aug_2009_13_50_31_+1000_qeL/MrprRHGAboFA"
Cc: Marcel Holtmann <marcel@holtmann.org>, vibi_sreenivasan@cms.com,
	netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Thomas Graf <tgraf@suug.ch>,
	linux-next <linux-next@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090811202459.7f98e496@nehalam>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__12_Aug_2009_13_50_31_+1000_qeL/MrprRHGAboFA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 11 Aug 2009 20:24:59 -0700 Stephen Hemminger <shemminger@vyatta.com=
> wrote:
>
> > > @@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *fa=
mily,
> > >  {
> > >         int id;
> > >         unsigned long *new_groups;
> > > -       int err;
> > > +       int err =3D 0;
> > > =20
> > >         BUG_ON(grp->name[0] =3D=3D '\0');
> >=20
> > this looks fishy. How does gcc thinks this variable is uninitialized. If
> > I look at the code in Linus' tree, I don't see it.
>=20
> Agreed, and the line numbers are off.

In the -next tree, it looks like this:

int genl_register_mc_group(struct genl_family *family,
			   struct genl_multicast_group *grp)
{
	int id;
	unsigned long *new_groups;
	int err;

	BUG_ON(grp->name[0] =3D=3D '\0');

	genl_lock();

	/* special-case our own group */
	if (grp =3D=3D &notify_grp)
		id =3D GENL_ID_CTRL;
	else
		id =3D find_first_zero_bit(mc_groups,
					 mc_groups_longs * BITS_PER_LONG);


	if (id >=3D mc_groups_longs * BITS_PER_LONG) {
		size_t nlen =3D (mc_groups_longs + 1) * sizeof(unsigned long);

		if (mc_groups =3D=3D &mc_group_start) {
			new_groups =3D kzalloc(nlen, GFP_KERNEL);
			if (!new_groups) {
				err =3D -ENOMEM;
				goto out;
			}
			mc_groups =3D new_groups;
			*mc_groups =3D mc_group_start;
		} else {
			new_groups =3D krealloc(mc_groups, nlen, GFP_KERNEL);
			if (!new_groups) {
				err =3D -ENOMEM;
				goto out;
			}
			mc_groups =3D new_groups;
			mc_groups[mc_groups_longs] =3D 0;
		}
		mc_groups_longs++;
	}

	if (family->netnsok) {
		struct net *net;

		rcu_read_lock();
		for_each_net_rcu(net) {
			err =3D netlink_change_ngroups(net->genl_sock,
					mc_groups_longs * BITS_PER_LONG);
			if (err) {
				rcu_read_unlock();
				goto out;
			}
		}
		rcu_read_unlock();
	} else {
		err =3D netlink_change_ngroups(init_net.genl_sock,
					     mc_groups_longs * BITS_PER_LONG);
		if (err)
			goto out;
	}

	grp->id =3D id;
	set_bit(id, mc_groups);
	list_add_tail(&grp->list, &family->mcast_groups);
	grp->family =3D family;

	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, grp);
 out:
	genl_unlock();
	return err;
}

so if family->netnsok is true and the for_each_net_rcu loop executes 0
times, err will not be set ...  Now, that may not be logically possible,
but I can't tell that from this code.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__12_Aug_2009_13_50_31_+1000_qeL/MrprRHGAboFA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqCPAgACgkQjjKRsyhoI8ycFQCfcnYK80mw5E5W8V6Q9UDHFfVf
8ZUAoJ5ZRQO3nz3i38EeHTzXhHSIvsY8
=kH5a
-----END PGP SIGNATURE-----

--Signature=_Wed__12_Aug_2009_13_50_31_+1000_qeL/MrprRHGAboFA--
