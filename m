From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 6/10 Rev4] [IPoIB] CM & Multicast changes
Date: Wed, 22 Aug 2007 14:00:32 +0530
Message-ID: <20070822083032.11964.97171.sendpatchset@localhost.localdomain>
References: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:50847 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbXHVI3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 04:29:04 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7M8T3x6026694
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:29:03 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M8T3OK507618
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:29:03 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M8T0Rd006831
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:29:03 -0400
In-Reply-To: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPoIB CM & Multicast changes based on header file changes.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_cm.c        |   13 +++++++++----
 ipoib_multicast.c |    4 ++--
 2 files changed, 11 insertions(+), 6 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_cm.c new/drivers/infiniband/ulp/ipoib/ipoib_cm.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2007-08-20 14:26:26.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2007-08-22 08:33:51.000000000 +0530
@@ -493,14 +493,19 @@ static inline int post_send(struct ipoib
 			    unsigned int wr_id,
 			    u64 addr, int len)
 {
+	int ret;
 	struct ib_send_wr *bad_wr;
 
-	priv->tx_sge.addr             = addr;
-	priv->tx_sge.length           = len;
+	priv->tx_sge[0].addr          = addr;
+	priv->tx_sge[0].length        = len;
+
+	priv->tx_wr[0].wr_id 	      = wr_id;
 
-	priv->tx_wr.wr_id 	      = wr_id;
+	priv->tx_wr[0].next = NULL;
+	ret = ib_post_send(tx->qp, priv->tx_wr, &bad_wr);
+	priv->tx_wr[0].next = &priv->tx_wr[1];
 
-	return ib_post_send(tx->qp, &priv->tx_wr, &bad_wr);
+	return ret;
 }
 
 void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_tx *tx)
diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_multicast.c new/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2007-08-20 14:26:26.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2007-08-22 08:33:51.000000000 +0530
@@ -217,7 +217,7 @@ static int ipoib_mcast_join_finish(struc
 	if (!memcmp(mcast->mcmember.mgid.raw, priv->dev->broadcast + 4,
 		    sizeof (union ib_gid))) {
 		priv->qkey = be32_to_cpu(priv->broadcast->mcmember.qkey);
-		priv->tx_wr.wr.ud.remote_qkey = priv->qkey;
+		priv->tx_wr[0].wr.ud.remote_qkey = priv->qkey;
 	}
 
 	if (!test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags)) {
@@ -736,7 +736,7 @@ out:
 			}
 		}
 
-		ipoib_send(dev, skb, mcast->ah, IB_MULTICAST_QPN);
+		ipoib_send(dev, skb, mcast->ah, IB_MULTICAST_QPN, 1);
 	}
 
 unlock:
