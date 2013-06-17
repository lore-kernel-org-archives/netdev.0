From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Mon, 17 Jun 2013 22:05:19 +0200
Message-ID: <51BF6BFF.7050705@suse.cz>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090100040802040701030900"
Cc: jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	linux-usb@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	Michal Marek <mmarek@suse.cz>, tomi.valkeinen@ti.com
To: Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:46870 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab3FQUFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 16:05:24 -0400
In-Reply-To: <519D8876.9050405@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090100040802040701030900
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 05/23/2013 05:09 AM, Jeff Mahoney wrote:
> On 5/22/13 10:23 PM, Greg Kroah-Hartman wrote:
>> On Wed, May 22, 2013 at 11:18:46AM +0200, Jiri Slaby wrote:
>>> Some drivers can be built on more platforms than they run on. This
>>> causes users and distributors packaging burden when they have to
>>> manually deselect some drivers from their allmodconfigs. Or sometimes
>>> it is even impossible to disable the drivers without patching the
>>> kernel.
>>>
>>> Introduce a new config option COMPILE_TEST and make all those drivers
>>> to depend on the platform they run on, or on the COMPILE_TEST option.
>>> Now, when users/distributors choose COMPILE_TEST=n they will not have
>>> the drivers in their allmodconfig setups, but developers still can
>>> compile-test them with COMPILE_TEST=y.
>>
>> I understand the urge, and it's getting hard for distros to handle these
>> drivers that just don't work on other architectures, but it's really
>> valuable to ensure that they build properly, for those of us that don't
>> have many/any cross compilers set up.

But this is exactly what COMPILE_TEST will give us when set to "y", or
am I missing something?

>>> Now the drivers where we use this new option:
>>> * PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
>>>   processors so it should depend on x86.
>>> * FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
>>> * USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
>>>   systems -- which do not actually support the hardware via that
>>>   method.
>>
>> This seems ripe to start to get really messy, really quickly.  Shouldn't
>> "default configs" handle if this "should" be enabled for a platform or
>> not, and let the rest of us just build them with no problems?
> 
> If every time a new Kconfig option is added, corresponding default
> config updates come with it, sure. I just don't see that happening,
> especially when it can be done much more clearly in the Kconfig while
> the developer is writing the driver.
> 
>> What problems is this causing you?  Are you running out of space in
>> kernel packages with drivers that will never be actually used?
> 
> Wasted build resources. Wasted disk space on /every/ system the kernel
> package is installed on. We're all trying to pare down the kernel
> packages to eliminate wasted space and doing it manually means a bunch
> of research, sometimes with incorrect assumptions about the results,
> needs to be done by someone not usually associated with that code. That
> research gets repeated by people maintaining kernel packages for pretty
> much every distro.

I second all the above.

>>> +config COMPILE_TEST
>>> +	bool "Compile also drivers which will not load" if EXPERT
>>
>> EXPERT is getting to be the "let's hide it here" option, isn't it...
>>
>> I don't know, if no one else strongly objects, I can be convinced that
>> this is needed, but so far, I don't see why it really is, or what this
>> is going to help with.
> 
> I'm not convinced adding a || COMPILE_TEST option to every driver that
> may be arch specific is the best way to go either. Perhaps adding a new
> Kconfig verb called "archdepends on" or something that will evaluate as
> true if COMPILE_TEST is enabled but will evaluate the conditional if
> not. *waves hands*

Sam Ravnborg (the kconfig ex-maintainer) once wrote that he doesn't want
to extend the kconfig language for this purpose (which I support). That
a config option is fine and sufficient in this case [1]. Except he
called the config option "SHOW_ALL_DRIVERS". Adding the current
maintainer to CCs ;).

[1] http://comments.gmane.org/gmane.linux.kbuild.devel/9829

The last point I inclined to the Greg's argument to remove the EXPERT
dependency.

So currently I have what is attached... Comments?

thanks,
-- 
js
suse labs

--------------090100040802040701030900
Content-Type: text/x-patch;
 name="0001-build-some-drivers-only-when-compile-testing.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-build-some-drivers-only-when-compile-testing.patch"

>From e818e90b4f901c8d949d08bd05735203c5e88530 Mon Sep 17 00:00:00 2001
From: Jiri Slaby <jslaby@suse.cz>
Date: Wed, 22 May 2013 10:56:24 +0200
Subject: [PATCH v2] build some drivers only when compile-testing

Some drivers can be built on more platforms than they run on. This is
a burden for users and distributors who package a kernel. They have to
manually deselect some (for them useless) drivers when updating their
configs via oldconfig. And yet, sometimes it is even impossible to
disable the drivers without patching the kernel.

Introduce a new config option COMPILE_TEST and make all those drivers
to depend on the platform they run on, or on the COMPILE_TEST option.
Now, when users/distributors choose COMPILE_TEST=n they will not have
the drivers in their allmodconfig setups, but developers still can
compile-test them with COMPILE_TEST=y.

Now the drivers where we use this new option:
* PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
  processors so it should depend on x86.
* FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
* USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
  systems -- which do not actually support the hardware via that
  method.
* INTEL_MID_PTI: It is specific to the Penwell type of Intel Atom
  device.

[v2]
* remove EXPERT dependency

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Mahoney <jeffm@suse.com>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-usb@vger.kernel.org
Cc: Florian Tobias Schandinat <FlorianSchandinat@gmx.de>
Cc: linux-geode@lists.infradead.org
Cc: linux-fbdev@vger.kernel.org
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: netdev@vger.kernel.org
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>
---
 drivers/misc/Kconfig          |  2 +-
 drivers/ptp/Kconfig           |  1 +
 drivers/usb/chipidea/Kconfig  |  6 ++++++
 drivers/usb/chipidea/Makefile |  4 +---
 drivers/video/geode/Kconfig   |  2 +-
 init/Kconfig                  | 14 ++++++++++++++
 6 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 80889d5..8dacd4c 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -135,7 +135,7 @@ config PHANTOM
 
 config INTEL_MID_PTI
 	tristate "Parallel Trace Interface for MIPI P1149.7 cJTAG standard"
-	depends on PCI && TTY
+	depends on PCI && TTY && (X86_INTEL_MID || COMPILE_TEST)
 	default n
 	help
 	  The PTI (Parallel Trace Interface) driver directs
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 1ea6f1d..5be73ba 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -72,6 +72,7 @@ config DP83640_PHY
 
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
+	depends on X86 || COMPILE_TEST
 	select PTP_1588_CLOCK
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
diff --git a/drivers/usb/chipidea/Kconfig b/drivers/usb/chipidea/Kconfig
index b2df442..3491d86 100644
--- a/drivers/usb/chipidea/Kconfig
+++ b/drivers/usb/chipidea/Kconfig
@@ -31,4 +31,10 @@ config USB_CHIPIDEA_DEBUG
 	help
 	  Say Y here to enable debugging output of the ChipIdea driver.
 
+config USB_CHIPIDEA_IMX
+	bool "ChipIdea IMX support"
+	depends on OF_DEVICE && (ARM || COMPILE_TEST)
+	help
+	  This option enables ChipIdea support on IMX.
+
 endif
diff --git a/drivers/usb/chipidea/Makefile b/drivers/usb/chipidea/Makefile
index 4113feb..76d66ff 100644
--- a/drivers/usb/chipidea/Makefile
+++ b/drivers/usb/chipidea/Makefile
@@ -16,6 +16,4 @@ ifneq ($(CONFIG_PCI),)
 	obj-$(CONFIG_USB_CHIPIDEA)	+= ci13xxx_pci.o
 endif
 
-ifneq ($(CONFIG_OF),)
-	obj-$(CONFIG_USB_CHIPIDEA)	+= ci13xxx_imx.o usbmisc_imx.o
-endif
+obj-$(CONFIG_USB_CHIPIDEA_IMX)	+= ci13xxx_imx.o usbmisc_imx.o
diff --git a/drivers/video/geode/Kconfig b/drivers/video/geode/Kconfig
index 21e351a..1e85552 100644
--- a/drivers/video/geode/Kconfig
+++ b/drivers/video/geode/Kconfig
@@ -3,7 +3,7 @@
 #
 config FB_GEODE
 	bool "AMD Geode family framebuffer support"
-	depends on FB && PCI && X86
+	depends on FB && PCI && (X86_32 || (X86 && COMPILE_TEST))
 	---help---
 	  Say 'Y' here to allow you to select framebuffer drivers for
 	  the AMD Geode family of processors.
diff --git a/init/Kconfig b/init/Kconfig
index fd0e436..e1854b2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -53,6 +53,20 @@ config CROSS_COMPILE
 	  need to set this unless you want the configured kernel build
 	  directory to select the cross-compiler automatically.
 
+config COMPILE_TEST
+	bool "Compile also drivers which will not load"
+	default n
+	help
+	  Some drivers can be compiled on a different platform than they are
+	  intended to be run on. Despite they cannot be loaded there (or even
+	  when they load they cannot be used due to missing HW support),
+	  developers still, opposing to distributors, might want to build such
+	  drivers to compile-test them.
+
+	  If you are a developer and want to build everything available, say Y
+	  here. If you are a user/distributor, say N here to exclude useless
+	  drivers to be distributed.
+
 config LOCALVERSION
 	string "Local version - append to kernel release"
 	help
-- 
1.8.3


--------------090100040802040701030900--
