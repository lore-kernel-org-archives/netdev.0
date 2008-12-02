From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next]dvb: Kill directly reference of netdev->priv
Date: Tue, 02 Dec 2008 21:32:30 +0800
Message-ID: <493538EE.4020704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60314 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752920AbYLBNco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 08:32:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/media/dvb/dvb-core/dvb_net.c |   37 +++++++++++++++++----------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index c93019c..03fd9dd 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -345,7 +345,7 @@ static inline void reset_ule( struct dvb_net_priv *p )
  */
 static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 	unsigned long skipped = 0L;
 	const u8 *ts, *ts_end, *from_where = NULL;
 	u8 ts_remain = 0, how_much = 0, new_ts = 1;
@@ -460,8 +460,8 @@ static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
 						/* Drop partly decoded SNDU, reset state, resync on PUSI. */
 						if (priv->ule_skb) {
 							dev_kfree_skb( priv->ule_skb );
-							((struct dvb_net_priv *) dev->priv)->stats.rx_errors++;
-							((struct dvb_net_priv *) dev->priv)->stats.rx_frame_errors++;
+							priv->stats.rx_errors++;
+							priv->stats.rx_frame_errors++;
 						}
 						reset_ule(priv);
 						priv->need_pusi = 1;
@@ -573,7 +573,7 @@ static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
 			if (priv->ule_skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
-				((struct dvb_net_priv *)dev->priv)->stats.rx_dropped++;
+				priv->stats.rx_dropped++;
 				return;
 			}
 
@@ -800,7 +800,8 @@ static void dvb_net_sec(struct net_device *dev,
 {
 	u8 *eth;
 	struct sk_buff *skb;
-	struct net_device_stats *stats = &(((struct dvb_net_priv *) dev->priv)->stats);
+	struct net_device_stats *stats =
+		&((struct dvb_net_priv *) netdev_priv(dev))->stats;
 	int snap = 0;
 
 	/* note: pkt_len includes a 32bit checksum */
@@ -917,7 +918,7 @@ static int dvb_net_filter_sec_set(struct net_device *dev,
 		   struct dmx_section_filter **secfilter,
 		   u8 *mac, u8 *mac_mask)
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 	int ret;
 
 	*secfilter=NULL;
@@ -961,7 +962,7 @@ static int dvb_net_filter_sec_set(struct net_device *dev,
 static int dvb_net_feed_start(struct net_device *dev)
 {
 	int ret = 0, i;
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 	struct dmx_demux *demux = priv->demux;
 	unsigned char *mac = (unsigned char *) dev->dev_addr;
 
@@ -1060,7 +1061,7 @@ error:
 
 static int dvb_net_feed_stop(struct net_device *dev)
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 	int i, ret = 0;
 
 	dprintk("%s\n", __func__);
@@ -1113,7 +1114,7 @@ static int dvb_net_feed_stop(struct net_device *dev)
 
 static int dvb_set_mc_filter (struct net_device *dev, struct dev_mc_list *mc)
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 
 	if (priv->multi_num == DVB_NET_MULTICAST_MAX)
 		return -ENOMEM;
@@ -1165,7 +1166,7 @@ static void wq_set_multicast_list (struct work_struct *work)
 
 static void dvb_net_set_multicast_list (struct net_device *dev)
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 	schedule_work(&priv->set_multicast_list_wq);
 }
 
@@ -1185,7 +1186,7 @@ static void wq_restart_net_feed (struct work_struct *work)
 
 static int dvb_net_set_mac (struct net_device *dev, void *p)
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 	struct sockaddr *addr=p;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
@@ -1199,7 +1200,7 @@ static int dvb_net_set_mac (struct net_device *dev, void *p)
 
 static int dvb_net_open(struct net_device *dev)
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 
 	priv->in_use++;
 	dvb_net_feed_start(dev);
@@ -1209,7 +1210,7 @@ static int dvb_net_open(struct net_device *dev)
 
 static int dvb_net_stop(struct net_device *dev)
 {
-	struct dvb_net_priv *priv = dev->priv;
+	struct dvb_net_priv *priv = netdev_priv(dev);
 
 	priv->in_use--;
 	return dvb_net_feed_stop(dev);
@@ -1217,7 +1218,7 @@ static int dvb_net_stop(struct net_device *dev)
 
 static struct net_device_stats * dvb_net_get_stats(struct net_device *dev)
 {
-	return &((struct dvb_net_priv*) dev->priv)->stats;
+	return &((struct dvb_net_priv *) netdev_priv(dev))->stats;
 }
 
 static const struct header_ops dvb_header_ops = {
@@ -1287,7 +1288,7 @@ static int dvb_net_add_if(struct dvb_net *dvbnet, u16 pid, u8 feedtype)
 
 	dvbnet->device[if_num] = net;
 
-	priv = net->priv;
+	priv = netdev_priv(net);
 	priv->net = net;
 	priv->demux = dvbnet->demux;
 	priv->pid = pid;
@@ -1320,7 +1321,7 @@ static int dvb_net_remove_if(struct dvb_net *dvbnet, unsigned long num)
 
 	if (!dvbnet->state[num])
 		return -EINVAL;
-	priv = net->priv;
+	priv = netdev_priv(net);
 	if (priv->in_use)
 		return -EBUSY;
 
@@ -1376,7 +1377,7 @@ static int dvb_net_do_ioctl(struct inode *inode, struct file *file,
 
 		netdev = dvbnet->device[dvbnetif->if_num];
 
-		priv_data = netdev->priv;
+		priv_data = netdev_priv(netdev);
 		dvbnetif->pid=priv_data->pid;
 		dvbnetif->feedtype=priv_data->feedtype;
 		break;
@@ -1427,7 +1428,7 @@ static int dvb_net_do_ioctl(struct inode *inode, struct file *file,
 
 		netdev = dvbnet->device[dvbnetif->if_num];
 
-		priv_data = netdev->priv;
+		priv_data = netdev_priv(netdev);
 		dvbnetif->pid=priv_data->pid;
 		break;
 	}
-- 
1.5.3.4


