From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 12/12] IB/ipoib: Add support for transmission of skbs w.o dst/neighbour
Date: Wed,  1 Aug 2012 20:09:35 +0300
Message-ID: <1343840975-3252-13-git-send-email-ogerlitz@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:60736 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753820Ab2HARKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:10:25 -0400
In-Reply-To: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

Guest IP packets sent by eIPoIB over an IPoIB VIF interface do not point
to dst or neighbour. This patch modifies IPoIB such that trasnmission
of such packets is possible. It does so by extending an already existing
path in the driver which was used so far only for unicast ARP probes.

This patch was made such that the series works as is over net-next, in
parallel to this driver a patch to modify IPoIB such that it doesn't
assume dst/neighbour on the skb was pushed upstream, its commit b63b70d87741 
"IPoIB: Use a private hash table for path lookup in xmit path", once
present in net-next this patch can simply be dropped.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 47034b4..fc4a1f0 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -732,7 +732,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	rcu_read_lock();
-	if (likely(skb_dst(skb))) {
+	if (likely(skb_dst(skb)) && !(dev->priv_flags & IFF_EIPOIB_VIF)) {
 		n = dst_neigh_lookup_skb(skb_dst(skb), skb);
 		if (!n) {
 			++dev->stats.tx_dropped;
@@ -800,7 +800,8 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* unicast GID -- should be ARP or RARP reply */
 
 			if ((be16_to_cpup((__be16 *) skb->data) != ETH_P_ARP) &&
-			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP)) {
+			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP) &&
+				!(dev->priv_flags & IFF_EIPOIB_VIF)) {
 				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x %pI6\n",
 					   skb_dst(skb) ? "neigh" : "dst",
 					   be16_to_cpup((__be16 *) skb->data),
@@ -850,7 +851,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
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
