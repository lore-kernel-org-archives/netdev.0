From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: l2tp_eth: use LLTX to avoid LOCKDEP splats
Date: Mon, 25 Jun 2012 17:35:45 +0200
Message-ID: <1340638545.10893.70.camel@edumazet-glaptop>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Hong zhi guo <honkiko@gmail.com>,
	James Chapman <jchapman@katalix.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37532 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab2FYPfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 11:35:55 -0400
Received: by bkcji2 with SMTP id ji2so3271703bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 08:35:53 -0700 (PDT)
In-Reply-To: <7ed49f446365ac625437702d92946add@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Denys Fedoryshchenko reported a LOCKDEP issue with l2tp code.


[ 8683.927442] ======================================================
[ 8683.927555] [ INFO: possible circular locking dependency detected ]
[ 8683.927672] 3.4.1-build-0061 #14 Not tainted
[ 8683.927782] -------------------------------------------------------
[ 8683.927895] swapper/0/0 is trying to acquire lock:
[ 8683.928007]  (slock-AF_INET){+.-...}, at: [<e0fc73ec>] 
l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]
[ 8683.928121] but task is already holding lock:
[ 8683.928121]  (_xmit_ETHER#2){+.-...}, at: [<c02f062d>] 
sch_direct_xmit+0x36/0x119
[ 8683.928121]
[ 8683.928121] which lock already depends on the new lock.
[ 8683.928121]
[ 8683.928121]
[ 8683.928121] the existing dependency chain (in reverse order) is:
[ 8683.928121]
[ 8683.928121] -> #1 (_xmit_ETHER#2){+.-...}:
[ 8683.928121]        [<c015a561>] lock_acquire+0x71/0x85
[ 8683.928121]        [<c034da2d>] _raw_spin_lock+0x33/0x40
[ 8683.928121]        [<c0304e0c>] ip_send_reply+0xf2/0x1ce
[ 8683.928121]        [<c0317dbc>] tcp_v4_send_reset+0x153/0x16f
[ 8683.928121]        [<c0317f4a>] tcp_v4_do_rcv+0x172/0x194
[ 8683.928121]        [<c031929b>] tcp_v4_rcv+0x387/0x5a0
[ 8683.928121]        [<c03001d0>] ip_local_deliver_finish+0x13a/0x1e9
[ 8683.928121]        [<c0300645>] NF_HOOK.clone.11+0x46/0x4d
[ 8683.928121]        [<c030075b>] ip_local_deliver+0x41/0x45
[ 8683.928121]        [<c03005dd>] ip_rcv_finish+0x31a/0x33c
[ 8683.928121]        [<c0300645>] NF_HOOK.clone.11+0x46/0x4d
[ 8683.928121]        [<c0300960>] ip_rcv+0x201/0x23d
[ 8683.928121]        [<c02de91b>] __netif_receive_skb+0x329/0x378
[ 8683.928121]        [<c02deae8>] netif_receive_skb+0x4e/0x7d
[ 8683.928121]        [<e08d5ef3>] rtl8139_poll+0x243/0x33d [8139too]
[ 8683.928121]        [<c02df103>] net_rx_action+0x90/0x15d
[ 8683.928121]        [<c012b2b5>] __do_softirq+0x7b/0x118
[ 8683.928121]
[ 8683.928121] -> #0 (slock-AF_INET){+.-...}:
[ 8683.928121]        [<c0159f1b>] __lock_acquire+0x9a3/0xc27
[ 8683.928121]        [<c015a561>] lock_acquire+0x71/0x85
[ 8683.928121]        [<c034da2d>] _raw_spin_lock+0x33/0x40
[ 8683.928121]        [<e0fc73ec>] l2tp_xmit_skb+0x173/0x47e 
[l2tp_core]
[ 8683.928121]        [<e0fe31fb>] l2tp_eth_dev_xmit+0x1a/0x2f 
[l2tp_eth]
[ 8683.928121]        [<c02e01e7>] dev_hard_start_xmit+0x333/0x3f2
[ 8683.928121]        [<c02f064c>] sch_direct_xmit+0x55/0x119
[ 8683.928121]        [<c02e0528>] dev_queue_xmit+0x282/0x418
[ 8683.928121]        [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]        [<c031f524>] arp_xmit+0x22/0x24
[ 8683.928121]        [<c031f567>] arp_send+0x41/0x48
[ 8683.928121]        [<c031fa7d>] arp_process+0x289/0x491
[ 8683.928121]        [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]        [<c031f7a0>] arp_rcv+0xb1/0xc3
[ 8683.928121]        [<c02de91b>] __netif_receive_skb+0x329/0x378
[ 8683.928121]        [<c02de9d3>] process_backlog+0x69/0x130
[ 8683.928121]        [<c02df103>] net_rx_action+0x90/0x15d
[ 8683.928121]        [<c012b2b5>] __do_softirq+0x7b/0x118
[ 8683.928121]
[ 8683.928121] other info that might help us debug this:
[ 8683.928121]
[ 8683.928121]  Possible unsafe locking scenario:
[ 8683.928121]
[ 8683.928121]        CPU0                    CPU1
[ 8683.928121]        ----                    ----
[ 8683.928121]   lock(_xmit_ETHER#2);
[ 8683.928121]                                lock(slock-AF_INET);
[ 8683.928121]                                lock(_xmit_ETHER#2);
[ 8683.928121]   lock(slock-AF_INET);
[ 8683.928121]
[ 8683.928121]  *** DEADLOCK ***
[ 8683.928121]
[ 8683.928121] 3 locks held by swapper/0/0:
[ 8683.928121]  #0:  (rcu_read_lock){.+.+..}, at: [<c02dbc10>] 
rcu_lock_acquire+0x0/0x30
[ 8683.928121]  #1:  (rcu_read_lock_bh){.+....}, at: [<c02dbc10>] 
rcu_lock_acquire+0x0/0x30
[ 8683.928121]  #2:  (_xmit_ETHER#2){+.-...}, at: [<c02f062d>] 
sch_direct_xmit+0x36/0x119
[ 8683.928121]
[ 8683.928121] stack backtrace:
[ 8683.928121] Pid: 0, comm: swapper/0 Not tainted 3.4.1-build-0061 #14
[ 8683.928121] Call Trace:
[ 8683.928121]  [<c034bdd2>] ? printk+0x18/0x1a
[ 8683.928121]  [<c0158904>] print_circular_bug+0x1ac/0x1b6
[ 8683.928121]  [<c0159f1b>] __lock_acquire+0x9a3/0xc27
[ 8683.928121]  [<c015a561>] lock_acquire+0x71/0x85
[ 8683.928121]  [<e0fc73ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]  [<c034da2d>] _raw_spin_lock+0x33/0x40
[ 8683.928121]  [<e0fc73ec>] ? l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]  [<e0fc73ec>] l2tp_xmit_skb+0x173/0x47e [l2tp_core]
[ 8683.928121]  [<e0fe31fb>] l2tp_eth_dev_xmit+0x1a/0x2f [l2tp_eth]
[ 8683.928121]  [<c02e01e7>] dev_hard_start_xmit+0x333/0x3f2
[ 8683.928121]  [<c02f064c>] sch_direct_xmit+0x55/0x119
[ 8683.928121]  [<c02e0528>] dev_queue_xmit+0x282/0x418
[ 8683.928121]  [<c02e02a6>] ? dev_hard_start_xmit+0x3f2/0x3f2
[ 8683.928121]  [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]  [<c031f524>] arp_xmit+0x22/0x24
[ 8683.928121]  [<c02e02a6>] ? dev_hard_start_xmit+0x3f2/0x3f2
[ 8683.928121]  [<c031f567>] arp_send+0x41/0x48
[ 8683.928121]  [<c031fa7d>] arp_process+0x289/0x491
[ 8683.928121]  [<c031f7f4>] ? __neigh_lookup.clone.20+0x42/0x42
[ 8683.928121]  [<c031f4fb>] NF_HOOK.clone.19+0x45/0x4c
[ 8683.928121]  [<c031f7a0>] arp_rcv+0xb1/0xc3
[ 8683.928121]  [<c031f7f4>] ? __neigh_lookup.clone.20+0x42/0x42
[ 8683.928121]  [<c02de91b>] __netif_receive_skb+0x329/0x378
[ 8683.928121]  [<c02de9d3>] process_backlog+0x69/0x130
[ 8683.928121]  [<c02df103>] net_rx_action+0x90/0x15d
[ 8683.928121]  [<c012b2b5>] __do_softirq+0x7b/0x118
[ 8683.928121]  [<c012b23a>] ? local_bh_enable+0xd/0xd
[ 8683.928121]  <IRQ>  [<c012b4d0>] ? irq_exit+0x41/0x91
[ 8683.928121]  [<c0103c6f>] ? do_IRQ+0x79/0x8d
[ 8683.928121]  [<c0157ea1>] ? trace_hardirqs_off_caller+0x2e/0x86
[ 8683.928121]  [<c034ef6e>] ? common_interrupt+0x2e/0x34
[ 8683.928121]  [<c0108a33>] ? default_idle+0x23/0x38
[ 8683.928121]  [<c01091a8>] ? cpu_idle+0x55/0x6f
[ 8683.928121]  [<c033df25>] ? rest_init+0xa1/0xa7
[ 8683.928121]  [<c033de84>] ? __read_lock_failed+0x14/0x14
[ 8683.928121]  [<c0498745>] ? start_kernel+0x303/0x30a
[ 8683.928121]  [<c0498209>] ? repair_env_string+0x51/0x51
[ 8683.928121]  [<c04980a8>] ? i386_start_kernel+0xa8/0xaf

It appears that like most virtual devices, l2tp should be converted to
LLTX mode.

This patch takes care of statistics using atomic_long in both RX and TX
paths, and fix a bug in l2tp_eth_dev_recv(), which was caching skb->data
before a pskb_may_pull() call.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Cc: James Chapman <jchapman@katalix.com>
Cc: Hong zhi guo <honkiko@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
---
Should be applied after "net: l2tp_eth: fix l2tp_eth_dev_xmit race"

 net/l2tp/l2tp_eth.c |   43 +++++++++++++++++++++++++++++++-----------
 1 file changed, 32 insertions(+), 11 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index c3738f4..47b259f 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -42,6 +42,11 @@ struct l2tp_eth {
 	struct sock		*tunnel_sock;
 	struct l2tp_session	*session;
 	struct list_head	list;
+	atomic_long_t		tx_bytes;
+	atomic_long_t		tx_packets;
+	atomic_long_t		rx_bytes;
+	atomic_long_t		rx_packets;
+	atomic_long_t		rx_errors;
 };
 
 /* via l2tp_session_priv() */
@@ -88,24 +93,40 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct l2tp_eth *priv = netdev_priv(dev);
 	struct l2tp_session *session = priv->session;
 
-	dev->stats.tx_bytes += skb->len;
-	dev->stats.tx_packets++;
+	atomic_long_add(skb->len, &priv->tx_bytes);
+	atomic_long_inc(&priv->tx_packets);
 
 	l2tp_xmit_skb(session, skb, session->hdr_len);
 
 	return NETDEV_TX_OK;
 }
 
+static struct rtnl_link_stats64 *l2tp_eth_get_stats64(struct net_device *dev,
+						      struct rtnl_link_stats64 *stats)
+{
+	struct l2tp_eth *priv = netdev_priv(dev);
+
+	stats->tx_bytes   = atomic_long_read(&priv->tx_bytes);
+	stats->tx_packets = atomic_long_read(&priv->tx_packets);
+	stats->rx_bytes   = atomic_long_read(&priv->rx_bytes);
+	stats->rx_packets = atomic_long_read(&priv->rx_packets);
+	stats->rx_errors  = atomic_long_read(&priv->rx_errors);
+	return stats;
+}
+
+
 static struct net_device_ops l2tp_eth_netdev_ops = {
 	.ndo_init		= l2tp_eth_dev_init,
 	.ndo_uninit		= l2tp_eth_dev_uninit,
 	.ndo_start_xmit		= l2tp_eth_dev_xmit,
+	.ndo_get_stats64	= l2tp_eth_get_stats64,
 };
 
 static void l2tp_eth_dev_setup(struct net_device *dev)
 {
 	ether_setup(dev);
-	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags		&= ~IFF_TX_SKB_SHARING;
+	dev->features		|= NETIF_F_LLTX;
 	dev->netdev_ops		= &l2tp_eth_netdev_ops;
 	dev->destructor		= free_netdev;
 }
@@ -114,17 +135,17 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 {
 	struct l2tp_eth_sess *spriv = l2tp_session_priv(session);
 	struct net_device *dev = spriv->dev;
+	struct l2tp_eth *priv = netdev_priv(dev);
 
 	if (session->debug & L2TP_MSG_DATA) {
 		unsigned int length;
-		u8 *ptr = skb->data;
 
 		length = min(32u, skb->len);
 		if (!pskb_may_pull(skb, length))
 			goto error;
 
 		pr_debug("%s: eth recv\n", session->name);
-		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, ptr, length);
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, skb->data, length);
 	}
 
 	if (!pskb_may_pull(skb, sizeof(ETH_HLEN)))
@@ -139,15 +160,15 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 	nf_reset(skb);
 
 	if (dev_forward_skb(dev, skb) == NET_RX_SUCCESS) {
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += data_len;
-	} else
-		dev->stats.rx_errors++;
-
+		atomic_long_inc(&priv->rx_packets);
+		atomic_long_add(data_len, &priv->rx_bytes);
+	} else {
+		atomic_long_inc(&priv->rx_errors);
+	}
 	return;
 
 error:
-	dev->stats.rx_errors++;
+	atomic_long_inc(&priv->rx_errors);
 	kfree_skb(skb);
 }
 
