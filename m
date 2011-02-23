From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH ethtool 2/3] ethtool: Regularise handling of offload
	flags
Date: Wed, 23 Feb 2011 04:03:21 +0100
Message-ID: <20110223030321.GA23620@rere.qmqm.pl>
References: <1298307282.2608.47.camel@bwh-desktop> <1298307548.2608.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41141 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561Ab1BWDDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 22:03:23 -0500
Content-Disposition: inline
In-Reply-To: <1298307548.2608.50.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 21, 2011 at 04:59:08PM +0000, Ben Hutchings wrote:
> Use the new ETHTOOL_{G,S}FEATURES operations where available, and
> use the new structure and netif feature flags in any case.
[...]
> --- a/ethtool.c
> +++ b/ethtool.c
[...] =20
>  static int do_soffload(int fd, struct ifreq *ifr)
>  {
> +	struct {
> +		struct ethtool_gfeatures cmd;
> +		struct ethtool_get_features_block data[1];
> +	} get_features;
> +	struct {
> +		struct ethtool_sfeatures cmd;
> +		struct ethtool_set_features_block data[1];
> +	} set_features;
>  	struct ethtool_value eval;
>  	int err, changed =3D 0;
> +	u32 value;
> +	int i;
[-]
> +	get_features.cmd.cmd =3D ETHTOOL_GFEATURES;
> +	get_features.cmd.size =3D ARRAY_SIZE(get_features.data);
> +	ifr->ifr_data =3D (caddr_t)&get_features;
> +	err =3D ioctl(fd, SIOCETHTOOL, ifr);
> +	if (err =3D=3D 0) {
> +		set_features.cmd.cmd =3D ETHTOOL_SFEATURES;
> +		set_features.cmd.size =3D ARRAY_SIZE(set_features.data);
> +		set_features.data[0] =3D off_features;
> +
> +		for (i =3D 0; i < ARRAY_SIZE(off_feature_def); i++) {
> +			value =3D off_feature_def[i].value;
> +			if (!(off_features.valid & value))
> +				continue;
> +			if (!(get_features.data[0].available & value)) {
> +				/* None of these features can be changed */
> +				fprintf(stderr,
> +					"Cannot set device %s settings: "
> +					"Operation not supported\n",
> +					off_feature_def[i].long_name);
> +			} else if (off_features.requested & value) {
> +				/* Some of these features can be
> +				 * enabled; mask out any that cannot
> +				 */
> +				set_features.data[0].requested &=3D
> +					~(value &
> +					  ~get_features.data[0].available);
> +			}
>  		}
[-]
> +		ifr->ifr_data =3D (caddr_t)&set_features;
> +		err =3D ioctl(fd, SIOCETHTOOL, ifr);
> +		if (err < 0) {
> +			perror("Cannot set device offload settings");
> +			return 1;
>  		}
[-]
> +		changed =3D !!set_features.data[0].valid;
[-]
> +		if (err & ETHTOOL_F_WISH)
> +			fprintf(stderr,
> +				"Cannot set device offload settings: "
> +				"Some requested features depend on others "
> +				"that are not currently enabled\n");
> +
> +		/* ETHTOOL_F_UNSUPPORTED should never be set as we
> +		 * checked for unsupported flags above.  Treat any
> +		 * other warning flags as unknown.
> +		 */
> +		if (err & ~ETHTOOL_F_WISH)
> +			fprintf(stderr,
> +				"Cannot set device offload settings: "
> +				"warning flags %#x",
> +				err & ~ETHTOOL_F_WISH);
> +	} else if (errno !=3D EOPNOTSUPP && errno !=3D EPERM) {
> +		perror("Cannot get device offload settings");
> +		return 1;
> +	} else {
> +		for (i =3D 0; i < ARRAY_SIZE(off_feature_def); i++) {
> +			if (!off_feature_def[i].cmd)
> +				continue;
> +			if (off_features.valid & off_feature_def[i].value) {
> +				changed =3D 1;
> +				eval.cmd =3D off_feature_def[i].cmd + 1;
> +				eval.data =3D !!(off_features.requested &
> +					       off_feature_def[i].value);
> +				ifr->ifr_data =3D (caddr_t)&eval;
> +				err =3D send_ioctl(fd, ifr);
> +				if (err) {
> +					fprintf(stderr,
> +						"Cannot set device %s settings: %m\n",
> +						off_feature_def[i].long_name);
> +					return 1;
> +				}
> +			}
>  		}
[-]
> +		if (off_features.valid & flags_dup_features) {
> +			changed =3D 1;
> +			eval.cmd =3D ETHTOOL_GFLAGS;
> +			eval.data =3D 0;
> +			ifr->ifr_data =3D (caddr_t)&eval;
> +			err =3D ioctl(fd, SIOCETHTOOL, ifr);
> +			if (err) {
> +				perror("Cannot get device flag settings");
> +				return 91;
> +			}
[-]
> +			eval.cmd =3D ETHTOOL_SFLAGS;
> +			eval.data &=3D ~(off_features.valid & flags_dup_features);
> +			eval.data |=3D (off_features.requested &
> +				      flags_dup_features);
> +
> +			err =3D ioctl(fd, SIOCETHTOOL, ifr);
> +			if (err) {
> +				perror("Cannot set device flag settings");
> +				return 92;
> +			}
>  		}
>  	}

I noticed that you assumed that ETHTOOL_SFEATURES can change all featur=
es
changeable. This was not the case for drivers not yet converted to
ndo_fix_features() as there could be features changeable only by old op=
s.
I implemented the kernel part for fixing that in patches sent earlier t=
oday.
This introduces ETHTOOL_F_COMPAT bit that indicates when the compatibil=
ity
fallback was used (requested features are not fully saved by kernel in
that case).

Best Regards,
Micha=B3 Miros=B3aw

