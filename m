From: akpm@linux-foundation.org
Subject: [patch 12/21] drivers/net/arcnet/arcnet.c: use time_* macros
Date: Fri, 28 Mar 2008 14:41:24 -0700
Message-ID: <200803282141.m2SLfPNn011834@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	caglar@pardus.org.tr
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55107 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756218AbYC1VmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:42:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: S.Caglar Onur <caglar@pardus.org.tr>

The functions time_before, time_before_eq, time_after, and time_after_eq are
more robust for comparing jiffies against other values.

So use the time_after() macro, defined in linux/jiffies.h, which deals with
wrapping correctly.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: S.Caglar Onur <caglar@pardus.org.tr>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/arcnet/arcnet.c |    5 +++--
 include/linux/arcdevice.h   |    4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff -puN drivers/net/arcnet/arcnet.c~drivers-net-arcnet-arcnetc-use-time_-macros drivers/net/arcnet/arcnet.c
--- a/drivers/net/arcnet/arcnet.c~drivers-net-arcnet-arcnetc-use-time_-macros
+++ a/drivers/net/arcnet/arcnet.c
@@ -940,7 +940,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
 
 			/* is the RECON info empty or old? */
 			if (!lp->first_recon || !lp->last_recon ||
-			    jiffies - lp->last_recon > HZ * 10) {
+			    time_after(jiffies, lp->last_recon + HZ * 10)) {
 				if (lp->network_down)
 					BUGMSG(D_NORMAL, "reconfiguration detected: cabling restored?\n");
 				lp->first_recon = lp->last_recon = jiffies;
@@ -974,7 +974,8 @@ irqreturn_t arcnet_interrupt(int irq, vo
 					lp->num_recons = 1;
 				}
 			}
-		} else if (lp->network_down && jiffies - lp->last_recon > HZ * 10) {
+		} else if (lp->network_down &&
+				time_after(jiffies, lp->last_recon + HZ * 10)) {
 			if (lp->network_down)
 				BUGMSG(D_NORMAL, "cabling restored?\n");
 			lp->first_recon = lp->last_recon = 0;
diff -puN include/linux/arcdevice.h~drivers-net-arcnet-arcnetc-use-time_-macros include/linux/arcdevice.h
--- a/include/linux/arcdevice.h~drivers-net-arcnet-arcnetc-use-time_-macros
+++ a/include/linux/arcdevice.h
@@ -283,8 +283,8 @@ struct arcnet_local {
 	int next_buf, first_free_buf;
 
 	/* network "reconfiguration" handling */
-	time_t first_recon,	/* time of "first" RECON message to count */
-		last_recon;	/* time of most recent RECON */
+	unsigned long first_recon; /* time of "first" RECON message to count */
+	unsigned long last_recon;  /* time of most recent RECON */
 	int num_recons;		/* number of RECONs between first and last. */
 	bool network_down;	/* do we think the network is down? */
 
_
