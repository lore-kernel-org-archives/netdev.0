From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 5/7] ibmvnic: Add set_link_state routine for
 setting adapter link state
Date: Fri, 21 Apr 2017 15:39:04 -0400
Message-ID: <20170421193904.11030.32765.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54937 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1039590AbdDUSKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:10:50 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFmjq7020616
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:10 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29ygy25m6s-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:10 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:50:09 -0400
In-Reply-To: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a common routine for setting the link state for the vnic adapter.
This update moves the sending of the crq and waiting for the link state
response to a common place. The new routine also adds handling of
resending the crq in cases of getting a partial success response.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   71 +++++++++++++++++++++++++++++-------
 drivers/net/ethernet/ibm/ibmvnic.h |    1 +
 2 files changed, 58 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 199cccb..115f216 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -561,6 +561,51 @@ static void release_resources(struct ibmvnic_adapter *adapter)
 	release_error_buffers(adapter);
 }
 
+static int set_link_state(struct ibmvnic_adapter *adapter, u8 link_state)
+{
+	struct net_device *netdev = adapter->netdev;
+	unsigned long timeout = msecs_to_jiffies(30000);
+	union ibmvnic_crq crq;
+	bool resend;
+	int rc;
+
+	if (adapter->logical_link_state == link_state) {
+		netdev_dbg(netdev, "Link state already %d\n", link_state);
+		return 0;
+	}
+
+	netdev_err(netdev, "setting link state %d\n", link_state);
+	memset(&crq, 0, sizeof(crq));
+	crq.logical_link_state.first = IBMVNIC_CRQ_CMD;
+	crq.logical_link_state.cmd = LOGICAL_LINK_STATE;
+	crq.logical_link_state.link_state = link_state;
+
+	do {
+		resend = false;
+
+		reinit_completion(&adapter->init_done);
+		rc = ibmvnic_send_crq(adapter, &crq);
+		if (rc) {
+			netdev_err(netdev, "Failed to set link state\n");
+			return rc;
+		}
+
+		if (!wait_for_completion_timeout(&adapter->init_done,
+						 timeout)) {
+			netdev_err(netdev, "timeout setting link state\n");
+			return -1;
+		}
+
+		if (adapter->init_done_rc == 1) {
+			/* Partuial success, delay and re-send */
+			mdelay(1000);
+			resend = true;
+		}
+	} while (resend);
+
+	return 0;
+}
+
 static int set_real_num_queues(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
@@ -583,7 +628,6 @@ static int ibmvnic_open(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	struct device *dev = &adapter->vdev->dev;
-	union ibmvnic_crq crq;
 	int rc = 0;
 	int i;
 
@@ -643,11 +687,9 @@ static int ibmvnic_open(struct net_device *netdev)
 	for (i = 0; i < adapter->req_tx_queues; i++)
 		enable_scrq_irq(adapter, adapter->tx_scrq[i]);
 
-	memset(&crq, 0, sizeof(crq));
-	crq.logical_link_state.first = IBMVNIC_CRQ_CMD;
-	crq.logical_link_state.cmd = LOGICAL_LINK_STATE;
-	crq.logical_link_state.link_state = IBMVNIC_LOGICAL_LNK_UP;
-	ibmvnic_send_crq(adapter, &crq);
+	rc = set_link_state(adapter, IBMVNIC_LOGICAL_LNK_UP);
+	if (rc)
+		goto ibmvnic_open_fail;
 
 	netif_tx_start_all_queues(netdev);
 	adapter->is_closed = false;
@@ -681,7 +723,7 @@ static void disable_sub_crqs(struct ibmvnic_adapter *adapter)
 static int ibmvnic_close(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
-	union ibmvnic_crq crq;
+	int rc = 0;
 	int i;
 
 	adapter->closing = true;
@@ -693,17 +735,13 @@ static int ibmvnic_close(struct net_device *netdev)
 	if (!adapter->failover)
 		netif_tx_stop_all_queues(netdev);
 
-	memset(&crq, 0, sizeof(crq));
-	crq.logical_link_state.first = IBMVNIC_CRQ_CMD;
-	crq.logical_link_state.cmd = LOGICAL_LINK_STATE;
-	crq.logical_link_state.link_state = IBMVNIC_LOGICAL_LNK_DN;
-	ibmvnic_send_crq(adapter, &crq);
+	rc = set_link_state(adapter, IBMVNIC_LOGICAL_LNK_DN);
 
 	release_resources(adapter);
 
 	adapter->is_closed = true;
 	adapter->closing = false;
-	return 0;
+	return rc;
 }
 
 /**
@@ -2945,9 +2983,14 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 		handle_login_rsp(crq, adapter);
 		break;
 	case LOGICAL_LINK_STATE_RSP:
-		netdev_dbg(netdev, "Got Logical Link State Response\n");
+		netdev_dbg(netdev,
+			   "Got Logical Link State Response, state: %d rc: %d\n",
+			   crq->logical_link_state_rsp.link_state,
+			   crq->logical_link_state_rsp.rc.code);
 		adapter->logical_link_state =
 		    crq->logical_link_state_rsp.link_state;
+		adapter->init_done_rc = crq->logical_link_state_rsp.rc.code;
+		complete(&adapter->init_done);
 		break;
 	case LINK_STATE_INDICATION:
 		netdev_dbg(netdev, "Got Logical Link State Indication\n");
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 387c843..a69979f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -964,6 +964,7 @@ struct ibmvnic_adapter {
 	struct ibmvnic_tx_pool *tx_pool;
 	bool closing;
 	struct completion init_done;
+	int init_done_rc;
 
 	struct list_head errors;
 	spinlock_t error_list_lock;
