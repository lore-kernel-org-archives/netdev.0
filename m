From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH] ibmvnic: driver initialization for kdump/kexec
Date: Thu, 15 Jun 2017 14:48:09 -0400
Message-ID: <20170615184809.42218.80768.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45151 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752773AbdFOPAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 11:00:23 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5FExEvO033618
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 11:00:23 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2b3rapugt6-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 11:00:22 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Thu, 15 Jun 2017 11:00:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When booting into the kdump/kexec kernel, pHyp and vios
are not prepared for the initialization crq request and
a failover transport event is generated. This is not
handled correctly.

At this point in initialization the driver is still in
the 'probing' state and cannot handle a full reset of the
driver as is normally done for a failover transport event.

To correct this we catch driver resets while still in the
'probing' state and return EAGAIN. This results in the
driver tearing down the main crq and calling ibmvnic_init()
again.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 59ea7a5..50ac1dc 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1447,6 +1447,12 @@ static void ibmvnic_reset(struct ibmvnic_adapter *adapter,
 		return;
 	}
 
+	if (adapter->state == VNIC_PROBING) {
+		netdev_warn(netdev, "Adapter reset during probe\n");
+		adapter->init_done_rc = EAGAIN;
+		return;
+	}
+
 	mutex_lock(&adapter->rwi_lock);
 
 	list_for_each(entry, &adapter->rwi_list) {
@@ -3634,12 +3640,18 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 	adapter->from_passive_init = false;
 
 	init_completion(&adapter->init_done);
+	adapter->init_done_rc = 0;
 	ibmvnic_send_crq_init(adapter);
 	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
 		dev_err(dev, "Initialization sequence timed out\n");
 		return -1;
 	}
 
+	if (adapter->init_done_rc) {
+		release_crq_queue(adapter);
+		return adapter->init_done_rc;
+	}
+
 	if (adapter->from_passive_init) {
 		adapter->state = VNIC_OPEN;
 		adapter->from_passive_init = false;
@@ -3708,11 +3720,13 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	mutex_init(&adapter->rwi_lock);
 	adapter->resetting = false;
 
-	rc = ibmvnic_init(adapter);
-	if (rc) {
-		free_netdev(netdev);
-		return rc;
-	}
+	do {
+		rc = ibmvnic_init(adapter);
+		if (rc != EAGAIN) {
+			free_netdev(netdev);
+			return rc;
+		}
+	} while (rc == EAGAIN);
 
 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
