From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/11] ibmvnic: Fix cleanup of SKB's on driver close
Date: Fri, 26 May 2017 10:30:31 -0400
Message-ID: <20170526143031.63648.82517.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56675 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1764905AbdEZOmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:16 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEdQSE133111
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:15 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2apkwny5wb-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:15 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:15 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

A race condition occurs when closing the driver. Free'ing of skb's
can race between the close routine and ibmvnic_tx_interrupt. To fix
this we move the claenup of tx pools during close to after the
sub-CRQ interrupts are disabled.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 465a8fa..0f705e6 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -804,7 +804,6 @@ static int __ibmvnic_close(struct net_device *netdev)
 	adapter->state = VNIC_CLOSING;
 	netif_tx_stop_all_queues(netdev);
 	ibmvnic_napi_disable(adapter);
-	clean_tx_pools(adapter);
 
 	if (adapter->tx_scrq) {
 		for (i = 0; i < adapter->req_tx_queues; i++)
@@ -833,6 +832,7 @@ static int __ibmvnic_close(struct net_device *netdev)
 		}
 	}
 
+	clean_tx_pools(adapter);
 	adapter->state = VNIC_CLOSED;
 	return rc;
 }
