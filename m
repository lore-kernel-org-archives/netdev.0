From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v3] sctp: fix incorrect overflow check on autoclose
Date: Fri, 16 Dec 2011 17:44:15 -0500
Message-ID: <4EEBC9BF.7020506@gmail.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58800 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760869Ab1LPWoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 17:44:20 -0500
In-Reply-To: <1323393883-3759-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8ffd3208 voids the previous patches f6778aab and 810c0719 for
limiting the autoclose value.  If userspace passes in -1 on 32-bit
platform, the overflow check didn't work and autoclose would be set
to 0xffffffff.

This patch defines a max_autoclose (in seconds) for limiting the value
and exposes it through sysctl, with the following intentions.

1) Avoid overflowing autoclose * HZ.

2) Keep the default autoclose bound consistent across 32- and 64-bit
   platforms (INT_MAX / HZ in this patch).

3) Keep the autoclose value consistent between setsockopt() and
   getsockopt() calls.

Suggested-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 include/net/sctp/structs.h |    4 ++++
 net/sctp/associola.c       |    2 +-
 net/sctp/protocol.c        |    3 +++
 net/sctp/socket.c          |    2 --
 net/sctp/sysctl.c          |   13 +++++++++++++
 5 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e90e7a9..a15432da 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -241,6 +241,9 @@ extern struct sctp_globals {
 	 * bits is an indicator of when to send and window update SACK.
 	 */
 	int rwnd_update_shift;
+
+	/* Threshold for autoclose timeout, in seconds. */
+	unsigned long max_autoclose;
 } sctp_globals;
 
 #define sctp_rto_initial		(sctp_globals.rto_initial)
@@ -281,6 +284,7 @@ extern struct sctp_globals {
 #define sctp_auth_enable		(sctp_globals.auth_enable)
 #define sctp_checksum_disable		(sctp_globals.checksum_disable)
 #define sctp_rwnd_upd_shift		(sctp_globals.rwnd_update_shift)
+#define sctp_max_autoclose		(sctp_globals.max_autoclose)
 
 /* SCTP Socket type: UDP or TCP style. */
 typedef enum {
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 152b5b3..acd2edb 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -173,7 +173,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_HEARTBEAT] = 0;
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_SACK] = asoc->sackdelay;
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE] =
-		(unsigned long)sp->autoclose * HZ;
+		min_t(unsigned long, sp->autoclose, sctp_max_autoclose) * HZ;
 
 	/* Initializes the timers */
 	for (i = SCTP_EVENT_TIMEOUT_NONE; i < SCTP_NUM_TIMEOUT_TYPES; ++i)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 61b9fca..6f6ad86 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1285,6 +1285,9 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_max_instreams    		= SCTP_DEFAULT_INSTREAMS;
 	sctp_max_outstreams   		= SCTP_DEFAULT_OUTSTREAMS;
 
+	/* Initialize maximum autoclose timeout. */
+	sctp_max_autoclose		= INT_MAX / HZ;
+
 	/* Initialize handle used for association ids. */
 	idr_init(&sctp_assocs_id);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 13bf5fc..54a7cd2 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2200,8 +2200,6 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
 		return -EINVAL;
 	if (copy_from_user(&sp->autoclose, optval, optlen))
 		return -EFAULT;
-	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
-	sp->autoclose = min_t(long, sp->autoclose, MAX_SCHEDULE_TIMEOUT / HZ);
 
 	return 0;
 }
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 6b39529..60ffbd0 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -53,6 +53,10 @@ static int sack_timer_min = 1;
 static int sack_timer_max = 500;
 static int addr_scope_max = 3; /* check sctp_scope_policy_t in include/net/sctp/constants.h for max entries */
 static int rwnd_scale_max = 16;
+static unsigned long max_autoclose_min = 0;
+static unsigned long max_autoclose_max =
+	(MAX_SCHEDULE_TIMEOUT / HZ > UINT_MAX)
+	? UINT_MAX : MAX_SCHEDULE_TIMEOUT / HZ;
 
 extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
@@ -258,6 +262,15 @@ static ctl_table sctp_table[] = {
 		.extra1		= &one,
 		.extra2		= &rwnd_scale_max,
 	},
+	{
+		.procname	= "max_autoclose",
+		.data		= &sctp_max_autoclose,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= &proc_doulongvec_minmax,
+		.extra1		= &max_autoclose_min,
+		.extra2		= &max_autoclose_max,
+	},
 
 	{ /* sentinel */ }
 };
-- 
1.7.5.4
