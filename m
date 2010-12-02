From: Amerigo Wang <amwang@redhat.com>
Subject: [v2 PATCH 2/2] netpoll: remove IFF_IN_NETPOLL flag
Date: Thu, 2 Dec 2010 08:35:55 -0500
Message-ID: <20101202134054.6073.77242.sendpatchset@localhost.localdomain>
References: <20101202134041.6073.5201.sendpatchset@localhost.localdomain>
Cc: Jiri Pirko <jpirko@redhat.com>, Neil Horman <nhorman@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Amerigo Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101202134041.6073.5201.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 2 Dec 2010 21:34:44 +0800
Subject: [v2 PATCH 2/2] netpoll: remove IFF_IN_NETPOLL flag

This patch removes the flag IFF_IN_NETPOLL, we don't need it any more since
we have netpoll_tx_running() now.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>

---
 drivers/net/bonding/bond_main.c |    6 ++----
 drivers/net/bonding/bonding.h   |    2 +-
 include/linux/if.h              |    9 ++++-----
 net/core/netpoll.c              |    2 --
 4 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2addafc..6ca374c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -449,11 +449,9 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 
 	skb->priority = 1;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	if (unlikely(netpoll_tx_running(slave_dev))) {
-		slave_dev->priv_flags |= IFF_IN_NETPOLL;
+	if (unlikely(netpoll_tx_running(slave_dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
-		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
-	} else
+	else
 #endif
 		dev_queue_xmit(skb);
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index d3f3563..6a5abf0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -138,7 +138,7 @@ static inline void unblock_netpoll_tx(void)
 
 static inline int is_netpoll_tx_blocked(struct net_device *dev)
 {
-	if (unlikely(dev->priv_flags & IFF_IN_NETPOLL))
+	if (unlikely(netpoll_tx_running(dev)))
 		return cpumask_test_cpu(smp_processor_id(), netpoll_block_tx);
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
index ee38acb..8a5c1c9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -314,9 +314,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
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
