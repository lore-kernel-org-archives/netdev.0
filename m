From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Fri, 13 Aug 2010 16:05:28 -0600
Message-ID: <AANLkTi=GduvsmkXpxsVoN7k3gPDjjRgqe0E_Z2YeEVS5@mail.gmail.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org> <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 10, 2010 at 5:49 PM, Patrick Pannuto
<ppannuto@codeaurora.org> wrote:
> (lkml.org seems to have lost August 3rd...)
> RFC: http://lkml.indiana.edu/hypermail//linux/kernel/1008.0/01342.htm=
l
> =A0v1: http://lkml.indiana.edu/hypermail//linux/kernel/1008.0/01942.h=
tml
>
> Based on the idea and code originally proposed by Kevin Hilman:
> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html

Hi Patrick,

Before acking this as something that should be merged, I'd like to see
some real device drivers converted to use this interface so I can
better judge whether or not it is a good idea.  More comments below.

> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index b69ccb4..933e0c1 100644
> --- a/drivers/base/platform.c
> +++ b/drivers/base/platform.c
> @@ -238,8 +238,12 @@ int platform_device_add(struct platform_device *=
pdev)
> =A0 =A0 =A0 =A0if (!pdev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> - =A0 =A0 =A0 if (!pdev->dev.parent)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->dev.parent =3D &platform_bus;
> + =A0 =A0 =A0 if (!pdev->dev.bus) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->dev.bus =3D &platform_bus_type;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pdev->dev.parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->dev.parent =3D &p=
latform_bus;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0pdev->dev.bus =3D &platform_bus_type;
>

=46or safety, I think you'd want to have a separate add function for
each new platform bus type, and change the name of this function to
explicitly pass the bus type:

int __platform_device_add(struct platform_device *pdev)
{
	if (!pdev->dev.bus)
		return -EINVAL;
	[... existing code ...]
}

int platform_device_add(struct platform_device *pdev)
{
 =A0 =A0 =A0 if (!pdev->dev.parent)
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdev->dev.parent =3D &platform_bus;
=A0 =A0 =A0 =A0pdev->dev.bus =3D &platform_bus_type;
       __platform_device_add(pdev);
}

And then for each bus type (in this example, I'll call it
foo_bus_type, and assume foo_device wraps platform_device):

int foo_device_add(struct foo_device *foo)
{
	foo->pdev.dev.bus =3D &foo_bus_type;
	__platform_device_add(&foo->pdev);
}

That will allow the new bus_type code to keep foo_bus_type as an
unexported static and will provide a bit more type safety.  For
example, it avoids accidentally registering a plain (unwrapped)
platform device on the foo_bus_type.

> @@ -482,7 +486,8 @@ static void platform_drv_shutdown(struct device *=
_dev)
> =A0*/
> =A0int platform_driver_register(struct platform_driver *drv)
> =A0{
> - =A0 =A0 =A0 drv->driver.bus =3D &platform_bus_type;
> + =A0 =A0 =A0 if (!drv->driver.bus)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 drv->driver.bus =3D &platform_bus_type;
> =A0 =A0 =A0 =A0if (drv->probe)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0drv->driver.probe =3D platform_drv_pro=
be;
> =A0 =A0 =A0 =A0if (drv->remove)

Ditto here; better to have a separate foo_driver_register() for each
new bus type.

> @@ -1017,6 +1022,87 @@ struct bus_type platform_bus_type =3D {
> =A0};
> =A0EXPORT_SYMBOL_GPL(platform_bus_type);
>
> +/** pseudo_platform_bus_register - register an "almost platform bus"

Kerneldoc style error.  Should be:

+/**
+ * pseudo_platform_bus_register - register an "almost platform bus"

> + * @bus: partially complete bus type to register
> + *
> + * This init will fill in any ommitted fields in @bus, however, it
> + * also allocates memory and replaces the pm field in @bus, since
> + * pm is const, but some of its pointers may need this one-time
> + * initialziation overwrite.
> + *
> + * @bus's registered this way should be released with
> + * pseudo_platform_bus_unregister
> + */
> +int pseudo_platform_bus_register(struct bus_type *bus)
> +{
> + =A0 =A0 =A0 int error;
> + =A0 =A0 =A0 struct dev_pm_ops* heap_pm;

Nit: heap_pm is an odd name.  Typically Linux local vars are named
according to what they are, not where the memory is allocated from.
How about simply 'ops'

> + =A0 =A0 =A0 heap_pm =3D kmalloc(sizeof (*heap_pm), GFP_KERNEL);
> +
> + =A0 =A0 =A0 if (!heap_pm)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 if (!bus->dev_attrs)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->dev_attrs =3D platform_bus_type.de=
v_attrs;
> + =A0 =A0 =A0 if (!bus->match)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->match =3D platform_bus_type.match;
> + =A0 =A0 =A0 if (!bus->uevent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->uevent =3D platform_bus_type.ueven=
t;
> + =A0 =A0 =A0 if (!bus->pm)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(heap_pm, &platform_bus_type.pm, =
sizeof(*heap_pm));
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->prepare =3D (bus->pm->prepare)=
 ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->prepare : plat=
form_pm_prepare;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->complete =3D (bus->pm->complet=
e) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->complete : pla=
tform_pm_complete;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->suspend =3D (bus->pm->suspend)=
 ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->suspend : plat=
form_pm_suspend;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->resume =3D (bus->pm->resume) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->resume : platf=
orm_pm_resume;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->freeze =3D (bus->pm->freeze) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->freeze : platf=
orm_pm_freeze;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->thaw =3D (bus->pm->thaw) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->thaw : platfor=
m_pm_thaw;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->poweroff =3D (bus->pm->powerof=
f) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->poweroff : pla=
tform_pm_poweroff;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->restore =3D (bus->pm->restore)=
 ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->restore : plat=
form_pm_restore;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->suspend_noirq =3D (bus->pm->su=
spend_noirq) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->suspend_noirq =
: platform_pm_suspend_noirq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->resume_noirq =3D (bus->pm->res=
ume_noirq) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->resume_noirq :=
 platform_pm_resume_noirq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->freeze_noirq =3D (bus->pm->fre=
eze_noirq) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->freeze_noirq :=
 platform_pm_freeze_noirq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->thaw_noirq =3D (bus->pm->thaw_=
noirq) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->thaw_noirq : p=
latform_pm_thaw_noirq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->poweroff_noirq =3D (bus->pm->p=
oweroff_noirq) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->poweroff_noirq=
 : platform_pm_poweroff_noirq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->restore_noirq =3D (bus->pm->re=
store_noirq) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->restore_noirq =
: platform_pm_restore_noirq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->runtime_suspend =3D (bus->pm->=
runtime_suspend) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->runtime_suspen=
d : platform_pm_runtime_suspend;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->runtime_resume =3D (bus->pm->r=
untime_resume) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->runtime_resume=
 : platform_pm_runtime_resume;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->runtime_idle =3D (bus->pm->run=
time_idle) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->runtime_idle :=
 platform_pm_runtime_idle;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 bus->pm =3D heap_pm;
> +
> + =A0 =A0 =A0 error =3D bus_register(bus);
> + =A0 =A0 =A0 if (error)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(bus->pm);
> +
> + =A0 =A0 =A0 return error;
> +}
> +EXPORT_SYMBOL_GPL(pseudo_platform_bus_register);

Ick, this is a nasty list of conditional statements.  :-)  Instead it
could have an unconditional initialize function which sets it up just
like the platform bus without registering.  Then allow the
foo_bus_type initialization code override the ones it cares about, and
then register directly.

> +
> +void pseudo_platform_bus_unregister(struct bus_type *bus)
> +{
> + =A0 =A0 =A0 bus_unregister(bus);
> + =A0 =A0 =A0 kfree(bus->pm);
> +}
> +EXPORT_SYMBOL_GPL(pseudo_platform_bus_unregister);
> +
> =A0int __init platform_bus_init(void)
> =A0{
> =A0 =A0 =A0 =A0int error;
> diff --git a/include/linux/platform_device.h b/include/linux/platform=
_device.h
> index 5417944..5ec827c 100644
> --- a/include/linux/platform_device.h
> +++ b/include/linux/platform_device.h
> @@ -79,6 +79,9 @@ extern int platform_driver_probe(struct platform_dr=
iver *driver,
> =A0#define platform_get_drvdata(_dev) =A0 =A0 dev_get_drvdata(&(_dev)=
->dev)
> =A0#define platform_set_drvdata(_dev,data) =A0 =A0 =A0 =A0dev_set_drv=
data(&(_dev)->dev, (data))
>
> +extern int pseudo_platform_bus_register(struct bus_type *);
> +extern void pseudo_platform_bus_unregister(struct bus_type *);
> +
> =A0extern struct platform_device *platform_create_bundle(struct platf=
orm_driver *driver,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0int (*probe)(struct platform_device *),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct resource *res, unsigned int n_res,
> --
> 1.7.2
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
