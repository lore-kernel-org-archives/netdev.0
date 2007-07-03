From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ACPI: export acpi events via generic netlink
Date: Tue, 03 Jul 2007 19:18:51 +0200
Message-ID: <1183483131.4021.8.camel@johannes.berg>
References: <1182224403.5411.84.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-C7mlnHTcn0ByTDQu5cga"
Cc: linux-acpi@vger.kernel.org, netdev@vger.kernel.org,
	lenb@kernel.org, hadi@cyberus.ca
To: Zhang Rui <rui.zhang@intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1182224403.5411.84.camel@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-C7mlnHTcn0ByTDQu5cga
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-06-19 at 11:40 +0800, Zhang Rui wrote:

> +/* attributes of acpi_genl_family */
> +enum {
> +	ACPI_GENL_ATTR_UNSPEC,
> +	ACPI_GENL_ATTR_EVENT,	/* ACPI event info needed by user space */
> +	__ACPI_GENL_ATTR_MAX,
> +};
> +#define ACPI_GENL_ATTR_MAX (__ACPI_GENL_ATTR_MAX - 1)
> +
> +/* commands supported by the acpi_genl_family */
> +enum {
> +	ACPI_GENL_CMD_UNSPEC,
> +	ACPI_GENL_CMD_EVENT,	/* kernel->user notifications for ACPI events */
> +	__ACPI_GENL_CMD_MAX,
> +};
> +#define ACPI_GENL_CMD_MAX (__ACPI_GENL_CMD_MAX - 1)

Shouldn't you put these into some header file instead of copying them
into your userspace tool?

> +#define ACPI_GENL_NAME		"acpi_event"
> +#define ACPI_GENL_VERSION	0x01

and maybe those too?

> +/* .doit: standard command callback */
> +static int acpi_genl_cmd_event(struct sk_buff *skb, struct genl_info *in=
fo)
> +{
> +	struct acpi_genl_event *event =3D info->userhdr;
> +
> +	if (!event)
> +		ACPI_DEBUG_PRINT((ACPI_DB_WARN, "ACPI event: NULL\n"));
> +
> +	return 0;
> +}
> +
> +static struct genl_ops acpi_event_genl_ops =3D {
> +	.cmd =3D ACPI_GENL_CMD_EVENT,
> +	.doit =3D acpi_genl_cmd_event,
> +};

This I don't understand, why would userspace ever send events to the
kernel? I think you should just leave this out completely.

> +	result =3D
> +	    genlmsg_multicast(skb, 0, acpi_event_genl_family.id, GFP_ATOMIC);

If my patches are merged you should now register a multicast group.

Here's how I do it in nl80211 now:

| static struct genl_multicast_group nl80211_config_mcgrp =3D {
| 	.name =3D "config",
| };

during init:

| err =3D genl_register_mc_group(&nl80211_fam, &nl80211_config_mcgrp);
| if (err)
| 	goto err_out;


for sending the message:

| genlmsg_multicast(msg, 0, nl80211_config_mcgrp.id, GFP_KERNEL);

(I suppose you want GFP_ATOMIC for a reason)

In userspace you query the new multicast group attribute(s) [but let's
see what Jamal wants me to change there first] and bind to that group
using
| int group =3D ...;
| setsockopt(s, 270 /*SOL_NETLINK*/, NETLINK_ADD_MEMBERSHIP, &group, sizeof=
(group));.

johannes

--=-C7mlnHTcn0ByTDQu5cga
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGioT6/ETPhpq3jKURAjxLAJ4gYY6Ofcej1XDuSgiSeeQREG+lgwCdGY3l
WAFaOzzd2h7PqWxuhvVAGlM=
=8wPw
-----END PGP SIGNATURE-----

--=-C7mlnHTcn0ByTDQu5cga--

