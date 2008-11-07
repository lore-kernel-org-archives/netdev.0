From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] pktgen: add full reset functionality
Date: Fri, 07 Nov 2008 14:01:40 -0800
Message-ID: <20081107220140.8528.21932.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Robert Olsson <robert.olsson@its.uu.se>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:34017
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751530AbYKGWCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 17:02:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

While testing pktgen, I found that sometimes my configurations from
previous runs would be left over, particularly when going from a test
with 8 threads down to a test with 4 threads.

This adds new functionality to pktgen where you can call
pgset "reset"

and it will be just like you just insmod'ed pktgen again.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Robert Olsson <robert.olsson@its.uu.se>
---

 net/core/pktgen.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fa4973b..a4f5ad1 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -422,6 +422,7 @@ static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
 					  const char *ifname);
 static int pktgen_device_event(struct notifier_block *, unsigned long, void *);
 static void pktgen_run_all_threads(void);
+static void pktgen_reset_all_threads(void);
 static void pktgen_stop_all_threads_ifs(void);
 static int pktgen_stop_device(struct pktgen_dev *pkt_dev);
 static void pktgen_stop(struct pktgen_thread *t);
@@ -480,6 +481,9 @@ static ssize_t pgctrl_write(struct file *file, const char __user * buf,
 	else if (!strcmp(data, "start"))
 		pktgen_run_all_threads();
 
+	else if (!strcmp(data, "reset"))
+		pktgen_reset_all_threads();
+
 	else
 		printk(KERN_WARNING "pktgen: Unknown command: %s\n", data);
 
@@ -3173,6 +3177,24 @@ static void pktgen_run_all_threads(void)
 	pktgen_wait_all_threads_run();
 }
 
+static void pktgen_reset_all_threads(void)
+{
+	struct pktgen_thread *t;
+
+	pr_debug("pktgen: entering pktgen_reset_all_threads.\n");
+
+	mutex_lock(&pktgen_thread_lock);
+
+	list_for_each_entry(t, &pktgen_threads, th_list)
+		t->control |= (T_REMDEVALL);
+
+	mutex_unlock(&pktgen_thread_lock);
+
+	schedule_timeout_interruptible(msecs_to_jiffies(125));	/* Propagate thread->control  */
+
+	pktgen_wait_all_threads_run();
+}
+
 static void show_results(struct pktgen_dev *pkt_dev, int nr_frags)
 {
 	__u64 total_us, bps, mbps, pps, idle;

