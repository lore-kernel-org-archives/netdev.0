From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/11] ibmvnic: Check adapter state during
 ibmvnic_poll
Date: Fri, 26 May 2017 10:30:54 -0400
Message-ID: <20170526143054.63648.25863.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:38637 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1765077AbdEZOmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:39 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEdnIE005717
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:39 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2ap8vrgf3m-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:39 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:38 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not want to process any receive frames if the ibmvnic_poll
routine is invoked while a reset is in process. Also, before
replenishing the rx pools in the ibmvnic_poll, we want to
make sure the adapter is not in the process of closing.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 47421e4..760352f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1435,6 +1435,10 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	int scrq_num = (int)(napi - adapter->napi);
 	int frames_processed = 0;
+
+	if (adapter->resetting)
+		return 0;
+
 restart_poll:
 	while (frames_processed < budget) {
 		struct sk_buff *skb;
@@ -1493,7 +1497,9 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 		netdev->stats.rx_bytes += length;
 		frames_processed++;
 	}
-	replenish_rx_pool(adapter, &adapter->rx_pool[scrq_num]);
+
+	if (adapter->state != VNIC_CLOSING)
+		replenish_rx_pool(adapter, &adapter->rx_pool[scrq_num]);
 
 	if (frames_processed < budget) {
 		enable_scrq_irq(adapter, adapter->rx_scrq[scrq_num]);
