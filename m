From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/11) netrom - ax25  interface changes
Date: Wed, 13 Aug 2003 15:41:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813154120.0b2ef7e8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>,
   netdev@oss.sgi.com, linux-hams@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeroen Vreeken <pe1rxq@amsat.org>

Better control over the AX25 devices


diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 13:19:42 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 13:19:42 2003
@@ -1363,6 +1363,7 @@
 
 	for (i = 0; i < nr_ndevs; i++) {
 		sprintf(dev_nr[i].name, "nr%d", i);
+		dev_nr[i].base_addr = i;
 		dev_nr[i].init = nr_init;
 		register_netdev(&dev_nr[i]);
 	}
@@ -1407,23 +1408,23 @@
 
 	nr_rt_free();
 
-	ax25_protocol_release(AX25_P_NETROM);
+#ifdef CONFIG_SYSCTL
+	nr_unregister_sysctl();
+#endif
+
 	ax25_linkfail_release(nr_link_failed);
+	ax25_protocol_release(AX25_P_NETROM);
 
 	unregister_netdevice_notifier(&nr_dev_notifier);
 
-#ifdef CONFIG_SYSCTL
-	nr_unregister_sysctl();
-#endif
 	sock_unregister(PF_NETROM);
 
 	for (i = 0; i < nr_ndevs; i++) {
 		if (dev_nr[i].priv != NULL) {
+			unregister_netdev(&dev_nr[i]);
 			kfree(dev_nr[i].priv);
 			dev_nr[i].priv = NULL;
-			unregister_netdev(&dev_nr[i]);
 		}
-		kfree(dev_nr[i].name);
 	}
 
 	kfree(dev_nr);
diff -Nru a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
--- a/net/netrom/nr_dev.c	Wed Aug 13 13:19:42 2003
+++ b/net/netrom/nr_dev.c	Wed Aug 13 13:19:42 2003
@@ -159,11 +159,13 @@
 {
 	struct sockaddr *sa = addr;
 
-	ax25_listen_release((ax25_address *)dev->dev_addr, NULL);
+	if (dev->flags & IFF_UP)
+		ax25_listen_release((ax25_address *)dev->dev_addr, NULL);
 
 	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
 
-	ax25_listen_register((ax25_address *)dev->dev_addr, NULL);
+	if (dev->flags & IFF_UP)
+		ax25_listen_register((ax25_address *)dev->dev_addr, NULL);
 
 	return 0;
 }
@@ -177,8 +179,8 @@
 
 static int nr_close(struct net_device *dev)
 {
-	netif_stop_queue(dev);
 	ax25_listen_release((ax25_address *)dev->dev_addr, NULL);
+	netif_stop_queue(dev);
 	return 0;
 }
 
@@ -207,6 +208,7 @@
 	dev->hard_header_len	= NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 	dev->addr_len		= AX25_ADDR_LEN;
 	dev->type		= ARPHRD_NETROM;
+	dev->tx_queue_len	= 40;
 	dev->rebuild_header	= nr_rebuild_header;
 	dev->set_mac_address    = nr_set_mac_address;
 
