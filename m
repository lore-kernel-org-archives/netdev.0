From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/7] ibmvnic: Fix ibmvnic_change_mac_addr struct
 format
Date: Sun, 09 Apr 2017 00:11:44 -0400
Message-ID: <20170409041144.47642.64000.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55670 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751125AbdDIEWf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 00:22:35 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v394J45k110929
        for <netdev@vger.kernel.org>; Sun, 9 Apr 2017 00:22:34 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29qdkmgc52-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 09 Apr 2017 00:22:34 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sun, 9 Apr 2017 00:22:33 -0400
In-Reply-To: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
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
index b791361..2e4d787 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2892,11 +2892,12 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
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
index 0a8f9a0..e6b0e60 100644
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
