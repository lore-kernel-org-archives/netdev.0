From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Do not disable IRQ after scheduling
 tasklet
Date: Fri, 14 Apr 2017 12:49:56 -0400
Message-ID: <20170414164956.50601.20659.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: brking@linux.vnet.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33038 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751473AbdDNNAy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 09:00:54 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ECwliK086879
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 09:00:54 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29tw55m0u7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 09:00:53 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 14 Apr 2017 09:00:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>

Since the primary CRQ is only used for service functions and
not in the performance path, simplify the code a bit and avoid
disabling the IRQ.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   25 ++++++-------------------
 1 file changed, 6 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index b5871df..27d7d27 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3027,12 +3027,8 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 static irqreturn_t ibmvnic_interrupt(int irq, void *instance)
 {
 	struct ibmvnic_adapter *adapter = instance;
-	unsigned long flags;
 
-	spin_lock_irqsave(&adapter->crq.lock, flags);
-	vio_disable_interrupts(adapter->vdev);
 	tasklet_schedule(&adapter->tasklet);
-	spin_unlock_irqrestore(&adapter->crq.lock, flags);
 	return IRQ_HANDLED;
 }
 
@@ -3040,32 +3036,23 @@ static void ibmvnic_tasklet(void *data)
 {
 	struct ibmvnic_adapter *adapter = data;
 	struct ibmvnic_crq_queue *queue = &adapter->crq;
-	struct vio_dev *vdev = adapter->vdev;
 	union ibmvnic_crq *crq;
 	unsigned long flags;
 	bool done = false;
 
 	spin_lock_irqsave(&queue->lock, flags);
-	vio_disable_interrupts(vdev);
 	while (!done) {
 		/* Pull all the valid messages off the CRQ */
 		while ((crq = ibmvnic_next_crq(adapter)) != NULL) {
 			ibmvnic_handle_crq(crq, adapter);
 			crq->generic.first = 0;
 		}
-		vio_enable_interrupts(vdev);
-		crq = ibmvnic_next_crq(adapter);
-		if (crq) {
-			vio_disable_interrupts(vdev);
-			ibmvnic_handle_crq(crq, adapter);
-			crq->generic.first = 0;
-		} else {
-			/* remain in tasklet until all
-			 * capabilities responses are received
-			 */
-			if (!adapter->wait_capability)
-				done = true;
-		}
+
+		/* remain in tasklet until all
+		 * capabilities responses are received
+		 */
+		if (!adapter->wait_capability)
+			done = true;
 	}
 	/* if capabilities CRQ's were sent in this tasklet, the following
 	 * tasklet must wait until all responses are received
