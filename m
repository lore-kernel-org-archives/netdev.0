From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] net: skip genenerating uevents for network namespaces that
	are exiting
Date: Thu, 20 Oct 2016 19:46:26 -0700
Message-ID: <1477017986-18889-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

No one can see these events, because a network namespace can not be
destroyed, if it has sockets.

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

Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/core/net-sysfs.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 6e4f347..c02515e 100644
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
+		dev->kobj.uevent_suppress = 1;
+
 	kobject_get(&dev->kobj);
 
 	remove_queue_kobjects(ndev);
-- 
2.7.4
