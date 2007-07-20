From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 08/10] IPoIB multicast/CM changes.
Date: Fri, 20 Jul 2007 12:03:26 +0530
Message-ID: <20070720063326.26341.24459.sendpatchset@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
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

IPoIB Multicast and CM changes for batching support.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_cm.c        |   13 +++++++++----
 ipoib_multicast.c |    4 ++--
 2 files changed, 11 insertions(+), 6 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_cm.c new/drivers/infiniband/ulp/ipoib/ipoib_cm.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2007-07-20 07:49:28.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2007-07-20 08:30:22.000000000 +0530
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
--- org/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2007-07-20 07:49:28.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_multicast.c	2007-07-20 08:30:22.000000000 +0530
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
