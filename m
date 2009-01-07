From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2/4] wimax: fix kconfig interactions with rfkill and input
	layers
Date: Wed,  7 Jan 2009 11:22:20 -0800
Message-ID: <f0f7dc5763046cc336ca087a2525c8b52811ddb4.1231355768.git.inaky@linux.intel.com>
References: <cover.1231355768.git.inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, wimax@linuxwimax.org,
	greg@kroah.com, LKML <linux-kernel@vger.kernel.org>,
	linux-wimax@intel.com, linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1231355768.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

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
