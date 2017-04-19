From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/10] ibmvnic: Allocate zero-filled memory for sub
 crqs
Date: Wed, 19 Apr 2017 13:45:16 -0400
Message-ID: <20170419174516.37372.58934.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46122 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934640AbdDSN4U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:56:20 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JDrh44045112
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:56:19 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29x760xm6y-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:56:19 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 19 Apr 2017 09:56:18 -0400
In-Reply-To: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the allocation of memory for the sub crq structs and their
associated pages to allocate zero-filled memory.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index ce8b147..221d652 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1360,12 +1360,12 @@ static struct ibmvnic_sub_crq_queue *init_sub_crq_queue(struct ibmvnic_adapter
 	struct ibmvnic_sub_crq_queue *scrq;
 	int rc;
 
-	scrq = kmalloc(sizeof(*scrq), GFP_ATOMIC);
+	scrq = kzalloc(sizeof(*scrq), GFP_ATOMIC);
 	if (!scrq)
 		return NULL;
 
-	scrq->msgs = (union sub_crq *)__get_free_pages(GFP_ATOMIC, 2);
-	memset(scrq->msgs, 0, 4 * PAGE_SIZE);
+	scrq->msgs =
+		(union sub_crq *)__get_free_pages(GFP_ATOMIC | __GFP_ZERO, 2);
 	if (!scrq->msgs) {
 		dev_warn(dev, "Couldn't allocate crq queue messages page\n");
 		goto zero_page_failed;
@@ -1393,9 +1393,6 @@ static struct ibmvnic_sub_crq_queue *init_sub_crq_queue(struct ibmvnic_adapter
 
 	scrq->adapter = adapter;
 	scrq->size = 4 * PAGE_SIZE / sizeof(*scrq->msgs);
-	scrq->cur = 0;
-	atomic_set(&scrq->used, 0);
-	scrq->rx_skb_top = NULL;
 	spin_lock_init(&scrq->lock);
 
 	netdev_dbg(adapter->netdev,
