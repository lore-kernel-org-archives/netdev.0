From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 11/12] net: add notifier hooks for devmap bpf map
Date: Fri, 07 Jul 2017 10:38:21 -0700
Message-ID: <20170707173821.9984.27299.stgit@john-Precision-Tower-5810>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, john.fastabend@gmail.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35186 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752046AbdGGRih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:38:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id q85so5409586pfq.2
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:38:36 -0700 (PDT)
In-Reply-To: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BPF map devmap holds a refcnt on the net_device structure when
it is in the map. We need to do this to ensure on driver unload we
don't lose a dev reference.

However, its not very convenient to have to manually unload the map
when destroying a net device so add notifier handlers to do the cleanup
automatically. But this creates a race between update/destroy BPF
syscall and programs and the unregister netdev hook.

Unfortunately, the best I could come up with is either to live with
requiring manual removal of net devices from the map before removing
the net device OR to add a mutex in devmap to ensure the map is not
modified while we are removing a device. The fallout also requires
that BPF programs no longer update/delete the map from the BPF program
side because the mutex may sleep and this can not be done from inside
an rcu critical section.  This is not a real problem though because I
have not come up with any use cases where this is actually useful in
practice. If/when we come up with a compelling user for this we may
need to revisit this.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/devmap.c   |   73 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c |    4 ++-
 2 files changed, 76 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 656e334..1191060 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -34,6 +34,17 @@
  * netdev_map consistent in this case. From the devmap side BPF programs
  * calling into these operations are the same as multiple user space threads
  * making system calls.
+ *
+ * Finally, any of the above may race with a netdev_unregister notifier. The
+ * unregister notifier must search for net devices in the map structure that
+ * contain a reference to the net device and remove them. This is a two step
+ * process (a) dereference the bpf_dtab_netdev object in netdev_map and (b)
+ * check to see if the ifindex is the same as the net_device being removed.
+ * Unfortunately, the xchg() operations do not protect against this. To avoid
+ * potentially removing incorrect objects the dev_map_list_mutex protects
+ * conflicting netdev unregister and BPF syscall operations. Updates and
+ * deletes from a BPF program (done in rcu critical section) are blocked
+ * because of this mutex.
  */
 #include <linux/bpf.h>
 #include <linux/jhash.h>
@@ -54,8 +65,12 @@ struct bpf_dtab {
 	struct bpf_map map;
 	struct bpf_dtab_netdev **netdev_map;
 	unsigned long int __percpu *flush_needed;
+	struct list_head list;
 };
 
+static DEFINE_MUTEX(dev_map_list_mutex);
+static LIST_HEAD(dev_map_list);
+
 static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 {
 	struct bpf_dtab *dtab;
@@ -112,6 +127,9 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	if (!dtab->netdev_map)
 		goto free_dtab;
 
+	mutex_lock(&dev_map_list_mutex);
+	list_add_tail(&dtab->list, &dev_map_list);
+	mutex_unlock(&dev_map_list_mutex);
 	return &dtab->map;
 
 free_dtab:
@@ -146,6 +164,11 @@ static void dev_map_free(struct bpf_map *map)
 			cpu_relax();
 	}
 
+	/* Although we should no longer have datapath or bpf syscall operations
+	 * at this point we we can still race with netdev notifier, hence the
+	 * lock.
+	 */
+	mutex_lock(&dev_map_list_mutex);
 	for (i = 0; i < dtab->map.max_entries; i++) {
 		struct bpf_dtab_netdev *dev;
 
@@ -160,6 +183,8 @@ static void dev_map_free(struct bpf_map *map)
 	/* At this point bpf program is detached and all pending operations
 	 * _must_ be complete
 	 */
+	list_del(&dtab->list);
+	mutex_unlock(&dev_map_list_mutex);
 	free_percpu(dtab->flush_needed);
 	bpf_map_area_free(dtab->netdev_map);
 	kfree(dtab);
@@ -296,9 +321,11 @@ static int dev_map_delete_elem(struct bpf_map *map, void *key)
 	 * the driver tear down ensures all soft irqs are complete before
 	 * removing the net device in the case of dev_put equals zero.
 	 */
+	mutex_lock(&dev_map_list_mutex);
 	old_dev = xchg(&dtab->netdev_map[k], NULL);
 	if (old_dev)
 		call_rcu(&old_dev->rcu, __dev_map_entry_free);
+	mutex_unlock(&dev_map_list_mutex);
 	return 0;
 }
 
@@ -341,9 +368,11 @@ static int dev_map_update_elem(struct bpf_map *map, void *key, void *value,
 	 * Remembering the driver side flush operation will happen before the
 	 * net device is removed.
 	 */
+	mutex_lock(&dev_map_list_mutex);
 	old_dev = xchg(&dtab->netdev_map[i], dev);
 	if (old_dev)
 		call_rcu(&old_dev->rcu, __dev_map_entry_free);
+	mutex_unlock(&dev_map_list_mutex);
 
 	return 0;
 }
@@ -356,3 +385,47 @@ static int dev_map_update_elem(struct bpf_map *map, void *key, void *value,
 	.map_update_elem = dev_map_update_elem,
 	.map_delete_elem = dev_map_delete_elem,
 };
+
+static int dev_map_notification(struct notifier_block *notifier,
+				ulong event, void *ptr)
+{
+	struct net_device *netdev = netdev_notifier_info_to_dev(ptr);
+	struct bpf_dtab *dtab;
+	int i;
+
+	switch (event) {
+	case NETDEV_UNREGISTER:
+		mutex_lock(&dev_map_list_mutex);
+		list_for_each_entry(dtab, &dev_map_list, list) {
+			for (i = 0; i < dtab->map.max_entries; i++) {
+				struct bpf_dtab_netdev *dev;
+
+				dev = dtab->netdev_map[i];
+				if (!dev ||
+				    dev->dev->ifindex != netdev->ifindex)
+					continue;
+				dev = xchg(&dtab->netdev_map[i], NULL);
+				if (dev)
+					call_rcu(&dev->rcu,
+						 __dev_map_entry_free);
+			}
+		}
+		mutex_unlock(&dev_map_list_mutex);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block dev_map_notifier = {
+	.notifier_call = dev_map_notification,
+};
+
+static int __init dev_map_init(void)
+{
+	register_netdevice_notifier(&dev_map_notifier);
+	return 0;
+}
+
+subsys_initcall(dev_map_init);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1d03956..8981704 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1299,7 +1299,9 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 	 * for now.
 	 */
 	case BPF_MAP_TYPE_DEVMAP:
-		if (func_id == BPF_FUNC_map_lookup_elem)
+		if (func_id == BPF_FUNC_map_lookup_elem ||
+		    func_id == BPF_FUNC_map_update_elem ||
+		    func_id == BPF_FUNC_map_delete_elem)
 			goto error;
 		break;
 	case BPF_MAP_TYPE_ARRAY_OF_MAPS:
