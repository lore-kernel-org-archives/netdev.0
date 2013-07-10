From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next v3 2/3] net: rename ll methods to
	busy-poll
Date: Wed, 10 Jul 2013 17:13:26 +0300
Message-ID: <20130710141326.15596.50172.stgit@ladj378.jer.intel.com>
References: <20130710141307.15596.47242.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Jonathan Corbet <corbet@lwn.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Eilon Greenstein <eilong@broadcom.com>, Eric Dumazet <erdnetdev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130710141307.15596.47242.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Rename ndo_ll_poll to ndo_busy_poll.
Rename sk_mark_ll to sk_mark_napi_id.
Rename skb_mark_ll to skb_mark_napi_id.
Correct all useres of these functions.
Update comments and defines  in include/net/busy_poll.h

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       |    2 +-
 include/linux/netdevice.h                        |    2 +-
 include/net/busy_poll.h                          |   22 ++++++++++++----------
 net/ipv4/tcp_ipv4.c                              |    2 +-
 net/ipv4/udp.c                                   |    2 +-
 net/ipv6/tcp_ipv6.c                              |    2 +-
 net/ipv6/udp.c                                   |    2 +-
 11 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 05b6b4e..3353efe 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -990,7 +990,7 @@ reuse_rx:
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       le16_to_cpu(cqe_fp->vlan_tag));
 
-		skb_mark_ll(skb, &fp->napi);
+		skb_mark_napi_id(skb, &fp->napi);
 
 		if (bnx2x_fp_ll_polling(fp))
 			netif_receive_skb(skb);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 15a528b..e5da078 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12027,7 +12027,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #endif
 
 #ifdef CONFIG_NET_LL_RX_POLL
-	.ndo_ll_poll		= bnx2x_low_latency_recv,
+	.ndo_busy_poll		= bnx2x_low_latency_recv,
 #endif
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 047ebaa..bad8f14 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1978,7 +1978,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 #endif /* IXGBE_FCOE */
-		skb_mark_ll(skb, &q_vector->napi);
+		skb_mark_napi_id(skb, &q_vector->napi);
 		ixgbe_rx_skb(q_vector, skb);
 
 		/* update budget accounting */
@@ -7228,7 +7228,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
 #ifdef CONFIG_NET_LL_RX_POLL
-	.ndo_ll_poll		= ixgbe_low_latency_recv,
+	.ndo_busy_poll		= ixgbe_low_latency_recv,
 #endif
 #ifdef IXGBE_FCOE
 	.ndo_fcoe_ddp_setup = ixgbe_fcoe_ddp_get,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0fb2438..5eac871 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2141,7 +2141,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
 #ifdef CONFIG_NET_LL_RX_POLL
-	.ndo_ll_poll		= mlx4_en_low_latency_recv,
+	.ndo_busy_poll		= mlx4_en_low_latency_recv,
 #endif
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 90746d3..dec455c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -767,7 +767,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					       timestamp);
 		}
 
-		skb_mark_ll(skb, &cq->napi);
+		skb_mark_napi_id(skb, &cq->napi);
 
 		/* Push it up the stack */
 		netif_receive_skb(skb);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bb82871..0741a1e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -974,7 +974,7 @@ struct net_device_ops {
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
 #ifdef CONFIG_NET_LL_RX_POLL
-	int			(*ndo_ll_poll)(struct napi_struct *dev);
+	int			(*ndo_busy_poll)(struct napi_struct *dev);
 #endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
 						  int queue, u8 *mac);
diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 76f0340..4ff7190 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -1,5 +1,5 @@
 /*
- * Low Latency Sockets
+ * net busy poll support
  * Copyright(c) 2013 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
@@ -21,8 +21,8 @@
  * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
  */
 
-#ifndef _LINUX_NET_LL_POLL_H
-#define _LINUX_NET_LL_POLL_H
+#ifndef _LINUX_NET_BUSY_POLL_H
+#define _LINUX_NET_BUSY_POLL_H
 
 #include <linux/netdevice.h>
 #include <net/ip.h>
@@ -110,11 +110,11 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 		goto out;
 
 	ops = napi->dev->netdev_ops;
-	if (!ops->ndo_ll_poll)
+	if (!ops->ndo_busy_poll)
 		goto out;
 
 	do {
-		rc = ops->ndo_ll_poll(napi);
+		rc = ops->ndo_busy_poll(napi);
 
 		if (rc == LL_FLUSH_FAILED)
 			break; /* permanent failure */
@@ -134,13 +134,14 @@ out:
 }
 
 /* used in the NIC receive handler to mark the skb */
-static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+static inline void skb_mark_napi_id(struct sk_buff *skb,
+				    struct napi_struct *napi)
 {
 	skb->napi_id = napi->napi_id;
 }
 
 /* used in the protocol hanlder to propagate the napi_id to the socket */
-static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+static inline void sk_mark_napi_id(struct sock *sk, struct sk_buff *skb)
 {
 	sk->sk_napi_id = skb->napi_id;
 }
@@ -166,11 +167,12 @@ static inline bool sk_busy_poll(struct sock *sk, int nonblock)
 	return false;
 }
 
-static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+static inline void skb_mark_napi_id(struct sk_buff *skb,
+				    struct napi_struct *napi)
 {
 }
 
-static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+static inline void sk_mark_napi_id(struct sock *sk, struct sk_buff *skb)
 {
 }
 
@@ -180,4 +182,4 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 }
 
 #endif /* CONFIG_NET_LL_RX_POLL */
-#endif /* _LINUX_NET_LL_POLL_H */
+#endif /* _LINUX_NET_BUSY_POLL_H */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3a261b4..b299da5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1994,7 +1994,7 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_mark_ll(sk, skb);
+	sk_mark_napi_id(sk, skb);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index bcc0ff2..a0d7151 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1713,7 +1713,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
-		sk_mark_ll(sk, skb);
+		sk_mark_napi_id(sk, skb);
 		ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 345bd92..6e1649d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1499,7 +1499,7 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_mark_ll(sk, skb);
+	sk_mark_napi_id(sk, skb);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 40e7203..f405815 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -844,7 +844,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
-		sk_mark_ll(sk, skb);
+		sk_mark_napi_id(sk, skb);
 		ret = udpv6_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 


------------------------------------------------------------------------------
See everything from the browser to the database with AppDynamics
Get end-to-end visibility with application monitoring from AppDynamics
Isolate bottlenecks and diagnose root cause in seconds.
Start your free trial of AppDynamics Pro today!
http://pubads.g.doubleclick.net/gampad/clk?id=48808831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
