From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V6 2/9] IB/ipoib: Verify address handle
	validity on send
Date: Mon, 24 Sep 2007 17:30:56 +0200
Message-ID: <46F7D830.3060809@voltaire.com>
References: <46F7D770.4090500@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F7D770.4090500@voltaire.com>
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

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Index: net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c
===================================================================
--- net-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-09-18 17:09:26.535874225 +0200
+++ net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-09-18 17:10:22.375853147 +0200
@@ -686,9 +686,10 @@ static int ipoib_start_xmit(struct sk_bu
 				goto out;
 			}
 		} else if (neigh->ah) {
-			if (unlikely(memcmp(&neigh->dgid.raw,
+			if (unlikely((memcmp(&neigh->dgid.raw,
 					    skb->dst->neighbour->ha + 4,
-					    sizeof(union ib_gid)))) {
+					    sizeof(union ib_gid))) ||
+					 (neigh->dev != dev))) {
 				spin_lock(&priv->lock);
 				/*
 				 * It's safe to call ipoib_put_ah() inside
