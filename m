From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] build some drivers only when compile-testing
Date: Wed, 22 May 2013 11:18:46 +0200
Message-ID: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Mahoney <jeffm@suse.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some drivers can be built on more platforms than they run on. This
causes users and distributors packaging burden when they have to
manually deselect some drivers from their allmodconfigs. Or sometimes
it is even impossible to disable the drivers without patching the
kernel.

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
 drivers/ptp/Kconfig           |  1 +
 drivers/usb/chipidea/Kconfig  |  6 ++++++
 drivers/usb/chipidea/Makefile |  4 +---
 drivers/video/geode/Kconfig   |  2 +-
 init/Kconfig                  | 14 ++++++++++++++
 5 files changed, 23 insertions(+), 4 deletions(-)

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
index 4ab83e9..76d66ff 100644
--- a/drivers/usb/chipidea/Makefile
+++ b/drivers/usb/chipidea/Makefile
@@ -16,6 +16,4 @@ ifneq ($(CONFIG_PCI),)
 	obj-$(CONFIG_USB_CHIPIDEA)	+= ci13xxx_pci.o
 endif
 
-ifneq ($(CONFIG_OF_DEVICE),)
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
index 7fb26a6..1233309 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -53,6 +53,20 @@ config CROSS_COMPILE
 	  need to set this unless you want the configured kernel build
 	  directory to select the cross-compiler automatically.
 
+config COMPILE_TEST
+	bool "Compile also drivers which will not load" if EXPERT
+	default n
+	help
+	  Some drivers can be compiled on a different platform than they are
+	  intended to be run on. Despite they cannot be loaded there (or even
+	  when they load they cannot be used due to missing HW support),
+	  developers still, opposing to distributors, might want to build such
+	  drivers to compile-test them.
+
+	  If you are a developer and want to build everything possible, say Y
+	  here. If you are a user/distributor, say N here to exclude useless
+	  drivers to be distributed.
+
 config LOCALVERSION
 	string "Local version - append to kernel release"
 	help
-- 
1.8.2.3
