From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/4] platform: Facilitate the creation of pseudo-platform buses
Date: Wed, 18 Aug 2010 16:25:57 -0600
Message-ID: <AANLkTimkpgRz2wDZgcRwqS8wSECCaKmLuo=j1avXxFfD@mail.gmail.com>
References: <1282158943-11902-1-git-send-email-ppannuto@codeaurora.org> <1282158943-11902-3-git-send-email-ppannuto@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	magnus.damm@gmail.com, gregkh@suse.de,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>, netdev@vger.kernel.org
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35776 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab0HSARB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 20:17:01 -0400
Received: by iwn7 with SMTP id 7so58676iwn.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 17:17:01 -0700 (PDT)
In-Reply-To: <1282158943-11902-3-git-send-email-ppannuto@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

On Wed, Aug 18, 2010 at 1:15 PM, Patrick Pannuto
<ppannuto@codeaurora.org> wrote:
> (lkml.org seems to have lost August 3rd...)
> RFC: http://lkml.indiana.edu/hypermail/linux/kernel/1008.0/01342.html
> =A0v1: http://lkml.indiana.edu/hypermail/linux/kernel/1008.0/01942.ht=
ml
> =A0v2: http://lkml.indiana.edu/hypermail/linux/kernel/1008.1/00958.ht=
ml
>
> Based on the idea and code originally proposed by Kevin Hilman:
> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
>
> Changes from v2:
> =A0 * Remove the pseudo_platform_bus_[un]register functions
> =A0 * Split affected platform functions:
> =A0 =A0 =A0 - Platform functions are split into a wrapper (with the
> =A0 =A0 =A0 =A0 original function name) that retains the 'bus-setting=
'
> =A0 =A0 =A0 =A0 and 'parent-setting' duties, and then exports all the
> =A0 =A0 =A0 =A0 heavy-lifting to new __platform* counterparts
> =A0 =A0 =A0 - "Pseudo" buses work the same as the platform bus now,
> =A0 =A0 =A0 =A0 writing their own wrappers and calling the __platform
> =A0 =A0 =A0 =A0 functions
> =A0 * Export a *lot* of platform symbols to allow for intialization
> =A0 =A0 of "pseudo" platform bus types.
> =A0 =A0 =A0 - I personally like this model a lot, I think it is very
> =A0 =A0 =A0 =A0 clean from an implementation perspective, even if it
> =A0 =A0 =A0 =A0 does export a lot of new symbols
> =A0 =A0 =A0 - Thanks to Michal Miroslaw <mirqus@gmail.com> for the
> =A0 =A0 =A0 =A0 suggestion here

I'm not quite as hot on this approach, mostly because it is a lot more
invasive to the namespace than just exposing an initialization
routine.  However, I leave that as a point of 'taste' and Greg can
decide.  :-)

Otherwise, the patch looks good.  As I commented on the other patch, I
still want to see a real use case (ie, a bus with different behaviour)
before casting my vote.

One more comment below...

> =A0 * Add more use-cases justifying the need of platform-ish bus type=
s
>
> Changes from v1:
>
> =A0 * "Pseudo" buses are no longer init'd, they are [un]registered by=
:
> =A0 =A0 =A0 - pseudo_platform_bus_register(struct bus_type *)
> =A0 =A0 =A0 - pseudo_platform_bus_unregister(struct bus_type *)
> =A0 * These registrations [de]allocate a dev_pm_ops structure for the
> =A0 =A0 pseudo bus_type
> =A0 * Do not overwrite the parent if .bus is already set (that is, al=
low
> =A0 =A0 pseudo bus devices to be root devices)
>
> =A0 * Split into 2 patches:
> =A0 =A0 =A0 - 1/2: Already sent separately, but included here for cla=
rity
> =A0 =A0 =A0 - 2/2: The real meat of the patch (this patch)
>
> INTRO
>
> As SOCs become more popular, the desire to quickly define a simple,
> but functional, bus type with only a few unique properties becomes
> desirable. As they become more complicated, the ability to nest these
> simple busses and otherwise orchestrate them to match the actual
> topology also becomes desirable.
>
> Also, as power management becomes more challenging, grouping devices
> on the same SOC under the same /logical bus/ provides a very natural
> interface and location for power-management issues for that SOC.
>
> This is a fairly natural extension of the "platform" bus; ultimately,
> this patch series allows for the creation of multiple platform buses =
(SOC
> buses), with the correct name and quirks for each of the "platforms" =
(SOCs)
> they are trying to support.
>
> EXAMPLE USAGE
>
> See follow-on patches implementing the MSM bus and moving the
> MSM uart device / driver onto it.
>
> Change-Id: I10d2fa4671302e81be8f9cac01a3855cef4eeebf
> Cc: Kevin Hilman <khilman@deeprootsystems.com>
> Signed-off-by: Patrick Pannuto <ppannuto@codeaurora.org>
> ---
> =A0drivers/base/platform.c =A0 =A0 =A0 =A0 | =A0184 +++++++++++++++++=
+++------------------
> =A0include/linux/platform_device.h | =A0 87 ++++++++++++++++++
> =A02 files changed, 184 insertions(+), 87 deletions(-)
>
> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index b69ccb4..e75640f 100644
> --- a/drivers/base/platform.c
> +++ b/drivers/base/platform.c
> @@ -224,25 +224,10 @@ int platform_device_add_data(struct platform_de=
vice *pdev, const void *data,
> =A0}
> =A0EXPORT_SYMBOL_GPL(platform_device_add_data);
>
> -/**
> - * platform_device_add - add a platform device to device hierarchy
> - * @pdev: platform device we're adding
> - *
> - * This is part 2 of platform_device_register(), though may be calle=
d
> - * separately _iff_ pdev was allocated by platform_device_alloc().
> - */
> -int platform_device_add(struct platform_device *pdev)
> +int __platform_device_add(struct platform_device *pdev)
> =A0{
> =A0 =A0 =A0 =A0int i, ret =3D 0;
>
> - =A0 =A0 =A0 if (!pdev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> -
> - =A0 =A0 =A0 if (!pdev->dev.parent)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->dev.parent =3D &platform_bus;
> -
> - =A0 =A0 =A0 pdev->dev.bus =3D &platform_bus_type;
> -
> =A0 =A0 =A0 =A0if (pdev->id !=3D -1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_set_name(&pdev->dev, "%s.%d", pdev=
->name, =A0pdev->id);
> =A0 =A0 =A0 =A0else
> @@ -289,6 +274,27 @@ int platform_device_add(struct platform_device *=
pdev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(__platform_device_add);
> +
> +/**
> + * platform_device_add - add a platform device to device hierarchy
> + * @pdev: platform device we're adding
> + *
> + * This is part 2 of platform_device_register(), though may be calle=
d
> + * separately _iff_ pdev was allocated by platform_device_alloc().
> + */
> +int platform_device_add(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 if (!pdev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 if (!pdev->dev.parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->dev.parent =3D &platform_bus;
> +
> + =A0 =A0 =A0 pdev->dev.bus =3D &platform_bus_type;
> +
> + =A0 =A0 =A0 return __platform_device_add(pdev);
> +}
> =A0EXPORT_SYMBOL_GPL(platform_device_add);
>
> =A0/**
> @@ -476,13 +482,8 @@ static void platform_drv_shutdown(struct device =
*_dev)
> =A0 =A0 =A0 =A0drv->shutdown(dev);
> =A0}
>
> -/**
> - * platform_driver_register - register a driver for platform-level d=
evices
> - * @drv: platform driver structure
> - */
> -int platform_driver_register(struct platform_driver *drv)
> +int __platform_driver_register(struct platform_driver *drv)
> =A0{
> - =A0 =A0 =A0 drv->driver.bus =3D &platform_bus_type;
> =A0 =A0 =A0 =A0if (drv->probe)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0drv->driver.probe =3D platform_drv_pro=
be;
> =A0 =A0 =A0 =A0if (drv->remove)
> @@ -492,6 +493,18 @@ int platform_driver_register(struct platform_dri=
ver *drv)
>
> =A0 =A0 =A0 =A0return driver_register(&drv->driver);
> =A0}
> +EXPORT_SYMBOL_GPL(__platform_driver_register);
> +
> +/**
> + * platform_driver_register - register a driver for platform-level d=
evices
> + * @drv: platform driver structure
> + */
> +int platform_driver_register(struct platform_driver *drv)
> +{
> + =A0 =A0 =A0 drv->driver.bus =3D &platform_bus_type;
> +
> + =A0 =A0 =A0 return __platform_driver_register(drv);
> +}
> =A0EXPORT_SYMBOL_GPL(platform_driver_register);
>
> =A0/**
> @@ -504,25 +517,9 @@ void platform_driver_unregister(struct platform_=
driver *drv)
> =A0}
> =A0EXPORT_SYMBOL_GPL(platform_driver_unregister);
>
> -/**
> - * platform_driver_probe - register driver for non-hotpluggable devi=
ce
> - * @drv: platform driver structure
> - * @probe: the driver probe routine, probably from an __init section
> - *
> - * Use this instead of platform_driver_register() when you know the =
device
> - * is not hotpluggable and has already been registered, and you want=
 to
> - * remove its run-once probe() infrastructure from memory after the =
driver
> - * has bound to the device.
> - *
> - * One typical use for this would be with drivers for controllers in=
tegrated
> - * into system-on-chip processors, where the controller devices have=
 been
> - * configured as part of board setup.
> - *
> - * Returns zero if the driver registered and bound to a device, else=
 returns
> - * a negative error code and with the driver not registered.
> - */
> -int __init_or_module platform_driver_probe(struct platform_driver *d=
rv,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int (*probe)(struct platform_device *))
> +int __init_or_module __platform_driver_probe(struct platform_driver =
*drv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int (*probe)(struct platform_device *),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int (*bustype_driver_register)(struct p=
latform_driver *))

Personally, unless you already have a use-case for using the
platform_driver_probe() hook on the custom busses, I would just leave
this one unimplemented.  It isn't critical (and I don't like it, but
that's a rant for another email).

> =A0{
> =A0 =A0 =A0 =A0int retval, code;
>
> @@ -531,7 +528,7 @@ int __init_or_module platform_driver_probe(struct=
 platform_driver *drv,
>
> =A0 =A0 =A0 =A0/* temporary section violation during probe() */
> =A0 =A0 =A0 =A0drv->probe =3D probe;
> - =A0 =A0 =A0 retval =3D code =3D platform_driver_register(drv);
> + =A0 =A0 =A0 retval =3D code =3D bustype_driver_register(drv);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Fixup that section violation, being paranoid about =
code scanning
> @@ -550,6 +547,30 @@ int __init_or_module platform_driver_probe(struc=
t platform_driver *drv,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0platform_driver_unregister(drv);
> =A0 =A0 =A0 =A0return retval;
> =A0}
> +EXPORT_SYMBOL_GPL(__platform_driver_probe);
> +
> +/**
> + * platform_driver_probe - register driver for non-hotpluggable devi=
ce
> + * @drv: platform driver structure
> + * @probe: the driver probe routine, probably from an __init section
> + *
> + * Use this instead of platform_driver_register() when you know the =
device
> + * is not hotpluggable and has already been registered, and you want=
 to
> + * remove its run-once probe() infrastructure from memory after the =
driver
> + * has bound to the device.
> + *
> + * One typical use for this would be with drivers for controllers in=
tegrated
> + * into system-on-chip processors, where the controller devices have=
 been
> + * configured as part of board setup.
> + *
> + * Returns zero if the driver registered and bound to a device, else=
 returns
> + * a negative error code and with the driver not registered.
> + */
> +int __init_or_module platform_driver_probe(struct platform_driver *d=
rv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int (*probe)(struct platform_device *))
> +{
> + =A0 =A0 =A0 return __platform_driver_probe(drv, probe, &platform_dr=
iver_register);
> +}
> =A0EXPORT_SYMBOL_GPL(platform_driver_probe);
>
> =A0/**
> @@ -627,12 +648,13 @@ static ssize_t modalias_show(struct device *dev=
, struct device_attribute *a,
> =A0 =A0 =A0 =A0return (len >=3D PAGE_SIZE) ? (PAGE_SIZE - 1) : len;
> =A0}
>
> -static struct device_attribute platform_dev_attrs[] =3D {
> +struct device_attribute platform_dev_attrs[] =3D {
> =A0 =A0 =A0 =A0__ATTR_RO(modalias),
> =A0 =A0 =A0 =A0__ATTR_NULL,
> =A0};
> +EXPORT_SYMBOL_GPL(platform_dev_attrs);
>
> -static int platform_uevent(struct device *dev, struct kobj_uevent_en=
v *env)
> +int platform_uevent(struct device *dev, struct kobj_uevent_env *env)
> =A0{
> =A0 =A0 =A0 =A0struct platform_device =A0*pdev =3D to_platform_device=
(dev);
>
> @@ -640,6 +662,7 @@ static int platform_uevent(struct device *dev, st=
ruct kobj_uevent_env *env)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(pdev->id_entry) ? pdev->id_entry->nam=
e : pdev->name);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_uevent);
>
> =A0static const struct platform_device_id *platform_match_id(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct platform_=
device_id *id,
> @@ -668,7 +691,7 @@ static const struct platform_device_id *platform_=
match_id(
> =A0* and compare it against the name of the driver. Return whether th=
ey match
> =A0* or not.
> =A0*/
> -static int platform_match(struct device *dev, struct device_driver *=
drv)
> +int platform_match(struct device *dev, struct device_driver *drv)
> =A0{
> =A0 =A0 =A0 =A0struct platform_device *pdev =3D to_platform_device(de=
v);
> =A0 =A0 =A0 =A0struct platform_driver *pdrv =3D to_platform_driver(dr=
v);
> @@ -680,10 +703,11 @@ static int platform_match(struct device *dev, s=
truct device_driver *drv)
> =A0 =A0 =A0 =A0/* fall-back to driver name match */
> =A0 =A0 =A0 =A0return (strcmp(pdev->name, drv->name) =3D=3D 0);
> =A0}
> +EXPORT_SYMBOL_GPL(platform_match);
>
> =A0#ifdef CONFIG_PM_SLEEP
>
> -static int platform_legacy_suspend(struct device *dev, pm_message_t =
mesg)
> +int platform_legacy_suspend(struct device *dev, pm_message_t mesg)
> =A0{
> =A0 =A0 =A0 =A0struct platform_driver *pdrv =3D to_platform_driver(de=
v->driver);
> =A0 =A0 =A0 =A0struct platform_device *pdev =3D to_platform_device(de=
v);
> @@ -695,7 +719,7 @@ static int platform_legacy_suspend(struct device =
*dev, pm_message_t mesg)
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static int platform_legacy_resume(struct device *dev)
> +int platform_legacy_resume(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct platform_driver *pdrv =3D to_platform_driver(de=
v->driver);
> =A0 =A0 =A0 =A0struct platform_device *pdev =3D to_platform_device(de=
v);
> @@ -707,7 +731,7 @@ static int platform_legacy_resume(struct device *=
dev)
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static int platform_pm_prepare(struct device *dev)
> +int platform_pm_prepare(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -717,19 +741,16 @@ static int platform_pm_prepare(struct device *d=
ev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_prepare);
>
> -static void platform_pm_complete(struct device *dev)
> +void platform_pm_complete(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
>
> =A0 =A0 =A0 =A0if (drv && drv->pm && drv->pm->complete)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0drv->pm->complete(dev);
> =A0}
> -
> -#else /* !CONFIG_PM_SLEEP */
> -
> -#define platform_pm_prepare =A0 =A0 =A0 =A0 =A0 =A0NULL
> -#define platform_pm_complete =A0 =A0 =A0 =A0 =A0 NULL
> +EXPORT_SYMBOL_GPL(platform_pm_complete);
>
> =A0#endif /* !CONFIG_PM_SLEEP */
>
> @@ -752,6 +773,7 @@ int __weak platform_pm_suspend(struct device *dev=
)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_suspend);
>
> =A0int __weak platform_pm_suspend_noirq(struct device *dev)
> =A0{
> @@ -768,6 +790,7 @@ int __weak platform_pm_suspend_noirq(struct devic=
e *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_suspend_noirq);
>
> =A0int __weak platform_pm_resume(struct device *dev)
> =A0{
> @@ -786,6 +809,7 @@ int __weak platform_pm_resume(struct device *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_resume);
>
> =A0int __weak platform_pm_resume_noirq(struct device *dev)
> =A0{
> @@ -802,19 +826,13 @@ int __weak platform_pm_resume_noirq(struct devi=
ce *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> -
> -#else /* !CONFIG_SUSPEND */
> -
> -#define platform_pm_suspend =A0 =A0 =A0 =A0 =A0 =A0NULL
> -#define platform_pm_resume =A0 =A0 =A0 =A0 =A0 =A0 NULL
> -#define platform_pm_suspend_noirq =A0 =A0 =A0NULL
> -#define platform_pm_resume_noirq =A0 =A0 =A0 NULL
> +EXPORT_SYMBOL_GPL(platform_pm_resume_noirq);
>
> =A0#endif /* !CONFIG_SUSPEND */
>
> =A0#ifdef CONFIG_HIBERNATION
>
> -static int platform_pm_freeze(struct device *dev)
> +int platform_pm_freeze(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -831,8 +849,9 @@ static int platform_pm_freeze(struct device *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_freeze);
>
> -static int platform_pm_freeze_noirq(struct device *dev)
> +int platform_pm_freeze_noirq(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -847,8 +866,9 @@ static int platform_pm_freeze_noirq(struct device=
 *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_freeze_noirq);
>
> -static int platform_pm_thaw(struct device *dev)
> +int platform_pm_thaw(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -865,8 +885,9 @@ static int platform_pm_thaw(struct device *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_thaw);
>
> -static int platform_pm_thaw_noirq(struct device *dev)
> +int platform_pm_thaw_noirq(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -881,8 +902,9 @@ static int platform_pm_thaw_noirq(struct device *=
dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_thaw_noirq);
>
> -static int platform_pm_poweroff(struct device *dev)
> +int platform_pm_poweroff(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -899,8 +921,9 @@ static int platform_pm_poweroff(struct device *de=
v)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_poweroff);
>
> -static int platform_pm_poweroff_noirq(struct device *dev)
> +int platform_pm_poweroff_noirq(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -915,8 +938,9 @@ static int platform_pm_poweroff_noirq(struct devi=
ce *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_poweroff_noirq);
>
> -static int platform_pm_restore(struct device *dev)
> +int platform_pm_restore(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -933,8 +957,9 @@ static int platform_pm_restore(struct device *dev=
)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> +EXPORT_SYMBOL_GPL(platform_pm_restore);
>
> -static int platform_pm_restore_noirq(struct device *dev)
> +int platform_pm_restore_noirq(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_driver *drv =3D dev->driver;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -949,17 +974,7 @@ static int platform_pm_restore_noirq(struct devi=
ce *dev)
>
> =A0 =A0 =A0 =A0return ret;
> =A0}
> -
> -#else /* !CONFIG_HIBERNATION */
> -
> -#define platform_pm_freeze =A0 =A0 =A0 =A0 =A0 =A0 NULL
> -#define platform_pm_thaw =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL
> -#define platform_pm_poweroff =A0 =A0 =A0 =A0 =A0 NULL
> -#define platform_pm_restore =A0 =A0 =A0 =A0 =A0 =A0NULL
> -#define platform_pm_freeze_noirq =A0 =A0 =A0 NULL
> -#define platform_pm_thaw_noirq =A0 =A0 =A0 =A0 NULL
> -#define platform_pm_poweroff_noirq =A0 =A0 NULL
> -#define platform_pm_restore_noirq =A0 =A0 =A0NULL
> +EXPORT_SYMBOL_GPL(platform_pm_restore_noirq);
>
> =A0#endif /* !CONFIG_HIBERNATION */
>
> @@ -980,15 +995,9 @@ int __weak platform_pm_runtime_idle(struct devic=
e *dev)
> =A0 =A0 =A0 =A0return pm_generic_runtime_idle(dev);
> =A0};
>
> -#else /* !CONFIG_PM_RUNTIME */
> -
> -#define platform_pm_runtime_suspend NULL
> -#define platform_pm_runtime_resume NULL
> -#define platform_pm_runtime_idle NULL
> -
> =A0#endif /* !CONFIG_PM_RUNTIME */
>
> -static const struct dev_pm_ops platform_dev_pm_ops =3D {
> +const struct dev_pm_ops platform_dev_pm_ops =3D {
> =A0 =A0 =A0 =A0.prepare =3D platform_pm_prepare,
> =A0 =A0 =A0 =A0.complete =3D platform_pm_complete,
> =A0 =A0 =A0 =A0.suspend =3D platform_pm_suspend,
> @@ -1007,6 +1016,7 @@ static const struct dev_pm_ops platform_dev_pm_=
ops =3D {
> =A0 =A0 =A0 =A0.runtime_resume =3D platform_pm_runtime_resume,
> =A0 =A0 =A0 =A0.runtime_idle =3D platform_pm_runtime_idle,
> =A0};
> +EXPORT_SYMBOL_GPL(platform_dev_pm_ops);
>
> =A0struct bus_type platform_bus_type =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D "platform",
> diff --git a/include/linux/platform_device.h b/include/linux/platform=
_device.h
> index 5417944..6d7d399 100644
> --- a/include/linux/platform_device.h
> +++ b/include/linux/platform_device.h
> @@ -53,6 +53,7 @@ extern int platform_device_add_resources(struct pla=
tform_device *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 const struct resource *res,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 unsigned int num);
> =A0extern int platform_device_add_data(struct platform_device *pdev, =
const void *data, size_t size);
> +extern int __platform_device_add(struct platform_device *pdev);
> =A0extern int platform_device_add(struct platform_device *pdev);
> =A0extern void platform_device_del(struct platform_device *pdev);
> =A0extern void platform_device_put(struct platform_device *pdev);
> @@ -67,12 +68,16 @@ struct platform_driver {
> =A0 =A0 =A0 =A0const struct platform_device_id *id_table;
> =A0};
>
> +extern int __platform_driver_register(struct platform_driver *);
> =A0extern int platform_driver_register(struct platform_driver *);
> =A0extern void platform_driver_unregister(struct platform_driver *);
>
> =A0/* non-hotpluggable platform devices may use this so that probe() =
and
> =A0* its support may live in __init sections, conserving runtime memo=
ry.
> =A0*/
> +extern int __platform_driver_probe(struct platform_driver *driver,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int (*probe)(struct platform_device *),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int (*bustype_driver_register)(struct p=
latform_driver *));
> =A0extern int platform_driver_probe(struct platform_driver *driver,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int (*probe)(struct platform_device *)=
);
>
> @@ -84,6 +89,88 @@ extern struct platform_device *platform_create_bun=
dle(struct platform_driver *dr
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct resource *res, unsigned int n_res,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0const void *data, size_t size);
>
> +extern struct device_attribute platform_dev_attrs[];
> +extern int platform_uevent(struct device *dev, struct kobj_uevent_en=
v *env);
> +extern int platform_match(struct device *dev, struct device_driver *=
drv);
> +
> +#ifdef CONFIG_PM_SLEEP
> +extern int platform_pm_prepare(struct device *dev);
> +extern void platform_pm_complete(struct device *dev);
> +#else =A0/* !CONFIG_PM_SLEEP */
> +#define platform_pm_prepare =A0 =A0 =A0 =A0 =A0 =A0NULL
> +#define platform_pm_complete =A0 =A0 =A0 =A0 =A0 NULL
> +#endif /* !CONFIG_PM_SLEEP */
> +
> +#ifdef CONFIG_SUSPEND
> +extern int __weak platform_pm_suspend(struct device *dev);
> +extern int __weak platform_pm_suspend_noirq(struct device *dev);
> +extern int __weak platform_pm_resume(struct device *dev);
> +extern int __weak platform_pm_resume_noirq(struct device *dev);
> +#else =A0/* !CONFIG_SUSPEND */
> +#define platform_pm_suspend =A0 =A0 =A0 =A0 =A0 =A0NULL
> +#define platform_pm_resume =A0 =A0 =A0 =A0 =A0 =A0 NULL
> +#define platform_pm_suspend_noirq =A0 =A0 =A0NULL
> +#define platform_pm_resume_noirq =A0 =A0 =A0 NULL
> +#endif /* !CONFIG_SUSPEND */
> +
> +#ifdef CONFIG_HIBERNATION
> +extern int platform_pm_freeze(struct device *dev);
> +extern int platform_pm_freeze_noirq(struct device *dev);
> +extern int platform_pm_thaw(struct device *dev);
> +extern int platform_pm_thaw_noirq(struct device *dev);
> +extern int platform_pm_poweroff(struct device *dev);
> +extern int platform_pm_poweroff_noirq(struct device *dev);
> +extern int platform_pm_restore(struct device *dev);
> +extern int platform_pm_restore_noirq(struct device *dev);
> +#else =A0/* !CONFIG_HIBERNATION */
> +#define platform_pm_freeze =A0 =A0 =A0 =A0 =A0 =A0 NULL
> +#define platform_pm_thaw =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL
> +#define platform_pm_poweroff =A0 =A0 =A0 =A0 =A0 NULL
> +#define platform_pm_restore =A0 =A0 =A0 =A0 =A0 =A0NULL
> +#define platform_pm_freeze_noirq =A0 =A0 =A0 NULL
> +#define platform_pm_thaw_noirq =A0 =A0 =A0 =A0 NULL
> +#define platform_pm_poweroff_noirq =A0 =A0 NULL
> +#define platform_pm_restore_noirq =A0 =A0 =A0NULL
> +#endif /* !CONFIG_HIBERNATION */
> +
> +#ifdef CONFIG_PM_RUNTIME
> +extern int __weak platform_pm_runtime_suspend(struct device *dev);
> +extern int __weak platform_pm_runtime_resume(struct device *dev);
> +extern int __weak platform_pm_runtime_idle(struct device *dev);
> +#else =A0/* !CONFIG_PM_RUNTIME */
> +#define platform_pm_runtime_suspend NULL
> +#define platform_pm_runtime_resume NULL
> +#define platform_pm_runtime_idle NULL
> +#endif /* !CONFIG_PM_RUNTIME */
> +
> +extern const struct dev_pm_ops platform_dev_pm_ops;
> +
> +#define PLATFORM_BUS_TEMPLATE \
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "XXX_OVERRIDEME_XXX", \
> + =A0 =A0 =A0 .dev_attrs =A0 =A0 =A0=3D platform_dev_attrs, =A0 \
> + =A0 =A0 =A0 .match =A0 =A0 =A0 =A0 =A0=3D platform_match, =A0 =A0 =A0=
 \
> + =A0 =A0 =A0 .uevent =A0 =A0 =A0 =A0 =3D platform_uevent, =A0 =A0 =A0=
\
> + =A0 =A0 =A0 .pm =A0 =A0 =A0 =A0 =A0 =A0 =3D &platform_dev_pm_ops
> +
> +#define PLATFORM_PM_OPS_TEMPLATE \
> + =A0 =A0 =A0 .prepare =3D platform_pm_prepare, =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 \
> + =A0 =A0 =A0 .complete =3D platform_pm_complete, =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 \
> + =A0 =A0 =A0 .suspend =3D platform_pm_suspend, =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 \
> + =A0 =A0 =A0 .resume =3D platform_pm_resume, =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 \
> + =A0 =A0 =A0 .freeze =3D platform_pm_freeze, =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 \
> + =A0 =A0 =A0 .thaw =3D platform_pm_thaw, =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 .poweroff =3D platform_pm_poweroff, =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 \
> + =A0 =A0 =A0 .restore =3D platform_pm_restore, =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 \
> + =A0 =A0 =A0 .suspend_noirq =3D platform_pm_suspend_noirq, =A0 =A0 \
> + =A0 =A0 =A0 .resume_noirq =3D platform_pm_resume_noirq, =A0 =A0 =A0=
 \
> + =A0 =A0 =A0 .freeze_noirq =3D platform_pm_freeze_noirq, =A0 =A0 =A0=
 \
> + =A0 =A0 =A0 .thaw_noirq =3D platform_pm_thaw_noirq, =A0 =A0 =A0 =A0=
 =A0 \
> + =A0 =A0 =A0 .poweroff_noirq =3D platform_pm_poweroff_noirq, =A0 \
> + =A0 =A0 =A0 .restore_noirq =3D platform_pm_restore_noirq, =A0 =A0 \
> + =A0 =A0 =A0 .runtime_suspend =3D platform_pm_runtime_suspend, \
> + =A0 =A0 =A0 .runtime_resume =3D platform_pm_runtime_resume, =A0 \
> + =A0 =A0 =A0 .runtime_idle =3D platform_pm_runtime_idle
> +
> =A0/* early platform driver interface */
> =A0struct early_platform_driver {
> =A0 =A0 =A0 =A0const char *class_str;
> --
> 1.7.2.1
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
