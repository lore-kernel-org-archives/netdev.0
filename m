From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 4/8] net/ncsi: Rework request index allocation
Date: Tue,  4 Oct 2016 11:25:50 +1100
Message-ID: <1475540754-31169-5-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42402 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751636AbcJDAZ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:27 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940Mr5D043036
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:27 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25uy9hw6an-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:26 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:24 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 50A6C2CE8046
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:22 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PMdE64028792
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:22 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PLe2031446
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:22 +1100
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NCSI request index (struct ncsi_request::id) is put into instance
ID (IID) field while sending NCSI command packet. It was designed the
available IDs are given in round-robin fashion. @ndp->request_id was
introduced to represent the next available ID, but it has been used
as number of successively allocated IDs. It breaks the round-robin
design. Besides, we shouldn't put 0 to NCSI command packet's IID
field, meaning ID#0 should be reserved according section 6.3.1.1
in NCSI spec (v1.1.0).

This fixes above two issues. With it applied, the available IDs will
be assigned in round-robin fashion and ID#0 won't be assigned.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Reviewed-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/internal.h    |  1 +
 net/ncsi/ncsi-manage.c | 17 +++++++++--------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 66dc851..c956fe8 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -259,6 +259,7 @@ struct ncsi_dev_priv {
 	struct list_head    packages;        /* List of packages           */
 	struct ncsi_request requests[256];   /* Request table              */
 	unsigned int        request_id;      /* Last used request ID       */
+#define NCSI_REQ_START_IDX	1
 	unsigned int        pending_req_num; /* Number of pending requests */
 	struct ncsi_package *active_package; /* Currently handled package  */
 	struct ncsi_channel *active_channel; /* Currently handled channel  */
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 8c5e016..00ce2c7 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -427,30 +427,31 @@ struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven)
 
 	/* Check if there is one available request until the ceiling */
 	spin_lock_irqsave(&ndp->lock, flags);
-	for (i = ndp->request_id; !nr && i < limit; i++) {
+	for (i = ndp->request_id; i < limit; i++) {
 		if (ndp->requests[i].used)
 			continue;
 
 		nr = &ndp->requests[i];
 		nr->used = true;
 		nr->driven = driven;
-		if (++ndp->request_id >= limit)
-			ndp->request_id = 0;
+		ndp->request_id = i + 1;
+		goto found;
 	}
 
 	/* Fail back to check from the starting cursor */
-	for (i = 0; !nr && i < ndp->request_id; i++) {
+	for (i = NCSI_REQ_START_IDX; i < ndp->request_id; i++) {
 		if (ndp->requests[i].used)
 			continue;
 
 		nr = &ndp->requests[i];
 		nr->used = true;
 		nr->driven = driven;
-		if (++ndp->request_id >= limit)
-			ndp->request_id = 0;
+		ndp->request_id = i + 1;
+		goto found;
 	}
-	spin_unlock_irqrestore(&ndp->lock, flags);
 
+found:
+	spin_unlock_irqrestore(&ndp->lock, flags);
 	return nr;
 }
 
@@ -1148,7 +1149,7 @@ struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 	/* Initialize private NCSI device */
 	spin_lock_init(&ndp->lock);
 	INIT_LIST_HEAD(&ndp->packages);
-	ndp->request_id = 0;
+	ndp->request_id = NCSI_REQ_START_IDX;
 	for (i = 0; i < ARRAY_SIZE(ndp->requests); i++) {
 		ndp->requests[i].id = i;
 		ndp->requests[i].ndp = ndp;
-- 
2.1.0
