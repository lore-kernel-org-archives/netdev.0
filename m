From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] dvb-net -- allocate network device structures
Date: Tue, 7 Oct 2003 17:22:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007172257.7dff3075.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: video4linux-list@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gerd Knorr <kraxel@bytesex.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch to 2.6.0-test6 converts the DVB net driver to allocate network
devices structures in a manner similar to other network devices in 2.6 by
using alloc_netdev.  Instead of an array of structures, and array of pointers
is used.

This solves the problem of OOPS when the following is done.
	rmmod dvb_net </sys/class/net/dvb0_0/mtu

Built, but not tested on real hardware.

diff -urN -X dontdiff linux-2.5/drivers/media/dvb/dvb-core/dvb_net.c linux-2.5-net/drivers/media/dvb/dvb-core/dvb_net.c
--- linux-2.5/drivers/media/dvb/dvb-core/dvb_net.c	2003-09-30 13:53:57.000000000 -0700
+++ linux-2.5-net/drivers/media/dvb/dvb-core/dvb_net.c	2003-09-05 12:50:57.000000000 -0700
@@ -456,7 +456,7 @@
 }
 
 
-static int dvb_net_init_dev(struct net_device *dev)
+static void dvb_net_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
@@ -472,8 +472,6 @@
 	dev->hard_header_cache  = NULL;
 
 	dev->flags |= IFF_NOARP;
-	
-	return 0;
 }
 
 static int get_if(struct dvb_net *dvbnet)
@@ -495,7 +493,6 @@
 static int dvb_net_add_if(struct dvb_net *dvbnet, u16 pid)
 {
         struct net_device *net;
-	struct dmx_demux *demux;
 	struct dvb_net_priv *priv;
 	int result;
 	int if_num;
@@ -503,25 +500,20 @@
 	if ((if_num = get_if(dvbnet)) < 0)
 		return -EINVAL;
 
-	net=&dvbnet->device[if_num];
-	demux=dvbnet->demux;
+	net = alloc_netdev(sizeof(struct dvb_net_priv), "dvb",
+			   dvb_net_setup);
+	if (!net)
+		return -ENOMEM;
 	
-	memset(net, 0, sizeof(struct net_device));
+	sprintf(net->name, "dvb%d_%d", dvbnet->dvbdev->adapter->num, if_num);
 
-        memcpy(net->name, "dvb0_0", 7);
-	net->name[3]   = dvbnet->dvbdev->adapter->num + '0';
-	net->name[5]   = if_num + '0';
-	net->addr_len  = 6;
+	net->addr_len  		= 6;
 	memcpy(net->dev_addr, dvbnet->dvbdev->adapter->proposed_mac, 6);
-        net->next      = NULL;
-        net->init      = dvb_net_init_dev;
-
-	if (!(net->priv = kmalloc(sizeof(struct dvb_net_priv), GFP_KERNEL)))
-			return -ENOMEM;
 
+	dvbnet->device[if_num] = net;
+	
 	priv = net->priv;
-	memset(priv, 0, sizeof(struct dvb_net_priv));
-        priv->demux = demux;
+        priv->demux = dvbnet->demux;
         priv->pid = pid;
 	priv->rx_mode = RX_MODE_UNI;
 
@@ -531,6 +523,7 @@
         net->base_addr = pid;
                 
 	if ((result = register_netdev(net)) < 0) {
+		kfree(net);
 		return result;
 	}
 
@@ -540,18 +533,20 @@
 
 static int dvb_net_remove_if(struct dvb_net *dvbnet, int num)
 {
-	struct dvb_net_priv *priv = dvbnet->device[num].priv;
+	struct net_device *net = dvbnet->device[num];
+	struct dvb_net_priv *priv = net->priv;
 
 	if (!dvbnet->state[num])
 		return -EINVAL;
 	if (priv->in_use)
 		return -EBUSY;
 
-	dvb_net_stop(&dvbnet->device[num]);
+	dvb_net_stop(net);
 	flush_scheduled_work();
-	kfree(priv);
-        unregister_netdev(&dvbnet->device[num]);
+        unregister_netdev(net);
 	dvbnet->state[num]=0;
+	free_netdev(net);
+
 	return 0;
 }
 
diff -urN -X dontdiff linux-2.5/drivers/media/dvb/dvb-core/dvb_net.h linux-2.5-net/drivers/media/dvb/dvb-core/dvb_net.h
--- linux-2.5/drivers/media/dvb/dvb-core/dvb_net.h	2003-09-30 13:53:57.000000000 -0700
+++ linux-2.5-net/drivers/media/dvb/dvb-core/dvb_net.h	2003-09-05 12:50:57.000000000 -0700
@@ -35,7 +35,7 @@
 
 struct dvb_net {
 	struct dvb_device *dvbdev;
-	struct net_device device[DVB_NET_DEVICES_MAX];
+	struct net_device *device[DVB_NET_DEVICES_MAX];
 	int state[DVB_NET_DEVICES_MAX];
 	struct dmx_demux *demux;
 };
