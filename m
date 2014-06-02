From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v5 ethtool 2/2] ethtool: Support for configurable RSS
 hash key
Date: Mon, 02 Jun 2014 02:49:00 +0100
Message-ID: <1401673740.14007.141.camel@deadeye.wl.decadent.org.uk>
References: <1398074931-13346-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <22b8983b-ec34-4465-aa31-f66cdaea91cb@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VdDmQZK6C/JBEGxYJeCj"
Cc: netdev@vger.kernel.org
To: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46440 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753811AbaFBBtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:49:13 -0400
In-Reply-To: <22b8983b-ec34-4465-aa31-f66cdaea91cb@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VdDmQZK6C/JBEGxYJeCj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-04-21 at 15:38 +0530, Venkat Duvvuru wrote:
[...]
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -874,6 +874,73 @@ static char *unparse_rxfhashopts(u64 opts)
>  	return buf;
>  }
> =20
> +static int convert_string_to_hashkey(char *rss_hkey, u32 key_size,
> +				     const char *rss_hkey_string)
> +{
> +	int i =3D 0;

Type should be u32, consistent with key_size.

> +	int hex_byte;
> +
> +	do {
> +		if (i > (key_size - 1)) {
> +			fprintf(stderr,
> +				"Invalid key: Device supports %d bytes key\n",
> +				key_size);
> +			goto err;
> +		}

Be specific - the key is too long.

> +		if (!(isxdigit(*rss_hkey_string) &&
> +		      isxdigit(*(rss_hkey_string + 1)))) {
> +			fprintf(stderr, "Invalid RSS Hash Key Format\n");
> +			goto err;
> +		}
> +
> +		sscanf(rss_hkey_string, "%2x", &hex_byte);
> +		rss_hkey[i++] =3D hex_byte;
> +		rss_hkey_string +=3D 2;

I don't like this - validation should be done as part of the conversion,
not separately.  I think this would be better written like:

	int len;
	/* ... */
		if (sscanf(rss_hkey_string, "%2x%n", &hex_byte, &len) < 1 ||
		    len !=3D 2) {
			fprintf(stderr, "Invalid RSS hash key format\n");
			goto err;
		}

(by the way, don't use title-case in error messages).

> +		if (*rss_hkey_string =3D=3D ':') {
> +			rss_hkey_string++;
> +		} else if (*rss_hkey_string !=3D '\0') {
> +			fprintf(stderr, "Invalid RSS Hash Key Format\n");
> +			goto err;
> +		}

> +	} while (*rss_hkey_string);
> +
> +	if (i !=3D key_size) {
> +		fprintf(stderr, "Invalid key: Device supports %d bytes key\n",
> +			key_size);
> +		goto err;
> +	}

Be specific - the key is too short.

> +	return 0;

This function either returns 0 or exits the program, so why does it have
a return value at all?

> +err:
> +	exit_bad_args();
> +}

I don't think it makes sense to show the general usage error message
after giving a very specific error message.

> static int parse_hkey(char **rss_hkey, u32 key_size,
> 		      const char *rss_hkey_string)
> {
> 	if (!key_size) {
> 		fprintf(stderr,
> 			"Cannot set RX flow hash configuration:\n"
> 			" Hash key setting not supported\n");
> 		exit(1);
> 	}
>=20
> 	*rss_hkey =3D malloc(key_size);
> 	if (!(*rss_hkey))
> 		return -ENOMEM;

Why is that not also fatal?

> 	if (convert_string_to_hashkey(*rss_hkey, key_size,
> 				      rss_hkey_string) < 0) {

Can't happen.

> 		free(*rss_hkey);
> 		*rss_hkey =3D NULL;
> 		return -EINVAL;
> 	}
> 	return 0;
> }
[...]=20
> -static int do_grxfhindir(struct cmd_context *ctx)
> +static int do_grxfh(struct cmd_context *ctx)
>  {
>  	struct ethtool_rxnfc ring_count;
> -	struct ethtool_rxfh_indir indir_head;
> -	struct ethtool_rxfh_indir *indir;
> -	u32 i;
> +	struct ethtool_rxfh rss_head;
> +	struct ethtool_rxfh *rss;
> +	u32 i, indir_bytes;
>  	int err;
> +	char *hkey;
> =20
>  	ring_count.cmd =3D ETHTOOL_GRXRINGS;
>  	err =3D send_ioctl(ctx, &ring_count);
> @@ -3050,77 +3118,148 @@ static int do_grxfhindir(struct cmd_context *ctx=
)
>  		return 102;
>  	}
> =20
> -	indir_head.cmd =3D ETHTOOL_GRXFHINDIR;
> -	indir_head.size =3D 0;
> -	err =3D send_ioctl(ctx, &indir_head);
> -	if (err < 0) {
> -		perror("Cannot get RX flow hash indirection table size");
> +	rss_head.cmd =3D ETHTOOL_GRSSH;
> +	rss_head.rss_context =3D 0;
> +	rss_head.indir_size =3D 0;
> +	rss_head.key_size =3D 0;

You need to clear the reserved fields too.  It would be best to
zero-initialise the whole structure and then just set .cmd.

> +	err =3D send_ioctl(ctx, &rss_head);
> +	if ((err < 0) || (!rss_head.indir_size && !rss_head.key_size)) {
> +		perror("Cannot get RX flow hash indirection and key size");
>  		return 103;
>  	}

You *must* fall back to using ETHTOOL_GRXFHINDIR (and similarly when
setting).  ethtool must continue to work with old kernel versions.
(Without the kernel changes I've just submitted, this also wouldn't work
with any driver other than be2net!)

> -	indir =3D malloc(sizeof(*indir) +
> -		       indir_head.size * sizeof(*indir->ring_index));
> -	indir->cmd =3D ETHTOOL_GRXFHINDIR;
> -	indir->size =3D indir_head.size;
> -	err =3D send_ioctl(ctx, indir);
> +	rss =3D calloc(1, sizeof(*rss) +
> +			rss_head.indir_size * sizeof(rss_head.rss_config[0]) +
> +			rss_head.key_size);
> +	rss->cmd =3D ETHTOOL_GRSSH;
> +	rss->indir_size =3D rss_head.indir_size;
> +	rss->key_size =3D rss_head.key_size;
> +	err =3D send_ioctl(ctx, rss);
>  	if (err < 0) {
> -		perror("Cannot get RX flow hash indirection table");
> +		perror("Cannot get RX flow hash configuration");
>  		return 103;
>  	}
> =20
>  	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
>  	       ctx->devname, ring_count.data);
> -	for (i =3D 0; i < indir->size; i++) {
> +	if (!rss->indir_size)
> +		printf("*** Operation Not Supported ***\n");

There is no other place in ethtool we use asterisks for emphasis, and I
don't wish to start.  Please try to be consistent with the existing
style of messages.

[...]=20
> -static int do_srxfhindir(struct cmd_context *ctx)
> +
> +
> +

Excess whitespace.

> +static int do_srxfh(struct cmd_context *ctx)
>  {
> +	struct ethtool_rxfh rss_head;
> +	struct ethtool_rxfh *rss;
> +	struct ethtool_rxnfc ring_count;
>  	int rxfhindir_equal =3D 0;
>  	char **rxfhindir_weight =3D NULL;
> -	struct ethtool_rxfh_indir indir_head;
> -	struct ethtool_rxfh_indir *indir;
> -	u32 i;
> +	char *rss_hkey =3D NULL;
>  	int err;
> +	u32 i, arg_num =3D 0, indir_bytes =3D 0;
> +	u32 entry_size =3D sizeof(rss_head.rss_config[0]);
> +	u8 parse_indir =3D 1;
> =20
>  	if (ctx->argc < 2)
>  		exit_bad_args();
> -	if (!strcmp(ctx->argp[0], "equal")) {
> -		if (ctx->argc !=3D 2)
> -			exit_bad_args();
> -		rxfhindir_equal =3D get_int_range(ctx->argp[1], 0, 1, INT_MAX);
> -	} else if (!strcmp(ctx->argp[0], "weight")) {
> -		rxfhindir_weight =3D ctx->argp + 1;
> -	} else {
> -		exit_bad_args();
> +
> +	ring_count.cmd =3D ETHTOOL_GRXRINGS;
> +	err =3D send_ioctl(ctx, &ring_count);
> +	if (err < 0) {
> +		perror("Cannot get RX ring count");
> +		return 102;
>  	}
> =20
> -	indir_head.cmd =3D ETHTOOL_GRXFHINDIR;
> -	indir_head.size =3D 0;
> -	err =3D send_ioctl(ctx, &indir_head);
> +	rss_head.cmd =3D ETHTOOL_GRSSH;
> +	rss_head.rss_context =3D 0;
> +	rss_head.indir_size =3D 0;
> +	rss_head.key_size =3D 0;
> +	err =3D send_ioctl(ctx, &rss_head);
>  	if (err < 0) {
> -		perror("Cannot get RX flow hash indirection table size");
> -		return 104;
> +		perror("Cannot get RX flow hash indirection and key size");
> +		return 103;
>  	}
> =20
> -	indir =3D malloc(sizeof(*indir) +
> -		       indir_head.size * sizeof(*indir->ring_index));
> -	indir->cmd =3D ETHTOOL_SRXFHINDIR;
> -	indir->size =3D indir_head.size;
> +	if (!strcmp(ctx->argp[0], "hkey")) {
> +		err =3D parse_hkey(&rss_hkey, rss_head.key_size,
> +				 ctx->argp[1]);
> +		if (err < 0)
> +			return err;
> +
> +		arg_num =3D 2;
> +		if (!ctx->argp[arg_num])
> +			parse_indir =3D 0;
> +	}
> =20
> +	if (parse_indir) {
> +		if (!strcmp(ctx->argp[arg_num], "equal"))
> +			rxfhindir_equal =3D get_int_range(ctx->argp[arg_num + 1],
> +							0, 1, INT_MAX);
> +		else if (!strcmp(ctx->argp[arg_num], "weight"))
> +			rxfhindir_weight =3D ctx->argp + arg_num + 1;
> +		else
> +			exit_bad_args();
> +
> +		indir_bytes =3D rss_head.indir_size * entry_size;
> +	}
> +
> +	rss =3D calloc(1, sizeof(*rss) + indir_bytes + rss_head.key_size);
> +	rss->cmd =3D ETHTOOL_SRSSH;
> +	rss->indir_size =3D rss_head.indir_size;
> +	rss->key_size =3D rss_head.key_size;
> +
> +	/*
> +	 * indir_size =3D 0 =3D=3D> reset indir to default
> +	 * indir_size =3D 0xDEADBEEF =3D=3D> ignore indir
> +	 */
>  	if (rxfhindir_equal) {
> -		for (i =3D 0; i < indir->size; i++)
> -			indir->ring_index[i] =3D i % rxfhindir_equal;
> -	} else {
> +		for (i =3D 0; i < rss->indir_size; i++)
> +			rss->rss_config[i] =3D i % rxfhindir_equal;
> +		arg_num +=3D 2;
> +		if (ctx->argp[arg_num] &&
> +		    !strcmp(ctx->argp[arg_num], "hkey")) {
> +			err =3D parse_hkey(&rss_hkey, rss_head.key_size,
> +					 ctx->argp[arg_num + 1]);
> +			if (err < 0)
> +				return err;
> +		}
> +	} else if (rxfhindir_weight) {
>  		u32 j, weight, sum =3D 0, partial =3D 0;
> =20
>  		for (j =3D 0; rxfhindir_weight[j]; j++) {
> +			if (!strcmp(rxfhindir_weight[j], "hkey")) {
> +				err =3D parse_hkey(&rss_hkey,
> +						 rss_head.key_size,
> +						 rxfhindir_weight[++j]);
> +				if (err < 0)
> +					return err;
> +				break;
> +			}

The repeated checks for "hkey" is unfortunate.  You should be able to
parse out the keywords using something like this:

	while (arg_num < ctx->argc) {
		if (!strcmp(ctx->argp[arg_num], "equal")) {
			++arg_num;
			rxfhindir_equal =3D get_int_range(ctx->argp[arg_num],
							0, 1, INT_MAX);
			++arg_num;
		} else if (!strcmp(ctx->argp[arg_num], "weight")) {
			++arg_num;
			rxfhindir_weight =3D ctx->argp + arg_num;
			while (arg_num < ctx->argc &&
			       isdigit((unsigned char)ctx->argp[arg_num][0]))
				++arg_num;
		} else if (!strcmp(ctx->argp[arg_num], "hkey")) {
			++arg_num;
			rxfhindir_key =3D ctx->argp + arg_num;
			++arg_num;
		} else {
			exit_bad_args();
		}
	}

and then do the complete validation afterwad.

Also, you obviously didn't run the tests (make check)... you'll need to
make them pass, and add new ones to cover the hkey keyword.

>  			weight =3D get_u32(rxfhindir_weight[j], 0);
>  			sum +=3D weight;
>  		}
> @@ -3131,7 +3270,7 @@ static int do_srxfhindir(struct cmd_context *ctx)
>  			exit(1);
>  		}
> =20
> -		if (sum > indir->size) {
> +		if (sum > rss->indir_size) {
>  			fprintf(stderr,
>  				"Total weight exceeds the size of the "
>  				"indirection table\n");
> @@ -3139,22 +3278,31 @@ static int do_srxfhindir(struct cmd_context *ctx)
>  		}
> =20
>  		j =3D -1;
> -		for (i =3D 0; i < indir->size; i++) {
> -			while (i >=3D indir->size * partial / sum) {
> +		for (i =3D 0; i < rss->indir_size; i++) {
> +			while (i >=3D rss->indir_size * partial / sum) {
>  				j +=3D 1;
>  				weight =3D get_u32(rxfhindir_weight[j], 0);
>  				partial +=3D weight;
>  			}
> -			indir->ring_index[i] =3D j;
> +			rss->rss_config[i] =3D j;
>  		}
> +	} else {
> +		rss->indir_size =3D 0xDEADBEEF;

This will need to be changed to ETH_RXFH_INDIR_NO_CHANGE (and the
comment about this magic number needs to be removed).

>  	}
> =20
> -	err =3D send_ioctl(ctx, indir);
> +	if (rss_hkey) {
> +		memcpy((char *)rss->rss_config + indir_bytes,
> +		       rss_hkey, rss->key_size);
> +		free(rss_hkey);
> +	} else {
> +		rss->key_size =3D 0;
> +	}
> +
> +	err =3D send_ioctl(ctx, rss);
>  	if (err < 0) {
> -		perror("Cannot set RX flow hash indirection table");
> +		perror("Cannot set RX flow hash configuration");
>  		return 105;
>  	}
> -
>  	return 0;
>  }
> =20
> @@ -3833,11 +3981,12 @@ static const struct option {
>  	  "		delete %d\n" },
>  	{ "-T|--show-time-stamping", 1, do_tsinfo,
>  	  "Show time stamping capabilities" },
> -	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
> -	  "Show Rx flow hash indirection" },
> -	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
> -	  "Set Rx flow hash indirection",
> -	  "		equal N | weight W0 W1 ...\n" },
> +	{ "-x|--show-rxfh-indir|--show-rxfh", 1, do_grxfh,
> +	  "Show Rx flow hash indirection and/or hashkey" },
> +	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
> +	  "Set Rx flow hash indirection and/or hashkey",
> +	  "		equal N | weight W0 W1 ...\n"

The indirection table part is also optional now, so you should put
brackets around that.

> +	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
>  	{ "-f|--flash", 1, do_flash,
>  	  "Flash firmware image from the specified file to a region on the devi=
ce",
>  	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },

Ben.

--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-VdDmQZK6C/JBEGxYJeCj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vYEee/yOyVhhEJAQorDw//QfFCRzS1XHTFbDL0jIB0VtndLnhSiZnz
pTQ0lBA8AlwexgEaMxQmCQr0hNi3z22Xz/xwHasCTPfCSpn2Q8tZsYvYXgDE0WNF
khW/AQiJsz43SOIeL54wwLxTXRenDNIDnw9ZhvyTbY92TEeL/55aI+MWT7QrooBl
oH3rRkkzMrFfD6BsCSDslBKLc1Ysts9HjNW9LN05cbJl9Y+4Qcj8Bes6dR35cdxS
YzYRecAQj8kYQtkV5D9IDD+GKvg0EIaDJbJ+x82M3ji/xJHQyQBVWJw9i+Ngo31+
9iGUN6gugKg614ajLcW8GjyMus1Q5nz3iXOIu7SSSyaJJbVjHtUy6CLFQykmIOys
ifRPnUjPbtDxAzEZK6OJ6DgaR15R0VMNTgjgD+9at6Wd8gxKTUbQJiOHk7Z3W5Jp
uyvJPL+6JaPZmmppXswa++uq/Y5rXfR0GZDFiCDb+T8LGbcl6I6ihAlIybkS1SqU
5BLDcldbv3q/5etT/dnIWC809Wy2RPunSh7rQI78F1fyyoIJ9BI1jZXURd3ohiCh
+HZhLVsBAwdGKVLBATPEO8xL9z/1W6NGwi3TriigkGWs/LjFlLtTF17PZjbV/OPD
yCB8bvwHUs3NG0bWkd/qL1bi4zN+Fdr0y80abBirN0ltZWsK/uHrZIMjYjJvbGvW
0dvAxrfSv/o=
=uTsQ
-----END PGP SIGNATURE-----

--=-VdDmQZK6C/JBEGxYJeCj--
