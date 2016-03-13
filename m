From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/2] ethtool: Add PHY statistics support
Date: Sun, 13 Mar 2016 15:50:16 +0000
Message-ID: <1457884216.3331.16.camel@decadent.org.uk>
References: <1450871911-19509-1-git-send-email-andrew@lunn.ch>
	 <1450871911-19509-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fG0U3rBvX4lZtSu7Vdg9"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40692 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751577AbcCMPuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 11:50:23 -0400
In-Reply-To: <1450871911-19509-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fG0U3rBvX4lZtSu7Vdg9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-12-23 at 12:58 +0100, Andrew Lunn wrote:
> This adds support for printing statistics from the network devices PHY.

Sorry it's taken me so long to respond to this. =C2=A0There are a few issue=
s
with it but I'll apply it anyway then fix them up.

> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> =C2=A0ethtool.8.in |=C2=A0=C2=A06 ++++++
> =C2=A0ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0| 60 +++++++++++++++++++++++++++++=
+++++++++++++++++++++++++++++++
> =C2=A02 files changed, 66 insertions(+)
>=20
> diff --git a/ethtool.8.in b/ethtool.8.in
> index eeffa70..2316556 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -220,6 +220,9 @@ ethtool \- query or control network driver and hardwa=
re settings
> =C2=A0.B ethtool \-S|\-\-statistics
> =C2=A0.I devname
> =C2=A0.HP
> +.B ethtool \-I|\-\-phy-statistics
> +.I devname
> +.HP

-I isn't a useful mnemonic, so I will drop the short option altogether.

> =C2=A0.B ethtool \-t|\-\-test
> =C2=A0.I devname
> =C2=A0.RI [\*(SD]
> @@ -492,6 +495,9 @@ auto-negotiation is enabled.
> =C2=A0Queries the specified network device for NIC- and driver-specific
> =C2=A0statistics.
> =C2=A0.TP
> +.B \-I \-\-phy\-statistics
> +Queries the specified network device for PHY specific statistics.
> +.TP
> =C2=A0.B \-t \-\-test
> =C2=A0Executes adapter selftest on the specified network device. Possible=
 test modes are:
> =C2=A0.TP
> diff --git a/ethtool.c b/ethtool.c
> index 92c40b8..480c14c 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -2995,6 +2995,64 @@ static int do_gstats(struct cmd_context *ctx)
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> +static int do_gphystats(struct cmd_context *ctx)
> +{
> +	struct ethtool_gstrings *strings;
> +	struct ethtool_stats *stats;
> +	unsigned int n_stats, sz_stats, i;
> +	int err;
> +
> +	if (ctx->argc !=3D 0)
> +		exit_bad_args();
> +
> +	strings =3D get_stringset(ctx, ETH_SS_PHY_STATS,
> +				offsetof(struct ethtool_drvinfo, n_stats),
> +				0);
> +	if (!strings) {
> +		perror("Cannot get stats strings information");
> +		return 96;
> +	}
> +

> +	n_stats =3D strings->len;
> +	if (n_stats < 1) {
> +		fprintf(stderr, "no stats available\n");
> +		free(strings);
> +		return 94;
> +	}
> +
> +	sz_stats =3D n_stats * sizeof(u64);
> +
> +	stats =3D calloc(1, sz_stats + sizeof(struct ethtool_stats));
> +	if (!stats) {
> +		fprintf(stderr, "no memory available\n");
> +		free(strings);
> +		return 95;
> +	}
> +
> +	stats->cmd =3D ETHTOOL_GPHYSTATS;
> +	stats->n_stats =3D n_stats;
> +	err =3D send_ioctl(ctx, stats);
> +	if (err < 0) {
> +		perror("Cannot get stats information");
> +		free(strings);
> +		free(stats);
> +		return 97;
> +	}
> +
> +	/* todo - pretty-print the strings per-driver */
> +	fprintf(stdout, "PHY statistics:\n");
> +	for (i =3D 0; i < n_stats; i++) {
> +		fprintf(stdout, "=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0%.*s: %llu\n",
> +			ETH_GSTRING_LEN,
> +			&strings->data[i * ETH_GSTRING_LEN],
> +			stats->data[i]);
> +	}
> +	free(strings);
> +	free(stats);
> +
> +	return 0;
> +}

This is basically a copy-paste of do_gstats() so they should be merged
into one function.

Ben.

> =C2=A0static int do_srxntuple(struct cmd_context *ctx,
> =C2=A0			struct ethtool_rx_flow_spec *rx_rule_fs);
> =C2=A0
> @@ -4078,6 +4136,8 @@ static const struct option {
> =C2=A0	{ "-t|--test", 1, do_test, "Execute adapter self test",
> =C2=A0	=C2=A0=C2=A0"=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[ online | offline | external_lb ]\n=
" },
> =C2=A0	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
> +	{ "-I|--phy-statistics", 1, do_gphystats,
> +	=C2=A0=C2=A0"Show phy statistics" },
> =C2=A0	{ "-n|-u|--show-nfc|--show-ntuple", 1, do_grxclass,
> =C2=A0	=C2=A0=C2=A0"Show Rx network flow classification options or rules"=
,
> =C2=A0	=C2=A0=C2=A0"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.
--=-fG0U3rBvX4lZtSu7Vdg9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW5Yw4AAoJEOe/yOyVhhEJZikP/jgfqo1xC8heVfGntK6kaSn1
TWBGzwPj6LEOEfY9+ShtqiDwmmaCBZQDDCGqxt2hnbJ1sWf0+rPyWbPUAguuwZLv
OM/P60N2KGrC1WyV/NISQFRs/f6pLQzlFGRQtOJvGvBq7FcZoBXxs4/5xUNCrGWE
8OhaKGwDOedLVLP4/xvGoC7phyrDG3OD80yu24O0+Q+6GeDe1m18EVpVk7X41FZr
R0Ne+/efb2lJAFWcDtOEIosXcJ3kOgZfduuGG0e9Smg4rt3PyYTRpIvUYA6AC4BJ
q2m+PLBbI/CrCVuOgJi5X4dzHr9HL5/gHqb0QhHO8asFo/7P2fIPZ6YdoGD8RSqR
NGlYAbC1Id7FdlwlchlVgiFp+lIkfvlYUPUkDJbfsfmCz+86WNwFv6FMkINEyojb
3yYLQTHCe4kkFma41jxTHUyR+nFvCodokM+gd7MqhZ7r9e9r7SbQGCPns94sndzg
9MV3o5uE3YGzR6sgYNZWL7bNmI0WwBdKJcpmH2In6LCUZMYRjfsfzlzrP02RSdjx
X/WRVAhp3qry/FOJZV4aWCc+Me303JP9D76ZhmtFt+vnvWF3T0ktgP+sYoWoO36M
Hmn3MYx1hjj8FtnKNd5gX9HbL6ytnxyZ13Ego/4bjR6j1jAsfTuLkiWqZrdWHsjE
otsYZ35/ii3BislJv75L
=qDWV
-----END PGP SIGNATURE-----

--=-fG0U3rBvX4lZtSu7Vdg9--
