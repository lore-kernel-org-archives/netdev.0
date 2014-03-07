From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 1/2] net: Utility function to get
 affinity_hint by policy
Date: Fri, 07 Mar 2014 16:05:25 -0500 (EST)
Message-ID: <20140307.160525.2117720349792780727.davem@davemloft.net>
References: <1394126332-11110-1-git-send-email-amirv@mellanox.com>
	<1394126332-11110-2-git-send-email-amirv@mellanox.com>
	<20140306.153835.2248996436618700806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, prarit@redhat.com, gvaradar@cisco.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbaCGVF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 16:05:27 -0500
In-Reply-To: <20140306.153835.2248996436618700806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Amir, although this patch is fine, when I tried to apply this series the second
patch (the mlx4 one) did not apply.

In fact, that second patch is corrupted, in this hunk:

====================
@@ -1521,6 +1521,31 @@  static void mlx4_en_linkstate(struct work_struct *work)
 	mutex_unlock(&mdev->state_lock);
 }
 
+static void mlx4_en_init_affinity_hint(struct mlx4_en_priv *priv, int ring_idx)
+{
+	struct mlx4_en_rx_ring *ring = priv->rx_ring[ring_idx];
+	int numa_node = priv->mdev->dev->numa_node;
+
+	if (numa_node == -1)
+		return;
+
+	if (!zalloc_cpumask_var(&ring->affinity_mask, GFP_KERNEL)) {
+		en_err(priv, "Failed to allocate core mask\n");
+		return;
+	}
+
+	if (netif_set_rx_queue_affinity_hint(ring_idx, numa_node,
+					     ring->affinity_mask)) {
+		en_err(priv, "Failed setting affinity hint\n");
+		free_cpumask_var(ring->affinity_mask);
+		ring->affinity_mask = NULL;
+	}
+}
+
+static void mlx4_en_free_affinity_hint(struct mlx4_en_priv *priv, int ring_idx)
+{
+	free_cpumask_var(priv->rx_ring[ring_idx]->affinity_mask);
+	priv->rx_ring[ring_idx]->affinity_mask = NULL;
+}
 
 int mlx4_en_start_port(struct net_device *dev)
 {
====================

The hunk header says "before the change there are 6 lines, after the change
there are 31 lines"  But that's not right, after the change there will be
32 lines.

Please respin, thanks.
