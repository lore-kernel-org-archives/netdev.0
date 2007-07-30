From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V3 2/7] IB/ipoib: Verify address handle
	validity on send
Date: Mon, 30 Jul 2007 15:49:43 +0300
Message-ID: <46ADDE67.7030502@voltaire.com>
References: <46ADDB89.5030601@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com,  davem@davemloft.net,  fubar@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46ADDB89.5030601@voltaire.com>
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

When the bonding device senses a carrier loss of its active slave it replaces
that slave with a new one. In between the times when the carrier of an IPoIB
device goes down and ipoib_neigh is destroyed, it is possible that the 
bonding driver will send a packet on a new slave that uses an old ipoib_neigh.
This patch detects and prevents this from happenning.

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Index: net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c
===================================================================
--- net-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-07-25 14:57:48.000000000 +0300
+++ net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-07-25 15:02:55.525131034 +0300
@@ -685,9 +685,10 @@ static int ipoib_start_xmit(struct sk_bu
 				goto out;
 			}
 		} else if (neigh->ah) {
-			if (unlikely(memcmp(&neigh->dgid.raw,
+			if (unlikely((memcmp(&neigh->dgid.raw,
 					    skb->dst->neighbour->ha + 4,
-					    sizeof(union ib_gid)))) {
+					    sizeof(union ib_gid))) ||
+						 (neigh->dev != dev))) {
 				spin_lock(&priv->lock);
 				/*
 				 * It's safe to call ipoib_put_ah() inside
