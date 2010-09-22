From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: igmp: Staggered igmp report intervals for unsolicited igmp reports
Date: Wed, 22 Sep 2010 14:01:28 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009221400010.32661@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David L Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009221354410.32661-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The earlier patch added an initial mininum latency and got us up to
~80ms. However, there are large networks that take longer to configure
multicast paths.

This patch changes the behavior for unsolicited igmp reports to ensure
that even sporadic loss of the initial IGMP reports will result in a
reasonable fast subscription.

The rfc states that the first igmp report should be sent immediately and
then mentions that a couple of more should be sent but does not specify
exactly how the repeating of the igmp reports should occur. The RFC
suggests that the behavior in response to an IGMP report (randomized
response 0-max response time) could be followed but we have seen issues
with this suggestion since the intervals can be very short. There is also
no reason to randomize since the unsolicited reports are not a response to
an igmp query but the result of a join request in the code.

The patch here establishes more fixed delays for sending unsolicited
igmp reports after join. There is still a fuzz factor associated but the
sending of the igmp reports follows more tightly a set of intervals and sends
up to 7 igmp reports.

IGMP Report	Time delay
------------------------------------------------------------
0		3 ticks		"immediate" accordig to RFC.
1		40ms
2		200ms
3		1sec
4		5sec
5		10sec
6		60sec

So unsolicited reports are send for an interval of at least a minute
(reports are aborted if igmp reports or other info is seen).

Signed-off-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>

---
 net/ipv4/igmp.c |   38 ++++++++++++++++++++++++++++++++++----
 1 file changed, 34 insertions(+), 4 deletions(-)

Index: linux-2.6/net/ipv4/igmp.c
===================================================================
--- linux-2.6.orig/net/ipv4/igmp.c	2010-09-22 12:50:32.000000000 -0500
+++ linux-2.6/net/ipv4/igmp.c	2010-09-22 13:32:58.000000000 -0500
@@ -124,17 +124,40 @@

 /* Control of unsolilcited reports (after join) */

-#define IGMP_Unsolicited_Report_Count		2
+#define IGMP_Unsolicited_Report_Count		6
 #define IGMP_Initial_Report_Delay		(1)
 #define IGMP_Unsolicited_Report_Min_Delay	(HZ/25)
+#define IGMP_Unsolicited_Fuzz			(HZ/100)
+

 /* IGMP_Initial_Report_Delay is not from IGMP specs!
  * IGMP specs require to report membership immediately after
  * joining a group, but we delay the first report by a
  * small interval. It seems more natural and still does not
  * contradict to specs provided this delay is small enough.
+ *
+ * The spec does not say how the initial igmp reports
+ * need to be repeated (aside from suggesting to just do the
+ * randomization of the intervals as for igmp queries but then
+ * there is no centralized trigger and therefore no randomization
+ * needed). We provide an array of delays here that are likely
+ * to work in general avoiding the often too short or too long intervals
+ * that would be generated if we would follow the suggestion in the rfc.
+ *
+ * Note that the sending of unsolicited reports may stop at any point
+ * if we see an igmp query from a router or a neighbors ignmp report.
  */

+static int unsolicited_delay[IGMP_Unsolicited_Report_Count + 1] = {
+	IGMP_Initial_Report_Delay + IGMP_Mininum_Delay,	/* "Immediate" */
+	HZ / 25,			/* 40ms  */
+	HZ / 5,				/* 200ms */
+	HZ,
+	5 * HZ,
+	10 * HZ,
+	60 * HZ
+};
+
 #define IGMP_V1_SEEN(in_dev) \
 	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) == 1 || \
 	 IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 1 || \
@@ -199,6 +222,13 @@ static void igmp_start_timer(struct ip_m
 		atomic_inc(&im->refcnt);
 }

+static void igmp_start_initial_timer(struct ip_mc_list *im, int interval)
+{
+	int delay = unsolicited_delay[interval];
+
+	igmp_start_timer(im, delay, delay + IGMP_Unsolicited_Fuzz);
+}
+
 static void igmp_gq_start_timer(struct in_device *in_dev)
 {
 	in_dev->mr_gq_running = 1;
@@ -748,8 +778,8 @@ static void igmp_timer_expire(unsigned l

 	if (im->unsolicit_count) {
 		im->unsolicit_count--;
-		igmp_start_timer(im, IGMP_Unsolicited_Report_Min_Delay,
-				IGMP_Unsolicited_Report_Interval);
+		igmp_start_initial_timer(im,
+			IGMP_Unsolicited_Report_Count - im->unsolicit_count);
 	}
 	im->reporter = 1;
 	spin_unlock(&im->lock);
@@ -1185,7 +1215,7 @@ static void igmp_group_added(struct ip_m
 		return;
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
 		spin_lock_bh(&im->lock);
-		igmp_start_timer(im, IGMP_Mininum_Delay, IGMP_Initial_Report_Delay);
+		igmp_start_initial_timer(im, 0);
 		spin_unlock_bh(&im->lock);
 		return;
 	}

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
