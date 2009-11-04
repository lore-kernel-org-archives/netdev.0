From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] rose: device refcount leak
Date: Wed, 04 Nov 2009 21:31:37 +0100
Message-ID: <4AF1E4A9.7050404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60370 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932384AbZKDUbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 15:31:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While hunting dev_put() for net-next-2.6, I found a device refcount
leak in ROSE, ioctl(SIOCADDRT) error path.

Fix is to not touch device refcount, as we hold RTNL

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/rose/rose_route.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 9478d9b..c55a543 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -578,18 +578,18 @@ static int rose_clear_routes(void)
 
 /*
  *	Check that the device given is a valid AX.25 interface that is "up".
+ * 	called whith RTNL
  */
-static struct net_device *rose_ax25_dev_get(char *devname)
+static struct net_device *rose_ax25_dev_find(char *devname)
 {
 	struct net_device *dev;
 
-	if ((dev = dev_get_by_name(&init_net, devname)) == NULL)
+	if ((dev = __dev_get_by_name(&init_net, devname)) == NULL)
 		return NULL;
 
 	if ((dev->flags & IFF_UP) && dev->type == ARPHRD_AX25)
 		return dev;
 
-	dev_put(dev);
 	return NULL;
 }
 
@@ -720,27 +720,23 @@ int rose_rt_ioctl(unsigned int cmd, void __user *arg)
 	case SIOCADDRT:
 		if (copy_from_user(&rose_route, arg, sizeof(struct rose_route_struct)))
 			return -EFAULT;
-		if ((dev = rose_ax25_dev_get(rose_route.device)) == NULL)
+		if ((dev = rose_ax25_dev_find(rose_route.device)) == NULL)
 			return -EINVAL;
-		if (rose_dev_exists(&rose_route.address)) { /* Can't add routes to ourself */
-			dev_put(dev);
+		if (rose_dev_exists(&rose_route.address)) /* Can't add routes to ourself */
 			return -EINVAL;
-		}
 		if (rose_route.mask > 10) /* Mask can't be more than 10 digits */
 			return -EINVAL;
 		if (rose_route.ndigis > AX25_MAX_DIGIS)
 			return -EINVAL;
 		err = rose_add_node(&rose_route, dev);
-		dev_put(dev);
 		return err;
 
 	case SIOCDELRT:
 		if (copy_from_user(&rose_route, arg, sizeof(struct rose_route_struct)))
 			return -EFAULT;
-		if ((dev = rose_ax25_dev_get(rose_route.device)) == NULL)
+		if ((dev = rose_ax25_dev_find(rose_route.device)) == NULL)
 			return -EINVAL;
 		err = rose_del_node(&rose_route, dev);
-		dev_put(dev);
 		return err;
 
 	case SIOCRSCLRRT:
