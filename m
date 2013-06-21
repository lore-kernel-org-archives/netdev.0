From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH v3] build some drivers only when compile-testing
Date: Fri, 21 Jun 2013 13:11:38 +0200
Message-ID: <1371813098-6649-1-git-send-email-jslaby@suse.cz>
References: <20130619142731.GA7979@kroah.com>
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Mahoney <jeffm@suse.com>,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip4-83-240-18-99.cust.nbox.cz ([83.240.18.99]:43910 "EHLO
	anemoi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423424Ab3FUS5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 14:57:30 -0400
In-Reply-To: <20130619142731.GA7979@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers can be built on more platforms than they run on. This is
a burden for users and distributors who package a kernel. They have to
read Kconfig help texts and manually deselect some (for them useless)
drivers when updating their configs via oldconfig. And yet, sometimes
it is even impossible to disable the drivers without patching the
kernel.

Introduce a new config option COMPILE_TEST and make all those drivers
to depend on the platform they really run on, or on the COMPILE_TEST
option.  Now, when users/distributors choose COMPILE_TEST=n they will
not have the drivers in their oldconfig output, but developers still
can compile-test them with COMPILE_TEST=y.

Now the drivers where we use this new option:
* PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
  processors so it should depend on x86.
* FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
* INTEL_MID_PTI: It is specific to the Penwell type of Intel Atom
  device.

[v2]
* remove EXPERT dependency

[v3]
* do not touch IMX

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Mahoney <jeffm@suse.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Florian Tobias Schandinat <FlorianSchandinat@gmx.de>
Cc: linux-geode@lists.infradead.org
Cc: linux-fbdev@vger.kernel.org
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: netdev@vger.kernel.org
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>
---
 drivers/misc/Kconfig        |  2 +-
 drivers/ptp/Kconfig         |  1 +
 drivers/video/geode/Kconfig |  2 +-
 init/Kconfig                | 14 ++++++++++++++
 4 files changed, 17 insertions(+), 2 deletions(-)

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
index ce540ef..54d3fa5 100644
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
1.8.3.1
