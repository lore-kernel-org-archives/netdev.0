From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 4/4] openvswitch: Correctly report flow used
	times for first 5 minutes after boot.
Date: Thu, 20 Mar 2014 11:09:14 -0700
Message-ID: <1395338954-26206-5-git-send-email-jesse@nicira.com>
References: <1395338954-26206-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395338954-26206-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

The kernel starts out its "jiffies" timer as 5 minutes below zero, as
shown in include/linux/jiffies.h:

  /*
   * Have the 32 bit jiffies value wrap 5 minutes after boot
   * so jiffies wrap bugs show up earlier.
   */
  #define INITIAL_JIFFIES ((unsigned long)(unsigned int) (-300*HZ))

The loop in ovs_flow_stats_get() starts out with 'used' set to 0, then
takes any "later" time.  This means that for the first five minutes after
boot, flows will always be reported as never used, since 0 is greater than
any time already seen.

Signed-off-by: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Acked-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index d71e60f..dda451f 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -92,7 +92,7 @@ static void stats_read(struct flow_stats *stats,
 		       unsigned long *used, __be16 *tcp_flags)
 {
 	spin_lock(&stats->lock);
-	if (time_after(stats->used, *used))
+	if (!*used || time_after(stats->used, *used))
 		*used = stats->used;
 	*tcp_flags |= stats->tcp_flags;
 	ovs_stats->n_packets += stats->packet_count;
-- 
1.8.3.2
