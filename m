From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 08/11] ibmvnic: Check for driver reset first in
 ibmvnic_xmit
Date: Mon, 01 May 2017 17:57:25 -0400
Message-ID: <20170501215725.27224.21638.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170501215424.27224.53918.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48435 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751184AbdEASJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:09:00 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v41I4EGd117110
        for <netdev@vger.kernel.org>; Mon, 1 May 2017 14:08:45 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a68vvb2mb-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 14:08:41 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Mon, 1 May 2017 14:08:40 -0400
In-Reply-To: <20170501215424.27224.53918.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the check for the driver resetting to the first thing
in ibmvnic_xmit().

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4da7080..2cf1b64 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -985,12 +985,6 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	int index = 0;
 	int ret = 0;
 
-	tx_pool = &adapter->tx_pool[queue_num];
-	tx_scrq = adapter->tx_scrq[queue_num];
-	txq = netdev_get_tx_queue(netdev, skb_get_queue_mapping(skb));
-	handle_array = (u64 *)((u8 *)(adapter->login_rsp_buf) +
-				   be32_to_cpu(adapter->login_rsp_buf->
-					       off_txsubm_subcrqs));
 	if (adapter->resetting) {
 		if (!netif_subqueue_stopped(netdev, skb))
 			netif_stop_subqueue(netdev, queue_num);
@@ -1002,6 +996,12 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto out;
 	}
 
+	tx_pool = &adapter->tx_pool[queue_num];
+	tx_scrq = adapter->tx_scrq[queue_num];
+	txq = netdev_get_tx_queue(netdev, skb_get_queue_mapping(skb));
+	handle_array = (u64 *)((u8 *)(adapter->login_rsp_buf) +
+		be32_to_cpu(adapter->login_rsp_buf->off_txsubm_subcrqs));
+
 	index = tx_pool->free_map[tx_pool->consumer_index];
 	offset = index * adapter->req_mtu;
 	dst = tx_pool->long_term_buff.buff + offset;
