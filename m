From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 7/8] net/ncsi: Introduce ncsi_stop_dev()
Date: Tue,  4 Oct 2016 11:25:53 +1100
Message-ID: <1475540754-31169-8-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39619 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752027AbcJDAZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:28 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940Mr90144135
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:28 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25uy9kd31f-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:27 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:25 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id 5305F357805A
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:23 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PNbt63963370
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:23 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PML9023624
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:23 +1100
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces ncsi_stop_dev(), as counterpart to ncsi_start_dev(),
to stop the NCSI device so that it can be reenabled in future. This
API should be called when the network device driver is going to
shutdown the device. There are 3 things done in the function: Stop
the channel monitoring; Reset channels to inactive state; Report
NCSI link down.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Reviewed-by: Joel Stanley <joel@jms.id.au>
---
 include/net/ncsi.h     |  5 +++++
 net/ncsi/ncsi-manage.c | 37 ++++++++++++++++++++++++-------------
 2 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/include/net/ncsi.h b/include/net/ncsi.h
index 1dbf42f..68680ba 100644
--- a/include/net/ncsi.h
+++ b/include/net/ncsi.h
@@ -31,6 +31,7 @@ struct ncsi_dev {
 struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 				   void (*notifier)(struct ncsi_dev *nd));
 int ncsi_start_dev(struct ncsi_dev *nd);
+void ncsi_stop_dev(struct ncsi_dev *nd);
 void ncsi_unregister_dev(struct ncsi_dev *nd);
 #else /* !CONFIG_NET_NCSI */
 static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
@@ -44,6 +45,10 @@ static inline int ncsi_start_dev(struct ncsi_dev *nd)
 	return -ENOTTY;
 }
 
+static void ncsi_stop_dev(struct ncsi_dev *nd)
+{
+}
+
 static inline void ncsi_unregister_dev(struct ncsi_dev *nd)
 {
 }
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 4742c7c..5e509e5 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -1187,11 +1187,7 @@ EXPORT_SYMBOL_GPL(ncsi_register_dev);
 int ncsi_start_dev(struct ncsi_dev *nd)
 {
 	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
-	struct ncsi_package *np;
-	struct ncsi_channel *nc;
-	unsigned long flags;
-	bool chained;
-	int old_state, ret;
+	int ret;
 
 	if (nd->state != ncsi_dev_state_registered &&
 	    nd->state != ncsi_dev_state_functional)
@@ -1203,9 +1199,29 @@ int ncsi_start_dev(struct ncsi_dev *nd)
 		return 0;
 	}
 
-	/* Reset channel's state and start over */
+	if (ndp->flags & NCSI_DEV_HWA)
+		ret = ncsi_enable_hwa(ndp);
+	else
+		ret = ncsi_choose_active_channel(ndp);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(ncsi_start_dev);
+
+void ncsi_stop_dev(struct ncsi_dev *nd)
+{
+	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	bool chained;
+	int old_state;
+	unsigned long flags;
+
+	/* Stop the channel monitor and reset channel's state */
 	NCSI_FOR_EACH_PACKAGE(ndp, np) {
 		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			ncsi_stop_channel_monitor(nc);
+
 			spin_lock_irqsave(&nc->lock, flags);
 			chained = !list_empty(&nc->link);
 			old_state = nc->state;
@@ -1217,14 +1233,9 @@ int ncsi_start_dev(struct ncsi_dev *nd)
 		}
 	}
 
-	if (ndp->flags & NCSI_DEV_HWA)
-		ret = ncsi_enable_hwa(ndp);
-	else
-		ret = ncsi_choose_active_channel(ndp);
-
-	return ret;
+	ncsi_report_link(ndp, true);
 }
-EXPORT_SYMBOL_GPL(ncsi_start_dev);
+EXPORT_SYMBOL_GPL(ncsi_stop_dev);
 
 void ncsi_unregister_dev(struct ncsi_dev *nd)
 {
-- 
2.1.0
