From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 7/9 Rev3] [IPoIB] Verb changes
Date: Wed, 08 Aug 2007 15:02:26 +0530
Message-ID: <20070808093226.15396.88288.sendpatchset@localhost.localdomain>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, hadi@cyberus.ca, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru, davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, sri@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

IPoIB verb changes to use batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_verbs.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff -ruNp ORG/drivers/infiniband/ulp/ipoib/ipoib_verbs.c NEW/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
--- ORG/drivers/infiniband/ulp/ipoib/ipoib_verbs.c	2007-07-12 08:55:06.000000000 +0530
+++ NEW/drivers/infiniband/ulp/ipoib/ipoib_verbs.c	2007-08-07 13:11:19.000000000 +0530
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
 
