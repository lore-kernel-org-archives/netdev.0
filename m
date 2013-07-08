From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH] drivers/net: caif: fix wrong rtnl_is_locked() usage
Date: Mon, 08 Jul 2013 11:23:04 +0400
Message-ID: <20130708072304.20622.60798.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtnl_is_locked() doesn't check who holds this lock, it just tells that it's
locked right now. if caif::ldisc_close really can be called under rtrnl_lock
then it should release net device in other context because there is no way
to grab rtnl_lock without deadlock.

This patch adds work which releases these devices. Also this patch fixes calling
dev_close/unregister_netdevice without rtnl_lock from caif_ser_exit().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
---
 drivers/net/caif/caif_serial.c |   61 ++++++++++++++++++++++++++--------------
 1 file changed, 39 insertions(+), 22 deletions(-)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 77be3cb..34dea95 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -35,8 +35,9 @@ MODULE_ALIAS_LDISC(N_CAIF);
 #define OFF 0
 #define CAIF_MAX_MTU 4096
 
-/*This list is protected by the rtnl lock. */
+static DEFINE_SPINLOCK(ser_lock);
 static LIST_HEAD(ser_list);
+static LIST_HEAD(ser_release_list);
 
 static bool ser_loop;
 module_param(ser_loop, bool, S_IRUGO);
@@ -308,6 +309,28 @@ static void ldisc_tx_wakeup(struct tty_struct *tty)
 }
 
 
+static void ser_release(struct work_struct *work)
+{
+	struct list_head list;
+	struct ser_device *ser, *tmp;
+
+	spin_lock(&ser_lock);
+	list_replace_init(&ser_release_list, &list);
+	spin_unlock(&ser_lock);
+
+	if (!list_empty(&list)) {
+		rtnl_lock();
+		list_for_each_entry_safe(ser, tmp, &list, node) {
+			dev_close(ser->dev);
+			unregister_netdevice(ser->dev);
+			debugfs_deinit(ser);
+		}
+		rtnl_unlock();
+	}
+}
+
+static DECLARE_WORK(ser_release_work, ser_release);
+
 static int ldisc_open(struct tty_struct *tty)
 {
 	struct ser_device *ser;
@@ -321,6 +344,9 @@ static int ldisc_open(struct tty_struct *tty)
 	if (!capable(CAP_SYS_ADMIN) && !capable(CAP_SYS_TTY_CONFIG))
 		return -EPERM;
 
+	/* release devices to avoid name collision */
+	ser_release(NULL);
+
 	sprintf(name, "cf%s", tty->name);
 	dev = alloc_netdev(sizeof(*ser), name, caifdev_setup);
 	if (!dev)
@@ -341,7 +367,9 @@ static int ldisc_open(struct tty_struct *tty)
 		return -ENODEV;
 	}
 
+	spin_lock(&ser_lock);
 	list_add(&ser->node, &ser_list);
+	spin_unlock(&ser_lock);
 	rtnl_unlock();
 	netif_stop_queue(dev);
 	update_tty_status(ser);
@@ -351,19 +379,13 @@ static int ldisc_open(struct tty_struct *tty)
 static void ldisc_close(struct tty_struct *tty)
 {
 	struct ser_device *ser = tty->disc_data;
-	/* Remove may be called inside or outside of rtnl_lock */
-	int islocked = rtnl_is_locked();
 
-	if (!islocked)
-		rtnl_lock();
-	/* device is freed automagically by net-sysfs */
-	dev_close(ser->dev);
-	unregister_netdevice(ser->dev);
-	list_del(&ser->node);
-	debugfs_deinit(ser);
 	tty_kref_put(ser->tty);
-	if (!islocked)
-		rtnl_unlock();
+
+	spin_lock(&ser_lock);
+	list_move(&ser->node, &ser_release_list);
+	spin_unlock(&ser_lock);
+	schedule_work(&ser_release_work);
 }
 
 /* The line discipline structure. */
@@ -438,16 +460,11 @@ static int __init caif_ser_init(void)
 
 static void __exit caif_ser_exit(void)
 {
-	struct ser_device *ser = NULL;
-	struct list_head *node;
-	struct list_head *_tmp;
-
-	list_for_each_safe(node, _tmp, &ser_list) {
-		ser = list_entry(node, struct ser_device, node);
-		dev_close(ser->dev);
-		unregister_netdevice(ser->dev);
-		list_del(node);
-	}
+	spin_lock(&ser_lock);
+	list_splice(&ser_list, &ser_release_list);
+	spin_unlock(&ser_lock);
+	ser_release(NULL);
+	cancel_work_sync(&ser_release_work);
 	tty_unregister_ldisc(N_CAIF);
 	debugfs_remove_recursive(debugfsdir);
 }
