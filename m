From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/16] batman-adv: Fix alignment after opened parentheses
Date: Mon,  2 Jul 2012 01:43:44 +0200
Message-ID: <1341186226-10549-15-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23572 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab2GAXno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:44 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/debugfs.c        |   18 +++++++++++-------
 net/batman-adv/hard-interface.c |    8 ++++----
 net/batman-adv/originator.c     |    9 +++++----
 net/batman-adv/routing.c        |    3 +--
 net/batman-adv/unicast.c        |    5 +++--
 5 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index e45cf0e..34fbb16 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -111,6 +111,11 @@ static int batadv_log_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
+static int batadv_log_empty(struct batadv_debug_log *debug_log)
+{
+	return !(debug_log->log_start - debug_log->log_end);
+}
+
 static ssize_t batadv_log_read(struct file *file, char __user *buf,
 			       size_t count, loff_t *ppos)
 {
@@ -120,8 +125,7 @@ static ssize_t batadv_log_read(struct file *file, char __user *buf,
 	char *char_addr;
 	char c;
 
-	if ((file->f_flags & O_NONBLOCK) &&
-	    !(debug_log->log_end - debug_log->log_start))
+	if ((file->f_flags & O_NONBLOCK) && batadv_log_empty(debug_log))
 		return -EAGAIN;
 
 	if (!buf)
@@ -134,7 +138,7 @@ static ssize_t batadv_log_read(struct file *file, char __user *buf,
 		return -EFAULT;
 
 	error = wait_event_interruptible(debug_log->queue_wait,
-				(debug_log->log_start - debug_log->log_end));
+					 (!batadv_log_empty(debug_log)));
 
 	if (error)
 		return error;
@@ -175,7 +179,7 @@ static unsigned int batadv_log_poll(struct file *file, poll_table *wait)
 
 	poll_wait(file, &debug_log->queue_wait, wait);
 
-	if (debug_log->log_end - debug_log->log_start)
+	if (!batadv_log_empty(debug_log))
 		return POLLIN | POLLRDNORM;
 
 	return 0;
@@ -370,9 +374,9 @@ int batadv_debugfs_add_meshif(struct net_device *dev)
 
 	for (bat_debug = batadv_mesh_debuginfos; *bat_debug; ++bat_debug) {
 		file = debugfs_create_file(((*bat_debug)->attr).name,
-					  S_IFREG | ((*bat_debug)->attr).mode,
-					  bat_priv->debug_dir,
-					  dev, &(*bat_debug)->fops);
+					   S_IFREG | ((*bat_debug)->attr).mode,
+					   bat_priv->debug_dir,
+					   dev, &(*bat_debug)->fops);
 		if (!file) {
 			batadv_err(dev, "Can't add debugfs file: %s/%s\n",
 				   dev->name, ((*bat_debug)->attr).name);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 60f50c5..282bf6e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -324,15 +324,15 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	batadv_info(hard_iface->soft_iface, "Adding interface: %s\n",
 		    hard_iface->net_dev->name);
 
-	if (atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
-		ETH_DATA_LEN + BATADV_HEADER_LEN)
+	if (atomic_read(&bat_priv->fragmentation) &&
+	    hard_iface->net_dev->mtu < ETH_DATA_LEN + BATADV_HEADER_LEN)
 		batadv_info(hard_iface->soft_iface,
 			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. Packets going over this interface will be fragmented on layer2 which could impact the performance. Setting the MTU to %zi would solve the problem.\n",
 			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
 			    ETH_DATA_LEN + BATADV_HEADER_LEN);
 
-	if (!atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
-		ETH_DATA_LEN + BATADV_HEADER_LEN)
+	if (!atomic_read(&bat_priv->fragmentation) &&
+	    hard_iface->net_dev->mtu < ETH_DATA_LEN + BATADV_HEADER_LEN)
 		batadv_info(hard_iface->soft_iface,
 			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. If you experience problems getting traffic through try increasing the MTU to %zi.\n",
 			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index fc1ce26..ac9bdf8 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -413,6 +413,7 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 	int batman_count = 0;
 	int last_seen_secs;
 	int last_seen_msecs;
+	unsigned long last_seen_jiffies;
 	uint32_t i;
 	int ret = 0;
 
@@ -451,10 +452,10 @@ int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 			if (neigh_node->tq_avg == 0)
 				goto next;
 
-			last_seen_secs = jiffies_to_msecs(jiffies -
-						orig_node->last_seen) / 1000;
-			last_seen_msecs = jiffies_to_msecs(jiffies -
-						orig_node->last_seen) % 1000;
+			last_seen_jiffies = jiffies - orig_node->last_seen;
+			last_seen_msecs = jiffies_to_msecs(last_seen_jiffies);
+			last_seen_secs = last_seen_msecs / 1000;
+			last_seen_msecs = last_seen_msecs % 1000;
 
 			seq_printf(seq, "%pM %4i.%03is   (%3i) %pM [%10s]:",
 				   orig_node->orig, last_seen_secs,
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b79e42e..bc2b88b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -969,8 +969,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 				  ETH_HLEN) < 0)
 			return 0;
 
-		ethhdr = (struct ethhdr *)(skb->data +
-			sizeof(struct batadv_unicast_packet));
+		ethhdr = (struct ethhdr *)(skb->data + sizeof(*unicast_packet));
 
 		/* we don't have an updated route for this client, so we should
 		 * not try to reroute the packet!!
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index c42b81d..0016464 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -296,6 +296,7 @@ int batadv_unicast_send_skb(struct sk_buff *skb, struct batadv_priv *bat_priv)
 	struct batadv_neigh_node *neigh_node;
 	int data_len = skb->len;
 	int ret = 1;
+	unsigned int dev_mtu;
 
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
@@ -344,9 +345,9 @@ find_router:
 	if (batadv_tt_global_client_is_roaming(bat_priv, ethhdr->h_dest))
 		unicast_packet->ttvn = unicast_packet->ttvn - 1;
 
+	dev_mtu = neigh_node->if_incoming->net_dev->mtu;
 	if (atomic_read(&bat_priv->fragmentation) &&
-	    data_len + sizeof(*unicast_packet) >
-				neigh_node->if_incoming->net_dev->mtu) {
+	    data_len + sizeof(*unicast_packet) > dev_mtu) {
 		/* send frag skb decreases ttl */
 		unicast_packet->header.ttl++;
 		ret = batadv_frag_send_skb(skb, bat_priv,
-- 
1.7.9.4
