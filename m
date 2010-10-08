From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/7] qlcnic: driver private workqueue
Date: Fri,  8 Oct 2010 02:46:05 -0700
Message-ID: <1286531171-21173-2-git-send-email-amit.salecha@qlogic.com>
References: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:2242 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754470Ab0JHJqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 05:46:12 -0400
In-Reply-To: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently fw recovery usage global workqueue.
As same workqueue used by kernel for ethtool and etc., supporting
quiescent mode is not possible, without driver private workqueue.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 4757908..7503c48 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -46,6 +46,7 @@ char qlcnic_driver_name[] = "qlcnic";
 static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
+static struct workqueue_struct *qlcnic_wq;
 static int qlcnic_mac_learn;
 module_param(qlcnic_mac_learn, int, 0644);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
@@ -2886,7 +2887,8 @@ qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 		return;
 
 	INIT_DELAYED_WORK(&adapter->fw_work, func);
-	schedule_delayed_work(&adapter->fw_work, round_jiffies_relative(delay));
+	queue_delayed_work(qlcnic_wq, &adapter->fw_work,
+					round_jiffies_relative(delay));
 }
 
 static void
@@ -4163,6 +4165,12 @@ static int __init qlcnic_init_module(void)
 
 	printk(KERN_INFO "%s\n", qlcnic_driver_string);
 
+	qlcnic_wq = create_singlethread_workqueue("qlcnic");
+	if (qlcnic_wq == NULL) {
+		printk(KERN_ERR "qlcnic: cannot create workqueue\n");
+		return -ENOMEM;
+	}
+
 #ifdef CONFIG_INET
 	register_netdevice_notifier(&qlcnic_netdev_cb);
 	register_inetaddr_notifier(&qlcnic_inetaddr_cb);
@@ -4174,6 +4182,7 @@ static int __init qlcnic_init_module(void)
 		unregister_inetaddr_notifier(&qlcnic_inetaddr_cb);
 		unregister_netdevice_notifier(&qlcnic_netdev_cb);
 #endif
+		destroy_workqueue(qlcnic_wq);
 	}
 
 	return ret;
@@ -4190,6 +4199,7 @@ static void __exit qlcnic_exit_module(void)
 	unregister_inetaddr_notifier(&qlcnic_inetaddr_cb);
 	unregister_netdevice_notifier(&qlcnic_netdev_cb);
 #endif
+	destroy_workqueue(qlcnic_wq);
 }
 
 module_exit(qlcnic_exit_module);
-- 
1.6.0.2

