From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] net: orphan queued skbs if device tx can stall
Date: Sun, 8 Apr 2012 20:13:25 +0300
Message-ID: <20120408171323.GA16012@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 0110d6f22f392f976e84ab49da1b42f85b64a3c5
tun: orphan an skb on tx
Fixed a configuration where skbs get queued
at the tun device forever, blocking senders.

However this fix isn't waterproof:
userspace can control whether the interface
is stopped, and if it is, packets
get queued in the qdisc, again potentially forever.

Complete the fix by setting a private flag and orphaning
at the qdisc level.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c       |    3 +++
 include/linux/if.h      |    1 +
 net/core/dev.c          |    5 +++++
 net/sched/sch_generic.c |    5 +++++
 4 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bb8c72c..15c5bb8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -535,6 +535,9 @@ static void tun_net_init(struct net_device *dev)
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
+	/* Once queue becomes full, we stop tx until userspace
+	 * dequeues some packets, that is potentially forever. */
+	dev->priv_flags |= IFF_TX_CAN_STALL;
 }
 
 /* Character device part */
diff --git a/include/linux/if.h b/include/linux/if.h
index f995c66..dd2c7f7 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -81,6 +81,7 @@
 #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
 #define IFF_TEAM_PORT	0x40000		/* device used as team port */
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
+#define IFF_TX_CAN_STALL 0x100000	/* Device can stop tx forever */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d59155..e812706 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2516,6 +2516,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
+	/* Orphan the skb - required if we might hang on to it
+	 * for indefinite time. */
+	if (dev->priv_flags & IFF_TX_CAN_STALL)
+		skb_orphan(skb);
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 67fc573..27883d1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -120,6 +120,11 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	/* And release qdisc */
 	spin_unlock(root_lock);
 
+	/* Orphan the skb - required if we might hang on to it
+	 * for indefinite time. */
+	if (dev->priv_flags & IFF_TX_CAN_STALL)
+		skb_orphan(skb);
+
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_stopped(txq))
 		ret = dev_hard_start_xmit(skb, dev, txq);
-- 
1.7.9.111.gf3fb0
