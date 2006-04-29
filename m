From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH 1/3] Eleminate HZ from AX.25 kernel interfaces
Date: Sat, 29 Apr 2006 15:12:44 +0100
Message-ID: <20060429141244.GA2407@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:26249 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750792AbWD2SsU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 14:48:20 -0400
Received: from localhost.localdomain ([127.0.0.1]:59333 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133567AbWD2SsT (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Sat, 29 Apr 2006 19:48:19 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert all AX.25 sysctl time values from jiffies to ms as units.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

--

 include/net/ax25.h         |   10 +++---
 net/ax25/af_ax25.c         |   73 +++++++++++++++++++++++++--------------------
 net/ax25/ax25_ds_timer.c   |    3 +
 net/ax25/sysctl_net_ax25.c |   10 +++---
 4 files changed, 53 insertions(+), 43 deletions(-)

Index: linux-net.git/include/net/ax25.h
===================================================================
--- linux-net.git.orig/include/net/ax25.h	2006-04-29 11:32:14.000000000 +0100
+++ linux-net.git/include/net/ax25.h	2006-04-29 11:33:43.000000000 +0100
@@ -145,14 +145,14 @@ enum {
 #define	AX25_DEF_CONMODE	2			/* Connected mode allowed */
 #define	AX25_DEF_WINDOW		2			/* Window=2 */
 #define	AX25_DEF_EWINDOW	32			/* Module-128 Window=32 */
-#define	AX25_DEF_T1		(10 * HZ)		/* T1=10s */
-#define	AX25_DEF_T2		(3 * HZ)		/* T2=3s  */
-#define	AX25_DEF_T3		(300 * HZ)		/* T3=300s */
+#define	AX25_DEF_T1		10000			/* T1=10s */
+#define	AX25_DEF_T2		3000			/* T2=3s  */
+#define	AX25_DEF_T3		300000			/* T3=300s */
 #define	AX25_DEF_N2		10			/* N2=10 */
-#define AX25_DEF_IDLE		(0 * 60 * HZ)		/* Idle=None */
+#define AX25_DEF_IDLE		0			/* Idle=None */
 #define AX25_DEF_PACLEN		256			/* Paclen=256 */
 #define	AX25_DEF_PROTOCOL	AX25_PROTO_STD_SIMPLEX	/* Standard AX.25 */
-#define AX25_DEF_DS_TIMEOUT	(3 * 60 * HZ)		/* DAMA timeout 3 minutes */
+#define AX25_DEF_DS_TIMEOUT	180000			/* DAMA timeout 3 minutes */
 
 typedef struct ax25_uid_assoc {
 	struct hlist_node	uid_node;
Index: linux-net.git/net/ax25/af_ax25.c
===================================================================
--- linux-net.git.orig/net/ax25/af_ax25.c	2006-04-29 11:32:14.000000000 +0100
+++ linux-net.git/net/ax25/af_ax25.c	2006-04-29 11:33:43.000000000 +0100
@@ -426,6 +426,26 @@ static int ax25_ctl_ioctl(const unsigned
 	return 0;
 }
 
+static void ax25_fillin_cb_from_dev(ax25_cb *ax25, ax25_dev *ax25_dev)
+{
+	ax25->rtt     = msecs_to_jiffies(ax25_dev->values[AX25_VALUES_T1]) / 2;
+	ax25->t1      = msecs_to_jiffies(ax25_dev->values[AX25_VALUES_T1]);
+	ax25->t2      = msecs_to_jiffies(ax25_dev->values[AX25_VALUES_T2]);
+	ax25->t3      = msecs_to_jiffies(ax25_dev->values[AX25_VALUES_T3]);
+	ax25->n2      = ax25_dev->values[AX25_VALUES_N2];
+	ax25->paclen  = ax25_dev->values[AX25_VALUES_PACLEN];
+	ax25->idle    = msecs_to_jiffies(ax25_dev->values[AX25_VALUES_IDLE]);
+	ax25->backoff = ax25_dev->values[AX25_VALUES_BACKOFF];
+
+	if (ax25_dev->values[AX25_VALUES_AXDEFMODE]) {
+		ax25->modulus = AX25_EMODULUS;
+		ax25->window  = ax25_dev->values[AX25_VALUES_EWINDOW];
+	} else {
+		ax25->modulus = AX25_MODULUS;
+		ax25->window  = ax25_dev->values[AX25_VALUES_WINDOW];
+	}
+}
+
 /*
  *	Fill in a created AX.25 created control block with the default
  *	values for a particular device.
@@ -435,39 +455,28 @@ void ax25_fillin_cb(ax25_cb *ax25, ax25_
 	ax25->ax25_dev = ax25_dev;
 
 	if (ax25->ax25_dev != NULL) {
-		ax25->rtt     = ax25_dev->values[AX25_VALUES_T1] / 2;
-		ax25->t1      = ax25_dev->values[AX25_VALUES_T1];
-		ax25->t2      = ax25_dev->values[AX25_VALUES_T2];
-		ax25->t3      = ax25_dev->values[AX25_VALUES_T3];
-		ax25->n2      = ax25_dev->values[AX25_VALUES_N2];
-		ax25->paclen  = ax25_dev->values[AX25_VALUES_PACLEN];
-		ax25->idle    = ax25_dev->values[AX25_VALUES_IDLE];
-		ax25->backoff = ax25_dev->values[AX25_VALUES_BACKOFF];
-
-		if (ax25_dev->values[AX25_VALUES_AXDEFMODE]) {
-			ax25->modulus = AX25_EMODULUS;
-			ax25->window  = ax25_dev->values[AX25_VALUES_EWINDOW];
-		} else {
-			ax25->modulus = AX25_MODULUS;
-			ax25->window  = ax25_dev->values[AX25_VALUES_WINDOW];
-		}
+		ax25_fillin_cb_from_dev(ax25, ax25_dev);
+		return;
+	}
+
+	/*
+	 * No device, use kernel / AX.25 spec default values
+	 */
+	ax25->rtt     = msecs_to_jiffies(AX25_DEF_T1) / 2;
+	ax25->t1      = msecs_to_jiffies(AX25_DEF_T1);
+	ax25->t2      = msecs_to_jiffies(AX25_DEF_T2);
+	ax25->t3      = msecs_to_jiffies(AX25_DEF_T3);
+	ax25->n2      = AX25_DEF_N2;
+	ax25->paclen  = AX25_DEF_PACLEN;
+	ax25->idle    = msecs_to_jiffies(AX25_DEF_IDLE);
+	ax25->backoff = AX25_DEF_BACKOFF;
+
+	if (AX25_DEF_AXDEFMODE) {
+		ax25->modulus = AX25_EMODULUS;
+		ax25->window  = AX25_DEF_EWINDOW;
 	} else {
-		ax25->rtt     = AX25_DEF_T1 / 2;
-		ax25->t1      = AX25_DEF_T1;
-		ax25->t2      = AX25_DEF_T2;
-		ax25->t3      = AX25_DEF_T3;
-		ax25->n2      = AX25_DEF_N2;
-		ax25->paclen  = AX25_DEF_PACLEN;
-		ax25->idle    = AX25_DEF_IDLE;
-		ax25->backoff = AX25_DEF_BACKOFF;
-
-		if (AX25_DEF_AXDEFMODE) {
-			ax25->modulus = AX25_EMODULUS;
-			ax25->window  = AX25_DEF_EWINDOW;
-		} else {
-			ax25->modulus = AX25_MODULUS;
-			ax25->window  = AX25_DEF_WINDOW;
-		}
+		ax25->modulus = AX25_MODULUS;
+		ax25->window  = AX25_DEF_WINDOW;
 	}
 }
 
Index: linux-net.git/net/ax25/ax25_ds_timer.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_ds_timer.c	2006-04-29 01:43:48.000000000 +0100
+++ linux-net.git/net/ax25/ax25_ds_timer.c	2006-04-29 11:33:43.000000000 +0100
@@ -61,7 +61,8 @@ void ax25_ds_set_timer(ax25_dev *ax25_de
 		return;
 
 	del_timer(&ax25_dev->dama.slave_timer);
-	ax25_dev->dama.slave_timeout = ax25_dev->values[AX25_VALUES_DS_TIMEOUT] / 10;
+	ax25_dev->dama.slave_timeout =
+		msecs_to_jiffies(ax25_dev->values[AX25_VALUES_DS_TIMEOUT]) / 10;
 	ax25_ds_add_timer(ax25_dev);
 }
 
Index: linux-net.git/net/ax25/sysctl_net_ax25.c
===================================================================
--- linux-net.git.orig/net/ax25/sysctl_net_ax25.c	2006-04-29 01:54:20.000000000 +0100
+++ linux-net.git/net/ax25/sysctl_net_ax25.c	2006-04-29 11:35:27.000000000 +0100
@@ -18,14 +18,14 @@ static int min_backoff[1],		max_backoff[
 static int min_conmode[1],		max_conmode[] = {2};
 static int min_window[] = {1},		max_window[] = {7};
 static int min_ewindow[] = {1},		max_ewindow[] = {63};
-static int min_t1[] = {1},		max_t1[] = {30 * HZ};
-static int min_t2[] = {1},		max_t2[] = {20 * HZ};
-static int min_t3[1],   		max_t3[] = {3600 * HZ};
-static int min_idle[1],  		max_idle[] = {65535 * HZ};
+static int min_t1[] = {1},		max_t1[] = {30000};
+static int min_t2[] = {1},		max_t2[] = {20000};
+static int min_t3[1],			max_t3[] = {3600000};
+static int min_idle[1],			max_idle[] = {65535000};
 static int min_n2[] = {1},		max_n2[] = {31};
 static int min_paclen[] = {1},		max_paclen[] = {512};
 static int min_proto[1],		max_proto[] = { AX25_PROTO_MAX };
-static int min_ds_timeout[1],   	max_ds_timeout[] = {65535 * HZ};
+static int min_ds_timeout[1],		max_ds_timeout[] = {65535000};
 
 static struct ctl_table_header *ax25_table_header;
 
