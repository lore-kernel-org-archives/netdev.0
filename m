From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 2/2] vlan: use struct netdev_queue counters instead of dev->stats
Date: Mon, 18 May 2009 12:35:38 +0200
Message-ID: <4A1139FA.2030703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51297 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbZERKfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 06:35:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can update netdev_queue tx_bytes/tx_packets/tx_dropped counters instead
of dev->stats ones, to reduce number of cache lines dirtied in xmit path.

This fixes a performance problem on SMP when many different cpus take
vlan tx path.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/8021q/vlan_dev.c |   14 +++++++-------
 net/8021q/vlanproc.c |    3 ++-
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 25ba41e..8faacee 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -290,7 +290,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = &dev->stats;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
 
 	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
@@ -309,7 +309,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 		skb = __vlan_put_tag(skb, vlan_tci);
 		if (!skb) {
-			stats->tx_dropped++;
+			txq->tx_dropped++;
 			return NETDEV_TX_OK;
 		}
 
@@ -317,8 +317,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
 	}
 
-	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	txq->tx_packets++;
+	txq->tx_bytes += skb->len;
 
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	dev_queue_xmit(skb);
@@ -328,15 +328,15 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
-	struct net_device_stats *stats = &dev->stats;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	u16 vlan_tci;
 
 	vlan_tci = vlan_dev_info(dev)->vlan_id;
 	vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 	skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 
-	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	txq->tx_packets++;
+	txq->tx_bytes += skb->len;
 
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	dev_queue_xmit(skb);
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 3628e0a..b55a091 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -279,13 +279,14 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 {
 	struct net_device *vlandev = (struct net_device *) seq->private;
 	const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
-	struct net_device_stats *stats = &vlandev->stats;
+	const struct net_device_stats *stats;
 	static const char fmt[] = "%30s %12lu\n";
 	int i;
 
 	if (!is_vlan_dev(vlandev))
 		return 0;
 
+	stats = dev_get_stats(vlandev);
 	seq_printf(seq,
 		   "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
 		   vlandev->name, dev_info->vlan_id,
