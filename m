From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 06/11] ibmvnic: Clean up tx pools when closing
Date: Mon, 01 May 2017 17:57:14 -0400
Message-ID: <20170501215713.27224.69804.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170501215424.27224.53918.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57627 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751150AbdEASIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:08:31 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v41I5uAr064221
        for <netdev@vger.kernel.org>; Mon, 1 May 2017 14:08:31 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a68vyk3p4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 14:08:30 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Mon, 1 May 2017 14:08:29 -0400
In-Reply-To: <20170501215424.27224.53918.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When closing the bimvnic driver, most notably during the reset
path, the tx pools need to be cleaned to ensure there are no
hanging skbs that need to be free'ed.

The need to do this was found during debugging a loss of network
traffic after handling a driver reset. The underlying cause was
some skbs that were in the tx pool that were never free'ed. As a
result the upper network layers never tried a re-send since it
believed the driver still had the skb.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index d20d884..0400ae7 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -760,6 +760,34 @@ static void disable_sub_crqs(struct ibmvnic_adapter *adapter)
 	}
 }
 
+static void clean_tx_pools(struct ibmvnic_adapter *adapter)
+{
+	struct ibmvnic_tx_pool *tx_pool;
+	u64 tx_entries;
+	int tx_scrqs;
+	int i, j;
+
+	if (!adapter->tx_pool)
+		return;
+
+	tx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
+	tx_entries = adapter->req_tx_entries_per_subcrq;
+
+	/* Free any remaining skbs in the tx buffer pools */
+	for (i = 0; i < tx_scrqs; i++) {
+		tx_pool = &adapter->tx_pool[i];
+		if (!tx_pool)
+			continue;
+
+		for (j = 0; j < tx_entries; j++) {
+			if (tx_pool->tx_buff[j].skb) {
+				dev_kfree_skb_any(tx_pool->tx_buff[j].skb);
+				tx_pool->tx_buff[j].skb = NULL;
+			}
+		}
+	}
+}
+
 static int __ibmvnic_close(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
@@ -768,6 +796,8 @@ static int __ibmvnic_close(struct net_device *netdev)
 
 	adapter->state = VNIC_CLOSING;
 	netif_tx_stop_all_queues(netdev);
+
+	clean_tx_pools(adapter);
 	disable_sub_crqs(adapter);
 
 	if (adapter->napi) {
