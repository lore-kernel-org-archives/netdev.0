From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v6 ethtool 2/2] ethtool: Support for configurable RSS
 hash key
Date: Sun, 20 Jul 2014 18:42:07 +0100
Message-ID: <1405878127.2682.38.camel@deadeye.wl.decadent.org.uk>
References: <1402069888-13302-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <8f08e0df-1ab6-4dc6-b331-ee1bf820593b@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i8ATcUTdDNUAW0TrzWsQ"
Cc: netdev@vger.kernel.org
To: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35865 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752893AbaGTRmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 13:42:24 -0400
In-Reply-To: <8f08e0df-1ab6-4dc6-b331-ee1bf820593b@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i8ATcUTdDNUAW0TrzWsQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-06-06 at 21:21 +0530, Venkat Duvvuru wrote:
> This ethtool patch will primarily implement the parser for the options pr=
ovided
> by the user for set and get rxfh before invoking the ioctl.
> This patch also has Ethtool man page changes which describes the Usage of
> set and get rxfh options.

Sorry for not reviewing this earlier.

> Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> ---
>  ethtool.8.in |   18 ++-
>  ethtool.c    |  390 ++++++++++++++++++++++++++++++++++++++++++++++++----=
-----
>  2 files changed, 340 insertions(+), 68 deletions(-)
>=20
> diff --git a/ethtool.8.in b/ethtool.8.in
> index bb394cc..df5a6ce 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
[...]
> -.B \-x \-\-show\-rxfh\-indir
> -Retrieves the receive flow hash indirection table.
> +.B \-x \-\-show\-rxfh\-indir \-\-show\-rxfh
> +Retrieves the receive flow hash indirection table and/or RSS hash key.
>  .TP
> -.B \-X \-\-set\-rxfh\-indir
> -Configures the receive flow hash indirection table.
> +.B \-X \-\-set\-rxfh\-indir \-\-rxfh
> +Configures the receive flow hash indirection table and/or RSS hash key.
> +.TP
> +.BI hkey
> +Sets rss hash key of the specified network device. RSS hash key should b=
e of device supported length.

Please use upper-case 'RSS' consistently in the manual page and all
messages.

> +Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the nib=
bles of a byte should be mentioned
> +even if a nibble is zero.
>  .TP
>  .BI equal\  N
>  Sets the receive flow hash indirection table to spread flows evenly
> diff --git a/ethtool.c b/ethtool.c
> index 8e968a8..f463e10 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -878,6 +878,72 @@ static char *unparse_rxfhashopts(u64 opts)
>  	return buf;
>  }
> =20
> +static int convert_string_to_hashkey(char *rss_hkey, u32 key_size,
> +				     const char *rss_hkey_string)
> +{
> +	u32 i =3D 0;
> +	int hex_byte, len;
> +
> +	do {
> +		if (i > (key_size - 1)) {
> +			fprintf(stderr,
> +				"Invalid key: Key is too long\n");
> +			goto err;
> +		}

This previously reported that the key needs to be so many bytes long,
and I said you should say specifically that the key is too long.  I did
not mean you should stop reporting what the correct length is!

Think about what kind of errors a user might make and what information
they would need to correct them.  Maybe they don't know how long the key
for this device needs to be.  Maybe they dropped or repeated a byte.
They need to know at least the correct key length, and telling them how
many bytes they provided would be helpful too.  So, something like:

			fprintf(stderr, "Key is too long for device (%u > %u)\n",
				i, key_size);

> +		if (sscanf(rss_hkey_string, "%2x%n", &hex_byte, &len) < 1 ||
> +		    len !=3D 2) {
> +			fprintf(stderr, "Invalid rss hash key format\n");
> +			goto err;
> +		}

I said "don't use title-case in error messages" but you've converted
everything to lower-case including "rss".  "rss" should still be
capitalised, just not the first letter of every word.

> +		rss_hkey[i++] =3D hex_byte;
> +		rss_hkey_string +=3D 2;
> +
> +		if (*rss_hkey_string =3D=3D ':') {
> +			rss_hkey_string++;
> +		} else if (*rss_hkey_string !=3D '\0') {
> +			fprintf(stderr, "Invalid rss hash key format\n");
> +			goto err;
> +		}
> +
> +	} while (*rss_hkey_string);
> +
> +	if (i !=3D key_size) {
> +		fprintf(stderr, "Invalid key: Key is too short\n");
> +		goto err;
> +	}

Again you stil need to say what the correct length is.

> +	return 0;
> +err:
> +	return -EINVAL;
> +}

Why is this returning a negative error code?  No other function in
ethtool does that.

[...]=20
> -static int do_grxfhindir(struct cmd_context *ctx)
> +static void print_indir_table(struct cmd_context *ctx,
> +			      struct ethtool_rxnfc *ring_count,
> +			      u32 indir_size, u32 *indir)
>  {
> -	struct ethtool_rxnfc ring_count;
> -	struct ethtool_rxfh_indir indir_head;
> -	struct ethtool_rxfh_indir *indir;
>  	u32 i;
> -	int err;
> =20
> -	ring_count.cmd =3D ETHTOOL_GRXRINGS;
> -	err =3D send_ioctl(ctx, &ring_count);
> -	if (err < 0) {
> -		perror("Cannot get RX ring count");
> -		return 102;
> +	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
> +	       ctx->devname, ring_count->data);
> +
> +	if (!indir_size)
> +		perror("Operation not supported\n");

Calling perror() with an error message does not make any sense.  And the
last function that might set errno was printf(), which is surely not
what you want to complain about here.

[...]
> +static int do_grxfhindir(struct cmd_context *ctx,
> +			 struct ethtool_rxnfc *ring_count)
> +{
> +	struct ethtool_rxfh_indir indir_head;
> +	struct ethtool_rxfh_indir *indir;
> +	int err;
> =20
>  	indir_head.cmd =3D ETHTOOL_GRXFHINDIR;
>  	indir_head.size =3D 0;
>  	err =3D send_ioctl(ctx, &indir_head);
>  	if (err < 0) {
> -		perror("Cannot get RX flow hash indirection table size");
> +		perror("Cannot get RX flow hash indirection table size\n");

No, read the manual page.

>  		return 103;
>  	}
> =20
>  	indir =3D malloc(sizeof(*indir) +
>  		       indir_head.size * sizeof(*indir->ring_index));
> +	if (!indir) {
> +		perror("Cannot allocate memory for indirection table\n");
> +		return 104;
> +	}

You should return only the conventional codes 1 (failure) or 2 (usage
error) from new error cases.  The assignment of a number to each error
case has never been documented and we have nearly run out of them (exit
codes are 8-bit and values >=3D 127 have special meaning for shells).

>  	indir->cmd =3D ETHTOOL_GRXFHINDIR;
>  	indir->size =3D indir_head.size;
>  	err =3D send_ioctl(ctx, indir);
>  	if (err < 0) {
>  		perror("Cannot get RX flow hash indirection table");
> -		return 103;
> +		free(indir);
> +		return 105;
>  	}

Don't change error codes except to the conventional 1 or 2.

[...]
> -static int do_srxfhindir(struct cmd_context *ctx)
> +static int do_grxfh(struct cmd_context *ctx)
>  {
> -	int rxfhindir_equal =3D 0;
> -	char **rxfhindir_weight =3D NULL;
> -	struct ethtool_rxfh_indir indir_head;
> -	struct ethtool_rxfh_indir *indir;
> -	u32 i;
> +	struct ethtool_rxfh rss_head =3D {0};
> +	struct ethtool_rxnfc ring_count;
> +	struct ethtool_rxfh *rss;
> +	u32 i, indir_bytes;
> +	char *hkey;
>  	int err;
> =20
> -	if (ctx->argc < 2)
> -		exit_bad_args();
> -	if (!strcmp(ctx->argp[0], "equal")) {
> -		if (ctx->argc !=3D 2)
> -			exit_bad_args();
> -		rxfhindir_equal =3D get_int_range(ctx->argp[1], 0, 1, INT_MAX);
> -	} else if (!strcmp(ctx->argp[0], "weight")) {
> -		rxfhindir_weight =3D ctx->argp + 1;
> -	} else {
> -		exit_bad_args();
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
> -	if (err < 0) {
> -		perror("Cannot get RX flow hash indirection table size");
> +	rss_head.cmd =3D ETHTOOL_GRSSH;
> +	err =3D send_ioctl(ctx, &rss_head);
> +	if (errno =3D=3D EOPNOTSUPP) {
> +		return do_grxfhindir(ctx, &ring_count);

You need to check the return value before checking errno.  There is no
guarantee that errno will be set to 0 by a successful call to ioctl()
(or most other functions that may set errno).

[...]
> +static int do_srxfh(struct cmd_context *ctx)
> +{
> +	struct ethtool_rxfh rss_head =3D {0};
> +	struct ethtool_rxfh *rss;
> +	struct ethtool_rxnfc ring_count;
> +	int rxfhindir_equal =3D 0;
> +	char **rxfhindir_weight =3D NULL;
> +	char *rxfhindir_key =3D NULL;
> +	char *hkey =3D NULL;
> +	int err =3D 0;
> +	u32 arg_num =3D 0, indir_bytes =3D 0;
> +	u32 entry_size =3D sizeof(rss_head.rss_config[0]);
> +	u32 num_weights =3D 0;
> +
> +	if (ctx->argc < 2)
> +		exit_bad_args();
> +
> +	while (arg_num < ctx->argc) {
> +		if (!strcmp(ctx->argp[arg_num], "equal")) {
> +			++arg_num;
> +			rxfhindir_equal =3D get_int_range(ctx->argp[arg_num],
> +							0, 1, INT_MAX);
> +			++arg_num;
> +		} else if (!strcmp(ctx->argp[arg_num], "weight")) {
> +			++arg_num;
> +			rxfhindir_weight =3D ctx->argp + arg_num;
> +			while (arg_num < ctx->argc &&
> +			       isdigit((unsigned char)ctx->argp[arg_num][0])) {
> +				++arg_num;
> +				++num_weights;
> +			}
> +			if (!num_weights)
> +				exit_bad_args();
> +		} else if (!strcmp(ctx->argp[arg_num], "hkey")) {
> +			++arg_num;
> +			rxfhindir_key =3D ctx->argp[arg_num];
> +			if (!rxfhindir_key)
> +				exit_bad_args();
> +			++arg_num;
> +		} else {
> +			exit_bad_args();
> +		}
> +	}

You need to add test cases for this in test-cmdline.c

> +	if (rxfhindir_equal && rxfhindir_weight) {
> +		printf("Equal and weight options are mutually exclusive\n");

This is an error message so must be printed to stderr.

[...]
> -	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
> -	  "Show Rx flow hash indirection" },
> -	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
> -	  "Set Rx flow hash indirection",
> -	  "		equal N | weight W0 W1 ...\n" },
> +	{ "-x|--show-rxfh-indir|--show-rxfh", 1, do_grxfh,
> +	  "Show Rx flow hash indirection and/or hashkey" },
> +	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
> +	  "Set Rx flow hash indirection and/or hashkey",

Space between 'hash' and 'key'.

Ben.

> +	  "		[ equal N | weight W0 W1 ... ]\n"
> +	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
>  	{ "-f|--flash", 1, do_flash,
>  	  "Flash firmware image from the specified file to a region on the devi=
ce",
>  	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },

--=20
Ben Hutchings
Kids!  Bringing about Armageddon can be dangerous.  Do not attempt it in
your own home. - Terry Pratchett and Neil Gaiman, `Good Omens'


--=-i8ATcUTdDNUAW0TrzWsQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU8v/dee/yOyVhhEJAQpFTw/+N5nMHyzOXvAiIlT5t1cNPi8jD4gpOs/c
3KjhpjpF4Z0G+yyflfiM9Kw9Kqgfq/wevo+0/enC0KZi6Ko5bQqPm7Hg40NhwjAf
J7TxIEZh1sRwBeu2NpstVLO2AWYGbWLKb+nuCWShHHJH7Du1DOBUh86RQeJ0hI2V
Er61h+K/cQzfELj2VL4P8W82+bFcAjbV4RPeMzR1xSDJMEa/nUSBcaW8dorRj8Bb
IFUNpmobA/fs7UUcjHnuuUkUVUMB5gyYpNgtDYrkjC0W2HA7hat2HGvs4MnO7vlB
IpMa66rcDbICRB+3HVdJ5BeRHKPJcDFYwrIMMH+iVdVmG/8khTErwMziK6uOEIP8
uGi6is9WMAKFJho2JurTP96B9akLxkSNZfEhEEK7k1396ECAsOwW1oR07C4zfaXe
hsxmeoerDbolIJ0bvdUWmBFm9R1wv7YadDBAJAk1k3qWS37WREzeAyN0Ur4CMA+7
JThLG+ZQCaHpEHfnIw8lxK0R1/S44jCMMx9BxeSE/KEgLzWAWuaC2Gmp/mfl6oT2
QAM36KuOEbl3+fPdhx/NFmwYhGIc163NeS7wb841AQ8rKNxnu9lSb/IefQcqJnlz
/2G1JP87SisbAaUPYGh8C0UyEqcuM6uSW3KGgHyIrfKngK3FEnpoC4F70VcsraLi
1hpSud1C/sI=
=df08
-----END PGP SIGNATURE-----

--=-i8ATcUTdDNUAW0TrzWsQ--
