From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/2] smc: ETH_ALEN as memcpy length for mac addresses
Date: Thu, 12 Jan 2017 14:57:15 +0100
Message-ID: <20170112135715.64242-3-ubraun@linux.vnet.ibm.com>
References: <20170112135715.64242-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47498 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750778AbdALN6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:58:04 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CDsCgZ125003
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:57:26 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27xaca213e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:57:26 -0500
Received: from localhost
        by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 13:57:23 -0000
In-Reply-To: <20170112135715.64242-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating an SMC connection, there is a CLC (connection layer control)
handshake to prepare for RDMA traffic. The corresponding code is part of
commit 0cfdd8f92cac ("smc: connection and link group creation").
Mac addresses to be exchanged in the handshake are copied with a wrong
length of 12 instead of 6 bytes. Following code overwrites the wrongly
copied code, but nevertheless the correct length should already be used for
the preceding mac address copying. Use ETH_ALEN for the memcpy length with
mac addresses.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Fixes: 0cfdd8f92cac ("smc: connection and link group creation")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/smc/smc_clc.c | 10 ++++------
 net/smc/smc_ib.h  |  4 +++-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
index e1e684c..cc6b6f8 100644
--- a/net/smc/smc_clc.c
+++ b/net/smc/smc_clc.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/in.h>
+#include <linux/if_ether.h>
 #include <net/sock.h>
 #include <net/tcp.h>
 
@@ -151,8 +152,7 @@ int smc_clc_send_proposal(struct smc_sock *smc,
 	pclc.hdr.version = SMC_CLC_V1;		/* SMC version */
 	memcpy(pclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
 	memcpy(&pclc.lcl.gid, &smcibdev->gid[ibport - 1], SMC_GID_SIZE);
-	memcpy(&pclc.lcl.mac, &smcibdev->mac[ibport - 1],
-	       sizeof(smcibdev->mac[ibport - 1]));
+	memcpy(&pclc.lcl.mac, &smcibdev->mac[ibport - 1], ETH_ALEN);
 
 	/* determine subnet and mask from internal TCP socket */
 	rc = smc_netinfo_by_tcpsk(smc->clcsock, &pclc.outgoing_subnet,
@@ -199,8 +199,7 @@ int smc_clc_send_confirm(struct smc_sock *smc)
 	memcpy(cclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
 	memcpy(&cclc.lcl.gid, &link->smcibdev->gid[link->ibport - 1],
 	       SMC_GID_SIZE);
-	memcpy(&cclc.lcl.mac, &link->smcibdev->mac[link->ibport - 1],
-	       sizeof(link->smcibdev->mac));
+	memcpy(&cclc.lcl.mac, &link->smcibdev->mac[link->ibport - 1], ETH_ALEN);
 	hton24(cclc.qpn, link->roce_qp->qp_num);
 	cclc.rmb_rkey =
 		htonl(conn->rmb_desc->mr_rx[SMC_SINGLE_LINK]->rkey);
@@ -252,8 +251,7 @@ int smc_clc_send_accept(struct smc_sock *new_smc, int srv_first_contact)
 	memcpy(aclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
 	memcpy(&aclc.lcl.gid, &link->smcibdev->gid[link->ibport - 1],
 	       SMC_GID_SIZE);
-	memcpy(&aclc.lcl.mac, link->smcibdev->mac[link->ibport - 1],
-	       sizeof(link->smcibdev->mac[link->ibport - 1]));
+	memcpy(&aclc.lcl.mac, link->smcibdev->mac[link->ibport - 1], ETH_ALEN);
 	hton24(aclc.qpn, link->roce_qp->qp_num);
 	aclc.rmb_rkey =
 		htonl(conn->rmb_desc->mr_rx[SMC_SINGLE_LINK]->rkey);
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index 3fe2d55..a95f74b 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -11,6 +11,7 @@
 #ifndef _SMC_IB_H
 #define _SMC_IB_H
 
+#include <linux/if_ether.h>
 #include <rdma/ib_verbs.h>
 
 #define SMC_MAX_PORTS			2	/* Max # of ports */
@@ -34,7 +35,8 @@ struct smc_ib_device {				/* ib-device infos for smc */
 	struct ib_cq		*roce_cq_recv;	/* recv completion queue */
 	struct tasklet_struct	send_tasklet;	/* called by send cq handler */
 	struct tasklet_struct	recv_tasklet;	/* called by recv cq handler */
-	char			mac[SMC_MAX_PORTS][6]; /* mac address per port*/
+	char			mac[SMC_MAX_PORTS][ETH_ALEN];
+						/* mac address per port*/
 	union ib_gid		gid[SMC_MAX_PORTS]; /* gid per port */
 	u8			initialized : 1; /* ib dev CQ, evthdl done */
 	struct work_struct	port_event_work;
-- 
2.8.4
