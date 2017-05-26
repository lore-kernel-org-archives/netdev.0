From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/11] ibmvnic: Deactivate RX pool buffer
 replenishment on H_CLOSED
Date: Fri, 26 May 2017 10:30:48 -0400
Message-ID: <20170526143048.63648.46534.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58106 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1030490AbdEZOmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:33 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEe35S026948
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:33 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2apjnfjmf9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:32 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:32 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

If H_CLOSED is returned, halt RX buffer replenishment activity
until firmware sends a notification that the driver can reset.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 1c3f1ed..47421e4 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -200,6 +200,15 @@ static void free_long_term_buff(struct ibmvnic_adapter *adapter,
 	dma_free_coherent(dev, ltb->size, ltb->buff, ltb->addr);
 }
 
+static void deactivate_rx_pools(struct ibmvnic_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
+	     i++)
+		adapter->rx_pool[i].active = 0;
+}
+
 static void replenish_rx_pool(struct ibmvnic_adapter *adapter,
 			      struct ibmvnic_rx_pool *pool)
 {
@@ -217,6 +226,9 @@ static void replenish_rx_pool(struct ibmvnic_adapter *adapter,
 	int index;
 	int i;
 
+	if (!pool->active)
+		return;
+
 	handle_array = (u64 *)((u8 *)(adapter->login_rsp_buf) +
 				      be32_to_cpu(adapter->login_rsp_buf->
 				      off_rxadd_subcrqs));
@@ -287,6 +299,15 @@ static void replenish_rx_pool(struct ibmvnic_adapter *adapter,
 	dev_kfree_skb_any(skb);
 	adapter->replenish_add_buff_failure++;
 	atomic_add(buffers_added, &pool->available);
+
+	if (lpar_rc == H_CLOSED) {
+		/* Disable buffer pool replenishment and report carrier off if
+		 * queue is closed. Firmware guarantees that a signal will
+		 * be sent to the driver, triggering a reset.
+		 */
+		deactivate_rx_pools(adapter);
+		netif_carrier_off(adapter->netdev);
+	}
 }
 
 static void replenish_pools(struct ibmvnic_adapter *adapter)
