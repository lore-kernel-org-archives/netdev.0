From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: igmp: Allow mininum interval specification for igmp timers.
Date: Wed, 22 Sep 2010 13:59:30 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009221354410.32661@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David L Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

IGMP timers sometimes fire too rapidly due to randomization of the
intervalsfrom 0 to max_delay in igmp_start_timer(). For some situations
(like the initial IGMP reports that are not responses to an IGMP query) we
do not want them in too rapid succession otherwise all the initial reports
may be lost due to a race conditions with the reconfiguration of the
routers and switches going on via the link layer (like on Infiniband). If
those are lost then the router will only discover that a new mc group was
joined when the igmp query was sent. General IGMP queries may be sent
rarely on large fabrics resulting in excessively long wait times until
data starts flowing. The application may abort before then concluding that
the network hardware is not operational.

The worst case scenario without the changes will send 3 igmp reports on join:

First		3 jiffies ("immediate" (spec) ~3 ms)
Second		3 jiffies (randomization leads to shortest interval) 3 ms
Third		3 jiffies (randomization leads to shortest interval) 3 ms

Which may result in a total of less than 10ms until the kernel gives up sending
igmp requests.

Change the IGMP layer to allow the specification of minimum and maximum delay.
Calculate the IGMP_Unsolicated_Report interval based on what the interval
before this patch would be on a 100HZ kernel. 3 jiffies at 100 HZ would result
in a mininum ~30 milliseconds spacing between the initial two IGMP reports.
Round it up to 40ms.

This will result in 3 initial unsolicited reports

First	"immediately"	3 jiffies (~ 3ms)
Second	randomized 40ms to 10seconds later
Third	randomized 40ms	to 10seconds later

So a mininum of ~83ms will pass before the unsolicted reports are
given up.

Signed-off-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>

---
 net/ipv4/igmp.c |   45 +++++++++++++++++++++++++++++++--------------
 1 file changed, 31 insertions(+), 14 deletions(-)

Index: linux-2.6/net/ipv4/igmp.c
===================================================================
--- linux-2.6.orig/net/ipv4/igmp.c	2010-09-22 11:15:19.000000000 -0500
+++ linux-2.6/net/ipv4/igmp.c	2010-09-22 12:50:32.000000000 -0500
@@ -116,10 +116,17 @@
 #define IGMP_V2_Router_Present_Timeout		(400*HZ)
 #define IGMP_Unsolicited_Report_Interval	(10*HZ)
 #define IGMP_Query_Response_Interval		(10*HZ)
-#define IGMP_Unsolicited_Report_Count		2

+/* Parameters not specified in igmp rfc. */
+
+/* Mininum ticks to have a meaningful notion of delay */
+#define IGMP_Mininum_Delay			(2)
+
+/* Control of unsolilcited reports (after join) */

+#define IGMP_Unsolicited_Report_Count		2
 #define IGMP_Initial_Report_Delay		(1)
+#define IGMP_Unsolicited_Report_Min_Delay	(HZ/25)

 /* IGMP_Initial_Report_Delay is not from IGMP specs!
  * IGMP specs require to report membership immediately after
@@ -174,22 +181,30 @@ static __inline__ void igmp_stop_timer(s
 	spin_unlock_bh(&im->lock);
 }

-/* It must be called with locked im->lock */
-static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
+static inline unsigned long jiffies_rand_delay(int min_delay, int max_delay)
 {
-	int tv = net_random() % max_delay;
+	int d = min_delay;
+
+	if (min_delay < max_delay)
+		d += net_random() % (max_delay - min_delay);

+	return jiffies + d;
+}
+
+/* It must be called with locked im->lock */
+static void igmp_start_timer(struct ip_mc_list *im, int min_delay, int max_delay)
+{
 	im->tm_running = 1;
-	if (!mod_timer(&im->timer, jiffies+tv+2))
+	if (!mod_timer(&im->timer, jiffies_rand_delay(min_delay, max_delay)))
 		atomic_inc(&im->refcnt);
 }

 static void igmp_gq_start_timer(struct in_device *in_dev)
 {
-	int tv = net_random() % in_dev->mr_maxdelay;
-
 	in_dev->mr_gq_running = 1;
-	if (!mod_timer(&in_dev->mr_gq_timer, jiffies+tv+2))
+	if (!mod_timer(&in_dev->mr_gq_timer,
+			jiffies_rand_delay(IGMP_Mininum_Delay,
+					in_dev->mr_maxdelay)))
 		in_dev_hold(in_dev);
 }

@@ -201,7 +216,7 @@ static void igmp_ifc_start_timer(struct
 		in_dev_hold(in_dev);
 }

-static void igmp_mod_timer(struct ip_mc_list *im, int max_delay)
+static void igmp_mod_timer(struct ip_mc_list *im, int min_delay, int max_delay)
 {
 	spin_lock_bh(&im->lock);
 	im->unsolicit_count = 0;
@@ -214,7 +229,7 @@ static void igmp_mod_timer(struct ip_mc_
 		}
 		atomic_dec(&im->refcnt);
 	}
-	igmp_start_timer(im, max_delay);
+	igmp_start_timer(im, min_delay, max_delay);
 	spin_unlock_bh(&im->lock);
 }

@@ -733,7 +748,8 @@ static void igmp_timer_expire(unsigned l

 	if (im->unsolicit_count) {
 		im->unsolicit_count--;
-		igmp_start_timer(im, IGMP_Unsolicited_Report_Interval);
+		igmp_start_timer(im, IGMP_Unsolicited_Report_Min_Delay,
+				IGMP_Unsolicited_Report_Interval);
 	}
 	im->reporter = 1;
 	spin_unlock(&im->lock);
@@ -911,7 +927,7 @@ static void igmp_heard_query(struct in_d
 			igmp_marksources(im, ntohs(ih3->nsrcs), ih3->srcs);
 		spin_unlock_bh(&im->lock);
 		if (changed)
-			igmp_mod_timer(im, max_delay);
+			igmp_mod_timer(im, IGMP_Mininum_Delay, max_delay);
 	}
 	read_unlock(&in_dev->mc_list_lock);
 }
@@ -1169,7 +1185,7 @@ static void igmp_group_added(struct ip_m
 		return;
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
 		spin_lock_bh(&im->lock);
-		igmp_start_timer(im, IGMP_Initial_Report_Delay);
+		igmp_start_timer(im, IGMP_Mininum_Delay, IGMP_Initial_Report_Delay);
 		spin_unlock_bh(&im->lock);
 		return;
 	}
@@ -1258,7 +1274,8 @@ void ip_mc_rejoin_group(struct ip_mc_lis
 		return;

 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
-		igmp_mod_timer(im, IGMP_Initial_Report_Delay);
+		igmp_mod_timer(im, IGMP_Mininum_Delay,
+					IGMP_Initial_Report_Delay);
 		return;
 	}
 	/* else, v3 */
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
