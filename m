From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/9] ehea: don't use flush_scheduled_work()
Date: Sun, 12 Dec 2010 16:53:00 +0100
Message-ID: <1292169185-10579-5-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Breno Leitao <leitao@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Directly cancel port->reset_task from ehea_shutdown_single_port()
instead.  As this cancels the work for each port on driver detach,
flushing system_wq from ehea_remove() or ehea_module_exit() is no
longer necessary.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ehea/ehea_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index d51def1..81e5b7b 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3318,6 +3318,8 @@ out_err:
 static void ehea_shutdown_single_port(struct ehea_port *port)
 {
 	struct ehea_adapter *adapter = port->adapter;
+
+	cancel_work_sync(&port->reset_task);
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
 	kfree(port->mc_list);
@@ -3607,8 +3609,6 @@ static int __devexit ehea_remove(struct platform_device *dev)
 
 	ehea_remove_device_sysfs(dev);
 
-	flush_scheduled_work();
-
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
 
@@ -3797,7 +3797,6 @@ static void __exit ehea_module_exit(void)
 {
 	int ret;
 
-	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	unregister_reboot_notifier(&ehea_reboot_nb);
-- 
1.7.1
