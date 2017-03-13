From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH] net: use net->count to check whether a netns is alive or not
Date: Sun, 12 Mar 2017 21:36:18 -0700
Message-ID: <20170313043618.16183-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        =?UTF-8?q?Mantas=20Mikul=C4=97nas?= <grawity@gmail.com>,
        stable@vger.kernel.org, Andrei Vagin <avagin@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous idea was to check whether a net namespace is in
net_exit_list or not. It doesn't work, because net->exit_list is used in
__register_pernet_operations and __unregister_pernet_operations where
all namespaces are added to a temporary list to make cleanup in a error
case, so list_empty(&net->exit_list) always returns false.

Reported-by: Mantas Mikulėnas <grawity@gmail.com>
Fixes: 002d8a1a6c11 ("net: skip genenerating uevents for network namespaces that are exiting")
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/core/net-sysfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b0c04cf..1004418 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -952,7 +952,7 @@ net_rx_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 	while (--i >= new_num) {
 		struct kobject *kobj = &dev->_rx[i].kobj;
 
-		if (!list_empty(&dev_net(dev)->exit_list))
+		if (!atomic_read(&dev_net(dev)->count))
 			kobj->uevent_suppress = 1;
 		if (dev->sysfs_rx_queue_group)
 			sysfs_remove_group(kobj, dev->sysfs_rx_queue_group);
@@ -1370,7 +1370,7 @@ netdev_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 	while (--i >= new_num) {
 		struct netdev_queue *queue = dev->_tx + i;
 
-		if (!list_empty(&dev_net(dev)->exit_list))
+		if (!atomic_read(&dev_net(dev)->count))
 			queue->kobj.uevent_suppress = 1;
 #ifdef CONFIG_BQL
 		sysfs_remove_group(&queue->kobj, &dql_group);
@@ -1557,7 +1557,7 @@ void netdev_unregister_kobject(struct net_device *ndev)
 {
 	struct device *dev = &(ndev->dev);
 
-	if (!list_empty(&dev_net(ndev)->exit_list))
+	if (!atomic_read(&dev_net(ndev)->count))
 		dev_set_uevent_suppress(dev, 1);
 
 	kobject_get(&dev->kobj);
-- 
2.9.3
