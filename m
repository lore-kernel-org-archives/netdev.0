From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool] ethtool.c: fix memory leaks
Date: Sun, 26 Jun 2016 10:59:11 +0200
Message-ID: <1466931551.2504.29.camel@decadent.org.uk>
References: <1458303855-4976-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xLXV7t7EH8ZRZJNAoPpq"
Cc: bwh@kernel.org
To: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55136 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751675AbcFZI7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 04:59:15 -0400
In-Reply-To: <1458303855-4976-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xLXV7t7EH8ZRZJNAoPpq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-18 at 13:24 +0100, Ivan Vecera wrote:
> Memory allocated at several places is not appropriately freed.

Given that ethtool is not a library or a long-running application - why
does that matter?

Ben.

> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
> =C2=A0ethtool.c | 60 +++++++++++++++++++++++++++++++++++++++++++++------
> ---------
> =C2=A01 file changed, 45 insertions(+), 15 deletions(-)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index 0cd0d4f..ca0bf28 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -2065,10 +2065,14 @@ static int do_gfeatures(struct cmd_context
> *ctx)
> =C2=A0	features =3D get_features(ctx, defs);
> =C2=A0	if (!features) {
> =C2=A0		fprintf(stdout, "no feature info available\n");
> +		free(defs);
> =C2=A0		return 1;
> =C2=A0	}
> =C2=A0
> =C2=A0	dump_features(defs, features, NULL);
> +
> +	free(features);
> +	free(defs);
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> @@ -2078,11 +2082,11 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0	int any_changed =3D 0, any_mismatch =3D 0;
> =C2=A0	u32 off_flags_wanted =3D 0;
> =C2=A0	u32 off_flags_mask =3D 0;
> -	struct ethtool_sfeatures *efeatures;
> +	struct ethtool_sfeatures *efeatures =3D NULL;
> =C2=A0	struct cmdline_info *cmdline_features;
> -	struct feature_state *old_state, *new_state;
> +	struct feature_state *old_state =3D NULL, *new_state =3D NULL;
> =C2=A0	struct ethtool_value eval;
> -	int err;
> +	int err, retval =3D 1;
> =C2=A0	int i, j;
> =C2=A0
> =C2=A0	defs =3D get_feature_defs(ctx);
> @@ -2096,7 +2100,7 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0				=C2=A0=C2=A0=C2=A0sizeof(efeatures->features[0]));
> =C2=A0		if (!efeatures) {
> =C2=A0			perror("Cannot parse arguments");
> -			return 1;
> +			goto finish;
> =C2=A0		}
> =C2=A0		efeatures->cmd =3D ETHTOOL_SFEATURES;
> =C2=A0		efeatures->size =3D FEATURE_BITS_TO_BLOCKS(defs-
> >n_features);
> @@ -2114,7 +2118,7 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0				=C2=A0=C2=A0sizeof(cmdline_features[0]));
> =C2=A0	if (!cmdline_features) {
> =C2=A0		perror("Cannot parse arguments");
> -		return 1;
> +		goto finish;
> =C2=A0	}
> =C2=A0	for (i =3D 0; i < ARRAY_SIZE(off_flag_def); i++)
> =C2=A0		flag_to_cmdline_info(off_flag_def[i].short_name,
> @@ -2133,12 +2137,13 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0
> =C2=A0	if (!any_changed) {
> =C2=A0		fprintf(stdout, "no features changed\n");
> -		return 0;
> +		retval =3D 0;
> +		goto finish;
> =C2=A0	}
> =C2=A0
> =C2=A0	old_state =3D get_features(ctx, defs);
> =C2=A0	if (!old_state)
> -		return 1;
> +		goto finish;
> =C2=A0
> =C2=A0	if (efeatures) {
> =C2=A0		/* For each offload that the user specified, update
> any
> @@ -2182,7 +2187,7 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0		err =3D send_ioctl(ctx, efeatures);
> =C2=A0		if (err < 0) {
> =C2=A0			perror("Cannot set device feature
> settings");
> -			return 1;
> +			goto finish;
> =C2=A0		}
> =C2=A0	} else {
> =C2=A0		for (i =3D 0; i < ARRAY_SIZE(off_flag_def); i++) {
> @@ -2197,7 +2202,7 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0					fprintf(stderr,
> =C2=A0						"Cannot set device
> %s settings: %m\n",
> =C2=A0						off_flag_def[i].long
> _name);
> -					return 1;
> +					goto finish;
> =C2=A0				}
> =C2=A0			}
> =C2=A0		}
> @@ -2211,7 +2216,8 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0			err =3D send_ioctl(ctx, &eval);
> =C2=A0			if (err) {
> =C2=A0				perror("Cannot set device flag
> settings");
> -				return 92;
> +				retval =3D 92;
> +				goto finish;
> =C2=A0			}
> =C2=A0		}
> =C2=A0	}
> @@ -2219,7 +2225,7 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0	/* Compare new state with requested state */
> =C2=A0	new_state =3D get_features(ctx, defs);
> =C2=A0	if (!new_state)
> -		return 1;
> +		goto finish;
> =C2=A0	any_changed =3D new_state->off_flags !=3D old_state->off_flags;
> =C2=A0	any_mismatch =3D (new_state->off_flags !=3D
> =C2=A0			((old_state->off_flags & ~off_flags_mask) |
> @@ -2238,13 +2244,19 @@ static int do_sfeatures(struct cmd_context
> *ctx)
> =C2=A0		if (!any_changed) {
> =C2=A0			fprintf(stderr,
> =C2=A0				"Could not change any device
> features\n");
> -			return 1;
> +			goto finish;
> =C2=A0		}
> =C2=A0		printf("Actual changes:\n");
> =C2=A0		dump_features(defs, new_state, old_state);
> =C2=A0	}
> =C2=A0
> -	return 0;
> +	retval =3D 0;
> +finish:
> +	free(new_state);
> +	free(old_state);
> +	free(efeatures);
> +	free(defs);
> +	return retval;
> =C2=A0}
> =C2=A0
> =C2=A0static int do_gset(struct cmd_context *ctx)
> @@ -2705,8 +2717,18 @@ static int do_gregs(struct cmd_context *ctx)
> =C2=A0			return 75;
> =C2=A0		}
> =C2=A0
> -		regs =3D realloc(regs, sizeof(*regs) + st.st_size);
> -		regs->len =3D st.st_size;
> +		if (regs->len !=3D st.st_size) {
> +			struct ethtool_regs *new_regs;
> +			new_regs =3D realloc(regs, sizeof(*regs) +
> st.st_size);
> +			if (!new_regs) {
> +				perror("Cannot allocate memory for
> register "
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0"dump");
> +				free(regs);
> +				return 73;
> +			}
> +			regs =3D new_regs;
> +			regs->len =3D st.st_size;
> +		}
> =C2=A0		nread =3D fread(regs->data, regs->len, 1, f);
> =C2=A0		fclose(f);
> =C2=A0		if (nread !=3D 1) {
> @@ -3775,6 +3797,7 @@ static int do_gprivflags(struct cmd_context
> *ctx)
> =C2=A0	}
> =C2=A0	if (strings->len =3D=3D 0) {
> =C2=A0		fprintf(stderr, "No private flags defined\n");
> +		free(strings);
> =C2=A0		return 1;
> =C2=A0	}
> =C2=A0	if (strings->len > 32) {
> @@ -3786,6 +3809,7 @@ static int do_gprivflags(struct cmd_context
> *ctx)
> =C2=A0	flags.cmd =3D ETHTOOL_GPFLAGS;
> =C2=A0	if (send_ioctl(ctx, &flags)) {
> =C2=A0		perror("Cannot get private flags");
> +		free(strings);
> =C2=A0		return 1;
> =C2=A0	}
> =C2=A0
> @@ -3804,6 +3828,7 @@ static int do_gprivflags(struct cmd_context
> *ctx)
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(const char *)strings->=
data + i *
> ETH_GSTRING_LEN,
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(flags.data & (1U << i)=
) ? "on" : "off");
> =C2=A0
> +	free(strings);
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> @@ -3825,6 +3850,7 @@ static int do_sprivflags(struct cmd_context
> *ctx)
> =C2=A0	}
> =C2=A0	if (strings->len =3D=3D 0) {
> =C2=A0		fprintf(stderr, "No private flags defined\n");
> +		free(strings);
> =C2=A0		return 1;
> =C2=A0	}
> =C2=A0	if (strings->len > 32) {
> @@ -3836,6 +3862,7 @@ static int do_sprivflags(struct cmd_context
> *ctx)
> =C2=A0	cmdline =3D calloc(strings->len, sizeof(*cmdline));
> =C2=A0	if (!cmdline) {
> =C2=A0		perror("Cannot parse arguments");
> +		free(strings);
> =C2=A0		return 1;
> =C2=A0	}
> =C2=A0	for (i =3D 0; i < strings->len; i++) {
> @@ -3852,6 +3879,7 @@ static int do_sprivflags(struct cmd_context
> *ctx)
> =C2=A0	flags.cmd =3D ETHTOOL_GPFLAGS;
> =C2=A0	if (send_ioctl(ctx, &flags)) {
> =C2=A0		perror("Cannot get private flags");
> +		free(strings);
> =C2=A0		return 1;
> =C2=A0	}
> =C2=A0
> @@ -3859,9 +3887,11 @@ static int do_sprivflags(struct cmd_context
> *ctx)
> =C2=A0	flags.data =3D (flags.data & ~seen_flags) | wanted_flags;
> =C2=A0	if (send_ioctl(ctx, &flags)) {
> =C2=A0		perror("Cannot set private flags");
> +		free(strings);
> =C2=A0		return 1;
> =C2=A0	}
> =C2=A0
> +	free(strings);
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-xLXV7t7EH8ZRZJNAoPpq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb5lfAAoJEOe/yOyVhhEJR+oP/RwN4jHdKYy9hu8Mw7+SiUzS
1Z3DB0C7VN7fldOi6oA2nfgGfpTXq0xhcINFv6C0AwebzHXalv2N9LuG1v1USN1N
HhAENzd6mgYSC2eOv35pmfF+WLPqTdAuUcQOhlt+0sCyTkC2E+5BcQPVGHsrD8Hx
IEaoqVvJDE7JDgBrtdSMQONDSf16dzy0ik+W2sYTaYKRhvNqM5bpJ3zhXNQwYk5E
GARw0CAObMR7D79ySZJ7rAjKj0jvVve1mz/LNiS+A9YAaFdS/zlVwbEDl8GUNiNO
0potDVeaQ3L8/UbSwa2S/PLb+RQRXsjxKJA3L43pj51V1FwJwSxDnXhtze9PDmbS
qZ9mykkyPLnThqLEU8W46UTv/SnB6lDbKr/mrAGaHaaF+2BdB386GBIGmJnuqzWj
YDQfLi+cMnXgKrvhtHDqJ8QFRQZfGRVW6PglTebqq9wCQo/oBjXOmzMChfiOTBoX
zkgpnkwcGv0QduJozeVJJogpJKle9OEspNDYqKWWgfLXksZzc0NG52YuBbsXf3Re
gRYksCvThFxaY/NJEWP4JCGlTmF2MJfMxmnLIb1arslAQVYxYx9qgmGyfUz938EE
pG6KbDuzS8Sf6KwakNRFAkUrQA8fzMDtNL9VvpGHp1P6z8HRmY8SMQwQIVyIW8yW
tKRyt1IS6D0sedPE3Gge
=NLj6
-----END PGP SIGNATURE-----

--=-xLXV7t7EH8ZRZJNAoPpq--
