From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] fix NAPI race
Date: Tue, 29 Jul 2003 16:05:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030729060509.GB13227@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: miltonm@bga.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Milton and I debugged an oops where we did list_del on a poisoned list
entry. It turns out there is nothing to order between list_del on
poll_list and the clear_bit that serialises list_add.

Anton

diff -ruN --exclude-from=exclude gr13_work/include/linux/netdevice.h gr13_work_miltonm/include/linux/netdevice.h
--- gr13_work/include/linux/netdevice.h	2003-07-17 23:30:43.000000000 -0500
+++ gr13_work_miltonm/include/linux/netdevice.h	2003-07-28 23:42:06.000000000 -0500
@@ -820,6 +820,7 @@
 	local_irq_save(flags);
 	if (!test_bit(__LINK_STATE_RX_SCHED, &dev->state)) BUG();
 	list_del(&dev->poll_list);
+	smp_mb__before_clear_bit();
 	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
 	local_irq_restore(flags);
 }
diff -ruN --exclude-from=exclude gr13_work/net/core/dev.c gr13_work_miltonm/net/core/dev.c
--- gr13_work/net/core/dev.c	2003-07-17 23:30:43.000000000 -0500
+++ gr13_work_miltonm/net/core/dev.c	2003-07-28 23:40:15.000000000 -0500
@@ -1657,6 +1657,7 @@
 	*budget -= work;
 
 	list_del(&backlog_dev->poll_list);
+	smp_mb__before_clear_bit();
 	clear_bit(__LINK_STATE_RX_SCHED, &backlog_dev->state);
 
 	if (queue->throttle) {
diff -ruN --exclude-from=exclude gr13_work/drivers/net/tg3.c gr13_work_miltonm/drivers/net/tg3.c
--- gr13_work/drivers/net/tg3.c	2003-07-13 23:40:19.000000000 -0500
+++ gr13_work_miltonm/drivers/net/tg3.c	2003-07-29 01:00:32.000000000 -0500
@@ -250,6 +250,7 @@
 {
 	if (!test_bit(__LINK_STATE_RX_SCHED, &dev->state)) BUG();
 	list_del(&dev->poll_list);
+	smp_mb__before_clear_bit();
 	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
 }
 
