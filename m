From: Amerigo Wang <amwang@redhat.com>
Subject: [V4 PATCH 2/3] netpoll: remove IFF_IN_NETPOLL flag
Date: Fri, 18 Feb 2011 17:43:33 +0800
Message-ID: <1298022215-21059-2-git-send-email-amwang@redhat.com>
References: <1298022215-21059-1-git-send-email-amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Amerigo Wang <amwang@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Jiri Pirko <jpirko@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298022215-21059-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

V4: rebase to net-next-2.6

This patch removes the flag IFF_IN_NETPOLL, we don't need it any more since
we have netpoll_tx_running() now.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>

---
 drivers/net/bonding/bond_main.c |    6 ++----
 drivers/net/bonding/bonding.h   |    2 +-
 include/linux/if.h              |    9 ++++-----
 net/core/netpoll.c              |    2 --
 4 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ed6624..c75126d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -423,11 +423,9 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 {
 	skb->dev = slave_dev;
 	skb->priority = 1;
-	if (unlikely(netpoll_tx_running(slave_dev))) {
-		slave_dev->priv_flags |= IFF_IN_NETPOLL;
+	if (unlikely(netpoll_tx_running(slave_dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
-		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
-	} else
+	else
 		dev_queue_xmit(skb);
 
 	return 0;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0a3e00b..a401b8d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -133,7 +133,7 @@ static inline void unblock_netpoll_tx(void)
 
 static inline int is_netpoll_tx_blocked(struct net_device *dev)
 {
-	if (unlikely(dev->priv_flags & IFF_IN_NETPOLL))
+	if (unlikely(netpoll_tx_running(dev)))
 		return atomic_read(&netpoll_block_tx);
 	return 0;
 }
diff --git a/include/linux/if.h b/include/linux/if.h
index 1239599..3bc63e6 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -71,11 +71,10 @@
 					 * release skb->dst
 					 */
 #define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
-#define IFF_IN_NETPOLL	0x1000		/* whether we are processing netpoll */
-#define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
-#define IFF_MACVLAN_PORT	0x4000	/* device used as macvlan port */
-#define IFF_BRIDGE_PORT	0x8000		/* device used as bridge port */
-#define IFF_OVS_DATAPATH	0x10000	/* device used as Open vSwitch
+#define IFF_DISABLE_NETPOLL	0x1000	/* disable netpoll at run-time */
+#define IFF_MACVLAN_PORT	0x2000	/* device used as macvlan port */
+#define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
+#define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
 					 * datapath port */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 02dc2cb..f68e694 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -313,9 +313,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_tx_queue_stopped(txq)) {
-					dev->priv_flags |= IFF_IN_NETPOLL;
 					status = ops->ndo_start_xmit(skb, dev);
-					dev->priv_flags &= ~IFF_IN_NETPOLL;
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
 				}
-- 
1.7.1
