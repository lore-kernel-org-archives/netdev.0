From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/10] ibmvnic: Fix ibmvnic_change_mac_addr struct
 format
Date: Wed, 19 Apr 2017 13:44:35 -0400
Message-ID: <20170419174434.37372.22338.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:51914 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934567AbdDSNzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:55:39 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JDreoi057690
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:55:38 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29x6x0y2wk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:55:38 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 19 Apr 2017 09:55:35 -0400
In-Reply-To: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Murilo Fossa Vicentini <muvic@linux.vnet.ibm.com>

The ibmvnic_change_mac_addr struct alignment was not matching the defined
format in PAPR+, it had the reserved and return code fields swapped. As a
consequence, the CHANGE_MAC_ADDR_RSP commands were being improperly handled
and executed even when the operation wasn't successfully completed by the
system firmware.

Also changing the endianness of the debug message to make it easier to
parse the CRQ content.

Signed-off-by: Murilo Fossa Vicentini <muvic@linux.vnet.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    5 +++--
 drivers/net/ethernet/ibm/ibmvnic.h |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7bf3507..625896d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2890,11 +2890,12 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 	struct ibmvnic_generic_crq *gen_crq = &crq->generic;
 	struct net_device *netdev = adapter->netdev;
 	struct device *dev = &adapter->vdev->dev;
+	u64 *u64_crq = (u64 *)crq;
 	long rc;
 
 	netdev_dbg(netdev, "Handling CRQ: %016lx %016lx\n",
-		   ((unsigned long int *)crq)[0],
-		   ((unsigned long int *)crq)[1]);
+		   (unsigned long int)cpu_to_be64(u64_crq[0]),
+		   (unsigned long int)cpu_to_be64(u64_crq[1]));
 	switch (gen_crq->first) {
 	case IBMVNIC_CRQ_INIT_RSP:
 		switch (gen_crq->cmd) {
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index b0d0b89..1b404ca 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -518,8 +518,8 @@ struct ibmvnic_change_mac_addr {
 	u8 first;
 	u8 cmd;
 	u8 mac_addr[6];
-	struct ibmvnic_rc rc;
 	u8 reserved[4];
+	struct ibmvnic_rc rc;
 } __packed __aligned(8);
 
 struct ibmvnic_multicast_ctrl {
