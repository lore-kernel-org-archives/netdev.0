From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next] ptp: dynamic allocation of PHC char devices
Date: Thu, 11 Apr 2013 14:48:51 +0200
Message-ID: <a2c31e85628e006bdd6c621c0b14aeded4b62c66.1365684455.git.jbenc@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751864Ab3DKMt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 08:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As network adapters supporting PTP are becoming more common, machines with
many NICs suddenly have many PHCs, too. The current limit of eight /dev/ptp*
char devices (and thus, 8 network interfaces with PHC) is insufficient. Let
the ptp driver allocate the char devices dynamically.

idr is used for tracking minor numbers allocation; the mapping from index to
pointer is not used, as it is not needed for posix clocks.

Tested with 28 PHCs, removing and re-adding some of them.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: Removed dynamic allocation of chunks of minor numbers, the full minor
    range is allocated instead.
---
 drivers/ptp/ptp_clock.c |   60 +++++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 22 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 79f4bce..c8c57bc 100644
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
@@ -42,7 +41,7 @@
 static dev_t ptp_devt;
 static struct class *ptp_class;
 
-static DECLARE_BITMAP(ptp_clocks_map, PTP_MAX_CLOCKS);
+static struct idr ptp_clocks_map;
 static DEFINE_MUTEX(ptp_clocks_mutex); /* protects 'ptp_clocks_map' */
 
 /* time stamp event queue operations */
@@ -166,17 +165,36 @@ static struct posix_clock_operations ptp_clock_ops = {
 	.read		= ptp_read,
 };
 
-static void delete_ptp_clock(struct posix_clock *pc)
+static int ptp_clock_alloc_index(struct ptp_clock *ptp)
 {
-	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+	int index;
 
-	mutex_destroy(&ptp->tsevq_mux);
+	mutex_lock(&ptp_clocks_mutex);
+	index = idr_alloc(&ptp_clocks_map, ptp, 0, 0, GFP_KERNEL);
+	if (index < 0)
+		goto no_idr;
+	if (index > MINORMASK) {
+		idr_remove(&ptp_clocks_map, index);
+		index = -EBUSY;
+	}
+no_idr:
+	mutex_unlock(&ptp_clocks_mutex);
+	return index;
+}
 
-	/* Remove the clock from the bit map. */
+static void ptp_clock_free_index(int index)
+{
 	mutex_lock(&ptp_clocks_mutex);
-	clear_bit(ptp->index, ptp_clocks_map);
+	idr_remove(&ptp_clocks_map, index);
 	mutex_unlock(&ptp_clocks_mutex);
+}
 
+static void delete_ptp_clock(struct posix_clock *pc)
+{
+	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
+
+	mutex_destroy(&ptp->tsevq_mux);
+	ptp_clock_free_index(ptp->index);
 	kfree(ptp);
 }
 
@@ -191,21 +209,18 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
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
 
+	index = ptp_clock_alloc_index(ptp);
+	if (index < 0) {
+		err = index;
+		goto no_slot;
+	}
+
 	ptp->clock.ops = ptp_clock_ops;
 	ptp->clock.release = delete_ptp_clock;
 	ptp->info = info;
@@ -260,11 +275,10 @@ no_sysfs:
 	device_destroy(ptp_class, ptp->devid);
 no_device:
 	mutex_destroy(&ptp->tsevq_mux);
+	ptp_clock_free_index(index);
+no_slot:
 	kfree(ptp);
 no_memory:
-	clear_bit(index, ptp_clocks_map);
-no_slot:
-	mutex_unlock(&ptp_clocks_mutex);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL(ptp_clock_register);
@@ -323,7 +337,8 @@ EXPORT_SYMBOL(ptp_clock_index);
 static void __exit ptp_exit(void)
 {
 	class_destroy(ptp_class);
-	unregister_chrdev_region(ptp_devt, PTP_MAX_CLOCKS);
+	unregister_chrdev_region(ptp_devt, MINORMASK + 1);
+	idr_destroy(&ptp_clocks_map);
 }
 
 static int __init ptp_init(void)
@@ -336,7 +351,8 @@ static int __init ptp_init(void)
 		return PTR_ERR(ptp_class);
 	}
 
-	err = alloc_chrdev_region(&ptp_devt, 0, PTP_MAX_CLOCKS, "ptp");
+	idr_init(&ptp_clocks_map);
+	err = alloc_chrdev_region(&ptp_devt, 0, MINORMASK + 1, "ptp");
 	if (err < 0) {
 		pr_err("ptp: failed to allocate device region\n");
 		goto no_region;
-- 
1.7.6.5
