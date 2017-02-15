From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Make CRQ interrupt tasklet wait for all capabilities crqs
Date: Wed, 15 Feb 2017 12:18:00 -0600
Message-ID: <1487182680-29421-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56969 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752728AbdBOSSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:18:15 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FIEbAQ062690
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:18:14 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28mq9k676f-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:18:14 -0500
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 15 Feb 2017 11:18:13 -0700
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
        by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 10D5F1FF0065
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 11:17:46 -0700 (MST)
In-Reply-To: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After sending device capability queries and requests to the vNIC Server,
an interrupt is triggered and the responses are written to the driver's
CRQ response buffer. Since the interrupt can be triggered before all
responses are written and visible to the partition, there is a danger
that the interrupt handler or tasklet can terminate before all responses
are read, resulting in a failure to initialize the device.

To avoid this scenario, when capability commands are sent, we set
a flag that will be checked in the following interrupt tasklet that
will handle the capability responses from the server. Once all
responses have been handled, the flag is disabled; and the tasklet
is allowed to terminate.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
This patch depends on
"[PATCH net] ibmvnic: Handle processing of CRQ messages in a tasklet"
and
"[PATCH net] ibmvnic: Use common counter for capabilities checks"
---
 drivers/net/ethernet/ibm/ibmvnic.c | 16 ++++++++++++++--
 drivers/net/ethernet/ibm/ibmvnic.h |  1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index fb683f2..5a8707f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2413,6 +2413,7 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
 		struct ibmvnic_query_ip_offload_buffer *ip_offload_buf =
 		    &adapter->ip_offload_buf;
 
+		adapter->wait_capability = false;
 		adapter->ip_offload_tok = dma_map_single(dev, ip_offload_buf,
 							 buf_sz,
 							 DMA_FROM_DEVICE);
@@ -2708,9 +2709,11 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 	}
 
 out:
-	if (atomic_read(&adapter->running_cap_crqs) == 0)
+	if (atomic_read(&adapter->running_cap_crqs) == 0) {
+		adapter->wait_capability = false;
 		init_sub_crqs(adapter, 0);
 		/* We're done querying the capabilities, initialize sub-crqs */
+	}
 }
 
 static void handle_control_ras_rsp(union ibmvnic_crq *crq,
@@ -3453,9 +3456,18 @@ static void ibmvnic_tasklet(void *data)
 			ibmvnic_handle_crq(crq, adapter);
 			crq->generic.first = 0;
 		} else {
-			done = true;
+			/* remain in tasklet until all
+			 * capabilities responses are received
+			 */
+			if (!adapter->wait_capability)
+				done = true;
 		}
 	}
+	/* if capabilities CRQ's were sent in this tasklet, the following
+	 * tasklet must wait until all responses are received
+	 */
+	if (atomic_read(&adapter->running_cap_crqs) != 0)
+		adapter->wait_capability = true;
 	spin_unlock_irqrestore(&queue->lock, flags);
 }
 
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 504d05c..422824f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -977,6 +977,7 @@ struct ibmvnic_adapter {
 	int login_rsp_buf_sz;
 
 	atomic_t running_cap_crqs;
+	bool wait_capability;
 
 	struct ibmvnic_sub_crq_queue **tx_scrq;
 	struct ibmvnic_sub_crq_queue **rx_scrq;
-- 
2.7.4
