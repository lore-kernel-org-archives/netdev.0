From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V4 1/2] net: Utility function to get affinity_hint by policy
Date: Sun,  9 Mar 2014 09:39:08 +0200
Message-ID: <1394350749-30522-2-git-send-email-amirv@mellanox.com>
References: <1394350749-30522-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Govindarajulu Varadarajan <gvaradar@cisco.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42430 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752059AbaCIHjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Mar 2014 03:39:19 -0400
In-Reply-To: <1394350749-30522-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function sets the affinity_mask according to a numa aware policy.
affinity_mask could be used as an affinity hint for the IRQ related to
this rx queue.
Current policy is to spread rx queues accross cores - local cores first.
It could be extended in the future.

CC: Prarit Bhargava <prarit@redhat.com>
CC: Govindarajulu Varadarajan <gvaradar@cisco.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/netdevice.h |  3 +++
 net/core/dev.c            | 57 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1a86948..db4fd12 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2526,6 +2526,9 @@ static inline int netif_set_real_num_rx_queues(struct net_device *dev,
 }
 #endif
 
+int netif_set_rx_queue_affinity_hint(int rxq, int numa_node,
+				     cpumask_var_t affinity_mask);
+
 static inline int netif_copy_real_num_queues(struct net_device *to_dev,
 					     const struct net_device *from_dev)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index b1b0c8d..72a46c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2117,6 +2117,63 @@ EXPORT_SYMBOL(netif_set_real_num_rx_queues);
 #endif
 
 /**
+ * netif_set_rx_queue_affinity_hint - set affinity hint of rx queue
+ * @rxq: index of rx queue
+ * @numa_node: prefered numa_node
+ * @affinity_mask: the relevant cpu bit is set according to the policy
+ *
+ * This function sets the affinity_mask according to a numa aware policy.
+ * affinity_mask coulbe used as an affinity hint for the IRQ related to this
+ * rx queue.
+ * The policy is to spread rx queues accross cores - local cores first.
+ *
+ * Returns 0 on success, or a negative error code.
+ */
+int netif_set_rx_queue_affinity_hint(int rxq, int numa_node,
+				     cpumask_var_t affinity_mask)
+{
+	const struct cpumask *p_numa_cores_mask;
+	cpumask_var_t non_numa_cores_mask = NULL;
+	int affinity_cpu;
+	int ret = 0;
+
+	rxq %= num_online_cpus();
+
+	p_numa_cores_mask = cpumask_of_node(numa_node);
+	if (!p_numa_cores_mask)
+		p_numa_cores_mask = cpu_online_mask;
+
+	for_each_cpu(affinity_cpu, p_numa_cores_mask) {
+		if (--rxq < 0)
+			goto out;
+	}
+
+	if (!zalloc_cpumask_var(&non_numa_cores_mask, GFP_KERNEL)) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	cpumask_xor(non_numa_cores_mask, cpu_online_mask, p_numa_cores_mask);
+
+	for_each_cpu(affinity_cpu, non_numa_cores_mask) {
+		if (--rxq < 0)
+			goto out;
+	}
+
+	ret = -EINVAL;
+	goto err;
+
+out:
+	cpumask_set_cpu(affinity_cpu, affinity_mask);
+
+err:
+	free_cpumask_var(non_numa_cores_mask);
+
+	return ret;
+}
+EXPORT_SYMBOL(netif_set_rx_queue_affinity_hint);
+
+/**
  * netif_get_num_default_rss_queues - default number of RSS queues
  *
  * This routine should set an upper limit on the number of RSS queues
-- 
1.8.3.1
