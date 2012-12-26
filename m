From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Wed, 26 Dec 2012 14:24:40 -0800
Message-ID: <1356560680.26650.15.camel@joe-AO722>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33206 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750759Ab2LZWYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2012 17:24:41 -0500
In-Reply-To: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-24 at 16:33 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
> BCMA is a Broadcom specific bus with devices AKA cores. All recent BC=
MA
> based SoCs have gigabit ethernet provided by the GBit MAC core. This
> patch adds driver for such a cores registering itself as a netdev. It
> has been tested on a BCM4706 and BCM4718 chipsets.

Just a trivial note:

> diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethe=
rnet/broadcom/bgmac.h
[]
> @@ -0,0 +1,443 @@
> +#ifndef _BGMAC_H
> +#define _BGMAC_H
> +
> +#define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
> +
> +#define bgmac_err(bgmac, fmt, ...) \
> +	pr_err("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
> +#define bgmac_warn(bgmac, fmt, ...) \
> +	pr_warn("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
> +#define bgmac_info(bgmac, fmt, ...) \
> +	pr_info("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)
> +#define bgmac_dbg(bgmac, fmt, ...) \
> +	pr_debug("u%d: " fmt, (bgmac)->core->core_unit, ##__VA_ARGS__)

Maybe all the bgmac_<level> macros should be:

	dev_<level>(&bgmac->core->dev, "u%d: " fmt,
	            (bgmac)->core->core_unit, ##__VA_ARGS)

or maybe a new function like below if you use
a lot of these to decrease object size a little.

int bgmac_printk(const char *level, const struct bgmac *bgmac,
                 const char *fmt, ...)
{

	struct va_format vaf;
	va_list args;
	int r;

	va_start(args, fmt);

	vaf.fmt =3D fmt;
	vaf.va =3D &args;

	r =3D dev_printk(&bgmac->core->dev, "u%d: %pV",
	               bgmac->core->core_unit, &vaf);

	va_end(args);

	return r;
}
