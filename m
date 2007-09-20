From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V5 4/11] IB/ipoib: Verify address handle validity on send
Date: Thu, 20 Sep 2007 16:42:42 +0300
Message-ID: <46F278D2.6080703@voltaire.com>
References: <46F27692.3070404@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: OpenFabrics General <general@lists.openfabrics.org>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:16092 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754112AbXITNmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 09:42:44 -0400
In-Reply-To: <46F27692.3070404@voltaire.com>
Sender: netdev-owner@vger.kernel.org
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

