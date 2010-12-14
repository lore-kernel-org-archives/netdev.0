From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 04/22] netconsole: Call netpoll_cleanup() in process context
Date: Tue, 14 Dec 2010 13:29:15 -0800
Message-ID: <20101214212915.17022.16007.stgit@mike.mtv.corp.google.com>
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

The netconsole driver currently deadlocks if a NETDEV_UNREGISTER event
is received while netconsole is in use, which in turn causes it to pin a
reference to the network device.  The first deadlock was dealt with in
3b410a31 so that we wouldn't recursively grab RTNL, but even calling
__netpoll_cleanup isn't safe to do considering that we are in atomic
context.  __netpoll_cleanup assumes it can sleep and has several
sleeping calls, such as synchronize_rcu_bh and
cancel_rearming_delayed_work.

Fix this by deferring netpoll_cleanup using scheduling work that
operates in process context.  We have to grab a reference to the
config_item in this case as we need to pin the item in place until it is
operated on.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
Changelog:
- v3
  - Updated to also cancel any pending workers and clean the target up
    if needed when removing being dropped from configfs.  Issue
    identified by Neil Horman.
---
 drivers/net/netconsole.c |   64 +++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 288a025..68700c1 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -106,6 +106,7 @@ struct netconsole_target {
 #endif
 	int			np_state;
 	struct netpoll		np;
+	struct work_struct	cleanup_work;
 };
 
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
@@ -166,6 +167,22 @@ static void netconsole_target_put(struct netconsole_target *nt)
 
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
+static void deferred_netpoll_cleanup(struct work_struct *work)
+{
+	struct netconsole_target *nt;
+	unsigned long flags;
+
+	nt = container_of(work, struct netconsole_target, cleanup_work);
+	netpoll_cleanup(&nt->np);
+
+	spin_lock_irqsave(&target_list_lock, flags);
+	BUG_ON(nt->np_state != NETPOLL_CLEANING);
+	nt->np_state = NETPOLL_DISABLED;
+	spin_unlock_irqrestore(&target_list_lock, flags);
+
+	netconsole_target_put(nt);
+}
+
 /* Allocate new target (from boot/module param) and setup netpoll for it */
 static struct netconsole_target *alloc_param_target(char *target_config)
 {
@@ -187,6 +204,7 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
 	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+	INIT_WORK(&nt->cleanup_work, deferred_netpoll_cleanup);
 
 	/* Parse parameters and setup netpoll */
 	err = netpoll_parse_options(&nt->np, target_config);
@@ -209,7 +227,9 @@ fail:
 /* Cleanup netpoll for given target (from boot/module param) and free it */
 static void free_param_target(struct netconsole_target *nt)
 {
-	netpoll_cleanup(&nt->np);
+	cancel_work_sync(&nt->cleanup_work);
+	if (nt->np_state == NETPOLL_CLEANING || nt->np_state == NETPOLL_ENABLED)
+		netpoll_cleanup(&nt->np);
 	kfree(nt);
 }
 
@@ -350,6 +370,13 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			goto busy;
 		else {
 			nt->np_state = NETPOLL_SETTINGUP;
+			/*
+			 * Nominally, we would grab an extra reference on the
+			 * config_item here for dynamic targets while we let go
+			 * of the lock, but this isn't required in this case
+			 * because there is a reference implicitly held by the
+			 * caller of the store operation.
+			 */
 			spin_unlock_irqrestore(&target_list_lock, flags);
 		}
 
@@ -635,6 +662,7 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
 	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+	INIT_WORK(&nt->cleanup_work, deferred_netpoll_cleanup);
 
 	/* Initialize the config_item member */
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
@@ -658,10 +686,16 @@ static void drop_netconsole_target(struct config_group *group,
 	spin_unlock_irqrestore(&target_list_lock, flags);
 
 	/*
-	 * The target may have never been enabled, or was manually disabled
-	 * before being removed so netpoll may have already been cleaned up.
+	 * The target may have never been disabled, or was disabled due
+	 * to a netdev event, but we haven't had the chance to clean
+	 * things up yet.
+	 *
+	 * We can't wait for the target to be cleaned up by its
+	 * scheduled work however, as that work doesn't pin this module
+	 * in place.
 	 */
-	if (nt->np_state == NETPOLL_ENABLED)
+	cancel_work_sync(&nt->cleanup_work);
+	if (nt->np_state == NETPOLL_ENABLED || nt->np_state == NETPOLL_CLEANING)
 		netpoll_cleanup(&nt->np);
 
 	config_item_put(&nt->item);
@@ -689,6 +723,19 @@ static struct configfs_subsystem netconsole_subsys = {
 
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
+/*
+ * Call netpoll_cleanup on this target asynchronously.
+ * target_list_lock is required.
+ */
+static void defer_netpoll_cleanup(struct netconsole_target *nt)
+{
+	if (nt->np_state != NETPOLL_ENABLED)
+		return;
+	netconsole_target_get(nt);
+	nt->np_state = NETPOLL_CLEANING;
+	schedule_work(&nt->cleanup_work);
+}
+
 /* Handle network interface device notifications */
 static int netconsole_netdev_event(struct notifier_block *this,
 				   unsigned long event,
@@ -712,13 +759,10 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			case NETDEV_BONDING_DESLAVE:
 			case NETDEV_UNREGISTER:
 				/*
-				 * rtnl_lock already held
+				 * We can't cleanup netpoll in atomic context.
+				 * Kick it off as deferred work.
 				 */
-				if (nt->np.dev) {
-					__netpoll_cleanup(&nt->np);
-					dev_put(nt->np.dev);
-					nt->np.dev = NULL;
-				}
+				defer_netpoll_cleanup(nt);
 			}
 		}
 	}
