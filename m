From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH] dp83640: Get gpio and master/slave configuration from
 DT
Date: Mon, 10 Feb 2014 13:42:38 +0000
Message-ID: <20140210134237.GF29080@e106331-lin.cambridge.arm.com>
References: <1392037240-30913-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stefan =?utf-8?B?U8O4cmVuc2Vu?= <stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392037240-30913-1-git-send-email-stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 10, 2014 at 01:00:40PM +0000, Stefan S=C3=B8rensen wrote:
> This patch removes the module parameters gpio_tab and chosen_phy in f=
avour of
> retrieving the configuration from DT through the properties
> 	dp83640,slave
> 	dp83640,calibrate-gpio
> 	dp83640,perout-gpios
> 	dp83640,extts-gpios
> The configuration is now stored for each master clock device, allowin=
g different=20
> gpio setups for each master.
>=20
> Furthermore the code is enhanced to handle more than one periodic out=
put.

Binding document please.

I have some basic comments below, but without a description of what the
properties mean, it's difficult to provide any meaningful review.

[...]

> +static int dp83640_probe_dt(struct device_node *node,
> +			    struct dp83640_private *dp83640)
> +{
> +	struct dp83640_clock *clock =3D dp83640->clock;
> +	struct property *prop;
> +	int err, proplen;
> +
> +	if (!node)
> +		return 0;
> +
> +	if (of_find_property(node, "dp83640,slave", NULL))
> +		dp83640->slave =3D true;

Use of_property_read_bool.

> +	if (!dp83640->slave && clock->chosen) {
> +		pr_err("dp83640,slave must be set if more than one device on the s=
ame bus");
> +		return -EINVAL;
> +	}
> +
> +	prop =3D of_find_property(node, "dp83640,perout-gpios", &proplen);
> +	if (prop) {
> +		if (dp83640->slave) {
> +			pr_err("dp83640,perout-gpios property can not be set together wit=
h dp83640,slave");
> +			return -EINVAL;
> +		}
> +
> +		clock->caps.n_per_out =3D proplen / sizeof(u32);
> +		if (clock->caps.n_per_out > N_EXT) {
> +			pr_err("dp83640,perout-gpios may not have more than %d entries",
> +			       N_EXT);
> +			return -EINVAL;
> +		}
> +		err =3D of_property_read_u32_array(node, "dp83640,perout-gpios",
> +						 clock->perout_gpios,
> +						 clock->caps.n_per_out);
> +		if (err < 0)
> +			return err;
> +	}

This looks nothing like the standard gpio bindings. What _exactly_ is
this property describing?

If this is not using the standard gpio bindings then this should be
renamed.

Either way this must be documented.

> +
> +	prop =3D of_find_property(node, "dp83640,extts-gpios", &proplen);
> +	if (prop) {
> +		if (dp83640->slave) {
> +			pr_err("dp83640,extts-gpios property can not be set together with=
 dp83640,slave");
> +			return -EINVAL;
> +		}
> +
> +		clock->caps.n_ext_ts =3D proplen / sizeof(u32);
> +		if (clock->caps.n_ext_ts > N_EXT) {
> +			pr_err("dp83640,extts-gpios may not have more than %d entries",
> +			       N_EXT);
> +			return -EINVAL;
> +		}
> +		err =3D of_property_read_u32_array(node, "dp83640,extts-gpios",
> +						 clock->extts_gpios,
> +						 clock->caps.n_ext_ts);
> +		if (err < 0)
> +			return err;
> +	}

Similarly this does not look right for parsing a standard -gpios proper=
ty.

> +
> +	prop =3D of_find_property(node, "dp83640,calibrate-gpio", &proplen)=
;
> +	if (prop) {
> +		if (dp83640->slave) {
> +			pr_err("dp83640,calibrate-gpio property can not be set together w=
ith dp83640,slave");
> +			return -EINVAL;
> +		}
> +		clock->calibrate_gpio =3D -1;
> +		of_property_read_u32(node, "dp83640,calibrate-gpio",
> +				     &clock->calibrate_gpio);
> +	}

And again, this doesn't look right.

Thanks,
Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
