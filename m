From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 6/9 Rev3] [IPoIB] CM & Multicast changes
Date: Wed, 08 Aug 2007 15:02:15 +0530
Message-ID: <20070808093215.15396.13679.sendpatchset@localhost.localdomain>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	hadi@cyberus.ca, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net, davem@davemloft.net
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

IPoIB CM & Multicast changes based on header file changes.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_cm.c        |   13 +++++++++----
 ipoib_multicast.c |    4 ++--
 2 files changed, 11 insertions(+), 6 deletions(-)

diff -ruNp ORG/drivers/infiniband/ulp/ipoib/ipoib_cm.c NEW/drivers/infiniband/ulp/ipoib/ipoib_cm.c
--- ORG/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2007-07-17 08:48:35.000000000 +0530
+++ NEW/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2007-08-07 13:11:19.000000000 +0530
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
diff -ruNp ORG/drivers/infiniband/ulp/ipoib/ipoib_multicast.c NEW/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
--- ORG/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2007-07-12 08:55:06.000000000 +0530
+++ NEW/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2007-08-07 13:11:19.000000000 +0530
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
