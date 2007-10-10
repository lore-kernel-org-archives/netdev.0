From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/9] IB/ipoib: Verify address handle validity on send
Date: Tue,  9 Oct 2007 19:43:37 -0700
Message-ID: <11919842261485-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:59759 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbXJJCnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9A2hlu9017495
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 22:43:47 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hkFK407590
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:46 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hkfh001999
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:46 -0600
In-Reply-To: <1191984225129-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

When the bonding device senses a carrier loss of its active slave it replaces
that slave with a new one. In between the times when the carrier of an IPoIB
device goes down and ipoib_neigh is destroyed, it is possible that the
bonding driver will send a packet on a new slave that uses an old ipoib_neigh.
This patch detects and prevents this from happenning.

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
Acked-by: Roland Dreier <rdreier@cisco.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index bbfe8f2..cdef7ac 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -690,9 +690,10 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
-- 
1.5.3.1

