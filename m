From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 2/6]NET:AX25:ROSE Add  device use counting for ROSE
 neighbour lists
Date: Sat, 16 Jul 2016 10:42:59 +0100
Message-ID: <201607160942.u6G9gxQ8014763@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 2/6]NET:AX25:ROSE Add  device use counting for ROSE neighbour lists
Adds device use counting for ROSE neighbour lists

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
---
 net/rose/rose_route.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 96ed06c..56e53d5 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -183,6 +183,7 @@ static int __must_check rose_add_node(struct rose_route_struct *rose_route,
 			}
 		}
 		rose_neigh->count++;
+		dev_hold(rose_neigh->dev);
 
 		goto out;
 	}
@@ -190,6 +191,7 @@ static int __must_check rose_add_node(struct rose_route_struct *rose_route,
 	/* We have space, slot it in */
 	if (rose_node->count < 3) {
 		rose_node->neighbour[rose_node->count] = rose_neigh;
+		dev_hold(rose_neigh->dev);
 		rose_node->count++;
 		rose_neigh->count++;
 	}
@@ -335,6 +337,7 @@ static int rose_del_node(struct rose_route_struct *rose_route,
 	for (i = 0; i < rose_node->count; i++) {
 		if (rose_node->neighbour[i] == rose_neigh) {
 			rose_neigh->count--;
+			dev_put(rose_neigh->dev);
 
 			if (rose_neigh->count == 0 && atomic_read(&rose_neigh->use) == 0)
 				rose_remove_neigh(rose_neigh);
@@ -594,12 +597,13 @@ static struct net_device *rose_ax25_dev_find(char *devname)
 {
 	struct net_device *dev;
 
-	if ((dev = __dev_get_by_name(&init_net, devname)) == NULL)
+	if ((dev = dev_get_by_name(&init_net, devname)) == NULL)
 		return NULL;
 
 	if ((dev->flags & IFF_UP) && dev->type == ARPHRD_AX25)
 		return dev;
 
+	dev_put(dev);
 	return NULL;
 }
 
@@ -616,6 +620,8 @@ struct net_device *rose_dev_first(void)
 			if (first == NULL || strncmp(dev->name, first->name, 3) < 0)
 				first = dev;
 	}
+	if (first)
+		dev_hold(first);
 	rcu_read_unlock();
 
 	return first;
@@ -734,15 +740,16 @@ int rose_rt_ioctl(unsigned int cmd, void __user *arg)
 	case SIOCADDRT:
 		if (copy_from_user(&rose_route, arg, sizeof(struct rose_route_struct)))
 			return -EFAULT;
-		if ((dev = rose_ax25_dev_find(rose_route.device)) == NULL)
-			return -EINVAL;
 		if (rose_dev_exists(&rose_route.address)) /* Can't add routes to ourself */
 			return -EINVAL;
 		if (rose_route.mask > 10) /* Mask can't be more than 10 digits */
 			return -EINVAL;
 		if (rose_route.ndigis > AX25_MAX_DIGIS)
 			return -EINVAL;
+		if ((dev = rose_ax25_dev_find(rose_route.device)) == NULL)
+			return -EINVAL;
 		err = rose_add_node(&rose_route, dev);
+		dev_put(dev);
 		return err;
 
 	case SIOCDELRT:
@@ -751,6 +758,7 @@ int rose_rt_ioctl(unsigned int cmd, void __user *arg)
 		if ((dev = rose_ax25_dev_find(rose_route.device)) == NULL)
 			return -EINVAL;
 		err = rose_del_node(&rose_route, dev);
+		dev_put(dev);
 		return err;
 
 	case SIOCRSCLRRT:
@@ -844,6 +852,7 @@ void rose_link_device_down(struct net_device *dev)
 		if (rose_neigh->dev == dev) {
 			rose_del_route_by_neigh(rose_neigh);
 			rose_kill_by_neigh(rose_neigh);
+			dev_put(dev);
 		}
 	}
 }
