From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/8] net/ncsi: Introduce ncsi_stop_dev()
Date: Thu, 29 Sep 2016 15:03:14 +1000
Message-ID: <1475125395-8459-8-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55347 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753151AbcI2FDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:03:19 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T53ICE139100
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:19 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25rrts1dhy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:18 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 15:03:10 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id C0A153578058
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8T537S856098898
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
        by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8T536Vb021767
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
In-Reply-To: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
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
 net/ncsi/ncsi-manage.c | 33 ++++++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 11 deletions(-)

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
index 1b797c9..6a96873 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -1161,9 +1161,7 @@ EXPORT_SYMBOL_GPL(ncsi_register_dev);
 int ncsi_start_dev(struct ncsi_dev *nd)
 {
 	struct ncsi_dev_priv *ndp = TO_NCSI_DEV_PRIV(nd);
-	struct ncsi_package *np;
-	struct ncsi_channel *nc;
-	int old_state, ret;
+	int ret;
 
 	if (nd->state != ncsi_dev_state_registered &&
 	    nd->state != ncsi_dev_state_functional)
@@ -1175,9 +1173,27 @@ int ncsi_start_dev(struct ncsi_dev *nd)
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
+	int old_state;
+
+	/* Stop the channel monitor and reset channel's state */
 	NCSI_FOR_EACH_PACKAGE(ndp, np) {
 		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			ncsi_stop_channel_monitor(nc);
+
 			old_state = READ_ONCE(nc->state);
 			WRITE_ONCE(nc->state, NCSI_CHANNEL_INACTIVE);
 			WARN_ON_ONCE(!list_empty(&nc->link) ||
@@ -1185,14 +1201,9 @@ int ncsi_start_dev(struct ncsi_dev *nd)
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
