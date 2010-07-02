From: kaber@trash.net
Subject: [PATCH 6/9] netfilter: complete the deprecation of CONFIG_NF_CT_ACCT
Date: Fri,  2 Jul 2010 11:52:19 +0200
Message-ID: <1278064342-19059-7-git-send-email-kaber@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278064342-19059-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Gardner <tim.gardner@canonical.com>

CONFIG_NF_CT_ACCT has been deprecated for awhile and
was originally scheduled for removal by 2.6.29.

Removing support for this config option also stops
this deprecation warning message in the kernel log.

[   61.669627] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   61.669850] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
[   61.669852] nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
[   61.669853] sysctl net.netfilter.nf_conntrack_acct=1 to enable it.

Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
[Patrick: changed default value to 0]
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 Documentation/feature-removal-schedule.txt |    9 ---------
 Documentation/kernel-parameters.txt        |    3 +--
 net/netfilter/Kconfig                      |   22 ----------------------
 net/netfilter/nf_conntrack_acct.c          |   14 +-------------
 4 files changed, 2 insertions(+), 46 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 672be01..92f021a 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -303,15 +303,6 @@ Who:	Johannes Berg <johannes@sipsolutions.net>
 
 ---------------------------
 
-What: CONFIG_NF_CT_ACCT
-When: 2.6.29
-Why:  Accounting can now be enabled/disabled without kernel recompilation.
-      Currently used only to set a default value for a feature that is also
-      controlled by a kernel/module/sysfs/sysctl parameter.
-Who:  Krzysztof Piotr Oledzki <ole@ans.pl>
-
----------------------------
-
 What:	sysfs ui for changing p4-clockmod parameters
 When:	September 2009
 Why:	See commits 129f8ae9b1b5be94517da76009ea956e89104ce8 and
diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 1808f11..cee6251 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1597,8 +1597,7 @@ and is between 256 and 4096 characters. It is defined in the file
 			[NETFILTER] Enable connection tracking flow accounting
 			0 to disable accounting
 			1 to enable accounting
-			Default value depends on CONFIG_NF_CT_ACCT that is
-			going to be removed in 2.6.29.
+			Default value is 0.
 
 	nfsaddrs=	[NFS]
 			See Documentation/filesystems/nfs/nfsroot.txt.
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 21be535..aa2f106 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -40,27 +40,6 @@ config NF_CONNTRACK
 
 if NF_CONNTRACK
 
-config NF_CT_ACCT
-	bool "Connection tracking flow accounting"
-	depends on NETFILTER_ADVANCED
-	help
-	  If this option is enabled, the connection tracking code will
-	  keep per-flow packet and byte counters.
-
-	  Those counters can be used for flow-based accounting or the
-	  `connbytes' match.
-
-	  Please note that currently this option only sets a default state.
-	  You may change it at boot time with nf_conntrack.acct=0/1 kernel
-	  parameter or by loading the nf_conntrack module with acct=0/1.
-
-	  You may also disable/enable it on a running system with:
-	   sysctl net.netfilter.nf_conntrack_acct=0/1
-
-	  This option will be removed in 2.6.29.
-
-	  If unsure, say `N'.
-
 config NF_CONNTRACK_MARK
 	bool  'Connection mark tracking support'
 	depends on NETFILTER_ADVANCED
@@ -630,7 +609,6 @@ config NETFILTER_XT_MATCH_CONNBYTES
 	tristate  '"connbytes" per-connection counter match support'
 	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
-	select NF_CT_ACCT
 	help
 	  This option adds a `connbytes' match, which allows you to match the
 	  number of bytes and/or packets for each direction within a connection.
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index ab81b38..5178c69 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -17,13 +17,7 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 
-#ifdef CONFIG_NF_CT_ACCT
-#define NF_CT_ACCT_DEFAULT 1
-#else
-#define NF_CT_ACCT_DEFAULT 0
-#endif
-
-static int nf_ct_acct __read_mostly = NF_CT_ACCT_DEFAULT;
+static int nf_ct_acct __read_mostly;
 
 module_param_named(acct, nf_ct_acct, bool, 0644);
 MODULE_PARM_DESC(acct, "Enable connection tracking flow accounting.");
@@ -114,12 +108,6 @@ int nf_conntrack_acct_init(struct net *net)
 	net->ct.sysctl_acct = nf_ct_acct;
 
 	if (net_eq(net, &init_net)) {
-#ifdef CONFIG_NF_CT_ACCT
-	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use\n");
-		printk(KERN_WARNING "nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or\n");
-		printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
-#endif
-
 		ret = nf_ct_extend_register(&acct_extend);
 		if (ret < 0) {
 			printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
-- 
1.7.0.4

