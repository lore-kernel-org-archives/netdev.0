From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/11] ibmvnic: Reset the CRQ queue during driver
 reset
Date: Fri, 26 May 2017 10:31:00 -0400
Message-ID: <20170526143100.63648.92061.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54360 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1030490AbdEZOmq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:46 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEek9R028592
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:45 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apkxx73kv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:45 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:44 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a driver reset operation occurs there is not a need to release
the CRQ resources and re-allocate them. Instead a reset of the CRQ
will suffice.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 760352f..b9b0c69 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1260,7 +1260,6 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 
 		release_resources(adapter);
 		release_sub_crqs(adapter);
-		release_crq_queue(adapter);
 
 		rc = ibmvnic_init(adapter);
 		if (rc)
@@ -3517,7 +3516,14 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 	unsigned long timeout = msecs_to_jiffies(30000);
 	int rc;
 
-	rc = init_crq_queue(adapter);
+	if (adapter->resetting) {
+		rc = ibmvnic_reset_crq(adapter);
+		if (!rc)
+			rc = vio_enable_interrupts(adapter->vdev);
+	} else {
+		rc = init_crq_queue(adapter);
+	}
+
 	if (rc) {
 		dev_err(dev, "Couldn't initialize crq. rc=%d\n", rc);
 		return rc;
