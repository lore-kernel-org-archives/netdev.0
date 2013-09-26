From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 1/4] [RFC] net: Explicitly initialize u64_stats_sync structures for lockdep
Date: Thu, 26 Sep 2013 11:34:21 -0700
Message-ID: <1380220464-28840-2-git-send-email-john.stultz@linaro.org>
References: <1380220464-28840-1-git-send-email-john.stultz@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roger Luethi <rl@hellgate.ch>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>, Jesse Gross <jesse@nicira.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380220464-28840-1-git-send-email-john.stultz@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to enable lockdep on seqcount/seqlock structures, we
must explicitly initialize any locks.

The u64_stats_sync structure, uses a seqcount, and thus we need
to introduce a u64_stats_init() function and use it to initialize
the structure.

This unfortunately adds a lot of fairly trivial initialization code
to a number of drivers. But the benefit of ensuring correctness makes
this worth while.

Because these changes are required for lockdep to be enabled, and the
changes are quite trivial, I've not yet split this patch out into 30-some
separate patches, as I figured it would be better to get the various
maintainers thoughts on how to best merge this change along with
the seqcount lockdep enablement code.

Feedback would be appreciated!

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Mirko Lindner <mlindner@marvell.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Roger Luethi <rl@hellgate.ch>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 drivers/net/dummy.c                            |  6 ++++++
 drivers/net/ethernet/emulex/benet/be_main.c    |  4 ++++
 drivers/net/ethernet/intel/igb/igb_main.c      |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  4 ++++
 drivers/net/ethernet/marvell/mvneta.c          |  3 +++
 drivers/net/ethernet/marvell/sky2.c            |  3 +++
 drivers/net/ethernet/neterion/vxge/vxge-main.c |  4 ++++
 drivers/net/ethernet/nvidia/forcedeth.c        |  2 ++
 drivers/net/ethernet/realtek/8139too.c         |  3 +++
 drivers/net/ethernet/tile/tilepro.c            |  2 ++
 drivers/net/ethernet/via/via-rhine.c           |  3 +++
 drivers/net/ifb.c                              |  5 +++++
 drivers/net/loopback.c                         |  6 ++++++
 drivers/net/macvlan.c                          |  7 +++++++
 drivers/net/nlmon.c                            |  8 ++++++++
 drivers/net/team/team.c                        |  6 ++++++
 drivers/net/team/team_mode_loadbalance.c       |  9 ++++++++-
 drivers/net/veth.c                             |  8 ++++++++
 drivers/net/virtio_net.c                       |  8 ++++++++
 drivers/net/vxlan.c                            |  8 ++++++++
 drivers/net/xen-netfront.c                     |  6 ++++++
 include/linux/u64_stats_sync.h                 |  7 +++++++
 net/8021q/vlan_dev.c                           |  9 ++++++++-
 net/bridge/br_device.c                         |  7 +++++++
 net/ipv4/af_inet.c                             | 14 ++++++++++++++
 net/ipv4/ip_tunnel.c                           |  8 +++++++-
 net/ipv6/addrconf.c                            | 14 ++++++++++++++
 net/ipv6/af_inet6.c                            | 14 ++++++++++++++
 net/ipv6/ip6_gre.c                             | 15 +++++++++++++++
 net/ipv6/ip6_tunnel.c                          |  7 +++++++
 net/ipv6/sit.c                                 | 15 +++++++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c                 | 25 ++++++++++++++++++++++---
 net/openvswitch/datapath.c                     |  6 ++++++
 net/openvswitch/vport.c                        |  8 ++++++++
 34 files changed, 253 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index b710c6b..bd8f84b 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -88,10 +88,16 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int dummy_dev_init(struct net_device *dev)
 {
+	int i;
 	dev->dstats = alloc_percpu(struct pcpu_dstats);
 	if (!dev->dstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_dstats *dstats;
+		dstats = per_cpu_ptr(dev->dstats, i);
+		u64_stats_init(&dstats->syncp);
+	}
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 100b528..d2dcf2e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2033,6 +2033,9 @@ static int be_tx_qs_create(struct be_adapter *adapter)
 		if (status)
 			return status;
 
+		u64_stats_init(&txo->stats.sync);
+		u64_stats_init(&txo->stats.sync_compl);
+
 		/* If num_evt_qs is less than num_tx_qs, then more than
 		 * one txq share an eq
 		 */
@@ -2094,6 +2097,7 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 		if (rc)
 			return rc;
 
+		u64_stats_init(&rxo->stats.sync);
 		eq = &adapter->eq_obj[i % adapter->num_evt_qs].q;
 		rc = be_cmd_cq_create(adapter, cq, eq, false, 3);
 		if (rc)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8cf44f2..b6edb93 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1223,6 +1223,9 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 		ring->count = adapter->tx_ring_count;
 		ring->queue_index = txr_idx;
 
+		u64_stats_init(&ring->tx_syncp);
+		u64_stats_init(&ring->tx_syncp2);
+
 		/* assign ring to adapter */
 		adapter->tx_ring[txr_idx] = ring;
 
@@ -1256,6 +1259,8 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 		ring->count = adapter->rx_ring_count;
 		ring->queue_index = rxr_idx;
 
+		u64_stats_init(&ring->rx_syncp);
+
 		/* assign ring to adapter */
 		adapter->rx_ring[rxr_idx] = ring;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0ade0cd..c175036 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4867,6 +4867,8 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 
+	u64_stats_init(&tx_ring->syncp);
+
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
@@ -4949,6 +4951,8 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 	if (!rx_ring->rx_buffer_info)
 		goto err;
 
+	u64_stats_init(&rx_ring->syncp);
+
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e35bac7..cb4635c 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2792,6 +2792,9 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	pp = netdev_priv(dev);
 
+	u64_stats_init(&pp->tx_stats.syncp);
+	u64_stats_init(&pp->rx_stats.syncp);
+
 	pp->weight = MVNETA_RX_POLL_WEIGHT;
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index e09a8c6..339d841 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4763,6 +4763,9 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 	sky2->hw = hw;
 	sky2->msg_enable = netif_msg_init(debug, default_msg);
 
+	u64_stats_init(&sky2->tx_stats.syncp);
+	u64_stats_init(&sky2->rx_stats.syncp);
+
 	/* Auto speed and flow control */
 	sky2->flags = SKY2_FLAG_AUTO_SPEED | SKY2_FLAG_AUTO_PAUSE;
 	if (hw->chip_id != CHIP_ID_YUKON_XL)
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 5a20eaf..44626ec 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -2072,6 +2072,10 @@ static int vxge_open_vpaths(struct vxgedev *vdev)
 				vdev->config.tx_steering_type;
 			vpath->fifo.ndev = vdev->ndev;
 			vpath->fifo.pdev = vdev->pdev;
+
+			u64_stats_init(&vpath->fifo.stats.syncp);
+			u64_stats_init(&vpath->ring.stats.syncp);
+
 			if (vdev->config.tx_steering_type)
 				vpath->fifo.txq =
 					netdev_get_tx_queue(vdev->ndev, i);
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 098b96d..2d045be 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5619,6 +5619,8 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	spin_lock_init(&np->lock);
 	spin_lock_init(&np->hwstats_lock);
 	SET_NETDEV_DEV(dev, &pci_dev->dev);
+	u64_stats_init(&np->swstats_rx_syncp);
+	u64_stats_init(&np->swstats_tx_syncp);
 
 	init_timer(&np->oom_kick);
 	np->oom_kick.data = (unsigned long) dev;
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 3ccedeb..c40e9848 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -791,6 +791,9 @@ static struct net_device *rtl8139_init_board(struct pci_dev *pdev)
 
 	pci_set_master (pdev);
 
+	u64_stats_init(&tp->rx_stats.syncp);
+	u64_stats_init(&tp->tx_stats.syncp);
+
 retry:
 	/* PIO bar register comes first. */
 	bar = !use_io;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 106be47..edb2e12 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -1008,6 +1008,8 @@ static void tile_net_register(void *dev_ptr)
 	info->egress_timer.data = (long)info;
 	info->egress_timer.function = tile_net_handle_egress_timer;
 
+	u64_stats_init(&info->stats.syncp);
+
 	priv->cpu[my_cpu] = info;
 
 	/*
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index c8f088a..13cade2 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -987,6 +987,9 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rp->base = ioaddr;
 
+	u64_stats_init(&rp->tx_stats.syncp);
+	u64_stats_init(&rp->rx_stats.syncp);
+
 	/* Get chip registers into a sane state */
 	rhine_power_init(dev);
 	rhine_hw_init(dev, pioaddr);
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index a3bed28..c14d39b 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -265,6 +265,7 @@ MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
+	struct ifb_private *dp;
 	int err;
 
 	dev_ifb = alloc_netdev(sizeof(struct ifb_private),
@@ -273,6 +274,10 @@ static int __init ifb_init_one(int index)
 	if (!dev_ifb)
 		return -ENOMEM;
 
+	dp = netdev_priv(dev_ifb);
+	u64_stats_init(&dp->rsync);
+	u64_stats_init(&dp->tsync);
+
 	dev_ifb->rtnl_link_ops = &ifb_link_ops;
 	err = register_netdevice(dev_ifb);
 	if (err < 0)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index a17d85a..ac24c27 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -137,10 +137,16 @@ static const struct ethtool_ops loopback_ethtool_ops = {
 
 static int loopback_dev_init(struct net_device *dev)
 {
+	int i;
 	dev->lstats = alloc_percpu(struct pcpu_lstats);
 	if (!dev->lstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_lstats *lb_stats;
+		lb_stats = per_cpu_ptr(dev->lstats, i);
+		u64_stats_init(&lb_stats->syncp);
+	}
 	return 0;
 }
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9bf46bd..0924e51b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -501,6 +501,7 @@ static int macvlan_init(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	const struct net_device *lowerdev = vlan->lowerdev;
+	int i;
 
 	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
 				  (lowerdev->state & MACVLAN_STATE_MASK);
@@ -516,6 +517,12 @@ static int macvlan_init(struct net_device *dev)
 	if (!vlan->pcpu_stats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct macvlan_pcpu_stats *mvlstats;
+		mvlstats = per_cpu_ptr(vlan->pcpu_stats, i);
+		u64_stats_init(&mvlstats->syncp);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index b57ce5f..d2bb12b 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -47,8 +47,16 @@ static int nlmon_change_mtu(struct net_device *dev, int new_mtu)
 
 static int nlmon_dev_init(struct net_device *dev)
 {
+	int i;
+
 	dev->lstats = alloc_percpu(struct pcpu_lstats);
 
+	for_each_possible_cpu(i) {
+		struct pcpu_lstats *nlmstats;
+		nlmstats = per_cpu_ptr(dev->lstats, i);
+		u64_stats_init(&nlmstats->syncp);
+	}
+
 	return dev->lstats == NULL ? -ENOMEM : 0;
 }
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 50e43e6..6574eb8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1540,6 +1540,12 @@ static int team_init(struct net_device *dev)
 	if (!team->pcpu_stats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct team_pcpu_stats *team_stats;
+		team_stats = per_cpu_ptr(team->pcpu_stats, i);
+		u64_stats_init(&team_stats->syncp);
+	}
+
 	for (i = 0; i < TEAM_PORT_HASHENTRIES; i++)
 		INIT_HLIST_HEAD(&team->en_port_hlist[i]);
 	INIT_LIST_HEAD(&team->port_list);
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 829a9cd..d671fc3 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -570,7 +570,7 @@ static int lb_init(struct team *team)
 {
 	struct lb_priv *lb_priv = get_lb_priv(team);
 	lb_select_tx_port_func_t *func;
-	int err;
+	int i, err;
 
 	/* set default tx port selector */
 	func = lb_select_tx_port_get_func("hash");
@@ -588,6 +588,13 @@ static int lb_init(struct team *team)
 		goto err_alloc_pcpu_stats;
 	}
 
+	for_each_possible_cpu(i) {
+		struct lb_pcpu_stats *team_lb_stats;
+		team_lb_stats = per_cpu_ptr(lb_priv->pcpu_stats, i);
+		u64_stats_init(&team_lb_stats->syncp);
+	}
+
+
 	INIT_DELAYED_WORK(&lb_priv->ex->stats.refresh_dw, lb_stats_refresh);
 
 	err = team_options_register(team, lb_options, ARRAY_SIZE(lb_options));
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index eee1f19..46e83e3 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -230,10 +230,18 @@ static int veth_change_mtu(struct net_device *dev, int new_mtu)
 
 static int veth_dev_init(struct net_device *dev)
 {
+	int i;
+
 	dev->vstats = alloc_percpu(struct pcpu_vstats);
 	if (!dev->vstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_vstats *veth_stats;
+		veth_stats = per_cpu_ptr(dev->vstats, i);
+		u64_stats_init(&veth_stats->syncp);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index defec2b..bd12772 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1559,6 +1559,14 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (vi->stats == NULL)
 		goto free;
 
+	for_each_possible_cpu(i) {
+		struct virtnet_stats *virtnet_stats;
+		virtnet_stats = per_cpu_ptr(vi->stats, i);
+		u64_stats_init(&virtnet_stats->tx_syncp);
+		u64_stats_init(&virtnet_stats->rx_syncp);
+	}
+
+
 	vi->vq_index = alloc_percpu(int);
 	if (vi->vq_index == NULL)
 		goto free_stats;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d1292fe..2e4cdc8 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1886,11 +1886,19 @@ static int vxlan_init(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_sock *vs;
+	int i;
 
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *vxlan_stats;
+		vxlan_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&vxlan_stats->syncp);
+	}
+
+
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(dev_net(dev), vxlan->dst_port);
 	if (vs) {
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 36808bf..54223ac 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1338,6 +1338,12 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	if (np->stats == NULL)
 		goto exit;
 
+	for_each_possible_cpu(i) {
+		struct netfront_stats *xen_nf_stats;
+		xen_nf_stats = per_cpu_ptr(np->stats, i);
+		u64_stats_init(&xen_nf_stats->syncp);
+	}
+
 	/* Initialise tx_skbs as a free chain containing every entry. */
 	np->tx_skb_freelist = 0;
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_sync.h
index 8da8c4e..c450e11 100644
--- a/include/linux/u64_stats_sync.h
+++ b/include/linux/u64_stats_sync.h
@@ -67,6 +67,13 @@ struct u64_stats_sync {
 #endif
 };
 
+
+#if BITS_PER_LONG == 32 && defined(CONFIG_SMP)
+#define u64_stats_init(syncp)	seqcount_init(syncp.seq)
+#else
+#define u64_stats_init(syncp)
+#endif
+
 static inline void u64_stats_update_begin(struct u64_stats_sync *syncp)
 {
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 09bf1c3..4deff3e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -558,7 +558,7 @@ static const struct net_device_ops vlan_netdev_ops;
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
-	int subclass = 0;
+	int subclass = 0, i;
 
 	netif_carrier_off(dev);
 
@@ -612,6 +612,13 @@ static int vlan_dev_init(struct net_device *dev)
 	if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct vlan_pcpu_stats *vlan_stat;
+		vlan_stat = per_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats, i);
+		u64_stats_init(&vlan_stat->syncp);
+	}
+
+
 	return 0;
 }
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ca04163..7893d64 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -88,11 +88,18 @@ out:
 static int br_dev_init(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	int i;
 
 	br->stats = alloc_percpu(struct br_cpu_netstats);
 	if (!br->stats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct br_cpu_netstats *br_dev_stats;
+		br_dev_stats = per_cpu_ptr(br->stats, i);
+		u64_stats_init(&br_dev_stats->syncp);
+	}
+
 	return 0;
 }
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7a1874b..f40ce62 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1520,6 +1520,7 @@ int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align)
 	ptr[0] = __alloc_percpu(mibsize, align);
 	if (!ptr[0])
 		return -ENOMEM;
+
 #if SNMP_ARRAY_SZ == 2
 	ptr[1] = __alloc_percpu(mibsize, align);
 	if (!ptr[1]) {
@@ -1563,6 +1564,8 @@ static const struct net_protocol icmp_protocol = {
 
 static __net_init int ipv4_mib_init_net(struct net *net)
 {
+	int i;
+
 	if (snmp_mib_init((void __percpu **)net->mib.tcp_statistics,
 			  sizeof(struct tcp_mib),
 			  __alignof__(struct tcp_mib)) < 0)
@@ -1571,6 +1574,17 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 			  sizeof(struct ipstats_mib),
 			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
+
+	for_each_possible_cpu(i) {
+		struct ipstats_mib *af_inet_stats;
+		af_inet_stats = per_cpu_ptr(net->mib.ip_statistics[0], i);
+		u64_stats_init(&af_inet_stats->syncp);
+#if SNMP_ARRAY_SZ == 2
+		af_inet_stats = per_cpu_ptr(net->mib.ip_statistics[1], i);
+		u64_stats_init(&af_inet_stats->syncp);
+#endif
+	}
+
 	if (snmp_mib_init((void __percpu **)net->mib.net_statistics,
 			  sizeof(struct linux_mib),
 			  __alignof__(struct linux_mib)) < 0)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index ac9fabe..2b9c945 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -976,13 +976,19 @@ int ip_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
-	int err;
+	int i, err;
 
 	dev->destructor	= ip_tunnel_dev_free;
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *ipt_stats;
+		ipt_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&ipt_stats->syncp);
+	}
+
 	err = gro_cells_init(&tunnel->gro_cells, dev);
 	if (err) {
 		free_percpu(dev->tstats);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d6ff126..390953c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -281,10 +281,24 @@ static void addrconf_mod_dad_timer(struct inet6_ifaddr *ifp,
 
 static int snmp6_alloc_dev(struct inet6_dev *idev)
 {
+	int i;
+
 	if (snmp_mib_init((void __percpu **)idev->stats.ipv6,
 			  sizeof(struct ipstats_mib),
 			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip;
+
+	for_each_possible_cpu(i) {
+		struct ipstats_mib *addrconf_stats;
+		addrconf_stats = per_cpu_ptr(idev->stats.ipv6[0], i);
+		u64_stats_init(&addrconf_stats->syncp);
+#if SNMP_ARRAY_SZ == 2
+		addrconf_stats = per_cpu_ptr(idev->stats.ipv6[1], i);
+		u64_stats_init(&addrconf_stats->syncp);
+#endif
+	}
+
+
 	idev->stats.icmpv6dev = kzalloc(sizeof(struct icmpv6_mib_device),
 					GFP_KERNEL);
 	if (!idev->stats.icmpv6dev)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7c96100..a8f8559 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -719,6 +719,8 @@ static void ipv6_packet_cleanup(void)
 
 static int __net_init ipv6_init_mibs(struct net *net)
 {
+	int i;
+
 	if (snmp_mib_init((void __percpu **)net->mib.udp_stats_in6,
 			  sizeof(struct udp_mib),
 			  __alignof__(struct udp_mib)) < 0)
@@ -731,6 +733,18 @@ static int __net_init ipv6_init_mibs(struct net *net)
 			  sizeof(struct ipstats_mib),
 			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
+
+	for_each_possible_cpu(i) {
+		struct ipstats_mib *af_inet6_stats;
+		af_inet6_stats = per_cpu_ptr(net->mib.ipv6_statistics[0], i);
+		u64_stats_init(&af_inet6_stats->syncp);
+#if SNMP_ARRAY_SZ == 2
+		af_inet6_stats = per_cpu_ptr(net->mib.ipv6_statistics[1], i);
+		u64_stats_init(&af_inet6_stats->syncp);
+#endif
+	}
+
+
 	if (snmp_mib_init((void __percpu **)net->mib.icmpv6_statistics,
 			  sizeof(struct icmpv6_mib),
 			  __alignof__(struct icmpv6_mib)) < 0)
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 6b26e9f..b355cb0 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1254,6 +1254,7 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 static int ip6gre_tunnel_init(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
+	int i;
 
 	tunnel = netdev_priv(dev);
 
@@ -1271,6 +1272,13 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *ip6gre_tunnel_stats;
+		ip6gre_tunnel_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&ip6gre_tunnel_stats->syncp);
+	}
+
+
 	return 0;
 }
 
@@ -1451,6 +1459,7 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
 static int ip6gre_tap_init(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
+	int i;
 
 	tunnel = netdev_priv(dev);
 
@@ -1464,6 +1473,12 @@ static int ip6gre_tap_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *ip6gre_tap_stats;
+		ip6gre_tap_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&ip6gre_tap_stats->syncp);
+	}
+
 	return 0;
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2d8f482..b0e3aa1 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1486,12 +1486,19 @@ static inline int
 ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
+	int i;
 
 	t->dev = dev;
 	t->net = dev_net(dev);
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
+
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *ip6_tnl_stats;
+		ip6_tnl_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&ip6_tnl_stats->syncp);
+	}
 	return 0;
 }
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 7ee5cb9..24889fc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1256,6 +1256,7 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 static int ipip6_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int i;
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
@@ -1268,6 +1269,12 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *ipip6_tunnel_stats;
+		ipip6_tunnel_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&ipip6_tunnel_stats->syncp);
+	}
+
 	return 0;
 }
 
@@ -1277,6 +1284,7 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	struct iphdr *iph = &tunnel->parms.iph;
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
+	int i;
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
@@ -1290,6 +1298,13 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
+
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *ipip6_fb_stats;
+		ipip6_fb_stats = per_cpu_ptr(dev->tstats, i);
+		u64_stats_init(&ipip6_fb_stats->syncp);
+	}
+
 	dev_hold(dev);
 	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c8148e4..5c54c23 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -836,7 +836,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	       struct ip_vs_dest **dest_p)
 {
 	struct ip_vs_dest *dest;
-	unsigned int atype;
+	unsigned int atype, i;
 
 	EnterFunction(2);
 
@@ -863,6 +863,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	if (!dest->stats.cpustats)
 		goto err_alloc;
 
+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *ip_vs_dest_stats;
+		ip_vs_dest_stats = per_cpu_ptr(dest->stats.cpustats, i);
+		u64_stats_init(&ip_vs_dest_stats->syncp);
+	}
+
 	dest->af = svc->af;
 	dest->protocol = svc->protocol;
 	dest->vaddr = svc->addr;
@@ -1136,7 +1142,7 @@ static int
 ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		  struct ip_vs_service **svc_p)
 {
-	int ret = 0;
+	int ret = 0, i;
 	struct ip_vs_scheduler *sched = NULL;
 	struct ip_vs_pe *pe = NULL;
 	struct ip_vs_service *svc = NULL;
@@ -1186,6 +1192,13 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 		goto out_err;
 	}
 
+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *ip_vs_stats;
+		ip_vs_stats = per_cpu_ptr(svc->stats.cpustats, i);
+		u64_stats_init(&ip_vs_stats->syncp);
+	}
+
+
 	/* I'm the first user of the service */
 	atomic_set(&svc->refcnt, 0);
 
@@ -3796,7 +3809,7 @@ static struct notifier_block ip_vs_dst_notifier = {
 
 int __net_init ip_vs_control_net_init(struct net *net)
 {
-	int idx;
+	int i, idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	/* Initialize rs_table */
@@ -3815,6 +3828,12 @@ int __net_init ip_vs_control_net_init(struct net *net)
 	if (!ipvs->tot_stats.cpustats)
 		return -ENOMEM;
 
+	for_each_possible_cpu(i) {
+		struct ip_vs_cpu_stats *ipvs_tot_stats;
+		ipvs_tot_stats = per_cpu_ptr(ipvs->tot_stats.cpustats, i);
+		u64_stats_init(&ipvs_tot_stats->syncp);
+	}
+
 	spin_lock_init(&ipvs->tot_stats.lock);
 
 	proc_create("ip_vs", 0, net->proc_net, &ip_vs_info_fops);
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2aa13bd..b92553c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1698,6 +1698,12 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_table;
 	}
 
+	for_each_possible_cpu(i) {
+		struct dp_stats_percpu *dpath_stats;
+		dpath_stats = per_cpu_ptr(dp->stats_percpu, i);
+		u64_stats_init(&dpath_stats->sync);
+	}
+
 	dp->ports = kmalloc(DP_VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
 			GFP_KERNEL);
 	if (!dp->ports) {
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6f65dbe..d830a95f 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -118,6 +118,7 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 {
 	struct vport *vport;
 	size_t alloc_size;
+	int i;
 
 	alloc_size = sizeof(struct vport);
 	if (priv_size) {
@@ -141,6 +142,13 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 		return ERR_PTR(-ENOMEM);
 	}
 
+	for_each_possible_cpu(i) {
+		struct pcpu_tstats *vport_stats;
+		vport_stats = per_cpu_ptr(vport->percpu_stats, i);
+		u64_stats_init(&vport_stats->syncp);
+	}
+
+
 	spin_lock_init(&vport->stats_lock);
 
 	return vport;
-- 
1.8.1.2
