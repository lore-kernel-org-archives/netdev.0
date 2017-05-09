From: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Subject: [PATCH 1/2] net: Added mtu parameter to dev_forward_skb calls
Date: Tue,  9 May 2017 14:44:37 +0200
Message-ID: <20170509124439.45674-2-fredrik.markstrom@gmail.com>
References: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org,
        =?UTF-8?q?Fredrik=20Markstr=C3=B6m?= <fredrik.markstrom@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fredrik Markström <fredrik.markstrom@gmail.com>

is_skb_forwardable() currently checks if the packet size is <= mtu of
the receiving interface. This is not consistent with most of the hardware
ethernet drivers that happily receives packets larger then MTU.

This patch adds a parameter to dev_forward_skb and is_skb_forwardable so
that the caller can override this packet size limit.

Signed-off-by: Fredrik Markstrom <fredrik.markstrom@gmail.com>
---
 drivers/net/ipvlan/ipvlan_core.c |  7 ++++---
 drivers/net/macvlan.c            |  4 ++--
 drivers/net/veth.c               |  2 +-
 include/linux/netdevice.h        | 10 +++++-----
 net/bridge/br_forward.c          |  4 ++--
 net/core/dev.c                   | 17 +++++++++++------
 net/core/filter.c                |  4 ++--
 net/l2tp/l2tp_eth.c              |  2 +-
 8 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 1f3295e274d0..dbbe48ade204 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -234,7 +234,8 @@ void ipvlan_process_multicast(struct work_struct *work)
 				nskb->pkt_type = pkt_type;
 				nskb->dev = ipvlan->dev;
 				if (tx_pkt)
-					ret = dev_forward_skb(ipvlan->dev, nskb);
+					ret = dev_forward_skb(ipvlan->dev,
+							      nskb, 0);
 				else
 					ret = netif_rx(nskb);
 			}
@@ -301,7 +302,7 @@ static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff **pskb,
 
 	if (local) {
 		skb->pkt_type = PACKET_HOST;
-		if (dev_forward_skb(ipvlan->dev, skb) == NET_RX_SUCCESS)
+		if (dev_forward_skb(ipvlan->dev, skb, 0) == NET_RX_SUCCESS)
 			success = true;
 	} else {
 		ret = RX_HANDLER_ANOTHER;
@@ -547,7 +548,7 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		 * the skb for the main-dev. At the RX side we just return
 		 * RX_PASS for it to be processed further on the stack.
 		 */
-		return dev_forward_skb(ipvlan->phy_dev, skb);
+		return dev_forward_skb(ipvlan->phy_dev, skb, 0);
 
 	} else if (is_multicast_ether_addr(eth->h_dest)) {
 		ipvlan_skb_crossing_ns(skb, NULL);
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9261722960a7..4db2876c1e44 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -202,7 +202,7 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 	struct net_device *dev = vlan->dev;
 
 	if (local)
-		return __dev_forward_skb(dev, skb);
+		return __dev_forward_skb(dev, skb, 0);
 
 	skb->dev = dev;
 	if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
@@ -495,7 +495,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		dest = macvlan_hash_lookup(port, eth->h_dest);
 		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
 			/* send to lowerdev first for its network taps */
-			dev_forward_skb(vlan->lowerdev, skb);
+			dev_forward_skb(vlan->lowerdev, skb, 0);
 
 			return NET_XMIT_SUCCESS;
 		}
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8c39d6d690e5..561da3a63b8a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -116,7 +116,7 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
-	if (likely(dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
+	if (likely(dev_forward_skb(rcv, skb, 0) == NET_RX_SUCCESS)) {
 		struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
 
 		u64_stats_update_begin(&stats->syncp);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97456b2539e4..f207b083ffec 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3282,16 +3282,16 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
-int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
-int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
+int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb, int mtu);
+int dev_forward_skb(struct net_device *dev, struct sk_buff *skb, int mtu);
 bool is_skb_forwardable(const struct net_device *dev,
-			const struct sk_buff *skb);
+			const struct sk_buff *skb, int mtu);
 
 static __always_inline int ____dev_forward_skb(struct net_device *dev,
-					       struct sk_buff *skb)
+					       struct sk_buff *skb, int mtu)
 {
 	if (skb_orphan_frags(skb, GFP_ATOMIC) ||
-	    unlikely(!is_skb_forwardable(dev, skb))) {
+	    unlikely(!is_skb_forwardable(dev, skb, mtu))) {
 		atomic_long_inc(&dev->rx_dropped);
 		kfree_skb(skb);
 		return NET_RX_DROP;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 902af6ba481c..a1a38bb0d890 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,7 +35,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 
 int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	if (!is_skb_forwardable(skb->dev, skb))
+	if (!is_skb_forwardable(skb->dev, skb, 0))
 		goto drop;
 
 	skb_push(skb, ETH_HLEN);
@@ -96,7 +96,7 @@ static void __br_forward(const struct net_bridge_port *to,
 		net = dev_net(indev);
 	} else {
 		if (unlikely(netpoll_tx_running(to->br->dev))) {
-			if (!is_skb_forwardable(skb->dev, skb)) {
+			if (!is_skb_forwardable(skb->dev, skb, skb->dev_mtu)) {
 				kfree_skb(skb);
 			} else {
 				skb_push(skb, ETH_HLEN);
diff --git a/net/core/dev.c b/net/core/dev.c
index 533a6d6f6092..f7c53d7c8e26 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1767,14 +1767,18 @@ static inline void net_timestamp_set(struct sk_buff *skb)
 			__net_timestamp(SKB);		\
 	}						\
 
-bool is_skb_forwardable(const struct net_device *dev, const struct sk_buff *skb)
+bool is_skb_forwardable(const struct net_device *dev,
+			const struct sk_buff *skb, int mtu)
 {
 	unsigned int len;
 
 	if (!(dev->flags & IFF_UP))
 		return false;
 
-	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
+	if (mtu == 0)
+		mtu = dev->mtu;
+
+	len = mtu + dev->hard_header_len + VLAN_HLEN;
 	if (skb->len <= len)
 		return true;
 
@@ -1788,9 +1792,9 @@ bool is_skb_forwardable(const struct net_device *dev, const struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(is_skb_forwardable);
 
-int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
+int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb, int mtu)
 {
-	int ret = ____dev_forward_skb(dev, skb);
+	int ret = ____dev_forward_skb(dev, skb, mtu);
 
 	if (likely(!ret)) {
 		skb->protocol = eth_type_trans(skb, dev);
@@ -1806,6 +1810,7 @@ EXPORT_SYMBOL_GPL(__dev_forward_skb);
  *
  * @dev: destination network device
  * @skb: buffer to forward
+ * @mtu: Maximum size to forward. If 0 dev->mtu is used.
  *
  * return values:
  *	NET_RX_SUCCESS	(no congestion)
@@ -1819,9 +1824,9 @@ EXPORT_SYMBOL_GPL(__dev_forward_skb);
  * we have to clear all information in the skb that could
  * impact namespace isolation.
  */
-int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
+int dev_forward_skb(struct net_device *dev, struct sk_buff *skb, int mtu)
 {
-	return __dev_forward_skb(dev, skb) ?: netif_rx_internal(skb);
+	return __dev_forward_skb(dev, skb, mtu) ?: netif_rx_internal(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index ebaeaf2e46e8..3f3eb26e7ea1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1632,13 +1632,13 @@ static const struct bpf_func_proto bpf_csum_update_proto = {
 
 static inline int __bpf_rx_skb(struct net_device *dev, struct sk_buff *skb)
 {
-	return dev_forward_skb(dev, skb);
+	return dev_forward_skb(dev, skb, 0);
 }
 
 static inline int __bpf_rx_skb_no_mac(struct net_device *dev,
 				      struct sk_buff *skb)
 {
-	int ret = ____dev_forward_skb(dev, skb);
+	int ret = ____dev_forward_skb(dev, skb, 0);
 
 	if (likely(!ret)) {
 		skb->dev = dev;
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 6fd41d7afe1e..1258555b6578 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -164,7 +164,7 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 	skb_dst_drop(skb);
 	nf_reset(skb);
 
-	if (dev_forward_skb(dev, skb) == NET_RX_SUCCESS) {
+	if (dev_forward_skb(dev, skb, 0) == NET_RX_SUCCESS) {
 		atomic_long_inc(&priv->rx_packets);
 		atomic_long_add(data_len, &priv->rx_bytes);
 	} else {
-- 
2.11.0
