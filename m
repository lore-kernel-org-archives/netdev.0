From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/5][SCTP]: Remove multiple levels of msecs to jiffies
	conversions.
Date: Fri, 18 Aug 2006 11:22:37 -0700
Message-ID: <1155925357.20802.27.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:25787 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964912AbWHRS2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 14:28:46 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7IISjB1032382
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7IISjTT259066
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:45 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7IISiqu009950
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 14:28:44 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Remove multiple levels of msecs to jiffies conversions.

The SCTP sysctl entries are displayed in milliseconds, but stored
internally in jiffies. This results in multiple levels of msecs to
jiffies conversion and as a result produces a truncation error. This
patch makes things consistent in that we store and display defaults
in milliseconds and only convert once for use by association.
This patch also adds some sane min/max values so that we don't go off
the deep end.

Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 include/net/sctp/constants.h |   13 ++--
 include/net/sctp/structs.h   |   12 ++--
 net/sctp/protocol.c          |    2 -
 net/sctp/socket.c            |   15 ++---
 net/sctp/sysctl.c            |  140 +++++++++++++++++++-----------------------
 net/sctp/transport.c         |    2 -
 6 files changed, 84 insertions(+), 100 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index c51541e..df65a72 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -264,10 +264,10 @@ enum { SCTP_MAX_DUP_TSNS = 16 };
 enum { SCTP_MAX_GABS = 16 };
 
 /* Heartbeat interval - 30 secs */
-#define SCTP_DEFAULT_TIMEOUT_HEARTBEAT	(30 * HZ)
+#define SCTP_DEFAULT_TIMEOUT_HEARTBEAT	(30*1000)
 
 /* Delayed sack timer - 200ms */
-#define SCTP_DEFAULT_TIMEOUT_SACK	((200 * HZ) / 1000)
+#define SCTP_DEFAULT_TIMEOUT_SACK	(200)
 
 /* RTO.Initial              - 3  seconds
  * RTO.Min                  - 1  second
@@ -275,9 +275,9 @@ #define SCTP_DEFAULT_TIMEOUT_SACK	((200 
  * RTO.Alpha                - 1/8
  * RTO.Beta                 - 1/4
  */
-#define SCTP_RTO_INITIAL	(3 * HZ)
-#define SCTP_RTO_MIN		(1 * HZ)
-#define SCTP_RTO_MAX		(60 * HZ)
+#define SCTP_RTO_INITIAL	(3 * 1000)
+#define SCTP_RTO_MIN		(1 * 1000)
+#define SCTP_RTO_MAX		(60 * 1000)
 
 #define SCTP_RTO_ALPHA          3   /* 1/8 when converted to right shifts. */
 #define SCTP_RTO_BETA           2   /* 1/4 when converted to right shifts. */
@@ -290,8 +290,7 @@ #define SCTP_CLOCK_GRANULARITY	1	/* 1 ji
 #define SCTP_DEF_MAX_INIT 6
 #define SCTP_DEF_MAX_SEND 10
 
-#define SCTP_DEFAULT_COOKIE_LIFE_SEC	60 /* seconds */
-#define SCTP_DEFAULT_COOKIE_LIFE_USEC	0  /* microseconds */
+#define SCTP_DEFAULT_COOKIE_LIFE	(60 * 1000) /* 60 seconds */
 
 #define SCTP_DEFAULT_MINWINDOW	1500	/* default minimum rwnd size */
 #define SCTP_DEFAULT_MAXWINDOW	65535	/* default rwnd size */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e5aa7ff..2243bb7 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -127,9 +127,9 @@ extern struct sctp_globals {
 	 * RTO.Alpha		    - 1/8  (3 when converted to right shifts.)
 	 * RTO.Beta		    - 1/4  (2 when converted to right shifts.)
 	 */
-	unsigned long rto_initial;
-	unsigned long rto_min;
-	unsigned long rto_max;
+	unsigned int rto_initial;
+	unsigned int rto_min;
+	unsigned int rto_max;
 
 	/* Note: rto_alpha and rto_beta are really defined as inverse
 	 * powers of two to facilitate integer operations.
@@ -144,13 +144,13 @@ extern struct sctp_globals {
 	int cookie_preserve_enable;
 
 	/* Valid.Cookie.Life	    - 60  seconds  */
-	unsigned long valid_cookie_life;
+	unsigned int valid_cookie_life;
 
 	/* Delayed SACK timeout  200ms default*/
-	unsigned long sack_timeout;
+	unsigned int sack_timeout;
 
 	/* HB.interval		    - 30 seconds  */
-	unsigned long hb_interval;
+	unsigned int hb_interval;
 
 	/* Association.Max.Retrans  - 10 attempts
 	 * Path.Max.Retrans	    - 5	 attempts (per destination address)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 1ab03a2..5692ef5 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1049,7 +1049,7 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_rto_beta			= SCTP_RTO_BETA;
 
 	/* Valid.Cookie.Life        - 60  seconds */
-	sctp_valid_cookie_life		= 60 * HZ;
+	sctp_valid_cookie_life		= SCTP_DEFAULT_COOKIE_LIFE;
 
 	/* Whether Cookie Preservative is enabled(1) or not(0) */
 	sctp_cookie_preserve_enable 	= 1;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 54722e6..48eeb26 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3033,14 +3033,14 @@ SCTP_STATIC int sctp_init_sock(struct so
 	sp->initmsg.sinit_num_ostreams   = sctp_max_outstreams;
 	sp->initmsg.sinit_max_instreams  = sctp_max_instreams;
 	sp->initmsg.sinit_max_attempts   = sctp_max_retrans_init;
-	sp->initmsg.sinit_max_init_timeo = jiffies_to_msecs(sctp_rto_max);
+	sp->initmsg.sinit_max_init_timeo = sctp_rto_max;
 
 	/* Initialize default RTO related parameters.  These parameters can
 	 * be modified for with the SCTP_RTOINFO socket option.
 	 */
-	sp->rtoinfo.srto_initial = jiffies_to_msecs(sctp_rto_initial);
-	sp->rtoinfo.srto_max     = jiffies_to_msecs(sctp_rto_max);
-	sp->rtoinfo.srto_min     = jiffies_to_msecs(sctp_rto_min);
+	sp->rtoinfo.srto_initial = sctp_rto_initial;
+	sp->rtoinfo.srto_max     = sctp_rto_max;
+	sp->rtoinfo.srto_min     = sctp_rto_min;
 
 	/* Initialize default association related parameters. These parameters
 	 * can be modified with the SCTP_ASSOCINFO socket option.
@@ -3049,8 +3049,7 @@ SCTP_STATIC int sctp_init_sock(struct so
 	sp->assocparams.sasoc_number_peer_destinations = 0;
 	sp->assocparams.sasoc_peer_rwnd = 0;
 	sp->assocparams.sasoc_local_rwnd = 0;
-	sp->assocparams.sasoc_cookie_life = 
-		jiffies_to_msecs(sctp_valid_cookie_life);
+	sp->assocparams.sasoc_cookie_life = sctp_valid_cookie_life;
 
 	/* Initialize default event subscriptions. By default, all the
 	 * options are off. 
@@ -3060,10 +3059,10 @@ SCTP_STATIC int sctp_init_sock(struct so
 	/* Default Peer Address Parameters.  These defaults can
 	 * be modified via SCTP_PEER_ADDR_PARAMS
 	 */
-	sp->hbinterval  = jiffies_to_msecs(sctp_hb_interval);
+	sp->hbinterval  = sctp_hb_interval;
 	sp->pathmaxrxt  = sctp_max_retrans_path;
 	sp->pathmtu     = 0; // allow default discovery
-	sp->sackdelay   = jiffies_to_msecs(sctp_sack_timeout);
+	sp->sackdelay   = sctp_sack_timeout;
 	sp->param_flags = SPP_HB_ENABLE |
 	                  SPP_PMTUD_ENABLE |
 	                  SPP_SACKDELAY_ENABLE;
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index dc6f3ff..633cd17 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -45,9 +45,10 @@ #include <net/sctp/structs.h>
 #include <net/sctp/sctp.h>
 #include <linux/sysctl.h>
 
-static ctl_handler sctp_sysctl_jiffies_ms;
-static long rto_timer_min = 1;
-static long rto_timer_max = 86400000; /* One day */
+static int zero = 0;
+static int one = 1;
+static int timer_max = 86400000; /* ms in one day */
+static int int_max = INT_MAX;
 static long sack_timer_min = 1;
 static long sack_timer_max = 500;
 
@@ -56,45 +57,45 @@ static ctl_table sctp_table[] = {
 		.ctl_name	= NET_SCTP_RTO_INITIAL,
 		.procname	= "rto_initial",
 		.data		= &sctp_rto_initial,
-		.maxlen		= sizeof(long),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
-		.strategy	= &sctp_sysctl_jiffies_ms,
-		.extra1         = &rto_timer_min,
-		.extra2         = &rto_timer_max
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1         = &one,
+		.extra2         = &timer_max
 	},
 	{
 		.ctl_name	= NET_SCTP_RTO_MIN,
 		.procname	= "rto_min",
 		.data		= &sctp_rto_min,
-		.maxlen		= sizeof(long),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
-		.strategy	= &sctp_sysctl_jiffies_ms,
-		.extra1         = &rto_timer_min,
-		.extra2         = &rto_timer_max
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1         = &one,
+		.extra2         = &timer_max
 	},
 	{
 		.ctl_name	= NET_SCTP_RTO_MAX,
 		.procname	= "rto_max",
 		.data		= &sctp_rto_max,
-		.maxlen		= sizeof(long),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
-		.strategy	= &sctp_sysctl_jiffies_ms,
-		.extra1         = &rto_timer_min,
-		.extra2         = &rto_timer_max
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1         = &one,
+		.extra2         = &timer_max
 	},
 	{
 		.ctl_name	= NET_SCTP_VALID_COOKIE_LIFE,
 		.procname	= "valid_cookie_life",
 		.data		= &sctp_valid_cookie_life,
-		.maxlen		= sizeof(long),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
-		.strategy	= &sctp_sysctl_jiffies_ms,
-		.extra1         = &rto_timer_min,
-		.extra2         = &rto_timer_max
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1         = &one,
+		.extra2         = &timer_max
 	},
 	{
 		.ctl_name	= NET_SCTP_MAX_BURST,
@@ -102,7 +103,10 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &int_max
 	},
 	{
 		.ctl_name	= NET_SCTP_ASSOCIATION_MAX_RETRANS,
@@ -110,7 +114,10 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_retrans_association,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &one,
+		.extra2		= &int_max
 	},
 	{
 		.ctl_name	= NET_SCTP_SNDBUF_POLICY,
@@ -118,7 +125,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_sndbuf_policy,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_RCVBUF_POLICY,
@@ -126,7 +134,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_rcvbuf_policy,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_PATH_MAX_RETRANS,
@@ -134,7 +143,10 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_retrans_path,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &one,
+		.extra2		= &int_max
 	},
 	{
 		.ctl_name	= NET_SCTP_MAX_INIT_RETRANSMITS,
@@ -142,18 +154,21 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_retrans_init,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &one,
+		.extra2		= &int_max
 	},
 	{
 		.ctl_name	= NET_SCTP_HB_INTERVAL,
 		.procname	= "hb_interval",
 		.data		= &sctp_hb_interval,
-		.maxlen		= sizeof(long),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
-		.strategy	= &sctp_sysctl_jiffies_ms,
-		.extra1         = &rto_timer_min,
-		.extra2         = &rto_timer_max
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1         = &one,
+		.extra2         = &timer_max
 	},
 	{
 		.ctl_name	= NET_SCTP_PRESERVE_ENABLE,
@@ -161,23 +176,26 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_cookie_preserve_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_RTO_ALPHA,
 		.procname	= "rto_alpha_exp_divisor",
 		.data		= &sctp_rto_alpha,
 		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.mode		= 0444,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_RTO_BETA,
 		.procname	= "rto_beta_exp_divisor",
 		.data		= &sctp_rto_beta,
 		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.mode		= 0444,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_ADDIP_ENABLE,
@@ -185,7 +203,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_addip_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_PRSCTP_ENABLE,
@@ -193,7 +212,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_prsctp_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_SACK_TIMEOUT,
@@ -201,8 +221,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_sack_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
-		.strategy	= &sctp_sysctl_jiffies_ms,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
 		.extra1         = &sack_timer_min,
 		.extra2         = &sack_timer_max,
 	},
@@ -242,37 +262,3 @@ void sctp_sysctl_unregister(void)
 {
 	unregister_sysctl_table(sctp_sysctl_header);
 }
-
-/* Strategy function to convert jiffies to milliseconds.  */
-static int sctp_sysctl_jiffies_ms(ctl_table *table, int __user *name, int nlen,
-		void __user *oldval, size_t __user *oldlenp,
-		void __user *newval, size_t newlen, void **context) {
-
-	if (oldval) {
-		size_t olen;
-
-		if (oldlenp) {
-			if (get_user(olen, oldlenp))
-				return -EFAULT;
-
-			if (olen != sizeof (int))
-				return -EINVAL;
-		}
-		if (put_user((*(int *)(table->data) * 1000) / HZ,
-			(int __user *)oldval) ||
-		    (oldlenp && put_user(sizeof (int), oldlenp)))
-			return -EFAULT;
-	}
-	if (newval && newlen) {
-		int new;
-
-		if (newlen != sizeof (int))
-			return -EINVAL;
-
-		if (get_user(new, (int __user *)newval))
-			return -EFAULT;
-
-		*(int *)(table->data) = (new * HZ) / 1000;
-	}
-	return 1;
-}
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 2763aa9..3e5936a 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -75,7 +75,7 @@ static struct sctp_transport *sctp_trans
 	 * parameter 'RTO.Initial'.
 	 */
 	peer->rtt = 0;
-	peer->rto = sctp_rto_initial;
+	peer->rto = msecs_to_jiffies(sctp_rto_initial);
 	peer->rttvar = 0;
 	peer->srtt = 0;
 	peer->rto_pending = 0;


