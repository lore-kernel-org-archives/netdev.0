From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v4 net-next 2/4] net: convert low latency
 sockets to sched_clock()
Date: Fri, 14 Jun 2013 04:57:00 +0300
Message-ID: <20130614015659.3500.48625.stgit@ladj378.jer.intel.com>
References: <20130614015638.3500.61523.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	sockperf-dev@googlegroups.com, Avner Ben Hanoch <avnerb@mellanox.com>,
	Andi Kleen <andi@firstfloor.org>, Eliezer Tamir <eliezer@tamir.org.il>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130614015638.3500.61523.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use sched_clock() instead of get_cycles().
We can use sched_clock() because we don't care much about accuracy.
Remove the dependency on X86_TSC

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/ll_poll.h |   32 +++++++++++++++++---------------
 net/Kconfig           |    1 -
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index 44e2f70..8608547 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -21,10 +21,6 @@
  * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
  */
 
-/*
- * For now this depends on CONFIG_X86_TSC
- */
-
 #ifndef _LINUX_NET_LL_POLL_H
 #define _LINUX_NET_LL_POLL_H
 
@@ -40,13 +36,19 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 #define LL_FLUSH_FAILED		-1
 #define LL_FLUSH_BUSY		-2
 
-/* we don't mind a ~2.5% imprecision */
-#define TSC_MHZ (tsc_khz >> 10)
-
-static inline cycles_t ll_end_time(void)
+/* we can use sched_clock() because we don't care much about precision
+ * we only care that the average is bounded
+ */
+static inline u64 ll_end_time(void)
 {
-	return (cycles_t)TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll)
-			+ get_cycles();
+	u64 end_time = ACCESS_ONCE(sysctl_net_ll_poll);
+
+	/* we don't mind a ~2.5% imprecision
+	 * sysctl_net_ll_poll is a u_int so this can't overflow
+	 */
+	end_time = (end_time << 10) + sched_clock();
+
+	return end_time;
 }
 
 static inline bool sk_valid_ll(struct sock *sk)
@@ -55,16 +57,16 @@ static inline bool sk_valid_ll(struct sock *sk)
 	       !need_resched() && !signal_pending(current);
 }
 
-static inline bool can_poll_ll(cycles_t end_time)
+static inline bool can_poll_ll(u64 end_time)
 {
-	return !time_after((unsigned long)get_cycles(),
+	return !time_after((unsigned long)sched_clock(),
 			    (unsigned long)end_time);
 }
 
 static inline bool sk_poll_ll(struct sock *sk, int nonblock)
 {
-	cycles_t end_time = ll_end_time();
 	const struct net_device_ops *ops;
+	u64 end_time = ll_end_time();
 	struct napi_struct *napi;
 	int rc = false;
 
@@ -117,7 +119,7 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 
 #else /* CONFIG_NET_LL_RX_POLL */
 
-static inline cycles_t ll_end_time(void)
+static inline u64 ll_end_time(void)
 {
 	return 0;
 }
@@ -140,7 +142,7 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 {
 }
 
-static inline bool can_poll_ll(cycles_t end_time)
+static inline bool can_poll_ll(u64 end_time)
 {
 	return false;
 }
diff --git a/net/Kconfig b/net/Kconfig
index d6a9ce6..e591668 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -245,7 +245,6 @@ config NETPRIO_CGROUP
 
 config NET_LL_RX_POLL
 	bool "Low Latency Receive Poll"
-	depends on X86_TSC
 	default n
 	---help---
 	  Support Low Latency Receive Queue Poll.


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
