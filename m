From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: fix permissions for rto_alpha and rto_beta knobs
Date: Sun, 15 Jun 2014 00:59:14 +0200
Message-ID: <1402786754-16807-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbaFNW7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2014 18:59:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3fd091e73b81 ("[SCTP]: Remove multiple levels of msecs
to jiffies conversions.") has silently changed permissions for
rto_alpha and rto_beta knobs from 0644 to 0444. The purpose of
this was to discourage users from tweaking rto_alpha and
rto_beta knobs in production environments since they are key
to correctly compute rtt/srtt.

RFC4960 under section 6.3.1. RTO Calculation says regarding
rto_alpha and rto_beta under rule C3 and C4:

  [...]
  C3)  When a new RTT measurement R' is made, set

       RTTVAR <- (1 - RTO.Beta) * RTTVAR + RTO.Beta * |SRTT - R'|

       and

       SRTT <- (1 - RTO.Alpha) * SRTT + RTO.Alpha * R'

       Note: The value of SRTT used in the update to RTTVAR
       is its value before updating SRTT itself using the
       second assignment. After the computation, update
       RTO <- SRTT + 4 * RTTVAR.

  C4)  When data is in flight and when allowed by rule C5
       below, a new RTT measurement MUST be made each round
       trip. Furthermore, new RTT measurements SHOULD be
       made no more than once per round trip for a given
       destination transport address. There are two reasons
       for this recommendation: First, it appears that
       measuring more frequently often does not in practice
       yield any significant benefit [ALLMAN99]; second,
       if measurements are made more often, then the values
       of RTO.Alpha and RTO.Beta in rule C3 above should be
       adjusted so that SRTT and RTTVAR still adjust to
       changes at roughly the same rate (in terms of how many
       round trips it takes them to reflect new values) as
       they would if making only one measurement per
       round-trip and using RTO.Alpha and RTO.Beta as given
       in rule C3. However, the exact nature of these
       adjustments remains a research issue.
  [...]

While it is discouraged to adjust rto_alpha and rto_beta
and not further specified how to adjust them, the RFC also
doesn't explicitly forbid it, but rather gives a RECOMMENDED
default value (rto_alpha=3, rto_beta=2). We have a couple
of users relying on the old permissions before they got
changed. That said, if someone really has the urge to adjust
them, we could allow it with a warning in the log.

Fixes: 3fd091e73b81 ("[SCTP]: Remove multiple levels of msecs to jiffies conversions.")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
---
 net/sctp/sysctl.c | 32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 7e5eb75..dcb1959 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -34,6 +34,8 @@
  *    Sridhar Samudrala     <sri@us.ibm.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/sctp/structs.h>
 #include <net/sctp/sctp.h>
 #include <linux/sysctl.h>
@@ -46,6 +48,11 @@ static int sack_timer_min = 1;
 static int sack_timer_max = 500;
 static int addr_scope_max = 3; /* check sctp_scope_policy_t in include/net/sctp/constants.h for max entries */
 static int rwnd_scale_max = 16;
+static int rto_alpha_min = 0;
+static int rto_beta_min = 0;
+static int rto_alpha_max = 1000;
+static int rto_beta_max = 1000;
+
 static unsigned long max_autoclose_min = 0;
 static unsigned long max_autoclose_max =
 	(MAX_SCHEDULE_TIMEOUT / HZ > UINT_MAX)
@@ -64,6 +71,9 @@ static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
 static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp,
 				loff_t *ppos);
+static int proc_sctp_do_alpha_beta(struct ctl_table *ctl, int write,
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos);
 static int proc_sctp_do_auth(struct ctl_table *ctl, int write,
 			     void __user *buffer, size_t *lenp,
 			     loff_t *ppos);
@@ -126,15 +136,19 @@ static struct ctl_table sctp_net_table[] = {
 		.procname	= "rto_alpha_exp_divisor",
 		.data		= &init_net.sctp.rto_alpha,
 		.maxlen		= sizeof(int),
-		.mode		= 0444,
-		.proc_handler	= proc_dointvec,
+		.mode		= 0644,
+		.proc_handler	= proc_sctp_do_alpha_beta,
+		.extra1		= &rto_alpha_min,
+		.extra2		= &rto_alpha_max,
 	},
 	{
 		.procname	= "rto_beta_exp_divisor",
 		.data		= &init_net.sctp.rto_beta,
 		.maxlen		= sizeof(int),
-		.mode		= 0444,
-		.proc_handler	= proc_dointvec,
+		.mode		= 0644,
+		.proc_handler	= proc_sctp_do_alpha_beta,
+		.extra1		= &rto_beta_min,
+		.extra2		= &rto_beta_max,
 	},
 	{
 		.procname	= "max_burst",
@@ -403,6 +417,16 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static int proc_sctp_do_alpha_beta(struct ctl_table *ctl, int write,
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos)
+{
+	pr_warn_once("Changing rto_alpha or rto_beta may lead to "
+		     "suboptimal rtt/srtt estimations!\n");
+
+	return proc_dointvec_minmax(ctl, write, buffer, lenp, ppos);
+}
+
 static int proc_sctp_do_auth(struct ctl_table *ctl, int write,
 			     void __user *buffer, size_t *lenp,
 			     loff_t *ppos)
-- 
1.7.11.7
