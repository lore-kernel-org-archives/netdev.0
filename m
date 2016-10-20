From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net 3/4] net/ncsi: Choose hot channel as active one if necessary
Date: Thu, 20 Oct 2016 11:45:51 +1100
Message-ID: <1476924352-31165-4-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49386 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932713AbcJTApL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 20:45:11 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9K0hrt1101528
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:11 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0b-001b2d01.pphosted.com with ESMTP id 266c365nue-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:10 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 20 Oct 2016 10:45:07 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6A33E3578052
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:05 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9K0j56F50135104
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:05 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9K0j41J006488
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:05 +1100
In-Reply-To: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was found on BCM5718 which has two NCSI channels in one
package: C0 and C1. C0 is in link-up state while C1 is in link-down
state. C0 is chosen as active channel until unplugging and plugging
C0's cable:  On unplugging C0's cable, LSC (Link State Change) AEN
packet received on C0 to report link-down event. After that, C1 is
chosen as active channel. LSC AEN for link-up event is lost on C0
when plugging C0's cable back. We lose the network even C0 is usable.

This resolves the issue by recording the (hot) channel that was ever
chosen as active one. The hot channel is chosen to be active one
if none of available channels in link-up state. With this, C0 is still
the active one after unplugging C0's cable. LSC AEN packet received
on C0 when plugging its cable back.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/internal.h    |  1 +
 net/ncsi/ncsi-manage.c | 22 +++++++++++++++++++---
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index eac4858..1308a56 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -265,6 +265,7 @@ struct ncsi_dev_priv {
 #endif
 	unsigned int        package_num;     /* Number of packages         */
 	struct list_head    packages;        /* List of packages           */
+	struct ncsi_channel *hot_channel;    /* Channel was ever active    */
 	struct ncsi_request requests[256];   /* Request table              */
 	unsigned int        request_id;      /* Last used request ID       */
 #define NCSI_REQ_START_IDX	1
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 4789f86..a3bd5fa 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -645,6 +645,7 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 	struct net_device *dev = nd->dev;
 	struct ncsi_package *np = ndp->active_package;
 	struct ncsi_channel *nc = ndp->active_channel;
+	struct ncsi_channel *hot_nc = NULL;
 	struct ncsi_cmd_arg nca;
 	unsigned char index;
 	unsigned long flags;
@@ -750,12 +751,20 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 		break;
 	case ncsi_dev_state_config_done:
 		spin_lock_irqsave(&nc->lock, flags);
-		if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1)
+		if (nc->modes[NCSI_MODE_LINK].data[2] & 0x1) {
+			hot_nc = nc;
 			nc->state = NCSI_CHANNEL_ACTIVE;
-		else
+		} else {
+			hot_nc = NULL;
 			nc->state = NCSI_CHANNEL_INACTIVE;
+		}
 		spin_unlock_irqrestore(&nc->lock, flags);
 
+		/* Update the hot channel */
+		spin_lock_irqsave(&ndp->lock, flags);
+		ndp->hot_channel = hot_nc;
+		spin_unlock_irqrestore(&ndp->lock, flags);
+
 		ncsi_start_channel_monitor(nc);
 		ncsi_process_next_channel(ndp);
 		break;
@@ -773,10 +782,14 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 static int ncsi_choose_active_channel(struct ncsi_dev_priv *ndp)
 {
 	struct ncsi_package *np;
-	struct ncsi_channel *nc, *found;
+	struct ncsi_channel *nc, *found, *hot_nc;
 	struct ncsi_channel_mode *ncm;
 	unsigned long flags;
 
+	spin_lock_irqsave(&ndp->lock, flags);
+	hot_nc = ndp->hot_channel;
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
 	/* The search is done once an inactive channel with up
 	 * link is found.
 	 */
@@ -794,6 +807,9 @@ static int ncsi_choose_active_channel(struct ncsi_dev_priv *ndp)
 			if (!found)
 				found = nc;
 
+			if (nc == hot_nc)
+				found = nc;
+
 			ncm = &nc->modes[NCSI_MODE_LINK];
 			if (ncm->data[2] & 0x1) {
 				spin_unlock_irqrestore(&nc->lock, flags);
-- 
2.1.0
