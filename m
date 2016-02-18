From: Alison Schofield <amsfield22@gmail.com>
Subject: [RESEND PATCH v3] isdn: divamnt: use y2038-safe ktime_get_ts64() for trace data timestamps
Date: Wed, 17 Feb 2016 22:35:11 -0800
Message-ID: <1455777311-3190-1-git-send-email-amsfield22@gmail.com>
References: <20151120182307.GA3513@d830.WORKGROUP>
To: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, y2038@lists.linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151120182307.GA3513@d830.WORKGROUP>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divamnt stores a start_time at module init and uses it to calculate
elapsed time. The elapsed time, stored in secs and usecs, is part of
the trace data the driver maintains for the DIVA Server ISDN cards.
No change to the format of that time data is required.

To avoid overflow on 32-bit systems use ktime_get_ts64() to return
the elapsed monotonic time since system boot.

This is a change from real to monotonic time. Since the driver only
stores elapsed time, monotonic time is sufficient and more robust
against real time clock changes. These new monotonic values can be
more useful for debugging because they can be easily compared to
other monotonic timestamps.

Note elaspsed time values will now start at system boot time rather
than module load time, so they will differ slightly from previously
reported values.

Remove declaration and init of previously unused time constants:
start_sec, start_usec.

Signed-off-by: Alison Schofield <amsfield22@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
Changes in v3:
  - use elapsed time since system boot in place of
    elapsed time since module load
  - commit message updated
  - changelog updated

Changes in v2:
 - switched to monotonic time
 - removed the unused time constants
 - changelog updated


 drivers/isdn/hardware/eicon/debug.c   |  4 ----
 drivers/isdn/hardware/eicon/divamnt.c | 30 ++++++------------------------
 2 files changed, 6 insertions(+), 28 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/debug.c b/drivers/isdn/hardware/eicon/debug.c
index b5226af..576b7b4 100644
--- a/drivers/isdn/hardware/eicon/debug.c
+++ b/drivers/isdn/hardware/eicon/debug.c
@@ -192,8 +192,6 @@ static diva_os_spin_lock_t dbg_q_lock;
 static diva_os_spin_lock_t dbg_adapter_lock;
 static int                 dbg_q_busy;
 static volatile dword      dbg_sequence;
-static dword               start_sec;
-static dword               start_usec;
 
 /*
   INTERFACE:
@@ -215,8 +213,6 @@ int diva_maint_init(byte *base, unsigned long length, int do_init) {
 
 	dbg_base = base;
 
-	diva_os_get_time(&start_sec, &start_usec);
-
 	*(dword *)base  = (dword)DBG_MAGIC; /* Store Magic */
 	base   += sizeof(dword);
 	length -= sizeof(dword);
diff --git a/drivers/isdn/hardware/eicon/divamnt.c b/drivers/isdn/hardware/eicon/divamnt.c
index 48db08d..0de29b7b 100644
--- a/drivers/isdn/hardware/eicon/divamnt.c
+++ b/drivers/isdn/hardware/eicon/divamnt.c
@@ -45,7 +45,6 @@ char *DRIVERRELEASE_MNT = "2.0";
 
 static wait_queue_head_t msgwaitq;
 static unsigned long opened;
-static struct timeval start_time;
 
 extern int mntfunc_init(int *, void **, unsigned long);
 extern void mntfunc_finit(void);
@@ -88,28 +87,12 @@ int diva_os_copy_from_user(void *os_handle, void *dst, const void __user *src,
  */
 void diva_os_get_time(dword *sec, dword *usec)
 {
-	struct timeval tv;
-
-	do_gettimeofday(&tv);
-
-	if (tv.tv_sec > start_time.tv_sec) {
-		if (start_time.tv_usec > tv.tv_usec) {
-			tv.tv_sec--;
-			tv.tv_usec += 1000000;
-		}
-		*sec = (dword) (tv.tv_sec - start_time.tv_sec);
-		*usec = (dword) (tv.tv_usec - start_time.tv_usec);
-	} else if (tv.tv_sec == start_time.tv_sec) {
-		*sec = 0;
-		if (start_time.tv_usec < tv.tv_usec) {
-			*usec = (dword) (tv.tv_usec - start_time.tv_usec);
-		} else {
-			*usec = 0;
-		}
-	} else {
-		*sec = (dword) tv.tv_sec;
-		*usec = (dword) tv.tv_usec;
-	}
+	struct timespec64 time;
+
+	ktime_get_ts64(&time);
+
+	*sec = (dword) time.tv_sec;
+	*usec = (dword) (time.tv_nsec / NSEC_PER_USEC);
 }
 
 /*
@@ -213,7 +196,6 @@ static int __init maint_init(void)
 	int ret = 0;
 	void *buffer = NULL;
 
-	do_gettimeofday(&start_time);
 	init_waitqueue_head(&msgwaitq);
 
 	printk(KERN_INFO "%s\n", DRIVERNAME);
-- 
2.1.4
