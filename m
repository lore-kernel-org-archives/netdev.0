From: Kevin Hilman <khilman@ti.com>
Subject: Re: [PATCH] net: davinci_emac: Add pre_open, post_stop platform callbacks
Date: Fri, 04 May 2012 14:02:43 -0700
Message-ID: <87397faccs.fsf@ti.com>
References: <20120502234718.GA5432@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
	<20120503160917.GA11310@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA73591@DBDE01.ent.ti.com>
	<20120503184632.GA28089@animalcreek.com>
	<B5906170F1614E41A8A28DE3B8D121433EA7366B@DBDE01.ent.ti.com>
	<1336076542.2998.23.camel@bwh-desktop.uk.solarflarecom.com>
	<87ehr1gdcv.fsf@ti.com>
	<B5906170F1614E41A8A28DE3B8D121433EA81B04@DBDE01.ent.ti.com>
	<87fwbgdnlp.fsf@ti.com> <20120504182938.GB28910@animalcreek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bedia\, Vaibhav" <vaibhav.bedia@ti.com>, nsekhar@ti.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Mark A. Greer" <mgreer@animalcreek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:46219 "EHLO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932711Ab2EDVCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 17:02:42 -0400
Received: by pbbrp8 with SMTP id rp8so4532479pbb.5
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 14:02:40 -0700 (PDT)
In-Reply-To: <20120504182938.GB28910@animalcreek.com> (Mark A. Greer's message
	of "Fri, 4 May 2012 11:29:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Mark A. Greer" <mgreer@animalcreek.com> writes:

> On Fri, May 04, 2012 at 07:31:30AM -0700, Kevin Hilman wrote:

[...]

>> Come to think of it, the right solution here is probably to use runtime
>> PM.  We could then to add some custom hooks for davinci_emac in the
>> device code to use enable_hlt/disable_hlt based on activity.
>
> That was my first thought, actually, but that only works if its
> okay for the driver to call enable_hlt/disable_hlt directly (i.e.,
> have runtime_suspend() call enable_hlt() and runtime_resume() call
> disable_hlt()).  However, I assumed it would _not_ be acceptable for
> the driver to issue those calls directly.  

I agree.

> Its a platform-specific issue that we shouldn't be polluting the
> driver with and there are currently no drivers that call them under
> the drivers directory.

Using runtime PM we don't have to have any platform specific calls in
the driver.  We handle it inside the platform-specific runtime PM
implementation.

IOW, we don't have to call enable_hlt/disable_hlt in the driver.  It can
be completely transparent to the driver.  We can call
enable_hlt/disable_hlt in device specific code.  That way, davinci
platforms with this same IP won't use

To demonstrate, assume the davinci_emac is runtime PM converted and does
a pm_runtime_get_sync() instead of clk_enable().  

For the first call to pm_runtime_get_sync() (when runtime PM count goes
from zero to 1), this will trigger the runtime PM core to runtime PM
enable the device.  Using the driver model's 'PM domain' layer, we've
plugged in our omap_device layer, so the omap_device layer is called for
runtime PM transitions.  (c.f. omap_device_pm_domain in plat-omap/omap_device.c)

Specifically, on a a runtime PM 'get', the PM domain's
->runtime_resume() callback is called.  For an omap_device, that is
_od_runtime_resume().  After enabling the device using
omap_device_enable() the driver's ->runtime_resume callback is called.

So, to summarize, the (simplified) flow looks like this:

pm_runtime_get_sync()
    <PM domain>->runtime_resume()   /* _od_runtime_resume() */
        omap_device_enable()
        pm_generic_runtime_resume()
            <driver>->runtime_resume()

However, you're still wondering where we would sneak in the call to
disable_hlt.  Well, I'm glad you asked....

Looking closer at omap_device_enable(), you'll see that it calls
_omap_device_activate() which uses a function pointer in the
omap_device_pm_latency structure to actually enable the device.

By default, this function is omap_device_enable_hwmods() for all
omap_devices, which in turn uses the hwmod layer to enable the HW
(including clock enable, PM init, etc.)

Now, here's the magic....

On a per-device basis, that activate function can be customized.  In the
custom function, you can add custom calls (e.g. disable_hlt) and then
call the normal omap_device_* functions to continue the default
behavior.

This is getting messy, so let me give a concrete example in the form of
a patch.  Starting from the GPIO driver, which is already runtime PM
converted.  If I wanted to add disable_hlt/enable_hlt whenver the device
is runtime PM enabled/disabled, it would be as simple as the patch below.

So in summary, whever pm_runtime_get_sync() is called (and the usecount
goes from zero to 1), the omap_device 'activate' function is called
(which can call disable_hlt()), and whenever pm_runtime_put() is called
(and the usecount reaches zero), the omap_device 'deactivate' function
is called, and enable_hlt() can be called.

The example I give below customizes the hooks for *all* SoCs, but in the
specific case we're trying to solve, we would only need to add custom
hooks for the devices without wakeups.

Note that all of this presumes that the driver is runtime PM converted
*and* the device itself is built using omap_device_build().  That means
that the device init code in am35xx_emac.c needs to be converted to use
omap_device_build instead of the normal platform_device_* calls.  (note
though that omap_device_build() will also create/register the
platform_device.

Kevin

diff --git a/arch/arm/mach-omap2/gpio.c b/arch/arm/mach-omap2/gpio.c
index a80e093..3acd1eb 100644
--- a/arch/arm/mach-omap2/gpio.c
+++ b/arch/arm/mach-omap2/gpio.c
@@ -26,8 +26,30 @@
 #include <plat/omap_device.h>
 #include <plat/omap-pm.h>
 
+#include <asm/system.h>
+
 #include "powerdomain.h"
 
+static int omap2_gpio_deactivate_func(struct omap_device *od)
+{
+	enable_hlt();
+	return omap_device_idle_hwmods(od);
+}
+
+static int omap2_gpio_activate_func(struct omap_device *od)
+{
+	disable_hlt();
+	return omap_device_enable_hwmods(od);
+}
+
+struct omap_device_pm_latency pm_lats[] __initdata = {
+	{
+		.activate_func = omap2_gpio_activate_func,
+		.deactivate_func = omap2_gpio_deactivate_func,
+		.flags = OMAP_DEVICE_LATENCY_AUTO_ADJUST,
+	},
+};
+
 static int __init omap2_gpio_dev_init(struct omap_hwmod *oh, void *unused)
 {
 	struct platform_device *pdev;
@@ -128,7 +150,8 @@ static int __init omap2_gpio_dev_init(struct omap_hwmod *oh, void *unused)
 	pdata->loses_context = pwrdm_can_ever_lose_context(pwrdm);
 
 	pdev = omap_device_build(name, id - 1, oh, pdata,
-				sizeof(*pdata),	NULL, 0, false);
+				 sizeof(*pdata),	pm_lats,
+				 ARRAY_SIZE(pm_lats), false);
 	kfree(pdata);
 
 	if (IS_ERR(pdev)) {
