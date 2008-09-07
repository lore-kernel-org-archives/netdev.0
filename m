From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] warn: Turn the netdev timeout WARN_ON() into a WARN()
Date: Sun, 7 Sep 2008 09:28:04 -0700
Message-ID: <20080907092804.12be0ae7@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53678 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbYIGQ15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 12:27:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave / netdev,

now that the dust has settled around the WARN() stuff in 2.6.27-rc,
below is a patch to make the netdev timeout message use WARN_ONCE()
(which is a thin wrapper that this patch also adds, just because
this is the first user)

Please consider merging for 2.6.28's merge window


From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [PATCH] warn: Turn the netdev timeout WARN_ON() into a WARN()

this patch turns the netdev timeout WARN_ON_ONCE() into a WARN_ONCE(),
so that the device and driver names are inside the warning message.
This helps automated tools like kerneloops.org to collect the data
and do statistics, as well as making it more likely that humans
cut-n-paste the important message as part of a bugreport.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 include/asm-generic/bug.h |   10 ++++++++++
 net/sched/sch_generic.c   |    3 +--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
index a3f738c..edc6ba8 100644
--- a/include/asm-generic/bug.h
+++ b/include/asm-generic/bug.h
@@ -97,6 +97,16 @@ extern void warn_slowpath(const char *file, const int line,
 	unlikely(__ret_warn_once);				\
 })
 
+#define WARN_ONCE(condition, format...)	({			\
+	static int __warned;					\
+	int __ret_warn_once = !!(condition);			\
+								\
+	if (unlikely(__ret_warn_once))				\
+		if (WARN(!__warned, format)) 			\
+			__warned = 1;				\
+	unlikely(__ret_warn_once);				\
+})
+
 #define WARN_ON_RATELIMIT(condition, state)			\
 		WARN_ON((condition) && __ratelimit(state))
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9634091..ec0a083 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -215,10 +215,9 @@ static void dev_watchdog(unsigned long arg)
 			    time_after(jiffies, (dev->trans_start +
 						 dev->watchdog_timeo))) {
 				char drivername[64];
-				printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
+				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
 				       dev->name, netdev_drivername(dev, drivername, 64));
 				dev->tx_timeout(dev);
-				WARN_ON_ONCE(1);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
 				       round_jiffies(jiffies +
-- 
1.5.5.1

