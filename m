From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v3 net-next] ptp: dynamic allocation of PHC char devices
Date: Fri, 12 Apr 2013 12:56:15 +0200
Message-ID: <bb5ff20a9968a810e6f827921e56fc8fc8fededf.1365764133.git.jbenc@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753376Ab3DLK4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 06:56:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As network adapters supporting PTP are becoming more common, machines with
many NICs suddenly have many PHCs, too. The current limit of eight /dev/ptp*
char devices (and thus, 8 network interfaces with PHC) is insufficient. Let
the ptp driver allocate the char devices dynamically.

Tested with 28 PHCs, removing and re-adding some of them.

Thanks to Ben Hutchings for advice leading to simpler and cleaner patch.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v3: Converted from idr to ida, dropped mutex guarding idr allocation, static
    ida initialization.

v2: Removed dynamic allocation of chunks of minor numbers, the full minor
    range is allocated instead.
---
 drivers/ptp/ptp_clock.c |   38 +++++++++++++-------------------------
 1 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 79f4bce..4a8c388 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -17,7 +17,7 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-#include <linux/bitops.h>
+#include <linux/idr.h>
 #include <linux/device.h>
 #include <linux/err.h>
 #include <linux/init.h>
@@ -32,7 +32,6 @@
 #include "ptp_private.h"
 
 #define PTP_MAX_ALARMS 4
-#define PTP_MAX_CLOCKS 8
 #define PTP_PPS_DEFAULTS (PPS_CAPTUREASSERT | PPS_OFFSETASSERT)
 #define PTP_PPS_EVENT PPS_CAPTUREASSERT
 #define PTP_PPS_MODE (PTP_PPS_DEFAULTS | PPS_CANWAIT | PPS_TSFMT_TSPEC)
@@ -42,8 +41,7 @@
 static dev_t ptp_devt;
 static struct class *ptp_class;
 
-static DECLARE_BITMAP(ptp_clocks_map, PTP_MAX_CLOCKS);
-static DEFINE_MUTEX(ptp_clocks_mutex); /* protects 'ptp_clocks_map' */
+static DEFINE_IDA(ptp_clocks_map);
 
 /* time stamp event queue operations */
 
@@ -171,12 +169,7 @@ static void delete_ptp_clock(struct posix_clock *pc)
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
 
 	mutex_destroy(&ptp->tsevq_mux);
-
-	/* Remove the clock from the bit map. */
-	mutex_lock(&ptp_clocks_mutex);
-	clear_bit(ptp->index, ptp_clocks_map);
-	mutex_unlock(&ptp_clocks_mutex);
-
+	ida_simple_remove(&ptp_clocks_map, ptp->index);
 	kfree(ptp);
 }
 
@@ -191,21 +184,18 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	if (info->n_alarm > PTP_MAX_ALARMS)
 		return ERR_PTR(-EINVAL);
 
-	/* Find a free clock slot and reserve it. */
-	err = -EBUSY;
-	mutex_lock(&ptp_clocks_mutex);
-	index = find_first_zero_bit(ptp_clocks_map, PTP_MAX_CLOCKS);
-	if (index < PTP_MAX_CLOCKS)
-		set_bit(index, ptp_clocks_map);
-	else
-		goto no_slot;
-
 	/* Initialize a clock structure. */
 	err = -ENOMEM;
 	ptp = kzalloc(sizeof(struct ptp_clock), GFP_KERNEL);
 	if (ptp == NULL)
 		goto no_memory;
 
+	index = ida_simple_get(&ptp_clocks_map, 0, MINORMASK + 1, GFP_KERNEL);
+	if (index < 0) {
+		err = index;
+		goto no_slot;
+	}
+
 	ptp->clock.ops = ptp_clock_ops;
 	ptp->clock.release = delete_ptp_clock;
 	ptp->info = info;
@@ -248,7 +238,6 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 		goto no_clock;
 	}
 
-	mutex_unlock(&ptp_clocks_mutex);
 	return ptp;
 
 no_clock:
@@ -260,11 +249,9 @@ no_sysfs:
 	device_destroy(ptp_class, ptp->devid);
 no_device:
 	mutex_destroy(&ptp->tsevq_mux);
+no_slot:
 	kfree(ptp);
 no_memory:
-	clear_bit(index, ptp_clocks_map);
-no_slot:
-	mutex_unlock(&ptp_clocks_mutex);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL(ptp_clock_register);
@@ -323,7 +310,8 @@ EXPORT_SYMBOL(ptp_clock_index);
 static void __exit ptp_exit(void)
 {
 	class_destroy(ptp_class);
-	unregister_chrdev_region(ptp_devt, PTP_MAX_CLOCKS);
+	unregister_chrdev_region(ptp_devt, MINORMASK + 1);
+	ida_destroy(&ptp_clocks_map);
 }
 
 static int __init ptp_init(void)
@@ -336,7 +324,7 @@ static int __init ptp_init(void)
 		return PTR_ERR(ptp_class);
 	}
 
-	err = alloc_chrdev_region(&ptp_devt, 0, PTP_MAX_CLOCKS, "ptp");
+	err = alloc_chrdev_region(&ptp_devt, 0, MINORMASK + 1, "ptp");
 	if (err < 0) {
 		pr_err("ptp: failed to allocate device region\n");
 		goto no_region;
-- 
1.7.6.5
