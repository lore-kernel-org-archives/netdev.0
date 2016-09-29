From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/8] net/ncsi: Rework request index allocation
Date: Thu, 29 Sep 2016 15:03:11 +1000
Message-ID: <1475125395-8459-5-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57277 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752970AbcI2FDX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:03:23 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T53LAA058917
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:22 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25rq5x60jv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:22 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 15:03:11 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id 72E033578067
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8T537Vh11272328
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8T53612000450
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
In-Reply-To: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
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
index 3eeb915..64aab38 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -415,30 +415,31 @@ struct ncsi_request *ncsi_alloc_request(struct ncsi_dev_priv *ndp, bool driven)
 
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
 
@@ -1122,7 +1123,7 @@ struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
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
