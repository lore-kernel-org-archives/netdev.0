From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Wed, 9 Mar 2016 11:56:14 +0100
Message-ID: <20160309105614.GA24911@bistromath.redhat.com>
References: <cover.1456937772.git.sd@queasysnail.net>
 <d7145f6037142ea5134be0402e014a9c72f7b8d4.1456937772.git.sd@queasysnail.net>
 <1457468033.24270.38.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbcCIK4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 05:56:18 -0500
Content-Disposition: inline
In-Reply-To: <1457468033.24270.38.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-03-08, 21:13:53 +0100, Johannes Berg wrote:
> On Mon, 2016-03-07 at 18:12 +0100, Sabrina Dubroca wrote:
> >=C2=A0
> > +struct gcm_iv {
> > +	union {
> > +		u8 secure_channel_id[8];
> > +		sci_t sci;
> > +	};
> > +	__be32 pn;
> > +};
>=20
> Should this be __packed?

I think that's not necessary here.


> But the struct is confusing; sci_t is a host type (that depends on
> endianness), and __be32 would seem to be a network type, how can they
> both be in the same struct? Or does sci_t have to be __be64?
>=20
> > +/**
> > + * struct macsec_rx_sa - receive secure association
> > + * @active
> > + * @next_pn packet number expected for the next packet
> > + * @lock protects next_pn manipulations
> > + * @key key structure
> > + * @stats per-SA stats
> > + */
> > +struct macsec_rx_sa {
> > +	bool active;
> > +	u32 next_pn;
> > +	spinlock_t lock;
>=20
> If you put the spinlock first or at least next to active you can get
> rid of some padding (on arches/configs where spinlock is small, at
> least)

Ok, I rearranged macsec_rx_sa and macsec_tx_sa.


> > +/**
> > + * struct macsec_rx_sc - receive secure channel
> > + * @sci secure channel identifier for this SC
> > + * @active channel is active
> > + * @sa array of secure associations
> > + * @stats per-SC stats
> > + */
>=20
> Btw, all your kernel-doc comments are actually malformed, they're
> missing a colon after the @member, e.g.
>=20
> =C2=A0@stats: per-SC stats

duh, I never noticed that :(
Thanks.


> > +struct macsec_tx_sc {
> > +	bool active;
> > +	u8 encoding_sa;
> > +	bool encrypt;
> > +	bool send_sci;
> > +	bool end_station;
> > +	bool scb;
> > +	struct macsec_tx_sa __rcu *sa[4];
>=20
>=20
> What's 4?

Good point.  I added:

    #define MACSEC_NUM_AN 4 /* 2 bits for the association number */

and used it in all the range tests (< 4, >=3D 3).


> > +static sci_t make_sci(u8 *addr, __be16 port)
> > +{
> > +	sci_t sci;
> > +
> > +	memcpy(&sci, addr, ETH_ALEN);
> > +	memcpy(((char *)&sci) + ETH_ALEN, &port, sizeof(port));
> > +
> > +	return sci;
> > +}
>=20
> Oh, maybe this explains my earlier question - looks like the sci_t
> isn't really a 64-bit integer but some kind of structure.

Yes, the bits in the SCI have some meaning.


> Is there really much point in using a __bitwise u64 typedef, rather
> than a small packed struct then?

I can use =3D=3D tests, as in find_rx_sc().


> > +/* minimum secure data length deemed "not short", see IEEE 802.1AE=
-
> > 2006 9.7 */
> > +#define MIN_NON_SHORT_LEN 48
>=20
> I saw
>=20
> > +#define MACSEC_SHORTLEN_THR 48
>=20
> before, are they different? Seem very similar.

They are exactly the same, good catch.


> > +	tx_sa->next_pn++;
> > +	if (tx_sa->next_pn =3D=3D 0) {
> > +		pr_debug("PN wrapped, transitionning to !oper\n");
>=20
> typo: transitioning

=46ixed.


> > +static const struct genl_ops macsec_genl_ops[] =3D {
> > +	{
> > +		.cmd =3D MACSEC_CMD_GET_TXSC,
> > +		.dumpit =3D macsec_dump_txsc,
> > +		.policy =3D macsec_genl_policy,
> > +	},
> > +	{
> > +		.cmd =3D MACSEC_CMD_ADD_RXSC,
> > +		.doit =3D macsec_add_rxsc,
> > +		.policy =3D macsec_genl_rxsc_policy,
> > +		.flags =3D GENL_ADMIN_PERM,
>=20
> IMHO, having different policies for different operations is pretty
> confusing. I now slowly start to understand why you had to do all thi=
s
> aliasing with the IDs. However, perhaps it'd be better to define a to=
p-
> level attribute list with the ifindex etc., and make all the
> *additional* data needed for RXSC operations for example go into a
> nested attribute in the top-level.
>=20
> That way, you have the same policy for everything and also don't have
> to play tricks with the aliasing since the top-level attributes
> actually exist now, coming from the same namespace & policy.

That's a good idea, I'll have a look today.
I don't really like the aliasing games I have to play, but I'd like to
keep the RXSC attributes separate from the SA attributes, I think it
looks cleaner (the first RFC had everything in the same policy:
http://www.spinics.net/lists/netdev/msg358152.html).


Thanks for the review.

--=20
Sabrina
