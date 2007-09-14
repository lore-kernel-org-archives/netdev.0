From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 7/10 REV5] [IPoIB] Verbs changes
Date: Fri, 14 Sep 2007 14:33:34 +0530
Message-ID: <20070914090334.17589.95279.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, xma@us.ibm.com, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:47433 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbXINJBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 05:01:34 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E91XFx023144
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:01:33 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E91X0k524368
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:01:33 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E91Uct027940
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:01:33 -0400
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPoIB verb changes to use batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_verbs.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_verbs.c new/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_verbs.c	2007-09-13 09:10:58.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_verbs.c	2007-09-14 10:25:36.000000000 +0530
@@ -152,11 +152,11 @@ int ipoib_transport_dev_init(struct net_
 			.max_send_sge = 1,
 			.max_recv_sge = 1
 		},
-		.sq_sig_type = IB_SIGNAL_ALL_WR,
+		.sq_sig_type = IB_SIGNAL_REQ_WR,	/* 11.2.4.1 */
 		.qp_type     = IB_QPT_UD
 	};
-
-	int ret, size;
+	struct ib_send_wr *next_wr = NULL;
+	int i, ret, size;
 
 	priv->pd = ib_alloc_pd(priv->ca);
 	if (IS_ERR(priv->pd)) {
@@ -197,12 +197,17 @@ int ipoib_transport_dev_init(struct net_
 	priv->dev->dev_addr[2] = (priv->qp->qp_num >>  8) & 0xff;
 	priv->dev->dev_addr[3] = (priv->qp->qp_num      ) & 0xff;
 
-	priv->tx_sge.lkey 	= priv->mr->lkey;
-
-	priv->tx_wr.opcode 	= IB_WR_SEND;
-	priv->tx_wr.sg_list 	= &priv->tx_sge;
-	priv->tx_wr.num_sge 	= 1;
-	priv->tx_wr.send_flags 	= IB_SEND_SIGNALED;
+	for (i = ipoib_sendq_size - 1; i >= 0; i--) {
+		priv->tx_sge[i].lkey		= priv->mr->lkey;
+		priv->tx_wr[i].opcode		= IB_WR_SEND;
+		priv->tx_wr[i].sg_list		= &priv->tx_sge[i];
+		priv->tx_wr[i].num_sge		= 1;
+		priv->tx_wr[i].send_flags	= 0;
+
+		/* Link the list properly for provider to use */
+		priv->tx_wr[i].next		= next_wr;
+		next_wr				= &priv->tx_wr[i];
+	}
 
 	return 0;
 
