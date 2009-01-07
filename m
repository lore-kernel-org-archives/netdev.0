From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2/3] wimax: fix kconfig interactions with rfkill and input layers
Date: Tue,  6 Jan 2009 23:58:21 -0800
Message-ID: <7c2fff491400cdec32b405fba1f2ead93ca40901.1231314782.git.inaky@linux.intel.com>
References: <cover.1231314782.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:42316 "EHLO gocho"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752919AbZAGH60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 02:58:26 -0500
In-Reply-To: <cover.1231314782.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WiMAX can work without RFKILL, but it was missing a check to make sure
RFKILL is not being made a module with wimax compiled into the
kernel. This caused failed builds in s390, where CONFIG_INPUT is
always off.

When RFKILL is enabled, the code uses the input layer to report
hardware switch changes; thus, if RFKILL is enabled, INPUT has to be
too. It also needs to display some message when INPUT is disabled that
explains why WiMAX is not selectable.

(issues found by Randy Dunlap in the linux-next tree).

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/Kconfig |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/wimax/Kconfig b/net/wimax/Kconfig
index 0bdbb69..18495cd 100644
--- a/net/wimax/Kconfig
+++ b/net/wimax/Kconfig
@@ -1,9 +1,23 @@
 #
 # WiMAX LAN device configuration
 #
+# Note the ugly 'depends on' on WIMAX: that disallows RFKILL to be a
+# module if WIMAX is to be linked in. The WiMAX code is done in such a
+# way that it doesn't require and explicit dependency on RFKILL in
+# case an embedded system wants to rip it out.
+#
+# As well, enablement of the RFKILL code means we need the INPUT layer
+# support to inject events coming from hw rfkill switches. That
+# dependency could be killed if input.h provided appropiate means to
+# work when input is disabled.
+
+comment "WiMAX Wireless Broadband support requires CONFIG_INPUT enabled"
+	depends on INPUT = n && RFKILL != n
 
 menuconfig WIMAX
 	tristate "WiMAX Wireless Broadband support"
+	depends on (y && RFKILL != m) || m
+	depends on (INPUT && RFKILL != n) || RFKILL = n
 	help
 
 	  Select to configure support for devices that provide
-- 
1.5.6.5

