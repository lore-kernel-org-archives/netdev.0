From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 07/22] netconsole: Move netdev_notifier into netpoll_targets
Date: Tue, 14 Dec 2010 13:29:32 -0800
Message-ID: <20101214212931.17022.10554.stgit@mike.mtv.corp.google.com>
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

Move the notifier chain node up into struct netpoll_targets, and use it
to get at the netpoll_targets struct whenever we get a NETDEV event.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
 drivers/net/netconsole.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index aa95b91..fed427d 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -71,6 +71,7 @@ struct netpoll_targets {
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
 	struct configfs_subsystem configfs_subsys;
 #endif
+	struct notifier_block netdev_notifier;
 };
 #define DEFINE_NETPOLL_TARGETS(x) struct netpoll_targets x = \
 	{ .list = LIST_HEAD_INIT(x.list), \
@@ -740,6 +741,8 @@ static int netconsole_netdev_event(struct notifier_block *this,
 				   unsigned long event,
 				   void *ptr)
 {
+	struct netpoll_targets *nts = container_of(this, struct netpoll_targets,
+						   netdev_notifier);
 	unsigned long flags;
 	struct netconsole_target *nt;
 	struct net_device *dev = ptr;
@@ -748,8 +751,8 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	      event == NETDEV_BONDING_DESLAVE))
 		goto done;
 
-	spin_lock_irqsave(&targets.lock, flags);
-	list_for_each_entry(nt, &targets.list, list) {
+	spin_lock_irqsave(&nts->lock, flags);
+	list_for_each_entry(nt, &nts->list, list) {
 		if (nt->np_state == NETPOLL_ENABLED && nt->np.dev == dev) {
 			switch (event) {
 			case NETDEV_CHANGENAME:
@@ -765,7 +768,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			}
 		}
 	}
-	spin_unlock_irqrestore(&targets.lock, flags);
+	spin_unlock_irqrestore(&nts->lock, flags);
 	if (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE)
 		printk(KERN_INFO "netconsole: network logging stopped, "
 			"interface %s %s\n",  dev->name,
@@ -775,10 +778,6 @@ done:
 	return NOTIFY_DONE;
 }
 
-static struct notifier_block netconsole_netdev_notifier = {
-	.notifier_call  = netconsole_netdev_event,
-};
-
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
@@ -842,7 +841,8 @@ static int __init init_netconsole(void)
 		}
 	}
 
-	err = register_netdevice_notifier(&netconsole_netdev_notifier);
+	targets.netdev_notifier.notifier_call = netconsole_netdev_event;
+	err = register_netdevice_notifier(&targets.netdev_notifier);
 	if (err)
 		goto fail;
 
@@ -856,7 +856,7 @@ static int __init init_netconsole(void)
 	return err;
 
 undonotifier:
-	unregister_netdevice_notifier(&netconsole_netdev_notifier);
+	unregister_netdevice_notifier(&targets.netdev_notifier);
 
 fail:
 	printk(KERN_ERR "netconsole: cleaning up\n");
@@ -880,7 +880,7 @@ static void __exit cleanup_netconsole(void)
 
 	unregister_console(&netconsole);
 	dynamic_netpoll_targets_exit(&targets);
-	unregister_netdevice_notifier(&netconsole_netdev_notifier);
+	unregister_netdevice_notifier(&targets.netdev_notifier);
 
 	/*
 	 * Targets created via configfs pin references on our module
