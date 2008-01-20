From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 04/18]: Use dev->stats
Date: Sun, 20 Jan 2008 18:11:22 +0100 (MET)
Message-ID: <20080120171122.7980.97369.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62343 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754429AbYATRLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:24 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Use dev->stats

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit fef4f968b4704bf2b37417ca6ba0dedda696e611
tree a5f8d87d4e193b681fba07727fc3ba1a078d0cfa
parent 6fcdd6b0d244f103898c3a37be2a3f4fec50fbd8
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:54 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:54 +0100

 include/linux/if_vlan.h |    9 +--------
 net/8021q/vlan.c        |    2 --
 net/8021q/vlan_dev.c    |    8 ++++----
 net/8021q/vlanproc.c    |    5 +----
 4 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 0325d6b..07db416 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -140,18 +140,11 @@ struct vlan_dev_info {
 	struct proc_dir_entry *dent;    /* Holds the proc data */
 	unsigned long cnt_inc_headroom_on_tx; /* How many times did we have to grow the skb on TX. */
 	unsigned long cnt_encap_on_xmit;      /* How many times did we have to encapsulate the skb on TX. */
-	struct net_device_stats dev_stats; /* Device stats (rx-bytes, tx-pkts, etc...) */
 };
 
 #define VLAN_DEV_INFO(x) ((struct vlan_dev_info *)(x->priv))
 
 /* inline functions */
-
-static inline struct net_device_stats *vlan_dev_get_stats(struct net_device *dev)
-{
-	return &(VLAN_DEV_INFO(dev)->dev_stats);
-}
-
 static inline __u32 vlan_get_ingress_priority(struct net_device *dev,
 					      unsigned short vlan_tag)
 {
@@ -196,7 +189,7 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
 
 	skb->dev->last_rx = jiffies;
 
-	stats = vlan_dev_get_stats(skb->dev);
+	stats = &skb->dev->stats;
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index af25255..54f2346 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -366,8 +366,6 @@ void vlan_setup(struct net_device *new_dev)
 	 * the global list.
 	 * iflink is set as well.
 	 */
-	new_dev->get_stats = vlan_dev_get_stats;
-
 	/* Make this thing known as a VLAN device */
 	new_dev->priv_flags |= IFF_802_1Q_VLAN;
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4f99bb8..9543e91 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -174,7 +174,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	skb->dev->last_rx = jiffies;
 
 	/* Bump the rx counters for the VLAN device. */
-	stats = vlan_dev_get_stats(skb->dev);
+	stats = &skb->dev->stats;
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
@@ -422,7 +422,7 @@ int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		skb = skb_realloc_headroom(sk_tmp, dev->hard_header_len);
 		kfree_skb(sk_tmp);
 		if (skb == NULL) {
-			struct net_device_stats *stats = vlan_dev_get_stats(vdev);
+			struct net_device_stats *stats = &vdev->stats;
 			stats->tx_dropped++;
 			return -ENOMEM;
 		}
@@ -453,7 +453,7 @@ int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = vlan_dev_get_stats(dev);
+	struct net_device_stats *stats = &dev->stats;
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
 
 	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
@@ -514,7 +514,7 @@ int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = vlan_dev_get_stats(dev);
+	struct net_device_stats *stats = &dev->stats;
 	unsigned short veth_TCI;
 
 	/* Construct the second two bytes. This field looks something
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 6cefdf8..1972d5c 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -316,7 +316,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 {
 	struct net_device *vlandev = (struct net_device *) seq->private;
 	const struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
-	struct net_device_stats *stats;
+	struct net_device_stats *stats = &vlandev->stats;
 	static const char fmt[] = "%30s %12lu\n";
 	int i;
 
@@ -327,9 +327,6 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 		       vlandev->name, dev_info->vlan_id,
 		       (int)(dev_info->flags & 1), vlandev->priv_flags);
 
-
-	stats = vlan_dev_get_stats(vlandev);
-
 	seq_printf(seq, fmt, "total frames received", stats->rx_packets);
 	seq_printf(seq, fmt, "total bytes received", stats->rx_bytes);
 	seq_printf(seq, fmt, "Broadcast/Multicast Rcvd", stats->multicast);
