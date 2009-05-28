From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 2/5] net: add IEEE 802.15.4 partial implementation
Date: Thu, 28 May 2009 04:08:51 +0100
Message-ID: <1243480131.16597.174.camel@deadeye>
References: <20090526112157.GA19976@doriath.ww600.siemens.net>
	 <1243336988-20109-1-git-send-email-dbaryshkov@gmail.com>
	 <1243336988-20109-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-/+NZtUfkEskQNNEHqOgC"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1243336988-20109-2-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-/+NZtUfkEskQNNEHqOgC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-05-26 at 15:23 +0400, Dmitry Eremin-Solenikov wrote:
[...]
> diff --git a/include/net/ieee802154/af_ieee802154.h b/include/net/ieee802=
154/af_ieee802154.h
> new file mode 100644
> index 0000000..6eb7f51
> --- /dev/null
> +++ b/include/net/ieee802154/af_ieee802154.h
[...]
> +#ifdef __KERNEL__
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>

The struct declarations would be sufficient.

> +extern struct proto ieee802154_raw_prot;
> +extern struct proto ieee802154_dgram_prot;
> +void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb)=
;
> +int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb=
);
> +#endif
> +
> +#endif
> diff --git a/include/net/ieee802154/beacon.h b/include/net/ieee802154/bea=
con.h
> new file mode 100644
> index 0000000..baca263
> --- /dev/null
> +++ b/include/net/ieee802154/beacon.h
[...]
> +/* Per spec; optimizations are needed */
> +struct ieee802154_pandsc {
> +	struct list_head	list;
> +	struct ieee802154_addr	addr; /* Contains panid */
> +	int			channel;
> +	u16			sf;
> +	bool			gts_permit;
> +	u8			lqi;
> +	u32			timestamp; /* FIXME */

When and how does this need to be fixed, if at all?

> +	bool			security;
> +	u8			mac_sec;
> +	bool			sec_fail;
> +};
[...]
> --- /dev/null
> +++ b/include/net/ieee802154/const.h
[...]
> +/* Time related constants, in microseconds.
> + *
> + * The 1SYM_TIME values are shown how much time is needed to transmit on=
e
> + * symbol across media.
> + * The callculation is following:
> + * For a 2450 MHZ radio freq rate is 62,5 ksym/sec. A byte (8 bit) trans=
fered
> + * by low 4 bits in first symbol, high 4 bits in next symbol. So, to tra=
nsmit
> + * 1 byte in 2450Mhz freq 2 symbols are needed. Therefore we have 31,25 =
kbyte/sec
> + * rate. 1 symbol transfered in 16*10^(-6) sec, or 16 microseconds.
> + * For a 868Mhz and 915Mhz, 1 symbol is equal to 1 byte. So, we have 20k=
byte/sec
> + * and 40 kbyte/sec respectively. And 5*10^(-5) sec and 2,5*10(-5) sec,
> + * or 50 and 25 microseconds respectively for 868Mhz and 915Mhz freq.
> + */

This is so verbose as to be unhelpful.  Since the following constants
only refer to symbol time, it should be sufficient to refer to the
specified symbol rates.

> +#define IEEE802154_2450MHZ_1SYM_TIME	16
> +#define IEEE802154_868MHZ_1SYM_TIME	50
> +#define IEEE802154_915MHZ_1SYM_TIME	25
> +
> +/***********************************************************************=
*******/
> +/* MAC constants */
> +/***********************************************************************=
*******/
> +/** The number of symbols forming a superframe slot when the superframe =
order
> + * is equal to 0.
> + */

Don't use two asterisks at the start of a comment unless it's in
kernel-doc format.

[...]
> +/**
> + * \brief PHY return codes description
> + *
> + * The return values of PHY operations
> + */

...and definitely don't use Doxygen format.

[...]
> +/* #define ZB_ED_EDGE	0x7f */

Define it or delete it.

> +/* I've got 0xBE on idle channel; let threshold be a little higher */
> +#define ZB_ED_EDGE	0xc8
> +/* In an ideal world this should be 1 */
> +#define IEEE802154_SLOW_SERIAL_FIXUP	75

Yes but what are these *for*?

> +#endif /* IEEE802154_CONST_H */
> diff --git a/include/net/ieee802154/crc.h b/include/net/ieee802154/crc.h
> new file mode 100644
> index 0000000..5b37218
> --- /dev/null
> +++ b/include/net/ieee802154/crc.h
> @@ -0,0 +1,38 @@
> +/*
> + * based on crc-itu-t.c.
> + * Basically it's CRC-ITU-T but with inverted bit numbering

This can probably be handled by crc_itu_t_bitreversed():

http://svn.debian.org/wsvn/kernel/dists/trunk/linux-2.6/debian/patches/feat=
ures/all/lib-crcitut-bit-reversed.patch

(That patch hasn't gone anywhere yet as Greg K-H is dragging his heels
over actually fixing his crap, but feel free to resubmit it as part of
your own patch series.)

[...]
> --- /dev/null
> +++ b/include/net/ieee802154/nl.h
[...]
> +/* commands */
> +/* REQ should be responded with CONF
> + * and INDIC with RESP
> + */
> +enum {
> +	__IEEE802154_COMMAND_INVALID,
> +
> +	IEEE802154_ASSOCIATE_REQ,
> +	IEEE802154_ASSOCIATE_CONF,
> +	IEEE802154_DISASSOCIATE_REQ,
> +	IEEE802154_DISASSOCIATE_CONF,
> +	IEEE802154_GET_REQ,
> +	IEEE802154_GET_CONF,
> +/* 	IEEE802154_GTS_REQ, */
> +/* 	IEEE802154_GTS_CONF, */

Why are some of these commented out?  Since they're apparently exposed
to user-space you can't insert them later.

[...]
> --- /dev/null
> +++ b/net/ieee802154/beacon.c
[...]
> +	/* TODO GTS */
> +	gts =3D 0;
> +
> +	if (flags & IEEE802154_BEACON_FLAG_GTSPERMIT)
> +		gts |=3D IEEE802154_BEACON_GTS_PERMIT;
> +	memcpy(skb_put(skb, sizeof(gts)), &gts, sizeof(gts));
> +
> +	/* FIXME pending address */
> +	addr16_cnt =3D 0;
> +	addr64_cnt =3D 0;
> +#if 0
> +	/* need more thinking about this */
> +	list_for_each_entry(l, al->list, list) {
> +		struct ieee802154_addr *s =3D container_of(l, struct list_head, list);
> +		if (s->addr_type =3D=3D IEEE802154_ADDR_LONG)
> +			addr16_cnt++;
> +
> +		if (s->addr_type =3D=3D IEEE802154_ADDR_SHORT)
> +			addr64_cnt++;
> +	}
> +#endif

This all looks very unfinished - as do several other sections with
FIXME, #if 0, commented-out code...

[...]
> +#define IEEE802154_FETCH_U64(skb, var)			\
> +	do {						\
> +		if (skb->len < IEEE802154_ADDR_LEN)	\

I see what you did there...

> +			goto exit_error;		\
> +		fetch_skb_u64(skb, &var);		\
> +	} while (0)
[...]
> --- /dev/null
> +++ b/net/ieee802154/netlink.c
> @@ -0,0 +1,637 @@
> +/*
> + * Netlink intefcace for IEEE 802.15.4 stack
[...]

Speling misstake.

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-/+NZtUfkEskQNNEHqOgC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKHgA/79ZNCRIGYgcRAmddAJ9bquDSE9oW5b//ALlp6ky6CdaX/ACfTII2
00S5Z3jB2oqs862iiJPQDhs=
=dFWp
-----END PGP SIGNATURE-----

--=-/+NZtUfkEskQNNEHqOgC--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
