From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/9) freenetdev - destructors
Date: Tue, 19 Aug 2003 12:23:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819122319.20cad225.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Drivers that use kfree in destructor are easily converted
to use free_netdev.

diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	Tue Aug 19 11:54:46 2003
+++ b/drivers/net/hamradio/bpqether.c	Tue Aug 19 11:54:46 2003
@@ -482,7 +482,7 @@
 	dev->set_mac_address = bpq_set_mac_address;
 	dev->get_stats	     = bpq_get_stats;
 	dev->do_ioctl	     = bpq_ioctl;
-	dev->destructor	     =  (void (*)(struct net_device *)) kfree;
+	dev->destructor	     = free_netdev;
 
 	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
 	memcpy(dev->dev_addr,  ax25_defaddr, AX25_ADDR_LEN);
diff -Nru a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c	Tue Aug 19 11:54:46 2003
+++ b/drivers/net/ppp_generic.c	Tue Aug 19 11:54:46 2003
@@ -2256,11 +2256,6 @@
  * and for initialization.
  */
 
-static void ppp_device_destructor(struct net_device *dev)
-{
-	kfree(dev);
-}
-
 /*
  * Create a new ppp interface unit.  Fails if it can't allocate memory
  * or if there is already a unit with the requested number.
@@ -2309,7 +2304,7 @@
 	dev->init = ppp_net_init;
 	sprintf(dev->name, "ppp%d", unit);
 	dev->priv = ppp;
-	dev->destructor = ppp_device_destructor;
+	dev->destructor = free_netdev;
 
 	rtnl_lock();
 	ret = register_netdevice(dev);
diff -Nru a/drivers/net/shaper.c b/drivers/net/shaper.c
--- a/drivers/net/shaper.c	Tue Aug 19 11:54:46 2003
+++ b/drivers/net/shaper.c	Tue Aug 19 11:54:46 2003
@@ -642,7 +642,7 @@
 
 	dev->open		= shaper_open;
 	dev->stop		= shaper_close;
-	dev->destructor 	= (void (*)(struct net_device *))kfree;
+	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit 	= shaper_start_xmit;
 	dev->get_stats 		= shaper_get_stats;
 	dev->set_multicast_list = NULL;
diff -Nru a/drivers/net/slip.c b/drivers/net/slip.c
--- a/drivers/net/slip.c	Tue Aug 19 11:54:46 2003
+++ b/drivers/net/slip.c	Tue Aug 19 11:54:46 2003
@@ -640,7 +640,7 @@
 	dev->init		= sl_init;
 	dev->uninit	  	= sl_uninit;
 	dev->open		= sl_open;
-	dev->destructor		= (void (*)(struct net_device *))kfree;
+	dev->destructor		= free_netdev;
 	dev->stop		= sl_close;
 	dev->get_stats	        = sl_get_stats;
 	dev->change_mtu		= sl_change_mtu;
diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	Tue Aug 19 11:54:46 2003
+++ b/drivers/net/tun.c	Tue Aug 19 11:54:46 2003
@@ -358,7 +358,7 @@
 	dev->hard_start_xmit = tun_net_xmit;
 	dev->stop = tun_net_close;
 	dev->get_stats = tun_net_stats;
-	dev->destructor = (void (*)(struct net_device *))kfree;
+	dev->destructor = free_netdev;
 }
 
 static struct tun_struct *tun_get_by_name(const char *name)
diff -Nru a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
--- a/drivers/net/wan/hdlc_fr.c	Tue Aug 19 11:54:46 2003
+++ b/drivers/net/wan/hdlc_fr.c	Tue Aug 19 11:54:46 2003
@@ -1055,7 +1055,7 @@
 		return -EIO;
 	}
 
-	dev->destructor = (void (*)(struct net_device *)) kfree;
+	dev->destructor = free_netdev;
 	*get_dev_p(pvc, type) = dev;
 	if (!used) {
 		hdlc->state.fr.dce_changed = 1;
diff -Nru a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
--- a/drivers/net/wan/lapbether.c	Tue Aug 19 11:54:46 2003
+++ b/drivers/net/wan/lapbether.c	Tue Aug 19 11:54:46 2003
@@ -324,7 +324,7 @@
 	dev->hard_start_xmit = lapbeth_xmit;
 	dev->open	     = lapbeth_open;
 	dev->stop	     = lapbeth_close;
-	dev->destructor	     = (void (*)(struct net_device *))kfree;
+	dev->destructor	     = free_netdev;
 	dev->set_mac_address = lapbeth_set_mac_address;
 	dev->get_stats	     = lapbeth_get_stats;
 	dev->type            = ARPHRD_X25;
diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	Tue Aug 19 11:54:46 2003
+++ b/net/8021q/vlan.c	Tue Aug 19 11:54:46 2003
@@ -358,7 +358,7 @@
 	new_dev->stop = vlan_dev_stop;
 	new_dev->set_mac_address = vlan_dev_set_mac_address;
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
-	new_dev->destructor = (void (*)(struct net_device *)) kfree;
+	new_dev->destructor = free_netdev;
 }
 
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	Tue Aug 19 11:54:46 2003
+++ b/net/bridge/br_device.c	Tue Aug 19 11:54:46 2003
@@ -110,22 +110,6 @@
 	return -1;
 }
 
-/* convert later to direct kfree */
-static void br_dev_free(struct net_device *dev)
-{
-	struct net_bridge *br = dev->priv;
-
-	WARN_ON(!list_empty(&br->port_list));
-	WARN_ON(!list_empty(&br->age_list));
-
-	BUG_ON(timer_pending(&br->hello_timer));
-	BUG_ON(timer_pending(&br->tcn_timer));
-	BUG_ON(timer_pending(&br->topology_change_timer));
-	BUG_ON(timer_pending(&br->gc_timer));
-
-	kfree(dev);
-}
-
 void br_dev_setup(struct net_device *dev)
 {
 	memset(dev->dev_addr, 0, ETH_ALEN);
@@ -137,7 +121,7 @@
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
-	dev->destructor = br_dev_free;
+	dev->destructor = free_netdev;
 	SET_MODULE_OWNER(dev);
 	dev->stop = br_dev_stop;
 	dev->accept_fastpath = br_dev_accept_fastpath;
diff -Nru a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
--- a/net/ipv4/ip_gre.c	Tue Aug 19 11:54:46 2003
+++ b/net/ipv4/ip_gre.c	Tue Aug 19 11:54:46 2003
@@ -1128,7 +1128,7 @@
 {
 	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipgre_tunnel_uninit;
-	dev->destructor 	= (void (*)(struct net_device *))kfree;
+	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit	= ipgre_tunnel_xmit;
 	dev->get_stats		= ipgre_tunnel_get_stats;
 	dev->do_ioctl		= ipgre_tunnel_ioctl;
diff -Nru a/net/ipv4/ipip.c b/net/ipv4/ipip.c
--- a/net/ipv4/ipip.c	Tue Aug 19 11:54:46 2003
+++ b/net/ipv4/ipip.c	Tue Aug 19 11:54:46 2003
@@ -246,7 +246,7 @@
 	nt = dev->priv;
 	SET_MODULE_OWNER(dev);
 	dev->init = ipip_tunnel_init;
-	dev->destructor = (void (*)(struct net_device *))kfree;
+	dev->destructor = free_netdev;
 	nt->parms = *parms;
 
 	if (register_netdevice(dev) < 0) {
diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Tue Aug 19 11:54:46 2003
+++ b/net/ipv4/ipmr.c	Tue Aug 19 11:54:46 2003
@@ -193,7 +193,7 @@
 	dev->flags		= IFF_NOARP;
 	dev->hard_start_xmit	= reg_vif_xmit;
 	dev->get_stats		= reg_vif_get_stats;
-	dev->destructor		= (void (*)(struct net_device *)) kfree;
+	dev->destructor		= free_netdev;
 }
 
 static struct net_device *ipmr_reg_vif(void)
diff -Nru a/net/ipv6/sit.c b/net/ipv6/sit.c
--- a/net/ipv6/sit.c	Tue Aug 19 11:54:46 2003
+++ b/net/ipv6/sit.c	Tue Aug 19 11:54:46 2003
@@ -722,7 +722,7 @@
 {
 	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipip6_tunnel_uninit;
-	dev->destructor 	= (void (*)(struct net_device *))kfree;
+	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit	= ipip6_tunnel_xmit;
 	dev->get_stats		= ipip6_tunnel_get_stats;
 	dev->do_ioctl		= ipip6_tunnel_ioctl;
diff -Nru a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c	Tue Aug 19 11:54:46 2003
+++ b/net/irda/irda_device.c	Tue Aug 19 11:54:46 2003
@@ -372,11 +372,6 @@
 	irda_task_kick(task);
 }
 
-static void irda_device_destructor(struct net_device *dev)
-{
-	kfree(dev);
-}
-
 /*
  * Function irda_device_setup (dev)
  *
@@ -388,7 +383,7 @@
         dev->hard_header_len = 0;
         dev->addr_len        = 0;
 
-	dev->destructor      = irda_device_destructor;
+	dev->destructor      = free_netdev;
 
         dev->type            = ARPHRD_IRDA;
         dev->tx_queue_len    = 8; /* Window size + 1 s-frame */
diff -Nru a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
--- a/net/netrom/nr_dev.c	Tue Aug 19 11:54:46 2003
+++ b/net/netrom/nr_dev.c	Tue Aug 19 11:54:46 2003
@@ -204,7 +204,7 @@
 	dev->hard_start_xmit	= nr_xmit;
 	dev->open		= nr_open;
 	dev->stop		= nr_close;
-	dev->destructor		= (void (*)(struct net_device *))kfree;
+	dev->destructor		= free_netdev;
 
 	dev->hard_header	= nr_header;
 	dev->hard_header_len	= NR_NETWORK_LEN + NR_TRANSPORT_LEN;
