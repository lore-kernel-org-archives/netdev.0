From: James Morris <jmorris@namei.org>
Subject: [PATCH] secmark: disable new controls for SELinux by default
Date: Mon, 22 May 2006 00:45:12 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605220037060.21251@d.namei>
References: <Pine.LNX.4.64.0605180458130.569@d.namei> <20060521165435.7cafbc7c.akpm@osdl.org>
 <Pine.LNX.4.64.0605212237160.20595@d.namei> <Pine.LNX.4.64.0605212308240.20759@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:22474 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751162AbWEVEpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 00:45:16 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605212308240.20759@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should address the issue of people tripping over the new secmark 
controls when upgrading their kernel before the userland components are 
available.

With this patch, the new secmark controls for SElinux are now disabled by 
default, so existing behavior is entirely preserved, and the user is not 
affected at all.

It also provides a config option to enable the secmark controls by default 
(which can always be overridden at boot and runtime).  It is also noted in 
the kconfig help that the user will need updated userspace if enabling 
secmark controls for SELinux and that they'll probably need the SECMARK 
and CONNMARK targets, and conntrack protocol helpers, although such 
decisions are beyond the scope of kernel configuration.

Please review an apply if ok.

Signed-off-by: James Morris <jmorris@namei.org>

---

 security/selinux/Kconfig     |   31 ++++++++++++++++++++++++++++++-
 security/selinux/selinuxfs.c |    9 ++++++++-
 2 files changed, 38 insertions(+), 2 deletions(-)

diff -purN -X dontdiff linux-2.6.17-rc4-mm2.p/security/selinux/Kconfig linux-2.6.17-rc4-mm2.w/security/selinux/Kconfig
--- linux-2.6.17-rc4-mm2.p/security/selinux/Kconfig	2006-05-20 19:46:38.000000000 -0400
+++ linux-2.6.17-rc4-mm2.w/security/selinux/Kconfig	2006-05-22 00:06:23.000000000 -0400
@@ -1,6 +1,7 @@
 config SECURITY_SELINUX
 	bool "NSA SELinux Support"
-	depends on SECURITY_NETWORK && AUDIT && NET && INET && NETWORK_SECMARK
+	depends on SECURITY_NETWORK && AUDIT && NET && INET
+	select NETWORK_SECMARK
 	default n
 	help
 	  This selects NSA Security-Enhanced Linux (SELinux).
@@ -95,3 +96,31 @@ config SECURITY_SELINUX_CHECKREQPROT_VAL
 	  via /selinux/checkreqprot if authorized by policy.
 
 	  If you are unsure how to answer this question, answer 1.
+
+config SECURITY_SELINUX_ENABLE_SECMARK_DEFAULT
+	bool "NSA SELinux enable new secmark network controls by default"
+	depends on SECURITY_SELINUX
+	default n
+	help
+	  This option determines whether the new secmark-based network
+	  controls will be enabled by default.  If not, the old internal
+	  per-packet controls will be enabled by default, preserving
+	  old behavior.
+	  
+	  If you enable the new controls, you will need updated 
+	  SELinux userspace libraries, tools and policy.  Typically,
+	  your distribution will provide these and enable the new controls
+	  in the kernel they also distribute.
+	  
+	  Note that this option can be overriden at boot with the
+	  selinux_compat_net parameter, and after boot via
+	  /selinux/compat_net.  See Documentation/kernel-parameters.txt
+	  for details on this parameter.
+	  
+	  If you enable the new network controls, you will likely
+	  also require the SECMARK and CONNSECMARK targets, as
+	  well as any conntrack helpers for protocols which you 
+	  wish to control.
+
+	  If you are unsure what do do here, select N.
+
diff -purN -X dontdiff linux-2.6.17-rc4-mm2.p/security/selinux/selinuxfs.c linux-2.6.17-rc4-mm2.w/security/selinux/selinuxfs.c
--- linux-2.6.17-rc4-mm2.p/security/selinux/selinuxfs.c	2006-05-20 19:46:38.000000000 -0400
+++ linux-2.6.17-rc4-mm2.w/security/selinux/selinuxfs.c	2006-05-22 00:23:00.000000000 -0400
@@ -37,7 +37,14 @@
 #include "conditional.h"
 
 unsigned int selinux_checkreqprot = CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE;
-int selinux_compat_net;
+
+#ifdef CONFIG_SECURITY_SELINUX_ENABLE_SECMARK_DEFAULT
+#define SELINUX_COMPAT_NET_VALUE 0
+#else
+#define SELINUX_COMPAT_NET_VALUE 1
+#endif
+
+int selinux_compat_net = SELINUX_COMPAT_NET_VALUE;
 
 static int __init checkreqprot_setup(char *str)
 {







