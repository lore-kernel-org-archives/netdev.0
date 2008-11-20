From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next] netdevice wanrouter: Convert directly reference
 of netdev->priv
Date: Thu, 20 Nov 2008 17:16:17 +0800
Message-ID: <49252AE1.8000609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?S3J6eXN6dG9mIEhhxYI=?= =?UTF-8?B?YXNh?= <khc@pm.waw.pl>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54667 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753206AbYKTJQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 04:16:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Make device driver to allocate memory for netdev.
2. Convert all directly reference of netdev->priv to netdev_priv().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wan/cycx_x25.c |   89 ++++++++++++++++++++++----------------------
 net/wanrouter/wanmain.c    |   36 +++++------------
 2 files changed, 55 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index aeea321..5fa5292 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -199,6 +199,8 @@ static struct net_device *cycx_x25_get_dev_by_lcn(struct wan_device *wandev,
 static struct net_device *
 	cycx_x25_get_dev_by_dte_addr(struct wan_device *wandev, char *dte);
 
+static void cycx_x25_chan_setup(struct net_device *dev);
+
 #ifdef CYCLOMX_X25_DEBUG
 static void hex_dump(char *msg, unsigned char *p, int len);
 static void cycx_x25_dump_config(struct cycx_x25_config *conf);
@@ -353,6 +355,12 @@ static int cycx_wan_update(struct wan_device *wandev)
 	return 0;
 }
 
+/* callback to initialize device */
+static void cycx_x25_chan_setup(struct net_device *dev)
+{
+	dev->init = cycx_netdevice_init;
+}
+
 /* Create new logical channel.
  * This routine is called by the router when ROUTER_IFNEW IOCTL is being
  * handled.
@@ -376,11 +384,12 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 		return -EINVAL;
 	}
 
-	/* allocate and initialize private data */
-	chan = kzalloc(sizeof(struct cycx_x25_channel), GFP_KERNEL);
-	if (!chan)
+	dev = alloc_netdev(sizeof(struct cycx_x25_channel), conf->name,
+			     cycx_x25_chan_setup);
+	if (!dev)
 		return -ENOMEM;
 
+	chan = netdev_priv(dev);
 	strcpy(chan->name, conf->name);
 	chan->card = card;
 	chan->link = conf->port;
@@ -396,14 +405,14 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 			if (len > WAN_ADDRESS_SZ) {
 				printk(KERN_ERR "%s: %s local addr too long!\n",
 						wandev->name, chan->name);
-				kfree(chan);
-				return -EINVAL;
+				err = -EINVAL;
+				goto error;
 			} else {
 				chan->local_addr = kmalloc(len + 1, GFP_KERNEL);
 
 				if (!chan->local_addr) {
-					kfree(chan);
-					return -ENOMEM;
+					err = -ENOMEM;
+					goto error;
 				}
 			}
 
@@ -429,41 +438,31 @@ static int cycx_wan_new_if(struct wan_device *wandev, struct net_device *dev,
 				"%s: PVC %u is out of range on interface %s!\n",
 				wandev->name, lcn, chan->name);
 			err = -EINVAL;
+			goto error;
 		}
 	} else {
 		printk(KERN_ERR "%s: invalid media address on interface %s!\n",
 				wandev->name, chan->name);
 		err = -EINVAL;
+		goto error;
 	}
 
-	if (err) {
-		kfree(chan->local_addr);
-		kfree(chan);
-		return err;
-	}
-
-	/* prepare network device data space for registration */
-	strcpy(dev->name, chan->name);
-	dev->init = cycx_netdevice_init;
-	dev->priv = chan;
-
 	return 0;
+
+error:
+	free_netdev(dev);
+	return err;
 }
 
 /* Delete logical channel. */
 static int cycx_wan_del_if(struct wan_device *wandev, struct net_device *dev)
 {
-	if (dev->priv) {
-		struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 
-		if (chan->svc) {
-			kfree(chan->local_addr);
-			if (chan->state == WAN_CONNECTED)
-				del_timer(&chan->timer);
-		}
-
-		kfree(chan);
-		dev->priv = NULL;
+	if (chan->svc) {
+		kfree(chan->local_addr);
+		if (chan->state == WAN_CONNECTED)
+			del_timer(&chan->timer);
 	}
 
 	return 0;
@@ -484,7 +483,7 @@ static const struct header_ops cycx_header_ops = {
  * registration. */
 static int cycx_netdevice_init(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 	struct cycx_device *card = chan->card;
 	struct wan_device *wandev = &card->wandev;
 
@@ -542,7 +541,7 @@ static int cycx_netdevice_open(struct net_device *dev)
  * o if there's no more open channels then disconnect physical link. */
 static int cycx_netdevice_stop(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -596,7 +595,7 @@ static int cycx_netdevice_rebuild_header(struct sk_buff *skb)
 static int cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 					  struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 	struct cycx_device *card = chan->card;
 
 	if (!chan->svc)
@@ -670,7 +669,7 @@ free_packet:
  * Return a pointer to struct net_device_stats */
 static struct net_device_stats *cycx_netdevice_get_stats(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 
 	return chan ? &chan->ifstats : NULL;
 }
@@ -783,7 +782,7 @@ static void cycx_x25_irq_rx(struct cycx_device *card, struct cycx_x25_cmd *cmd)
 		return;
 	}
 
-	chan = dev->priv;
+	chan = netdev_priv(dev);
 	reset_timer(dev);
 
 	if (chan->drop_sequence) {
@@ -883,7 +882,7 @@ static void cycx_x25_irq_connect(struct cycx_device *card,
 		return;
 	}
 
-	chan = dev->priv;
+	chan = netdev_priv(dev);
 	chan->lcn = lcn;
 	cycx_x25_connect_response(card, chan);
 	cycx_x25_set_chan_state(dev, WAN_CONNECTED);
@@ -913,7 +912,7 @@ static void cycx_x25_irq_connect_confirm(struct cycx_device *card,
 	}
 
 	clear_bit(--key, (void*)&card->u.x.connection_keys);
-	chan = dev->priv;
+	chan = netdev_priv(dev);
 	chan->lcn = lcn;
 	cycx_x25_set_chan_state(dev, WAN_CONNECTED);
 }
@@ -953,7 +952,7 @@ static void cycx_x25_irq_disconnect(struct cycx_device *card,
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (dev) {
-		struct cycx_x25_channel *chan = dev->priv;
+		struct cycx_x25_channel *chan = netdev_priv(dev);
 
 		cycx_x25_disconnect_response(card, chan->link, lcn);
 		cycx_x25_set_chan_state(dev, WAN_DISCONNECTED);
@@ -1301,7 +1300,7 @@ static struct net_device *cycx_x25_get_dev_by_lcn(struct wan_device *wandev,
 	struct cycx_x25_channel *chan;
 
 	while (dev) {
-		chan = (struct cycx_x25_channel*)dev->priv;
+		chan = netdev_priv(dev);
 
 		if (chan->lcn == lcn)
 			break;
@@ -1318,7 +1317,7 @@ static struct net_device *
 	struct cycx_x25_channel *chan;
 
 	while (dev) {
-		chan = (struct cycx_x25_channel*)dev->priv;
+		chan = netdev_priv(dev);
 
 		if (!strcmp(chan->addr, dte))
 			break;
@@ -1336,7 +1335,7 @@ static struct net_device *
  *		<0	failure */
 static int cycx_x25_chan_connect(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 	struct cycx_device *card = chan->card;
 
 	if (chan->svc) {
@@ -1361,7 +1360,7 @@ static int cycx_x25_chan_connect(struct net_device *dev)
  * o if SVC then clear X.25 call */
 static void cycx_x25_chan_disconnect(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 
 	if (chan->svc) {
 		x25_clear_call(chan->card, chan->link, chan->lcn, 0, 0);
@@ -1374,7 +1373,7 @@ static void cycx_x25_chan_disconnect(struct net_device *dev)
 static void cycx_x25_chan_timer(unsigned long d)
 {
 	struct net_device *dev = (struct net_device *)d;
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 
 	if (chan->state == WAN_CONNECTED)
 		cycx_x25_chan_disconnect(dev);
@@ -1386,7 +1385,7 @@ static void cycx_x25_chan_timer(unsigned long d)
 /* Set logical channel state. */
 static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 	struct cycx_device *card = chan->card;
 	unsigned long flags;
 	char *string_state = NULL;
@@ -1452,7 +1451,7 @@ static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
  *    to the router.  */
 static int cycx_x25_chan_send(struct net_device *dev, struct sk_buff *skb)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 	struct cycx_device *card = chan->card;
 	int bitm = 0;		/* final packet */
 	unsigned len = skb->len;
@@ -1545,7 +1544,7 @@ static unsigned dec_to_uint(u8 *str, int len)
 
 static void reset_timer(struct net_device *dev)
 {
-	struct cycx_x25_channel *chan = dev->priv;
+	struct cycx_x25_channel *chan = netdev_priv(dev);
 
 	if (chan->svc)
 		mod_timer(&chan->timer, jiffies+chan->idle_tmout*HZ);
@@ -1598,7 +1597,7 @@ static void cycx_x25_dump_devs(struct wan_device *wandev)
 	printk(KERN_INFO "---------------------------------------\n");
 
 	while(dev) {
-		struct cycx_x25_channel *chan = dev->priv;
+		struct cycx_x25_channel *chan = netdev_priv(dev);
 
 		printk(KERN_INFO "%-5.5s %-15.15s   %d     ETH_P_%s\n",
 				 chan->name, chan->addr, netif_queue_stopped(dev),
diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 7f07152..39701de 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -60,6 +60,8 @@
 
 #define KMEM_SAFETYZONE 8
 
+#define DEV_TO_SLAVE(dev)	(*((struct net_device **)netdev_priv(dev)))
+
 /*
  * 	Function Prototypes
  */
@@ -511,7 +513,7 @@ static int wanrouter_device_shutdown(struct wan_device *wandev)
 		if (err)
 			return err;
 		/* The above function deallocates the current dev
-		 * structure. Therefore, we cannot use dev->priv
+		 * structure. Therefore, we cannot use netdev_priv(dev)
 		 * as the next element: wandev->dev points to the
 		 * next element */
 		dev = wandev->dev;
@@ -589,10 +591,6 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 		err = -EPROTONOSUPPORT;
 		goto out;
 	} else {
-		dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
-		err = -ENOBUFS;
-		if (dev == NULL)
-			goto out;
 		err = wandev->new_if(wandev, dev, cnf);
 	}
 
@@ -622,10 +620,9 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 					wandev->dev = dev;
 				} else {
 					for (slave=wandev->dev;
-					 *((struct net_device **)slave->priv);
-				 slave = *((struct net_device **)slave->priv));
-
-				     *((struct net_device **)slave->priv) = dev;
+					     DEV_TO_SLAVE(slave);
+					     slave = DEV_TO_SLAVE(slave))
+						DEV_TO_SLAVE(slave) = dev;
 				}
 				++wandev->ndev;
 
@@ -636,15 +633,9 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 		}
 		if (wandev->del_if)
 			wandev->del_if(wandev, dev);
+		free_netdev(dev);
 	}
 
-	/* This code has moved from del_if() function */
-	kfree(dev->priv);
-	dev->priv = NULL;
-
-	/* Sync PPP is disabled */
-	if (cnf->config_id != WANCONFIG_MPPP)
-		kfree(dev);
 out:
 	kfree(cnf);
 	return err;
@@ -734,7 +725,7 @@ static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 	dev = wandev->dev;
 	prev = NULL;
 	while (dev && strcmp(name, dev->name)) {
-		struct net_device **slave = dev->priv;
+		struct net_device **slave = netdev_priv(dev);
 		prev = dev;
 		dev = *slave;
 	}
@@ -751,12 +742,12 @@ static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 
 	lock_adapter_irq(&wandev->lock, &smp_flags);
 	if (prev) {
-		struct net_device **prev_slave = prev->priv;
-		struct net_device **slave = dev->priv;
+		struct net_device **prev_slave = netdev_priv(prev);
+		struct net_device **slave = netdev_priv(dev);
 
 		*prev_slave = *slave;
 	} else {
-		struct net_device **slave = dev->priv;
+		struct net_device **slave = netdev_priv(dev);
 		wandev->dev = *slave;
 	}
 	--wandev->ndev;
@@ -764,11 +755,6 @@ static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 
 	printk(KERN_INFO "%s: unregistering '%s'\n", wandev->name, dev->name);
 
-	/* Due to new interface linking method using dev->priv,
-	 * this code has moved from del_if() function.*/
-	kfree(dev->priv);
-	dev->priv=NULL;
-
 	unregister_netdev(dev);
 
 	free_netdev(dev);
-- 
1.5.3.4


