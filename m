From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Handle processing of CRQ messages in a tasklet
Date: Wed, 15 Feb 2017 12:17:58 -0600
Message-ID: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56851 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752707AbdBOSSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:18:11 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FIEaW1062623
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:18:10 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28mq9k672u-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:18:10 -0500
Received: from localhost
        by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 15 Feb 2017 11:18:08 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
        by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 87CAA19D8026
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 11:17:19 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a tasklet to process queued commands or messages received from
firmware instead of processing them in the interrupt handler. Note that
this handler does not process network traffic, but communications related
to resource allocation and device settings.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 18 +++++++++++++++++-
 drivers/net/ethernet/ibm/ibmvnic.h |  1 +
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5b66b4f..244be77 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3415,6 +3415,18 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 static irqreturn_t ibmvnic_interrupt(int irq, void *instance)
 {
 	struct ibmvnic_adapter *adapter = instance;
+	unsigned long flags;
+
+	spin_lock_irqsave(&adapter->crq.lock, flags);
+	vio_disable_interrupts(adapter->vdev);
+	tasklet_schedule(&adapter->tasklet);
+	spin_unlock_irqrestore(&adapter->crq.lock, flags);
+	return IRQ_HANDLED;
+}
+
+static void ibmvnic_tasklet(void *data)
+{
+	struct ibmvnic_adapter *adapter = data;
 	struct ibmvnic_crq_queue *queue = &adapter->crq;
 	struct vio_dev *vdev = adapter->vdev;
 	union ibmvnic_crq *crq;
@@ -3440,7 +3452,6 @@ static irqreturn_t ibmvnic_interrupt(int irq, void *instance)
 		}
 	}
 	spin_unlock_irqrestore(&queue->lock, flags);
-	return IRQ_HANDLED;
 }
 
 static int ibmvnic_reenable_crq_queue(struct ibmvnic_adapter *adapter)
@@ -3495,6 +3506,7 @@ static void ibmvnic_release_crq_queue(struct ibmvnic_adapter *adapter)
 
 	netdev_dbg(adapter->netdev, "Releasing CRQ\n");
 	free_irq(vdev->irq, adapter);
+	tasklet_kill(&adapter->tasklet);
 	do {
 		rc = plpar_hcall_norets(H_FREE_CRQ, vdev->unit_address);
 	} while (rc == H_BUSY || H_IS_LONG_BUSY(rc));
@@ -3540,6 +3552,9 @@ static int ibmvnic_init_crq_queue(struct ibmvnic_adapter *adapter)
 
 	retrc = 0;
 
+	tasklet_init(&adapter->tasklet, (void *)ibmvnic_tasklet,
+		     (unsigned long)adapter);
+
 	netdev_dbg(adapter->netdev, "registering irq 0x%x\n", vdev->irq);
 	rc = request_irq(vdev->irq, ibmvnic_interrupt, 0, IBMVNIC_NAME,
 			 adapter);
@@ -3561,6 +3576,7 @@ static int ibmvnic_init_crq_queue(struct ibmvnic_adapter *adapter)
 	return retrc;
 
 req_irq_failed:
+	tasklet_kill(&adapter->tasklet);
 	do {
 		rc = plpar_hcall_norets(H_FREE_CRQ, vdev->unit_address);
 	} while (rc == H_BUSY || H_IS_LONG_BUSY(rc));
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index dd775d9..0d0edc3 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1049,5 +1049,6 @@ struct ibmvnic_adapter {
 
 	struct work_struct vnic_crq_init;
 	struct work_struct ibmvnic_xport;
+	struct tasklet_struct tasklet;
 	bool failover;
 };
-- 
2.7.4
