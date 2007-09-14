From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 04/11] IB/ipoib: Verify address handle validity on send
Date: Fri, 14 Sep 2007 16:40:23 -0700
Message-ID: <11898132372856-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
 <11898132322950-git-send-email-fubar@us.ibm.com>
 <1189813234208-git-send-email-fubar@us.ibm.com>
 <11898132352341-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:59914 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757756AbXINXkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:40 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENedNB005127
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:39 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENedCE551942
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:39 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENecqp008617
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:39 -0400
In-Reply-To: <11898132352341-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

When the bonding device senses a carrier loss of its active slave it replaces
that slave with a new one. In between the times when the carrier of an IPoIB
device goes down and ipoib_neigh is destroyed, it is possible that the
bonding driver will send a packet on a new slave that uses an old ipoib_neigh.
This patch detects and prevents this from happenning.

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index cb26cfd..6c4e9fb 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -686,9 +686,10 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
-- 
1.5.2-rc2.GIT

