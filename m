From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC PATCH] net: NETDEV WATCHDOG should print something every time
Date: Fri, 22 Jan 2010 13:43:33 -0800
Message-ID: <20100122214333.14389.86017.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754636Ab0AVVnf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 5337407c changed NETDEV WATCHDOG messages into a message
that will only print once per driver load.  This removed a significant amount
of information from an admin who might be missing that his system was having
NETDEV WATCHDOGs, esp since there is no other global counter available to
count these events.

simply check the __warned flag and print a simple version of the message
without the full stack dump if the (kerneloops related) WARN_ON_ONCE has
already logged the hardware type and one hang.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Arjan <arjan@linux.intel.com>
---

 include/asm-generic/bug.h |    5 +++++
 net/sched/sch_generic.c   |    9 +++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
index 18c435d..ad810a0 100644
--- a/include/asm-generic/bug.h
+++ b/include/asm-generic/bug.h
@@ -132,6 +132,11 @@ extern void warn_slowpath_null(const char *file, const int line);
 	unlikely(__ret_warn_once);				\
 })
 
+#define WARNED_ALREADY() ({					\
+	static bool __warned;					\
+	unlikely(__warned);					\
+})
+
 #define WARN_ON_RATELIMIT(condition, state)			\
 		WARN_ON((condition) && __ratelimit(state))
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5173c1e..28fb14f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -251,8 +251,13 @@ static void dev_watchdog(unsigned long arg)
 
 			if (some_queue_timedout) {
 				char drivername[64];
-				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
-				       dev->name, netdev_drivername(dev, drivername, 64), i);
+				/* FIXME: is there a way to const char string[] = "NETDEV WATCHDOG..." */
+				if (!WARNED_ALREADY())
+					WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
+						  dev->name, netdev_drivername(dev, drivername, 64), i);
+				else
+					printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
+					       dev->name, netdev_drivername(dev, drivername, 64), i);
 				dev->netdev_ops->ndo_tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
