From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 9/9] IB/ipoib: Add support for transmission of skbs w.o dst/neighbour
Date: Tue, 10 Jul 2012 15:16:09 +0300
Message-ID: <1341922569-4118-10-git-send-email-ogerlitz@mellanox.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:46862 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755323Ab2GJMQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:16:55 -0400
In-Reply-To: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

Guest IP packets sent by eIPoIB over an IPoIB VIF interface do not point
to dst or neighbour. This patch modifies IPoIB such that trasnmission
of such packets is possible. It does so by extending an already existing
path in the driver which was used so far only for unicast ARP probes.

This patch was made such that the series works as is over net-next, in
parallel to this driver a patch to modify IPoIB such that it doesn't
assume dst/neighbour on the skb was posted.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 1ccd42f..afe282c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -739,7 +739,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	rcu_read_lock();
-	if (likely(skb_dst(skb))) {
+	if (likely(skb_dst(skb)) && !(dev->priv_flags & IFF_EIPOIB_VIF)) {
 		n = dst_neigh_lookup_skb(skb_dst(skb), skb);
 		if (!n) {
 			++dev->stats.tx_dropped;
@@ -807,7 +807,8 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* unicast GID -- should be ARP or RARP reply */
 
 			if ((be16_to_cpup((__be16 *) skb->data) != ETH_P_ARP) &&
-			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP)) {
+			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP) &&
+				!(dev->priv_flags & IFF_EIPOIB_VIF)) {
 				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x %pI6\n",
 					   skb_dst(skb) ? "neigh" : "dst",
 					   be16_to_cpup((__be16 *) skb->data),
@@ -857,7 +858,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	 * destination address into skb->cb so we can figure out where
 	 * to send the packet later.
 	 */
-	if (!skb_dst(skb)) {
+	if (!skb_dst(skb) || dev->priv_flags & IFF_EIPOIB_VIF) {
 		struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
 		memcpy(cb->hwaddr, daddr, INFINIBAND_ALEN);
 	}
-- 
1.7.1
