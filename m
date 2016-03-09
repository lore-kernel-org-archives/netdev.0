From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 1/3] uapi: add MACsec bits
Date: Wed, 9 Mar 2016 11:51:42 +0100
Message-ID: <20160309105142.GA32207@bistromath.redhat.com>
References: <cover.1456937772.git.sd@queasysnail.net>
 <08d3b90c1577276ccbb8ae1794f8c9842df5222d.1456937772.git.sd@queasysnail.net>
 <1457466768.24270.24.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753179AbcCIKvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 05:51:47 -0500
Content-Disposition: inline
In-Reply-To: <1457466768.24270.24.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-03-08, 20:52:48 +0100, Johannes Berg wrote:
> On Mon, 2016-03-07 at 18:12 +0100, Sabrina Dubroca wrote:
>=20
> > +++ b/include/uapi/linux/if_macsec.h
>=20
> Some bits of documentation in this file, regarding all the various
> operations and attributes, might be nice. At least the netlink types?

ok. Most of them are already indicated in the policies, but I can add
some comments here.


> E.g., given this:
>=20
> > +#define DEFAULT_CIPHER_NAME "GCM-AES-128"
> > +#define DEFAULT_CIPHER_ID=C2=A0=C2=A0=C2=A00x0080020001000001ULL
> > +#define DEFAULT_CIPHER_ALT=C2=A0=C2=A00x0080C20001000001ULL
>=20
> > +enum macsec_attrs {
> [...]
> > +	MACSEC_ATTR_CIPHER_SUITE,
>=20
> should that be the ID, the alternate ID, or the string?

uh, the string is never actually used, I could get rid of it.


> > +	MACSEC_ATTR_ICV_LEN,
> > +	MACSEC_TXSA_LIST,
> > +	MACSEC_RXSC_LIST,
> > +	MACSEC_TXSC_STATS,
> > +	MACSEC_SECY_STATS,
> > +	MACSEC_ATTR_PROTECT,
>=20
> This seems a bit inconsistent, MACSEC_ATTR_* vs. MACSEC_*?

Only the MACSEC_ATTR_* can be set, the others are just for dumping.


> > +enum macsec_sa_list_attrs {
> > +	MACSEC_SA_LIST_UNSPEC,
> > +	MACSEC_SA,
> > +	__MACSEC_ATTR_SA_LIST_MAX,
> > +	MACSEC_ATTR_SA_LIST_MAX =3D __MACSEC_ATTR_SA_LIST_MAX - 1,
> > +};
>=20
> Again, without documentation, it seems odd to have an enum with just =
a
> single useful entry? If you just wanted an array you don't need this =
at
> all? The netlink nesting properties could be specified somewhere.

Yes, in dump_secy(), I nest the TXSA_LIST, and then each SA underneath
it.  I'm not sure how that would work without the list.  Can you have
an array without the dummy level of nesting?


> > +enum macsec_rxsc_list_attrs {
> > +	MACSEC_RXSC_LIST_UNSPEC,
> > +	MACSEC_RXSC,
>=20
> similarly here
>=20
> > +enum macsec_rxsc_attrs {
> > +	MACSEC_ATTR_SC_UNSPEC,
> > +	/* use the same value to allow generic helper function, see
> > +	=C2=A0* get_*_from_nl in drivers/net/macsec.c */
> > +	MACSEC_ATTR_SC_IFINDEX =3D MACSEC_ATTR_IFINDEX,
> > +	MACSEC_ATTR_SC_SCI =3D MACSEC_ATTR_SCI,
>=20
> This seems odd, this must be nested inside the top-level attributes
> since it's a single genl family, so why not use the top-level
> attributes to start with?
>=20
> If you need multiple you can use dump with multiple messages.
>=20
> > +enum macsec_sa_attrs {
> > +	MACSEC_ATTR_SA_UNSPEC,
> > +	/* use the same value to allow generic helper function, see
> > +	=C2=A0* get_*_from_nl in drivers/net/macsec.c */
> > +	MACSEC_ATTR_SA_IFINDEX =3D MACSEC_ATTR_IFINDEX,
> > +	MACSEC_ATTR_SA_SCI =3D MACSEC_ATTR_SCI,
>=20
> likewise here
>=20
> > +enum validation_type {
> > +	MACSEC_VALIDATE_DISABLED =3D 0,
> > +	MACSEC_VALIDATE_CHECK =3D 1,
> > +	MACSEC_VALIDATE_STRICT =3D 2,
> > +	__MACSEC_VALIDATE_MAX,
> > +};
> > +#define MACSEC_VALIDATE_MAX (__MACSEC_VALIDATE_MAX - 1)
>=20
> everywhere else you put that into the enum, why not here?

Will fix.


> > +struct macsec_rx_sc_stats {
> > +	__u64 InOctetsValidated;
> > +	__u64 InOctetsDecrypted;
> > +	__u64 InPktsUnchecked;
> > +	__u64 InPktsDelayed;
> > +	__u64 InPktsOK;
> > +	__u64 InPktsInvalid;
> > +	__u64 InPktsLate;
> > +	__u64 InPktsNotValid;
> > +	__u64 InPktsNotUsingSA;
> > +	__u64 InPktsUnusedSA;
> > +};
>=20
> It might be worth splitting those into attributes so that, if some
> hardware offload can't provide all of the counters in the future, the=
y
> can just be left out of the netlink message?

These stats are defined by the standard, but marked optional.
A hardware device that doesn't implement some stat could just ignore
it and export 0.
I don't have a strong opinion about this.


Thanks,

--=20
Sabrina
