From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 3/3] macsec: introduce IEEE 802.1AE driver
Date: Tue, 08 Mar 2016 21:13:53 +0100
Message-ID: <1457468033.24270.38.camel@sipsolutions.net>
References: <cover.1456937772.git.sd@queasysnail.net>
	 <d7145f6037142ea5134be0402e014a9c72f7b8d4.1456937772.git.sd@queasysnail.net>
	 (sfid-20160307_181311_294856_FFC6A2EE)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>, stephen@networkplumber.org
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39521 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbcCHUOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 15:14:03 -0500
In-Reply-To: <d7145f6037142ea5134be0402e014a9c72f7b8d4.1456937772.git.sd@queasysnail.net> (sfid-20160307_181311_294856_FFC6A2EE)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-07 at 18:12 +0100, Sabrina Dubroca wrote:
>=C2=A0
> +struct gcm_iv {
> +	union {
> +		u8 secure_channel_id[8];
> +		sci_t sci;
> +	};
> +	__be32 pn;
> +};

Should this be __packed?

But the struct is confusing; sci_t is a host type (that depends on
endianness), and __be32 would seem to be a network type, how can they
both be in the same struct? Or does sci_t have to be __be64?

> +/**
> + * struct macsec_rx_sa - receive secure association
> + * @active
> + * @next_pn packet number expected for the next packet
> + * @lock protects next_pn manipulations
> + * @key key structure
> + * @stats per-SA stats
> + */
> +struct macsec_rx_sa {
> +	bool active;
> +	u32 next_pn;
> +	spinlock_t lock;

If you put the spinlock first or at least next to active you can get
rid of some padding (on arches/configs where spinlock is small, at
least)

> +/**
> + * struct macsec_rx_sc - receive secure channel
> + * @sci secure channel identifier for this SC
> + * @active channel is active
> + * @sa array of secure associations
> + * @stats per-SC stats
> + */

Btw, all your kernel-doc comments are actually malformed, they're
missing a colon after the @member, e.g.

=C2=A0@stats: per-SC stats

> +struct macsec_tx_sc {
> +	bool active;
> +	u8 encoding_sa;
> +	bool encrypt;
> +	bool send_sci;
> +	bool end_station;
> +	bool scb;
> +	struct macsec_tx_sa __rcu *sa[4];


What's 4?

> +static sci_t make_sci(u8 *addr, __be16 port)
> +{
> +	sci_t sci;
> +
> +	memcpy(&sci, addr, ETH_ALEN);
> +	memcpy(((char *)&sci) + ETH_ALEN, &port, sizeof(port));
> +
> +	return sci;
> +}

Oh, maybe this explains my earlier question - looks like the sci_t
isn't really a 64-bit integer but some kind of structure.

Is there really much point in using a __bitwise u64 typedef, rather
than a small packed struct then?

> +/* minimum secure data length deemed "not short", see IEEE 802.1AE-
> 2006 9.7 */
> +#define MIN_NON_SHORT_LEN 48

I saw

> +#define MACSEC_SHORTLEN_THR 48

before, are they different? Seem very similar.

> +	tx_sa->next_pn++;
> +	if (tx_sa->next_pn =3D=3D 0) {
> +		pr_debug("PN wrapped, transitionning to !oper\n");

typo: transitioning

> +static const struct genl_ops macsec_genl_ops[] =3D {
> +	{
> +		.cmd =3D MACSEC_CMD_GET_TXSC,
> +		.dumpit =3D macsec_dump_txsc,
> +		.policy =3D macsec_genl_policy,
> +	},
> +	{
> +		.cmd =3D MACSEC_CMD_ADD_RXSC,
> +		.doit =3D macsec_add_rxsc,
> +		.policy =3D macsec_genl_rxsc_policy,
> +		.flags =3D GENL_ADMIN_PERM,

IMHO, having different policies for different operations is pretty
confusing. I now slowly start to understand why you had to do all this
aliasing with the IDs. However, perhaps it'd be better to define a top-
level attribute list with the ifindex etc., and make all the
*additional* data needed for RXSC operations for example go into a
nested attribute in the top-level.

That way, you have the same policy for everything and also don't have
to play tricks with the aliasing since the top-level attributes
actually exist now, coming from the same namespace & policy.

johannes
