From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool : Add option -L | --set-common to set common
 flags.
Date: Fri, 14 Jan 2011 21:19:44 +0000
Message-ID: <1295039984.5386.19.camel@bwh-desktop>
References: <1294963892-11997-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32397 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab1ANVTr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 16:19:47 -0500
In-Reply-To: <1294963892-11997-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-13 at 16:11 -0800, Mahesh Bandewar wrote:
> This patch adds -L | --set-common option to add / remove common flags=
 which
> includes loopback flag. The -l | --show-common displays the current v=
alues
> for these common flags.
>=20
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  ethtool-copy.h |    1 +
>  ethtool.8      |   16 ++++++++++
>  ethtool.c      |   90 ++++++++++++++++++++++++++++++++++++++++++++++=
++++++++-
>  3 files changed, 105 insertions(+), 2 deletions(-)
>=20
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 75c3ae7..5fd18c7 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -309,6 +309,7 @@ struct ethtool_perm_addr {
>   * flag differs from the read-only value.
>   */
>  enum ethtool_flags {
> +	ETH_FLAG_LOOPBACK	=3D (1 << 2),	/* Loopback enable / disable */
>  	ETH_FLAG_TXVLAN		=3D (1 << 7),	/* TX VLAN offload enabled */
>  	ETH_FLAG_RXVLAN		=3D (1 << 8),	/* RX VLAN offload enabled */
>  	ETH_FLAG_LRO		=3D (1 << 15),	/* LRO is enabled */
> diff --git a/ethtool.8 b/ethtool.8
> index 1760924..cf7128f 100644
> --- a/ethtool.8
> +++ b/ethtool.8
> @@ -174,6 +174,13 @@ ethtool \- Display or change ethernet card setti=
ngs
>  .B2 txvlan on off
>  .B2 rxhash on off
> =20
> +.B ethtool \-l|\-\-show\-common
> +.I ethX
> +
> +.B ethtool \-L|\-\-set\-common
> +.I ethX
> +.B2 loopback on off
> +
>  .B ethtool \-p|\-\-identify
>  .I ethX
>  .RI [ N ]
> @@ -406,6 +413,15 @@ Specifies whether TX VLAN acceleration should be=
 enabled
>  .A2 rxhash on off
>  Specifies whether receive hashing offload should be enabled
>  .TP
> +.B \-l \-\-show\-common
> +Queries the specified ethernet device for common flag settings.
> +.TP
> +.B \-L \-\-set\-common
> +Changes the common parameters of the specified ethernet device.
> +.TP
> +.A2 loopback on off
> +Specifies whether loopback should be enabled.
> +.TP

I've just gone through the manual page and changed 'ethernet device' to
'network device' for all generic operations; please follow that.  The
source for the manual page was also renamed to ethtool.8.in as it now
goes through autoconf substitution.

>  .B \-p \-\-identify
>  Initiates adapter-specific action intended to enable an operator to
>  easily identify the adapter by sight.  Typically this involves
> diff --git a/ethtool.c b/ethtool.c
> index 63e0ead..1a0c10c 100644
> --- a/ethtool.c
> +++ b/ethtool.c
[...]
> @@ -1905,6 +1932,13 @@ static int dump_offload(int rx, int tx, int sg=
, int tso, int ufo, int gso,
>  	return 0;
>  }
> =20
> +static int dump_common_flags(int loopback)
> +{
> +	fprintf(stdout, "loopback: %s\n", loopback ? "on" : "off");
> +
> +	return 0;
> +}
> +
>  static int dump_rxfhash(int fhash, u64 val)
>  {
>  	switch (fhash) {
[...]
> @@ -2219,6 +2257,53 @@ static int do_scoalesce(int fd, struct ifreq *=
ifr)
>  	return 0;
>  }
> =20
> +static int do_gcommon(int fd, struct ifreq *ifr)
> +{
> +	struct ethtool_value eval;
> +	int loopback =3D 0;
> +
> +	fprintf(stdout, "Common flags for %s:\n", devname);
> +
> +	eval.cmd =3D ETHTOOL_GFLAGS;
> +	ifr->ifr_data =3D (caddr_t)&eval;
> +	if (ioctl(fd, SIOCETHTOOL, ifr)) {
> +		perror("Cannot get device flags");
> +	} else {
> +		loopback =3D (eval.data & ETH_FLAG_LOOPBACK) !=3D 0;
> +	}
> +
> +	return dump_common_flags(loopback);

Breaking up a bitmask into a list of flag parameters is fairly
pointless.  I realise do_goffload() and dump_offload() do that but I am
just waiting for Micha=C5=82 Miros=C5=82aw's changes to offload flags t=
o be
settled before I fix them.

> +}
> +
> +static int do_scommon(int fd, struct ifreq *ifr)
> +{
> +	struct ethtool_value eval;
> +
> +	if (common_flags_mask) {
> +		eval.cmd =3D ETHTOOL_GFLAGS;
> +		eval.data =3D 0;
> +		ifr->ifr_data =3D (caddr_t)&eval;
> +		if (ioctl(fd, SIOCETHTOOL, ifr)) {
> +			perror("Cannot get device common flags");
> +			return 1;
> +		}
> +
> +		eval.cmd =3D ETHTOOL_SFLAGS;
> +		eval.data =3D
> +		    ((eval.data & ~(common_flags_mask | off_flags_mask)) |
> +		     (common_flags_wanted | off_flags_wanted));

Why should this use off_flags_mask and off_flags_wanted?  They should
both be 0 if this function is called.

> +		if (ioctl(fd, SIOCETHTOOL, ifr)) {
> +			perror("Cannot set device common flags");
> +			return 1;
> +		}
> +	} else {
> +		fprintf(stdout, "No common settings changed\n");
> +	}
> +
> +	return 0;
> +}
> +
>  static int do_goffload(int fd, struct ifreq *ifr)
>  {
>  	struct ethtool_value eval;
> @@ -2407,8 +2492,9 @@ static int do_soffload(int fd, struct ifreq *if=
r)
>  		}
> =20
>  		eval.cmd =3D ETHTOOL_SFLAGS;
> -		eval.data =3D ((eval.data & ~off_flags_mask) |
> -			     off_flags_wanted);
> +		eval.data =3D
> +		    ((eval.data & ~(off_flags_mask | common_flags_mask)) |
> +		     (off_flags_wanted | common_flags_wanted));

Similarly, why should this use common_flags_mask and
common_flags_wanted?

Ben.

> =20
>  		err =3D ioctl(fd, SIOCETHTOOL, ifr);
>  		if (err) {

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

