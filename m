From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 13/22] netpoll: Introduce netpoll_target configs
Date: Tue, 14 Dec 2010 13:30:05 -0800
Message-ID: <20101214213004.17022.50295.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As preparation for moving netpoll_targets out of netconsole and making
them available to other clients, introduce new Kconfig options.

CONFIG_NETPOLL_TARGETS

Access to targets APIs.  Only supports parameter based parsing of
targets (via the kernel command line or module paramters).

CONFIG_NETPOLL_TARGETS_DYNAMIC

Extends the support that netpoll_targets provides by allowing for the
dynamic creation of targets in configfs on a per client basis.  This is
boolean flag used to enable dynamic support.  Specifying it without
also selecting NETPOLL_TARGETS is meaningless.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>

---
Changelog:
- v3
  - Fixed to support building netpoll_targets as a module.  It depends
    on netpoll, but netpoll itself doesn't depend on it.
    netpoll_targets will be built as a module if it is needed by either
    NETCONSOLE or NETOOPS are enabled as modules (and neither are built
    in).  CONFIGFS_FS is also only selected to be a module if that is
    possible.
---
 drivers/net/Kconfig      |   15 ++++++++++++---
 drivers/net/netconsole.c |   10 +++++-----
 2 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4f1755b..2ae9818 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3379,14 +3379,15 @@ config NET_FC
 
 config NETCONSOLE
 	tristate "Network console logging support"
+	select NETPOLL_TARGETS
 	---help---
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
 
 config NETCONSOLE_DYNAMIC
 	bool "Dynamic reconfiguration of logging targets"
-	depends on NETCONSOLE && SYSFS
-	select CONFIGFS_FS
+	depends on NETCONSOLE
+	select NETPOLL_TARGETS_DYNAMIC
 	help
 	  This option enables the ability to dynamically reconfigure target
 	  parameters (interface, IP addresses, port numbers, MAC addresses)
@@ -3394,7 +3395,15 @@ config NETCONSOLE_DYNAMIC
 	  See <file:Documentation/networking/netconsole.txt> for details.
 
 config NETPOLL
-	def_bool NETCONSOLE
+	def_bool false
+
+config NETPOLL_TARGETS
+	tristate
+	select NETPOLL
+	select CONFIGFS_FS if NETPOLL_TARGETS_DYNAMIC
+
+config NETPOLL_TARGETS_DYNAMIC
+	bool
 
 config NETPOLL_TRAP
 	bool "Netpoll traffic trapping"
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index fbef723..1970be3 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -69,7 +69,7 @@ struct netpoll_targets {
 	struct list_head list;
 	spinlock_t lock;
 	u16 default_local_port, default_remote_port;
-#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+#ifdef	CONFIG_NETPOLL_TARGETS_DYNAMIC
 	struct configfs_subsystem configfs_subsys;
 #endif
 	struct notifier_block netdev_notifier;
@@ -111,7 +111,7 @@ static DEFINE_NETPOLL_TARGETS(targets);
 struct netpoll_target {
 	struct netpoll_targets *nts;
 	struct list_head	list;
-#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+#ifdef	CONFIG_NETPOLL_TARGETS_DYNAMIC
 	struct config_item	item;
 #endif
 	int			np_state;
@@ -194,7 +194,7 @@ static void free_param_target(struct netpoll_target *nt)
 	kfree(nt);
 }
 
-#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+#ifdef	CONFIG_NETPOLL_TARGETS_DYNAMIC
 
 /*
  * Our subsystem hierarchy is:
@@ -724,7 +724,7 @@ static void netpoll_target_put(struct netpoll_target *nt)
 		config_item_put(&nt->item);
 }
 
-#else	/* !CONFIG_NETCONSOLE_DYNAMIC */
+#else	/* !CONFIG_NETPOLL_TARGETS_DYNAMIC */
 
 static int __init dynamic_netpoll_targets_init(const char *subsys_name,
 					       struct netpoll_targets *nts)
@@ -748,7 +748,7 @@ static void netpoll_target_put(struct netpoll_target *nt)
 {
 }
 
-#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
+#endif	/* CONFIG_NETPOLL_TARGETS_DYNAMIC */
 
 /*
  * Call netpoll_cleanup on this target asynchronously.
