From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 3/3] Eleminate HZ from ROSE kernel interfaces
Date: Sat, 29 Apr 2006 15:19:24 +0100
Message-ID: <20060429141924.GA2941@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:26249 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750789AbWD2SsR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 14:48:17 -0400
Received: from localhost.localdomain ([127.0.0.1]:59333 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133564AbWD2SsQ (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Sat, 29 Apr 2006 19:48:16 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert all ROSE sysctl time values from jiffies to ms as units.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

--

 include/net/rose.h   |   14 +++++++-------
 net/rose/af_rose.c   |   10 +++++-----
 net/rose/rose_link.c |    6 ++++--
 3 files changed, 16 insertions(+), 14 deletions(-)

Index: linux-net.git/include/net/rose.h
===================================================================
--- linux-net.git.orig/include/net/rose.h	2006-04-29 01:43:47.000000000 +0100
+++ linux-net.git/include/net/rose.h	2006-04-29 11:37:34.000000000 +0100
@@ -49,14 +49,14 @@ enum {
 	ROSE_STATE_5			/* Deferred Call Acceptance */
 };
 
-#define ROSE_DEFAULT_T0			(180 * HZ)	/* Default T10 T20 value */
-#define ROSE_DEFAULT_T1			(200 * HZ)	/* Default T11 T21 value */
-#define ROSE_DEFAULT_T2			(180 * HZ)	/* Default T12 T22 value */
-#define	ROSE_DEFAULT_T3			(180 * HZ)	/* Default T13 T23 value */
-#define	ROSE_DEFAULT_HB			(5 * HZ)	/* Default Holdback value */
-#define	ROSE_DEFAULT_IDLE		(0 * 60 * HZ)	/* No Activity Timeout - none */
+#define ROSE_DEFAULT_T0			180000		/* Default T10 T20 value */
+#define ROSE_DEFAULT_T1			200000		/* Default T11 T21 value */
+#define ROSE_DEFAULT_T2			180000		/* Default T12 T22 value */
+#define	ROSE_DEFAULT_T3			180000		/* Default T13 T23 value */
+#define	ROSE_DEFAULT_HB			5000		/* Default Holdback value */
+#define	ROSE_DEFAULT_IDLE		0		/* No Activity Timeout - none */
 #define	ROSE_DEFAULT_ROUTING		1		/* Default routing flag */
-#define	ROSE_DEFAULT_FAIL_TIMEOUT	(120 * HZ)	/* Time until link considered usable */
+#define	ROSE_DEFAULT_FAIL_TIMEOUT	120000		/* Time until link considered usable */
 #define	ROSE_DEFAULT_MAXVC		50		/* Maximum number of VCs per neighbour */
 #define	ROSE_DEFAULT_WINDOW_SIZE	7		/* Default window size */
 
Index: linux-net.git/net/rose/af_rose.c
===================================================================
--- linux-net.git.orig/net/rose/af_rose.c	2006-04-29 01:54:21.000000000 +0100
+++ linux-net.git/net/rose/af_rose.c	2006-04-29 11:37:34.000000000 +0100
@@ -518,11 +518,11 @@ static int rose_create(struct socket *so
 	init_timer(&rose->timer);
 	init_timer(&rose->idletimer);
 
-	rose->t1   = sysctl_rose_call_request_timeout;
-	rose->t2   = sysctl_rose_reset_request_timeout;
-	rose->t3   = sysctl_rose_clear_request_timeout;
-	rose->hb   = sysctl_rose_ack_hold_back_timeout;
-	rose->idle = sysctl_rose_no_activity_timeout;
+	rose->t1   = msecs_to_jiffies(sysctl_rose_call_request_timeout);
+	rose->t2   = msecs_to_jiffies(sysctl_rose_reset_request_timeout);
+	rose->t3   = msecs_to_jiffies(sysctl_rose_clear_request_timeout);
+	rose->hb   = msecs_to_jiffies(sysctl_rose_ack_hold_back_timeout);
+	rose->idle = msecs_to_jiffies(sysctl_rose_no_activity_timeout);
 
 	rose->state = ROSE_STATE_0;
 
Index: linux-net.git/net/rose/rose_link.c
===================================================================
--- linux-net.git.orig/net/rose/rose_link.c	2006-04-29 01:43:47.000000000 +0100
+++ linux-net.git/net/rose/rose_link.c	2006-04-29 11:37:34.000000000 +0100
@@ -40,7 +40,8 @@ void rose_start_ftimer(struct rose_neigh
 
 	neigh->ftimer.data     = (unsigned long)neigh;
 	neigh->ftimer.function = &rose_ftimer_expiry;
-	neigh->ftimer.expires  = jiffies + sysctl_rose_link_fail_timeout;
+	neigh->ftimer.expires  =
+		jiffies + msecs_to_jiffies(sysctl_rose_link_fail_timeout);
 
 	add_timer(&neigh->ftimer);
 }
@@ -51,7 +52,8 @@ static void rose_start_t0timer(struct ro
 
 	neigh->t0timer.data     = (unsigned long)neigh;
 	neigh->t0timer.function = &rose_t0timer_expiry;
-	neigh->t0timer.expires  = jiffies + sysctl_rose_restart_request_timeout;
+	neigh->t0timer.expires  =
+		jiffies + msecs_to_jiffies(sysctl_rose_restart_request_timeout);
 
 	add_timer(&neigh->t0timer);
 }
