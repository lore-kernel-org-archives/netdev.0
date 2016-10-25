From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH v2] net: skip genenerating uevents for network namespaces that are exiting
Date: Mon, 24 Oct 2016 19:09:53 -0700
Message-ID: <1477361393-24876-1-git-send-email-avagin@openvz.org>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
        containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Andrei Vagin <avagin@openvz.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No one can see these events, because a network namespace can not be
destroyed, if it has sockets.

Unlike other devices, uevent-s for network devices are generated
only inside their network namespaces. They are filtered in
kobj_bcast_filter()

My experiments shows that net namespaces are destroyed more 30% faster
with this optimization.

Here is a perf output for destroying network namespaces without this
patch.

-   94.76%     0.02%  kworker/u48:1  [kernel.kallsyms]     [k] cleanup_net
   - 94.74% cleanup_net
      - 94.64% ops_exit_list.isra.4
         - 41.61% default_device_exit_batch
            - 41.47% unregister_netdevice_many
               - rollback_registered_many
                  - 40.36% netdev_unregister_kobject
                     - 14.55% device_del
                        + 13.71% kobject_uevent
                     - 13.04% netdev_queue_update_kobjects
                        + 12.96% kobject_put
                     - 12.72% net_rx_queue_update_kobjects
                          kobject_put
                        - kobject_release
                           + 12.69% kobject_uevent
                  + 0.80% call_netdevice_notifiers_info
         + 19.57% nfsd_exit_net
         + 11.15% tcp_net_metrics_exit
         + 8.25% rpcsec_gss_exit_net

It's very critical to optimize the exit path for network namespaces,
because they are destroyed under net_mutex and many namespaces can be
destroyed for one iteration.

v2: use dev_set_uevent_suppress()

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/core/net-sysfs.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 6e4f347..d4fe286 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -950,10 +950,13 @@ net_rx_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 	}
 
 	while (--i >= new_num) {
+		struct kobject *kobj = &dev->_rx[i].kobj;
+
+		if (!list_empty(&dev_net(dev)->exit_list))
+			kobj->uevent_suppress = 1;
 		if (dev->sysfs_rx_queue_group)
-			sysfs_remove_group(&dev->_rx[i].kobj,
-					   dev->sysfs_rx_queue_group);
-		kobject_put(&dev->_rx[i].kobj);
+			sysfs_remove_group(kobj, dev->sysfs_rx_queue_group);
+		kobject_put(kobj);
 	}
 
 	return error;
@@ -1340,6 +1343,8 @@ netdev_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 	while (--i >= new_num) {
 		struct netdev_queue *queue = dev->_tx + i;
 
+		if (!list_empty(&dev_net(dev)->exit_list))
+			queue->kobj.uevent_suppress = 1;
 #ifdef CONFIG_BQL
 		sysfs_remove_group(&queue->kobj, &dql_group);
 #endif
@@ -1525,6 +1530,9 @@ void netdev_unregister_kobject(struct net_device *ndev)
 {
 	struct device *dev = &(ndev->dev);
 
+	if (!list_empty(&dev_net(ndev)->exit_list))
+		dev_set_uevent_suppress(dev, 1);
+
 	kobject_get(&dev->kobj);
 
 	remove_queue_kobjects(ndev);
-- 
2.7.4
