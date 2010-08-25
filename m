From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH v2] driver core: platform_bus: allow runtime override of dev_pm_ops
Date: Wed, 25 Aug 2010 12:50:00 -0700
Message-ID: <871v9mfp5j.fsf@deeprootsystems.com>
References: <1282583922-984-1-git-send-email-khilman@deeprootsystems.com>
	<AANLkTikMmuQbrGB-S1FWcmRJQ0Lmr9MYJkXHtEw7VXnE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:64655 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab0HYTuD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:50:03 -0400
In-Reply-To: <AANLkTikMmuQbrGB-S1FWcmRJQ0Lmr9MYJkXHtEw7VXnE@mail.gmail.com>
	(Grant Likely's message of "Wed, 25 Aug 2010 01:30:09 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely <grant.likely@secretlab.ca> writes:

> On Mon, Aug 23, 2010 at 11:18 AM, Kevin Hilman
> <khilman@deeprootsystems.com> wrote:
>> Currently, the platform_bus allows customization of several of the
>> busses dev_pm_ops methods by using weak symbols so that platform cod=
e
>> can override them. =A0The weak-symbol approach is not scalable when
>> wanting to support multiple platforms in a single kernel binary.
>>
>> Instead, provide __init methods for platform code to customize the
>> dev_pm_ops methods at runtime.
>>
>> NOTE: after these dynamic methods are merged, the weak symbols shoul=
d
>> =A0 =A0 =A0be removed from drivers/base/platform.c. =A0AFAIK, this w=
ill only
>> =A0 =A0 =A0affect SH and sh-mobile which should be converted to use =
this
>> =A0 =A0 =A0runtime approach instead of the weak symbols. =A0After SH=
 &
>> =A0 =A0 =A0sh-mobile are converted, the weak symobols could be remov=
ed.
>>
>> Tested on OMAP3.
>>
>> Cc: Grant Likely <grant.likely@secretlab.ca>
>> Cc: Magnus Damm <magnus.damm@gmail.com>
>> Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
>
> Looks good to me.  A handful of nitpicks below, I don't know if Greg
> will want you to respin for these or not.  Feel free to add my
> acked-by line though:
>
> Acked-by: Grant Likely <grant.likely@secretlab.ca>

Thanks, here's a re-spin with your signoff and fixing the issues you
raised.

Applies to v2.6.36-rc1.

Kevin

=46rom 728f0ae551e805a10c9a45bcfb29f81ad45842da Mon Sep 17 00:00:00 200=
1
=46rom: Kevin Hilman <khilman@ti.com>
Date: Fri, 20 Aug 2010 10:46:53 -0700
Subject: [PATCH] driver core: platform_bus: allow runtime override of d=
ev_pm_ops

Currently, the platform_bus allows customization of several of the
busses dev_pm_ops methods by using weak symbols so that platform code
can override them.  The weak-symbol approach is not scalable when
wanting to support multiple platforms in a single kernel binary.

Instead, provide __init methods for platform code to customize the
dev_pm_ops methods at runtime.

NOTE: after these dynamic methods are merged, the weak symbols should
      be removed from drivers/base/platform.c.  AFAIK, this will only
      affect SH and sh-mobile which should be converted to use this
      runtime approach instead of the weak symbols.  After SH &
      sh-mobile are converted, the weak symobols could be removed.

Tested on OMAP3.

Cc: Magnus Damm <magnus.damm@gmail.com>
Acked-by: Grant Likely <grant.likely@secretlab.ca>
Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
---
 drivers/base/platform.c         |   35 +++++++++++++++++++++++++++++++=
++++
 include/linux/platform_device.h |    3 +++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index c6c933f..468bbfd 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -976,6 +976,41 @@ struct bus_type platform_bus_type =3D {
 };
 EXPORT_SYMBOL_GPL(platform_bus_type);
=20
+/**
+ * platform_bus_get_pm_ops() - return pointer to busses dev_pm_ops
+ *
+ * This function can be used by platform code to get the current
+ * set of dev_pm_ops functions used by the platform_bus_type.
+ */
+const struct dev_pm_ops * __init platform_bus_get_pm_ops(void)
+{
+	return platform_bus_type.pm;
+}
+
+/**
+ * platform_bus_set_pm_ops() - update dev_pm_ops for the platform_bus_=
type
+ *
+ * @pm: pointer to new dev_pm_ops struct to be used for platform_bus_t=
ype
+ *
+ * Platform code can override the dev_pm_ops methods of
+ * platform_bus_type by using this function.  It is expected that
+ * platform code will first do a platform_bus_get_pm_ops(), then
+ * kmemdup it, then customize selected methods and pass a pointer to
+ * the new struct dev_pm_ops to this function.
+ *
+ * Since platform-specific code is customizing methods for *all*
+ * devices (not just platform-specific devices) it is expected that
+ * any custom overrides of these functions will keep existing behavior
+ * and simply extend it.  For example, any customization of the
+ * runtime PM methods should continue to call the pm_generic_*
+ * functions as the default ones do in addition to the
+ * platform-specific behavior.
+ */
+void __init platform_bus_set_pm_ops(const struct dev_pm_ops *pm)
+{
+	platform_bus_type.pm =3D pm;
+}
+
 int __init platform_bus_init(void)
 {
 	int error;
diff --git a/include/linux/platform_device.h b/include/linux/platform_d=
evice.h
index d7ecad0..2e700ec 100644
--- a/include/linux/platform_device.h
+++ b/include/linux/platform_device.h
@@ -138,6 +138,9 @@ extern struct platform_device *platform_create_bund=
le(struct platform_driver *dr
 					struct resource *res, unsigned int n_res,
 					const void *data, size_t size);
=20
+extern const struct dev_pm_ops * platform_bus_get_pm_ops(void);
+extern void platform_bus_set_pm_ops(const struct dev_pm_ops *pm);
+
 /* early platform driver interface */
 struct early_platform_driver {
 	const char *class_str;
--=20
1.7.2.1

