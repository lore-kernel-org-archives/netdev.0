From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Improve output for unsupported stats
Date: Mon, 2 Oct 2017 15:31:39 -0500
Message-ID: <6ce14d1a-11cc-37be-e6ca-b9ec4afb01a8@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45460 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751084AbdJBUbp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 16:31:45 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v92KTRiY100904
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 16:31:44 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dbt1qppty-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 16:31:44 -0400
Received: from localhost
        by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Mon, 2 Oct 2017 14:31:43 -0600
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vnic server can report -1 in the event that a given statistic is not
supported. Currently, the -1 value is implicitly cast to an unsigned
integer and appears through the ethtool -S output as a very large number.
This patch improves this behavior by reporting 0 in the event that a
given statistic is not supported.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index cb8182f..b8ad2db 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1862,6 +1862,7 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(dev);
 	union ibmvnic_crq crq;
+	u64 stat;
 	int i, j;

 	memset(&crq, 0, sizeof(crq));
@@ -1876,9 +1877,11 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 	ibmvnic_send_crq(adapter, &crq);
 	wait_for_completion(&adapter->stats_done);

-	for (i = 0; i < ARRAY_SIZE(ibmvnic_stats); i++)
-		data[i] = be64_to_cpu(IBMVNIC_GET_STAT(adapter,
-						ibmvnic_stats[i].offset));
+	for (i = 0; i < ARRAY_SIZE(ibmvnic_stats); i++) {
+		stat = be64_to_cpu(IBMVNIC_GET_STAT(adapter,
+						    ibmvnic_stats[i].offset));
+		data[i] = stat == -1 ? 0 : stat;
+	}

 	for (j = 0; j < adapter->req_tx_queues; j++) {
 		data[i] = adapter->tx_stats_buffers[j].packets;
