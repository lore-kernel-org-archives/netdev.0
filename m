From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmveth: Disable tx queue while changing mtu
Date: Tue,  9 Aug 2016 12:47:37 -0500
Message-ID: <1470764857-7714-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:20216 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752127AbcHIRrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 13:47:42 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u79HhVBm001830
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 13:47:41 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24qchyen4j-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 13:47:41 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 9 Aug 2016 13:47:41 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 93AF5C90042
	for <netdev@vger.kernel.org>; Tue,  9 Aug 2016 13:47:27 -0400 (EDT)
Received: from b01ledav005.gho.pok.ibm.com (b01ledav005.gho.pok.ibm.com [9.57.199.110])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u79Hlc7x16515388
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 17:47:38 GMT
Received: from b01ledav005.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 918B9AE03B
	for <netdev@vger.kernel.org>; Tue,  9 Aug 2016 13:47:38 -0400 (EDT)
Received: from tlfalcon-workstation.austin.ibm.com (unknown [9.41.92.189])
	by b01ledav005.gho.pok.ibm.com (Postfix) with ESMTP id 6641AAE034
	for <netdev@vger.kernel.org>; Tue,  9 Aug 2016 13:47:38 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the device is running while the MTU is changed, ibmveth
is closed and the bounce buffer is freed. If a transmission
is sent before ibmveth can be reopened, ibmveth_start_xmit
tries to copy to the null bounce buffer, leading to a kernel
oops. The proposed solution disables the tx queue until
ibmveth is restarted.

Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index ebe6071..9a74e4c 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1362,6 +1362,7 @@ static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 	/* Deactivate all the buffer pools so that the next loop can activate
 	   only the buffer pools necessary to hold the new MTU */
 	if (netif_running(adapter->netdev)) {
+		netif_tx_disable(dev);
 		need_restart = 1;
 		adapter->pool_config = 1;
 		ibmveth_close(adapter->netdev);
@@ -1378,14 +1379,18 @@ static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 						ibmveth_get_desired_dma
 						(viodev));
 			if (need_restart) {
-				return ibmveth_open(adapter->netdev);
+				rc = ibmveth_open(adapter->netdev);
+				netif_wake_queue(dev);
+				return rc;
 			}
 			return 0;
 		}
 	}
 
-	if (need_restart && (rc = ibmveth_open(adapter->netdev)))
+	if (need_restart && (rc = ibmveth_open(adapter->netdev))) {
+		netif_wake_queue(dev);
 		return rc;
+	}
 
 	return -EINVAL;
 }
-- 
2.4.11
