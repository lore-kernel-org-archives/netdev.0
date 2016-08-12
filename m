From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 6/6] net: virtio-net: Convert to hotplug state machine
Date: Fri, 12 Aug 2016 19:49:43 +0200
Message-ID: <1471024183-12666-7-git-send-email-bigeasy@linutronix.de>
References: <1471024183-12666-1-git-send-email-bigeasy@linutronix.de>
Cc: rt@linutronix.de, Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471024183-12666-1-git-send-email-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Install the callbacks via the state machine.
The driver supports multiple instances and therefore the new
cpuhp_state_add_instance_nocalls() infrastrucure is used. The driver
currently uses get_online_cpus() to avoid missing a CPU hotplug event
while invoking virtnet_set_affinity(). This could be avoided by using
cpuhp_state_add_instance() variant which holds the hotplug lock and
invokes callback during registration. This is more or less a 1:1
conversation of the current code.

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/virtio_net.c   | 110 +++++++++++++++++++++++++++++++++++----------
 include/linux/cpuhotplug.h |   1 +
 2 files changed, 87 insertions(+), 24 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1b5f531eeb25..e9be88cd76c1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -138,8 +138,9 @@ struct virtnet_info {
 	/* Does the affinity hint is set for virtqueues? */
 	bool affinity_hint_set;
 
-	/* CPU hot plug notifier */
-	struct notifier_block nb;
+	/* CPU hotplug instances for online & dead */
+	struct hlist_node node;
+	struct hlist_node node_dead;
 
 	/* Control VQ buffers: protected by the rtnl lock */
 	struct virtio_net_ctrl_hdr ctrl_hdr;
@@ -1237,25 +1238,53 @@ static void virtnet_set_affinity(struct virtnet_info *vi)
 	vi->affinity_hint_set = true;
 }
 
-static int virtnet_cpu_callback(struct notifier_block *nfb,
-			        unsigned long action, void *hcpu)
+static int virtnet_cpu_online(unsigned int cpu, struct hlist_node *node)
 {
-	struct virtnet_info *vi = container_of(nfb, struct virtnet_info, nb);
+	struct virtnet_info *vi = hlist_entry_safe(node, struct virtnet_info,
+						   node);
+	virtnet_set_affinity(vi);
+	return 0;
+}
 
-	switch(action & ~CPU_TASKS_FROZEN) {
-	case CPU_ONLINE:
-	case CPU_DOWN_FAILED:
-	case CPU_DEAD:
-		virtnet_set_affinity(vi);
-		break;
-	case CPU_DOWN_PREPARE:
-		virtnet_clean_affinity(vi, (long)hcpu);
-		break;
-	default:
-		break;
-	}
+static int virtnet_cpu_dead(unsigned int cpu, struct hlist_node *node)
+{
+	struct virtnet_info *vi = hlist_entry_safe(node, struct virtnet_info,
+						   node_dead);
+	virtnet_set_affinity(vi);
+	return 0;
+}
 
-	return NOTIFY_OK;
+static int virtnet_cpu_down_prep(unsigned int cpu, struct hlist_node *node)
+{
+	struct virtnet_info *vi = hlist_entry_safe(node, struct virtnet_info,
+						   node);
+
+	virtnet_clean_affinity(vi, cpu);
+	return 0;
+}
+
+static enum cpuhp_state virtionet_online;
+
+static int virtnet_cpu_notif_add(struct virtnet_info *vi)
+{
+	int ret;
+
+	ret = cpuhp_state_add_instance_nocalls(virtionet_online, &vi->node);
+	if (ret)
+		return ret;
+	ret = cpuhp_state_add_instance_nocalls(CPUHP_VIRT_NET_DEAD,
+					       &vi->node_dead);
+	if (!ret)
+		return ret;
+	cpuhp_state_remove_instance_nocalls(virtionet_online, &vi->node);
+	return ret;
+}
+
+static void virtnet_cpu_notif_remove(struct virtnet_info *vi)
+{
+	cpuhp_state_remove_instance_nocalls(virtionet_online, &vi->node);
+	cpuhp_state_remove_instance_nocalls(CPUHP_VIRT_NET_DEAD,
+					    &vi->node_dead);
 }
 
 static void virtnet_get_ringparam(struct net_device *dev,
@@ -1879,8 +1908,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	virtio_device_ready(vdev);
 
-	vi->nb.notifier_call = &virtnet_cpu_callback;
-	err = register_hotcpu_notifier(&vi->nb);
+	err = virtnet_cpu_notif_add(vi);
 	if (err) {
 		pr_debug("virtio_net: registering cpu notifier failed\n");
 		goto free_unregister_netdev;
@@ -1934,7 +1962,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 
-	unregister_hotcpu_notifier(&vi->nb);
+	virtnet_cpu_notif_remove(vi);
 
 	/* Make sure no work handler is accessing the device. */
 	flush_work(&vi->config_work);
@@ -1953,7 +1981,7 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	struct virtnet_info *vi = vdev->priv;
 	int i;
 
-	unregister_hotcpu_notifier(&vi->nb);
+	virtnet_cpu_notif_remove(vi);
 
 	/* Make sure no work handler is accessing the device */
 	flush_work(&vi->config_work);
@@ -1997,7 +2025,7 @@ static int virtnet_restore(struct virtio_device *vdev)
 	virtnet_set_queues(vi, vi->curr_queue_pairs);
 	rtnl_unlock();
 
-	err = register_hotcpu_notifier(&vi->nb);
+	err = virtnet_cpu_notif_add(vi);
 	if (err)
 		return err;
 
@@ -2039,7 +2067,41 @@ static struct virtio_driver virtio_net_driver = {
 #endif
 };
 
-module_virtio_driver(virtio_net_driver);
+static __init int virtio_net_driver_init(void)
+{
+	int ret;
+
+	ret = cpuhp_setup_state_multi(CPUHP_AP_ONLINE_DYN, "AP_VIRT_NET_ONLINE",
+				      virtnet_cpu_online,
+				      virtnet_cpu_down_prep);
+	if (ret < 0)
+		goto out;
+	virtionet_online = ret;
+	ret = cpuhp_setup_state_multi(CPUHP_VIRT_NET_DEAD, "VIRT_NET_DEAD",
+				      NULL, virtnet_cpu_dead);
+	if (ret)
+		goto err_dead;
+
+        ret = register_virtio_driver(&virtio_net_driver);
+	if (ret)
+		goto err_virtio;
+	return 0;
+err_virtio:
+	cpuhp_remove_state_nocalls(CPUHP_VIRT_NET_DEAD);
+err_dead:
+	cpuhp_remove_state_nocalls(virtionet_online);
+out:
+	return ret;
+}
+module_init(virtio_net_driver_init);
+
+static __exit void virtio_net_driver_exit(void)
+{
+	cpuhp_remove_state_nocalls(CPUHP_VIRT_NET_DEAD);
+	cpuhp_remove_state_nocalls(virtionet_online);
+	unregister_virtio_driver(&virtio_net_driver);
+}
+module_exit(virtio_net_driver_exit);
 
 MODULE_DEVICE_TABLE(virtio, id_table);
 MODULE_DESCRIPTION("Virtio network driver");
diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 81cc20789a3e..5c657c836de6 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -20,6 +20,7 @@ enum cpuhp_state {
 	CPUHP_PROFILE_PREPARE,
 	CPUHP_X2APIC_PREPARE,
 	CPUHP_SMPCFD_PREPARE,
+	CPUHP_VIRT_NET_DEAD,
 	CPUHP_RCUTREE_PREP,
 	CPUHP_NOTIFY_PREPARE,
 	CPUHP_TIMERS_DEAD,
-- 
2.8.1
