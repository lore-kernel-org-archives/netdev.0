From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2] driver core: platform_bus: allow runtime override of dev_pm_ops
Date: Wed, 25 Aug 2010 01:30:09 -0600
Message-ID: <AANLkTikMmuQbrGB-S1FWcmRJQ0Lmr9MYJkXHtEw7VXnE@mail.gmail.com>
References: <1282583922-984-1-git-send-email-khilman@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	=?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>, Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43440 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab0HYHaa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 03:30:30 -0400
In-Reply-To: <1282583922-984-1-git-send-email-khilman@deeprootsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 11:18 AM, Kevin Hilman
<khilman@deeprootsystems.com> wrote:
> Currently, the platform_bus allows customization of several of the
> busses dev_pm_ops methods by using weak symbols so that platform code
> can override them. =A0The weak-symbol approach is not scalable when
> wanting to support multiple platforms in a single kernel binary.
>
> Instead, provide __init methods for platform code to customize the
> dev_pm_ops methods at runtime.
>
> NOTE: after these dynamic methods are merged, the weak symbols should
> =A0 =A0 =A0be removed from drivers/base/platform.c. =A0AFAIK, this wi=
ll only
> =A0 =A0 =A0affect SH and sh-mobile which should be converted to use t=
his
> =A0 =A0 =A0runtime approach instead of the weak symbols. =A0After SH =
&
> =A0 =A0 =A0sh-mobile are converted, the weak symobols could be remove=
d.
>
> Tested on OMAP3.
>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Magnus Damm <magnus.damm@gmail.com>
> Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>

Looks good to me.  A handful of nitpicks below, I don't know if Greg
will want you to respin for these or not.  Feel free to add my
acked-by line though:

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> ---
> =A0drivers/base/platform.c =A0 =A0 =A0 =A0 | =A0 35 +++++++++++++++++=
++++++++++++++++++
> =A0include/linux/platform_device.h | =A0 =A03 +++
> =A02 files changed, 38 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index c6c933f..e40a773 100644
> --- a/drivers/base/platform.c
> +++ b/drivers/base/platform.c
> @@ -976,6 +976,41 @@ struct bus_type platform_bus_type =3D {
> =A0};
> =A0EXPORT_SYMBOL_GPL(platform_bus_type);
>
> +/**
> + * platform_bus_get_pm_ops: return pointer to busses dev_pm_ops

Nit: first line of kerneldoc format should look like this:

/**
 * platform_bus_get_pm_ops() - return pointer to busses dev_pm_ops

> + *
> + * This function can be used by platform code to get the current
> + * set of dev_pm_ops functions used by the platform_bus_type.
> + */
> +const struct dev_pm_ops * __init platform_bus_get_pm_ops(void)
> +{
> + =A0 =A0 =A0 return platform_bus_type.pm;
> +}
> +
> +/**
> + * platform_bus_set_pm_ops: update dev_pm_ops for the platform_bus_t=
ype
> + *
> + * @pm: pointer to new dev_pm_ops struct to be used for platform_bus=
_type
> + *
> + * Platform code can override the dev_pm_ops methods of
> + * platform_bus_type by using this function. =A0It is expected that
> + * platform code will first do a platform_bus_get_pm_ops(), then
> + * kmemdup it, then customize selected methods and pass a pointer to
> + * the new struct dev_pm_ops to this function.
> + *
> + * Since platform-specific code is customizing methods for *all*
> + * devices (not just platform-specific devices) it is expected that
> + * any custom overrides of these functions will keep existing behavi=
or
> + * and simply extend it. =A0For example, any customization of the
> + * runtime PM methods should continue to call the pm_generic_*
> + * functions as the default ones do in addition to the
> + * platform-specific behavior.
> + */
> +void __init platform_bus_set_pm_ops(struct dev_pm_ops *pm)

nit: const struct dev_pm_ops would be appropriate

> +{
> + =A0 =A0 =A0 platform_bus_type.pm =3D pm;
> +}
> +
> =A0int __init platform_bus_init(void)
> =A0{
> =A0 =A0 =A0 =A0int error;
> diff --git a/include/linux/platform_device.h b/include/linux/platform=
_device.h
> index d7ecad0..cd55d39 100644
> --- a/include/linux/platform_device.h
> +++ b/include/linux/platform_device.h
> @@ -138,6 +138,9 @@ extern struct platform_device *platform_create_bu=
ndle(struct platform_driver *dr
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct resource *res, unsigned int n_res,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0const void *data, size_t size);
>
> +extern const struct dev_pm_ops * __init platform_bus_get_pm_ops(void=
);
> +extern void __init platform_bus_set_pm_ops(struct dev_pm_ops *pm);

The __init annotations should only appear in the .c file, not the heade=
r.

Cheers,
g.
