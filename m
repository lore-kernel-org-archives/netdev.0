From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 03/39] wimax: constants and definitions to interact
	with user space
Date: Thu, 27 Nov 2008 10:41:39 +0100
Message-ID: <1227778899.3809.30.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <999a8be21ed5a6c6d5960789783b38bf51dfd3c3.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LUL0T8YPsUQAOly2jCBi"
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:54073 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbYK0Jm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:42:29 -0500
In-Reply-To: <999a8be21ed5a6c6d5960789783b38bf51dfd3c3.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LUL0T8YPsUQAOly2jCBi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> diff --git a/include/linux/wimax.h b/include/linux/wimax.h
> new file mode 100644
> index 0000000..f9d6a17
> --- /dev/null
> +++ b/include/linux/wimax.h
> @@ -0,0 +1,235 @@
> +/*
> + * Linux WiMax
> + * API for user space
> + *
> + *
> + * Copyright (C) 2007 Intel Corporation <linux-wimax@intel.com>
> + * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.

Explicitly licensing a header file that's used for userspace tools under
GPL2 might seem to indicate that the tool must be GPL2'ed as well, this
seems unintended. To be on the safe side, it seems that a lot of people
would prefer this to be under something as simple as the ISC license
just so that you can simply copy the file if necessary.

I know this hasn't been done traditionally, but in wireless a lot of
people are complaining and I know of one case where a complete header
file was "reimplemented" from scratch because of such an issue.

> +	WIMAX_GNL_ATTR_MAX =3D 5,

This is another side effect of your decision of declaring attributes for
each command. If you didn't, you could simply do

enum wimax_attr {
	__WIMAX_GNL_ATTR_INVALID,
	WIMAX_GNL_ATTR_RFKILL_STATE,
	WIMAX_GNL_ATTR_...

	__WIMAX_GNL_ATTR_AFTER_LAST,
	WIMAX_GNL_ATTR_MAX =3D __WIMAX_GNL_ATTR_AFTER_LAST - 1
};

and have everything fall into place naturally.

Having just a single policy for all top-level attributes is a lot easier
to understand and also a lot more flexible in the long run.

> + * Most of these map to an API call; _OP_ stands for operation, _RP_
> + * for reply and _RE_ for report (aka: signal).
> + */
> +enum {
> +	WIMAX_GNL_OP_MSG_FROM_USER,	/* User to kernel message */
> +	WIMAX_GNL_OP_MSG_TO_USER,	/* Kernel to user message */

What are those used for? Smells a lot like "iwpriv"...

> +	WIMAX_GNL_OP_OPEN,	/* Open a handle to a wimax device */
> +	WIMAX_GNL_OP_UNUSED,	/* Unused */
> +	WIMAX_GNL_OP_RFKILL,	/* Run wimax_rfkill() */
> +	WIMAX_GNL_RP_IFINFO,	/* Reply to OPEN: Interface info */
> +	WIMAX_GNL_RP_RESULT,	/* Reply: result of operation */
> +	WIMAX_GNL_OP_RESET,	/* Run wimax_rfkill() */
> +	WIMAX_GNL_RE_STATE_CHANGE,	/* Report: status change */
> +	WIMAX_GNL_OP_MAX,

That's not MAX, it's MAX+1, see the idiom above if you really need MAX.

> +/* Message from user / to user */
> +enum {
> +	WIMAX_GNL_MSG_DATA =3D 1,
> +};

So this is iwpriv? Why bother with an enum if you're not doing
kernel-doc?

> +enum wimax_rf_state {
> +	WIMAX_RF_OFF =3D 0,	/* Radio is off, rfkill on/enabled */
> +	WIMAX_RF_ON =3D 1,	/* Radio is on, rfkill off/disabled */
> +	WIMAX_RF_QUERY =3D 2,
> +};
> +
> +/* Attributes */
> +enum {
> +	WIMAX_GNL_RFKILL_STATE =3D 1,
> +};

What's wrong with making that 2, and using a single enum for all the
attributes? It doesn't make a huge difference.

> +enum {
> +	WIMAX_GNL_IFINFO_MC_GROUPS =3D 1,
> +	WIMAX_GNL_IFINFO_MC_GROUP,
> +	WIMAX_GNL_IFINFO_MC_NAME,
> +	WIMAX_GNL_IFINFO_MC_ID,
> +	WIMAX_GNL_IFINFO_MAX,		/* Used by user space */

again, not MAX, also what do you need MC_GROUP stuff for? genl mc groups
are available via the genl controller, isn't that sufficient?

> +/*
> + * Attributes for the result-of-operation
> + */
> +enum {
> +	WIMAX_GNL_RESULT_CODE =3D 1,

This is a bit strange, what operations cannot just use the regular genl
ack message? Are these asynchronous?

> +enum {
> +	WIMAX_GNL_STCH_STATE_OLD =3D 1,
> +	WIMAX_GNL_STCH_STATE_NEW,
> +};
> +
> +
> +/**
> + * enum wimax_st - The different states of a WiMAX device
> + * @__WIMAX_ST_NULL: The device structure has been allocated and zeroed,
> + *     but still wimax_dev_add() hasn't been called. There is no state.

That's not really available to userspace, is it? I mean, at that point
wimax-genl will just not work?

johannes

--=-LUL0T8YPsUQAOly2jCBi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLmtQAAoJEKVg1VMiehFYcC8P/iOc7PwCENpajSo5TfLJFk4i
+bx9hq8Ec5tcjqmFnTvUwnyf5tYO1tZ7t8RxfQ+TQBXTSefcM6zua+PWyXKckCcK
TyUPnbNIAB/WqxAxhidc0Tmh9l81De+VOBkOu13+AFbsdzTMuKAYqsNwft0xVSj6
C58V2+VDVA0iqgbdMmKNiZn3Cxn0p0mMDG6GkcQ5dUeEF9pnV8Ax/SjRFbKZKfgb
M6k5iLFwlb4GBfaxu+8GquUhqu17xTpVjnw95gf1qZ+FojHe4CUfzbNTMcM121Ed
FP+i65Fk8GrgnkKhfjHktSa5G7vIJVYhDsw7Shk1jXQsFFx0WS7gEF+xB7G6N2Ty
Fr6ZAatLfCRvtZY0b3nqt+lVlgZ231eMaaQN1g2iM0eOoWmfNVAqc50D26s/JPNm
YgFG8pxU1l0hhYDzbhjn1iTGTdU9pi83VI7o6YCJT6wXGSPs2aZYb9YN1rCLHZgW
coHEF9HWEm0tUqiBA6t/StXVHXAkzFS644zvIC/PSuOMv2rVZMXJDaOIEGjee7dD
ZrJsD2zl0n+t21xAh04AMCx9PpSW3nKR1n999JRHLo4JH37ArB8T3mcfax4kNmLh
oo7P5L8UTMYgSH4K/EpeoBw9ebaFirMalVL9leZjSaWXEJ5k2T+2OcAYV5L49PLl
x2RywYEOwOi8KOk5JvG2
=NPrB
-----END PGP SIGNATURE-----

--=-LUL0T8YPsUQAOly2jCBi--

