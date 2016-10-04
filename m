From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 1/8] net/ncsi: Avoid unused-value build warning from ia64-linux-gcc
Date: Tue,  4 Oct 2016 11:25:47 +1100
Message-ID: <1475540754-31169-2-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53275 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752109AbcJDAZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:29 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940N1Bf094247
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:28 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25uy9kmy65-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:28 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:25 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 28F2D2CE805C
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:22 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PMRX60555402
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:22 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PLp6031434
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:21 +1100
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xchg() is used to set NCSI channel's state in order for consistent
access to the state. xchg()'s return value should be used. Otherwise,
one build warning will be raised (with -Wunused-value) as below message
indicates. It is reported by ia64-linux-gcc (GCC) 4.9.0.

 net/ncsi/ncsi-manage.c: In function 'ncsi_channel_monitor':
 arch/ia64/include/uapi/asm/cmpxchg.h:56:2: warning: value computed is \
 not used [-Wunused-value]
  ((__typeof__(*(ptr))) __xchg((unsigned long) (x), (ptr), sizeof(*(ptr))))
   ^
 net/ncsi/ncsi-manage.c:202:3: note: in expansion of macro 'xchg'
  xchg(&nc->state, NCSI_CHANNEL_INACTIVE);

This removes the atomic access to NCSI channel's state avoid the above
build warning. We have to hold the channel's lock when its state is readed
or updated. No functional changes introduced.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Reviewed-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/ncsi-aen.c    | 37 +++++++++++++++++++-------
 net/ncsi/ncsi-manage.c | 71 ++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 81 insertions(+), 27 deletions(-)

diff --git a/net/ncsi/ncsi-aen.c b/net/ncsi/ncsi-aen.c
index d463468..b41a661 100644
--- a/net/ncsi/ncsi-aen.c
+++ b/net/ncsi/ncsi-aen.c
@@ -53,7 +53,9 @@ static int ncsi_aen_handler_lsc(struct ncsi_dev_priv *ndp,
 	struct ncsi_aen_lsc_pkt *lsc;
 	struct ncsi_channel *nc;
 	struct ncsi_channel_mode *ncm;
-	unsigned long old_data;
+	bool chained;
+	int state;
+	unsigned long old_data, data;
 	unsigned long flags;
 
 	/* Find the NCSI channel */
@@ -62,20 +64,27 @@ static int ncsi_aen_handler_lsc(struct ncsi_dev_priv *ndp,
 		return -ENODEV;
 
 	/* Update the link status */
-	ncm = &nc->modes[NCSI_MODE_LINK];
 	lsc = (struct ncsi_aen_lsc_pkt *)h;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	ncm = &nc->modes[NCSI_MODE_LINK];
 	old_data = ncm->data[2];
-	ncm->data[2] = ntohl(lsc->status);
+	data = ntohl(lsc->status);
+	ncm->data[2] = data;
 	ncm->data[4] = ntohl(lsc->oem_status);
-	if (!((old_data ^ ncm->data[2]) & 0x1) ||
-	    !list_empty(&nc->link))
+
+	chained = !list_empty(&nc->link);
+	state = nc->state;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	if (!((old_data ^ data) & 0x1) || chained)
 		return 0;
-	if (!(nc->state == NCSI_CHANNEL_INACTIVE && (ncm->data[2] & 0x1)) &&
-	    !(nc->state == NCSI_CHANNEL_ACTIVE && !(ncm->data[2] & 0x1)))
+	if (!(state == NCSI_CHANNEL_INACTIVE && (data & 0x1)) &&
+	    !(state == NCSI_CHANNEL_ACTIVE && !(data & 0x1)))
 		return 0;
 
 	if (!(ndp->flags & NCSI_DEV_HWA) &&
-	    nc->state == NCSI_CHANNEL_ACTIVE)
+	    state == NCSI_CHANNEL_ACTIVE)
 		ndp->flags |= NCSI_DEV_RESHUFFLE;
 
 	ncsi_stop_channel_monitor(nc);
@@ -97,13 +106,21 @@ static int ncsi_aen_handler_cr(struct ncsi_dev_priv *ndp,
 	if (!nc)
 		return -ENODEV;
 
+	spin_lock_irqsave(&nc->lock, flags);
 	if (!list_empty(&nc->link) ||
-	    nc->state != NCSI_CHANNEL_ACTIVE)
+	    nc->state != NCSI_CHANNEL_ACTIVE) {
+		spin_unlock_irqrestore(&nc->lock, flags);
 		return 0;
+	}
+	spin_unlock_irqrestore(&nc->lock, flags);
 
 	ncsi_stop_channel_monitor(nc);
+	spin_lock_irqsave(&nc->lock, flags);
+	nc->state = NCSI_CHANNEL_INVISIBLE;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
 	spin_lock_irqsave(&ndp->lock, flags);
-	xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+	nc->state = NCSI_CHANNEL_INACTIVE;
 	list_add_tail_rcu(&nc->link, &ndp->channel_queue);
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index ef017b8..a26ce51 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -132,6 +132,7 @@ static void ncsi_report_link(struct ncsi_dev_priv *ndp, bool force_down)
 	struct ncsi_dev *nd = &ndp->ndev;
 	struct ncsi_package *np;
 	struct ncsi_channel *nc;
+	unsigned long flags;
 
 	nd->state = ncsi_dev_state_functional;
 	if (force_down) {
@@ -142,14 +143,21 @@ static void ncsi_report_link(struct ncsi_dev_priv *ndp, bool force_down)
 	nd->link_up = 0;
 	NCSI_FOR_EACH_PACKAGE(ndp, np) {
 		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			spin_lock_irqsave(&nc->lock, flags);
+
 			if (!list_empty(&nc->link) ||
-			    nc->state != NCSI_CHANNEL_ACTIVE)
+			    nc->state != NCSI_CHANNEL_ACTIVE) {
+				spin_unlock_irqrestore(&nc->lock, flags);
 				continue;
+			}
 
 			if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1) {
+				spin_unlock_irqrestore(&nc->lock, flags);
 				nd->link_up = 1;
 				goto report;
 			}
+
+			spin_unlock_irqrestore(&nc->lock, flags);
 		}
 	}
 
@@ -163,20 +171,22 @@ static void ncsi_channel_monitor(unsigned long data)
 	struct ncsi_package *np = nc->package;
 	struct ncsi_dev_priv *ndp = np->ndp;
 	struct ncsi_cmd_arg nca;
-	bool enabled;
+	bool enabled, chained;
 	unsigned int timeout;
 	unsigned long flags;
-	int ret;
+	int state, ret;
 
 	spin_lock_irqsave(&nc->lock, flags);
+	state = nc->state;
+	chained = !list_empty(&nc->link);
 	timeout = nc->timeout;
 	enabled = nc->enabled;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
-	if (!enabled || !list_empty(&nc->link))
+	if (!enabled || chained)
 		return;
-	if (nc->state != NCSI_CHANNEL_INACTIVE &&
-	    nc->state != NCSI_CHANNEL_ACTIVE)
+	if (state != NCSI_CHANNEL_INACTIVE &&
+	    state != NCSI_CHANNEL_ACTIVE)
 		return;
 
 	if (!(timeout % 2)) {
@@ -195,11 +205,15 @@ static void ncsi_channel_monitor(unsigned long data)
 
 	if (timeout + 1 >= 3) {
 		if (!(ndp->flags & NCSI_DEV_HWA) &&
-		    nc->state == NCSI_CHANNEL_ACTIVE)
+		    state == NCSI_CHANNEL_ACTIVE)
 			ncsi_report_link(ndp, true);
 
+		spin_lock_irqsave(&nc->lock, flags);
+		nc->state = NCSI_CHANNEL_INVISIBLE;
+		spin_unlock_irqrestore(&nc->lock, flags);
+
 		spin_lock_irqsave(&ndp->lock, flags);
-		xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+		nc->state = NCSI_CHANNEL_INACTIVE;
 		list_add_tail_rcu(&nc->link, &ndp->channel_queue);
 		spin_unlock_irqrestore(&ndp->lock, flags);
 		ncsi_process_next_channel(ndp);
@@ -508,6 +522,7 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 	struct ncsi_package *np = ndp->active_package;
 	struct ncsi_channel *nc = ndp->active_channel;
 	struct ncsi_cmd_arg nca;
+	unsigned long flags;
 	int ret;
 
 	nca.ndp = ndp;
@@ -556,7 +571,9 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 
 		break;
 	case ncsi_dev_state_suspend_done:
-		xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+		spin_lock_irqsave(&nc->lock, flags);
+		nc->state = NCSI_CHANNEL_INACTIVE;
+		spin_unlock_irqrestore(&nc->lock, flags);
 		ncsi_process_next_channel(ndp);
 
 		break;
@@ -574,6 +591,7 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 	struct ncsi_channel *nc = ndp->active_channel;
 	struct ncsi_cmd_arg nca;
 	unsigned char index;
+	unsigned long flags;
 	int ret;
 
 	nca.ndp = ndp;
@@ -675,10 +693,12 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 			goto error;
 		break;
 	case ncsi_dev_state_config_done:
+		spin_lock_irqsave(&nc->lock, flags);
 		if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1)
-			xchg(&nc->state, NCSI_CHANNEL_ACTIVE);
+			nc->state = NCSI_CHANNEL_ACTIVE;
 		else
-			xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
+			nc->state = NCSI_CHANNEL_INACTIVE;
+		spin_unlock_irqrestore(&nc->lock, flags);
 
 		ncsi_start_channel_monitor(nc);
 		ncsi_process_next_channel(ndp);
@@ -707,18 +727,25 @@ static int ncsi_choose_active_channel(struct ncsi_dev_priv *ndp)
 	found = NULL;
 	NCSI_FOR_EACH_PACKAGE(ndp, np) {
 		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			spin_lock_irqsave(&nc->lock, flags);
+
 			if (!list_empty(&nc->link) ||
-			    nc->state != NCSI_CHANNEL_INACTIVE)
+			    nc->state != NCSI_CHANNEL_INACTIVE) {
+				spin_unlock_irqrestore(&nc->lock, flags);
 				continue;
+			}
 
 			if (!found)
 				found = nc;
 
 			ncm = &nc->modes[NCSI_MODE_LINK];
 			if (ncm->data[2] & 0x1) {
+				spin_unlock_irqrestore(&nc->lock, flags);
 				found = nc;
 				goto out;
 			}
+
+			spin_unlock_irqrestore(&nc->lock, flags);
 		}
 	}
 
@@ -987,11 +1014,14 @@ int ncsi_process_next_channel(struct ncsi_dev_priv *ndp)
 		goto out;
 	}
 
-	old_state = xchg(&nc->state, NCSI_CHANNEL_INVISIBLE);
 	list_del_init(&nc->link);
-
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
+	spin_lock_irqsave(&nc->lock, flags);
+	old_state = nc->state;
+	nc->state = NCSI_CHANNEL_INVISIBLE;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
 	ndp->active_channel = nc;
 	ndp->active_package = nc->package;
 
@@ -1006,7 +1036,7 @@ int ncsi_process_next_channel(struct ncsi_dev_priv *ndp)
 		break;
 	default:
 		netdev_err(ndp->ndev.dev, "Invalid state 0x%x on %d:%d\n",
-			   nc->state, nc->package->id, nc->id);
+			   old_state, nc->package->id, nc->id);
 		ncsi_report_link(ndp, false);
 		return -EINVAL;
 	}
@@ -1151,6 +1181,8 @@ int ncsi_start_dev(struct ncsi_dev *nd)
 	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
 	struct ncsi_package *np;
 	struct ncsi_channel *nc;
+	unsigned long flags;
+	bool chained;
 	int old_state, ret;
 
 	if (nd->state != ncsi_dev_state_registered &&
@@ -1166,8 +1198,13 @@ int ncsi_start_dev(struct ncsi_dev *nd)
 	/* Reset channel's state and start over */
 	NCSI_FOR_EACH_PACKAGE(ndp, np) {
 		NCSI_FOR_EACH_CHANNEL(np, nc) {
-			old_state = xchg(&nc->state, NCSI_CHANNEL_INACTIVE);
-			WARN_ON_ONCE(!list_empty(&nc->link) ||
+			spin_lock_irqsave(&nc->lock, flags);
+			chained = !list_empty(&nc->link);
+			old_state = nc->state;
+			nc->state = NCSI_CHANNEL_INACTIVE;
+			spin_unlock_irqrestore(&nc->lock, flags);
+
+			WARN_ON_ONCE(chained ||
 				     old_state == NCSI_CHANNEL_INVISIBLE);
 		}
 	}
-- 
2.1.0
