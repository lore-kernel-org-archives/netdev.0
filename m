From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove net_init.c ifdef clutter
Date: Mon, 1 Nov 2004 14:01:44 +0100
Message-ID: <20041101130144.GA8727@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Move the devicetype-specific functions from net_init.c to the
devicetype-specific files under net/.


--- 1.24/drivers/net/net_init.c	2004-04-06 00:46:26 +02:00
+++ edited/drivers/net/net_init.c	2004-11-01 13:20:45 +01:00
@@ -105,260 +105,6 @@
 }
 EXPORT_SYMBOL(alloc_netdev);
 
-/**
- * alloc_etherdev - Allocates and sets up an ethernet device
- * @sizeof_priv: Size of additional driver-private structure to be allocated
- *	for this ethernet device
- *
- * Fill in the fields of the device structure with ethernet-generic
- * values. Basically does everything except registering the device.
- *
- * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
- * this private data area.
- */
-
-struct net_device *alloc_etherdev(int sizeof_priv)
-{
-	return alloc_netdev(sizeof_priv, "eth%d", ether_setup);
-}
-
-EXPORT_SYMBOL(alloc_etherdev);
-
-static int eth_mac_addr(struct net_device *dev, void *p)
-{
-	struct sockaddr *addr=p;
-	if (netif_running(dev))
-		return -EBUSY;
-	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
-	return 0;
-}
-
-static int eth_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > 1500))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
-#ifdef CONFIG_FDDI
-
-/**
- * alloc_fddidev - Register FDDI device
- * @sizeof_priv: Size of additional driver-private structure to be allocated
- *	for this FDDI device
- *
- * Fill in the fields of the device structure with FDDI-generic values.
- *
- * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
- * this private data area.
- */
-
-struct net_device *alloc_fddidev(int sizeof_priv)
-{
-	return alloc_netdev(sizeof_priv, "fddi%d", fddi_setup);
-}
-
-EXPORT_SYMBOL(alloc_fddidev);
-
-static int fddi_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < FDDI_K_SNAP_HLEN) || (new_mtu > FDDI_K_SNAP_DLEN))
-		return(-EINVAL);
-	dev->mtu = new_mtu;
-	return(0);
-}
-
-#endif /* CONFIG_FDDI */
-
-#ifdef CONFIG_HIPPI
-
-static int hippi_change_mtu(struct net_device *dev, int new_mtu)
-{
-	/*
-	 * HIPPI's got these nice large MTUs.
-	 */
-	if ((new_mtu < 68) || (new_mtu > 65280))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return(0);
-}
-
-
-/*
- * For HIPPI we will actually use the lower 4 bytes of the hardware
- * address as the I-FIELD rather than the actual hardware address.
- */
-static int hippi_mac_addr(struct net_device *dev, void *p)
-{
-	struct sockaddr *addr = p;
-	if (netif_running(dev))
-		return -EBUSY;
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	return 0;
-}
-
-static int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
-{
-	/* Never send broadcast/multicast ARP messages */
-	p->mcast_probes = 0;
- 
-	/* In IPv6 unicast probes are valid even on NBMA,
-	* because they are encapsulated in normal IPv6 protocol.
-	* Should be a generic flag. 
-	*/
-	if (p->tbl->family != AF_INET6)
-		p->ucast_probes = 0;
-	return 0;
-}
-
-static void hippi_setup(struct net_device *dev)
-{
-	dev->set_multicast_list	= NULL;
-	dev->change_mtu			= hippi_change_mtu;
-	dev->hard_header		= hippi_header;
-	dev->rebuild_header 		= hippi_rebuild_header;
-	dev->set_mac_address 		= hippi_mac_addr;
-	dev->hard_header_parse		= NULL;
-	dev->hard_header_cache		= NULL;
-	dev->header_cache_update	= NULL;
-	dev->neigh_setup 		= hippi_neigh_setup_dev; 
-
-	/*
-	 * We don't support HIPPI `ARP' for the time being, and probably
-	 * never will unless someone else implements it. However we
-	 * still need a fake ARPHRD to make ifconfig and friends play ball.
-	 */
-	dev->type		= ARPHRD_HIPPI;
-	dev->hard_header_len 	= HIPPI_HLEN;
-	dev->mtu		= 65280;
-	dev->addr_len		= HIPPI_ALEN;
-	dev->tx_queue_len	= 25 /* 5 */;
-	memset(dev->broadcast, 0xFF, HIPPI_ALEN);
-
-
-	/*
-	 * HIPPI doesn't support broadcast+multicast and we only use
-	 * static ARP tables. ARP is disabled by hippi_neigh_setup_dev. 
-	 */
-	dev->flags = 0; 
-}
-
-/**
- * alloc_hippi_dev - Register HIPPI device
- * @sizeof_priv: Size of additional driver-private structure to be allocated
- *	for this HIPPI device
- *
- * Fill in the fields of the device structure with HIPPI-generic values.
- *
- * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
- * this private data area.
- */
-
-struct net_device *alloc_hippi_dev(int sizeof_priv)
-{
-	return alloc_netdev(sizeof_priv, "hip%d", hippi_setup);
-}
-
-EXPORT_SYMBOL(alloc_hippi_dev);
-
-#endif /* CONFIG_HIPPI */
-
-void ether_setup(struct net_device *dev)
-{
-	/* Fill in the fields of the device structure with ethernet-generic values.
-	   This should be in a common file instead of per-driver.  */
-	
-	dev->change_mtu		= eth_change_mtu;
-	dev->hard_header	= eth_header;
-	dev->rebuild_header 	= eth_rebuild_header;
-	dev->set_mac_address 	= eth_mac_addr;
-	dev->hard_header_cache	= eth_header_cache;
-	dev->header_cache_update= eth_header_cache_update;
-	dev->hard_header_parse	= eth_header_parse;
-
-	dev->type		= ARPHRD_ETHER;
-	dev->hard_header_len 	= ETH_HLEN;
-	dev->mtu		= 1500; /* eth_mtu */
-	dev->addr_len		= ETH_ALEN;
-	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */	
-	
-	memset(dev->broadcast,0xFF, ETH_ALEN);
-
-	/* New-style flags. */
-	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
-}
-EXPORT_SYMBOL(ether_setup);
-
-#ifdef CONFIG_FDDI
-
-void fddi_setup(struct net_device *dev)
-{
-	/*
-	 * Fill in the fields of the device structure with FDDI-generic values.
-	 * This should be in a common file instead of per-driver.
-	 */
-	
-	dev->change_mtu			= fddi_change_mtu;
-	dev->hard_header		= fddi_header;
-	dev->rebuild_header		= fddi_rebuild_header;
-
-	dev->type				= ARPHRD_FDDI;
-	dev->hard_header_len	= FDDI_K_SNAP_HLEN+3;	/* Assume 802.2 SNAP hdr len + 3 pad bytes */
-	dev->mtu				= FDDI_K_SNAP_DLEN;		/* Assume max payload of 802.2 SNAP frame */
-	dev->addr_len			= FDDI_K_ALEN;
-	dev->tx_queue_len		= 100;	/* Long queues on FDDI */
-	
-	memset(dev->broadcast, 0xFF, FDDI_K_ALEN);
-
-	/* New-style flags */
-	dev->flags		= IFF_BROADCAST | IFF_MULTICAST;
-}
-EXPORT_SYMBOL(fddi_setup);
-
-#endif /* CONFIG_FDDI */
-
-#if defined(CONFIG_ATALK) || defined(CONFIG_ATALK_MODULE)
-
-static int ltalk_change_mtu(struct net_device *dev, int mtu)
-{
-	return -EINVAL;
-}
-
-static int ltalk_mac_addr(struct net_device *dev, void *addr)
-{	
-	return -EINVAL;
-}
-
-
-void ltalk_setup(struct net_device *dev)
-{
-	/* Fill in the fields of the device structure with localtalk-generic values. */
-	
-	dev->change_mtu		= ltalk_change_mtu;
-	dev->hard_header	= NULL;
-	dev->rebuild_header 	= NULL;
-	dev->set_mac_address 	= ltalk_mac_addr;
-	dev->hard_header_cache	= NULL;
-	dev->header_cache_update= NULL;
-
-	dev->type		= ARPHRD_LOCALTLK;
-	dev->hard_header_len 	= LTALK_HLEN;
-	dev->mtu		= LTALK_MTU;
-	dev->addr_len		= LTALK_ALEN;
-	dev->tx_queue_len	= 10;	
-	
-	dev->broadcast[0]	= 0xFF;
-
-	dev->flags		= IFF_BROADCAST|IFF_MULTICAST|IFF_NOARP;
-}
-EXPORT_SYMBOL(ltalk_setup);
-
-#endif /* CONFIG_ATALK || CONFIG_ATALK_MODULE */
-
 int register_netdev(struct net_device *dev)
 {
 	int err;
@@ -404,90 +150,3 @@
 
 EXPORT_SYMBOL(register_netdev);
 EXPORT_SYMBOL(unregister_netdev);
-
-#ifdef CONFIG_TR
-
-void tr_setup(struct net_device *dev)
-{
-	/*
-	 *	Configure and register
-	 */
-	
-	dev->hard_header	= tr_header;
-	dev->rebuild_header	= tr_rebuild_header;
-
-	dev->type		= ARPHRD_IEEE802_TR;
-	dev->hard_header_len	= TR_HLEN;
-	dev->mtu		= 2000;
-	dev->addr_len		= TR_ALEN;
-	dev->tx_queue_len	= 100;	/* Long queues on tr */
-	
-	memset(dev->broadcast,0xFF, TR_ALEN);
-
-	/* New-style flags. */
-	dev->flags		= IFF_BROADCAST | IFF_MULTICAST ;
-}
-
-/**
- * alloc_trdev - Register token ring device
- * @sizeof_priv: Size of additional driver-private structure to be allocated
- *	for this token ring device
- *
- * Fill in the fields of the device structure with token ring-generic values.
- *
- * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
- * this private data area.
- */
-
-struct net_device *alloc_trdev(int sizeof_priv)
-{
-	return alloc_netdev(sizeof_priv, "tr%d", tr_setup);
-}
-
-EXPORT_SYMBOL(tr_setup);
-EXPORT_SYMBOL(alloc_trdev);
-
-#endif /* CONFIG_TR */
-
-#ifdef CONFIG_NET_FC
-
-void fc_setup(struct net_device *dev)
-{
-	dev->hard_header        =        fc_header;
-        dev->rebuild_header  	=        fc_rebuild_header;
-                
-        dev->type               =        ARPHRD_IEEE802;
-	dev->hard_header_len    =        FC_HLEN;
-        dev->mtu                =        2024;
-        dev->addr_len           =        FC_ALEN;
-        dev->tx_queue_len       =        100; /* Long queues on fc */
-
-        memset(dev->broadcast,0xFF, FC_ALEN);
-
-        /* New-style flags. */
-        dev->flags              =        IFF_BROADCAST;
-}
-
-/**
- * alloc_fcdev - Register fibre channel device
- * @sizeof_priv: Size of additional driver-private structure to be allocated
- *	for this fibre channel device
- *
- * Fill in the fields of the device structure with fibre channel-generic values.
- *
- * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
- * this private data area.
- */
-
-struct net_device *alloc_fcdev(int sizeof_priv)
-{
-	return alloc_netdev(sizeof_priv, "fc%d", fc_setup);
-}
-
-EXPORT_SYMBOL(fc_setup);
-EXPORT_SYMBOL(alloc_fcdev);
-
-#endif /* CONFIG_NET_FC */
-
--- 1.91/include/linux/netdevice.h	2004-10-26 18:09:33 +02:00
+++ edited/include/linux/netdevice.h	2004-11-01 13:13:07 +01:00
@@ -910,10 +910,7 @@
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
 
 extern void		ether_setup(struct net_device *dev);
-extern void		fddi_setup(struct net_device *dev);
-extern void		tr_setup(struct net_device *dev);
-extern void		fc_setup(struct net_device *dev);
-extern void		fc_freedev(struct net_device *dev);
+
 /* Support for loadable net-drivers */
 extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *));
===== net/802/fc.c 1.3 vs edited =====
--- 1.3/net/802/fc.c	2004-06-24 21:37:35 +02:00
+++ edited/net/802/fc.c	2004-11-01 13:52:59 +01:00
@@ -129,3 +129,35 @@
 
 	return ntohs(ETH_P_802_2);
 }
+
+static void fc_setup(struct net_device *dev)
+{
+	dev->hard_header	= fc_header;
+	dev->rebuild_header	= fc_rebuild_header;
+                
+	dev->type		= ARPHRD_IEEE802;
+	dev->hard_header_len	= FC_HLEN;
+	dev->mtu		= 2024;
+	dev->addr_len		= FC_ALEN;
+	dev->tx_queue_len	= 100; /* Long queues on fc */
+	dev->flags		= IFF_BROADCAST;
+
+	memset(dev->broadcast, 0xFF, FC_ALEN);
+}
+
+/**
+ * alloc_fcdev - Register fibre channel device
+ * @sizeof_priv: Size of additional driver-private structure to be allocated
+ *	for this fibre channel device
+ *
+ * Fill in the fields of the device structure with fibre channel-generic values.
+ *
+ * Constructs a new net device, complete with a private data area of
+ * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * this private data area.
+ */
+struct net_device *alloc_fcdev(int sizeof_priv)
+{
+	return alloc_netdev(sizeof_priv, "fc%d", fc_setup);
+}
+EXPORT_SYMBOL(alloc_fcdev);
--- 1.3/net/802/fddi.c	2003-09-29 04:23:30 +02:00
+++ edited/net/802/fddi.c	2004-11-01 13:12:14 +01:00
@@ -166,3 +166,44 @@
 }
 
 EXPORT_SYMBOL(fddi_type_trans);
+
+static int fddi_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < FDDI_K_SNAP_HLEN) || (new_mtu > FDDI_K_SNAP_DLEN))
+		return(-EINVAL);
+	dev->mtu = new_mtu;
+	return(0);
+}
+
+static void fddi_setup(struct net_device *dev)
+{
+	dev->change_mtu		= fddi_change_mtu;
+	dev->hard_header	= fddi_header;
+	dev->rebuild_header	= fddi_rebuild_header;
+
+	dev->type		= ARPHRD_FDDI;
+	dev->hard_header_len	= FDDI_K_SNAP_HLEN+3;	/* Assume 802.2 SNAP hdr len + 3 pad bytes */
+	dev->mtu		= FDDI_K_SNAP_DLEN;	/* Assume max payload of 802.2 SNAP frame */
+	dev->addr_len		= FDDI_K_ALEN;
+	dev->tx_queue_len	= 100;			/* Long queues on FDDI */
+	dev->flags		= IFF_BROADCAST | IFF_MULTICAST;
+	
+	memset(dev->broadcast, 0xFF, FDDI_K_ALEN);
+}
+
+/**
+ * alloc_fddidev - Register FDDI device
+ * @sizeof_priv: Size of additional driver-private structure to be allocated
+ *	for this FDDI device
+ *
+ * Fill in the fields of the device structure with FDDI-generic values.
+ *
+ * Constructs a new net device, complete with a private data area of
+ * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * this private data area.
+ */
+struct net_device *alloc_fddidev(int sizeof_priv)
+{
+	return alloc_netdev(sizeof_priv, "fddi%d", fddi_setup);
+}
+EXPORT_SYMBOL(alloc_fddidev);
--- 1.4/net/802/hippi.c	2003-09-29 04:23:30 +02:00
+++ edited/net/802/hippi.c	2004-11-01 13:53:31 +01:00
@@ -154,3 +154,92 @@
 }
 
 EXPORT_SYMBOL(hippi_type_trans);
+
+static int hippi_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/*
+	 * HIPPI's got these nice large MTUs.
+	 */
+	if ((new_mtu < 68) || (new_mtu > 65280))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return(0);
+}
+
+/*
+ * For HIPPI we will actually use the lower 4 bytes of the hardware
+ * address as the I-FIELD rather than the actual hardware address.
+ */
+static int hippi_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	if (netif_running(dev))
+		return -EBUSY;
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	return 0;
+}
+
+static int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
+{
+	/* Never send broadcast/multicast ARP messages */
+	p->mcast_probes = 0;
+ 
+	/* In IPv6 unicast probes are valid even on NBMA,
+	* because they are encapsulated in normal IPv6 protocol.
+	* Should be a generic flag. 
+	*/
+	if (p->tbl->family != AF_INET6)
+		p->ucast_probes = 0;
+	return 0;
+}
+
+static void hippi_setup(struct net_device *dev)
+{
+	dev->set_multicast_list		= NULL;
+	dev->change_mtu			= hippi_change_mtu;
+	dev->hard_header		= hippi_header;
+	dev->rebuild_header 		= hippi_rebuild_header;
+	dev->set_mac_address 		= hippi_mac_addr;
+	dev->hard_header_parse		= NULL;
+	dev->hard_header_cache		= NULL;
+	dev->header_cache_update	= NULL;
+	dev->neigh_setup 		= hippi_neigh_setup_dev; 
+
+	/*
+	 * We don't support HIPPI `ARP' for the time being, and probably
+	 * never will unless someone else implements it. However we
+	 * still need a fake ARPHRD to make ifconfig and friends play ball.
+	 */
+	dev->type		= ARPHRD_HIPPI;
+	dev->hard_header_len 	= HIPPI_HLEN;
+	dev->mtu		= 65280;
+	dev->addr_len		= HIPPI_ALEN;
+	dev->tx_queue_len	= 25 /* 5 */;
+	memset(dev->broadcast, 0xFF, HIPPI_ALEN);
+
+
+	/*
+	 * HIPPI doesn't support broadcast+multicast and we only use
+	 * static ARP tables. ARP is disabled by hippi_neigh_setup_dev. 
+	 */
+	dev->flags = 0; 
+}
+
+/**
+ * alloc_hippi_dev - Register HIPPI device
+ * @sizeof_priv: Size of additional driver-private structure to be allocated
+ *	for this HIPPI device
+ *
+ * Fill in the fields of the device structure with HIPPI-generic values.
+ *
+ * Constructs a new net device, complete with a private data area of
+ * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * this private data area.
+ */
+
+struct net_device *alloc_hippi_dev(int sizeof_priv)
+{
+	return alloc_netdev(sizeof_priv, "hip%d", hippi_setup);
+}
+
+EXPORT_SYMBOL(alloc_hippi_dev);
--- 1.17/net/802/tr.c	2004-06-24 21:36:53 +02:00
+++ edited/net/802/tr.c	2004-11-01 13:14:02 +01:00
@@ -583,6 +583,43 @@
 
 #endif
 
+static void tr_setup(struct net_device *dev)
+{
+	/*
+	 *	Configure and register
+	 */
+	
+	dev->hard_header	= tr_header;
+	dev->rebuild_header	= tr_rebuild_header;
+
+	dev->type		= ARPHRD_IEEE802_TR;
+	dev->hard_header_len	= TR_HLEN;
+	dev->mtu		= 2000;
+	dev->addr_len		= TR_ALEN;
+	dev->tx_queue_len	= 100;	/* Long queues on tr */
+	
+	memset(dev->broadcast,0xFF, TR_ALEN);
+
+	/* New-style flags. */
+	dev->flags		= IFF_BROADCAST | IFF_MULTICAST ;
+}
+
+/**
+ * alloc_trdev - Register token ring device
+ * @sizeof_priv: Size of additional driver-private structure to be allocated
+ *	for this token ring device
+ *
+ * Fill in the fields of the device structure with token ring-generic values.
+ *
+ * Constructs a new net device, complete with a private data area of
+ * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * this private data area.
+ */
+struct net_device *alloc_trdev(int sizeof_priv)
+{
+	return alloc_netdev(sizeof_priv, "tr%d", tr_setup);
+}
+
 /*
  *	Called during bootup.  We don't actually have to initialise
  *	too much for this.
@@ -604,3 +641,4 @@
 
 EXPORT_SYMBOL(tr_source_route);
 EXPORT_SYMBOL(tr_type_trans);
+EXPORT_SYMBOL(alloc_trdev);
--- 1.8/net/appletalk/Makefile	2004-08-18 23:35:04 +02:00
+++ edited/net/appletalk/Makefile	2004-11-01 13:22:42 +01:00
@@ -4,6 +4,6 @@
 
 obj-$(CONFIG_ATALK) += appletalk.o
 
-appletalk-y			:= aarp.o ddp.o
+appletalk-y			:= aarp.o ddp.o dev.o
 appletalk-$(CONFIG_PROC_FS)	+= atalk_proc.o
 appletalk-$(CONFIG_SYSCTL)	+= sysctl_net_atalk.o
--- 1.9/net/ethernet/eth.c	2004-10-05 23:51:01 +02:00
+++ edited/net/ethernet/eth.c	2004-11-01 13:54:23 +01:00
@@ -245,3 +245,64 @@
 }
 
 EXPORT_SYMBOL(eth_type_trans);
+
+static int eth_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr=p;
+	if (netif_running(dev))
+		return -EBUSY;
+	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
+	return 0;
+}
+
+static int eth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > 1500))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+/*
+ * Fill in the fields of the device structure with ethernet-generic values.
+ */
+void ether_setup(struct net_device *dev)
+{
+	dev->change_mtu		= eth_change_mtu;
+	dev->hard_header	= eth_header;
+	dev->rebuild_header 	= eth_rebuild_header;
+	dev->set_mac_address 	= eth_mac_addr;
+	dev->hard_header_cache	= eth_header_cache;
+	dev->header_cache_update= eth_header_cache_update;
+	dev->hard_header_parse	= eth_header_parse;
+
+	dev->type		= ARPHRD_ETHER;
+	dev->hard_header_len 	= ETH_HLEN;
+	dev->mtu		= 1500; /* eth_mtu */
+	dev->addr_len		= ETH_ALEN;
+	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */	
+	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
+	
+	memset(dev->broadcast,0xFF, ETH_ALEN);
+
+}
+EXPORT_SYMBOL(ether_setup);
+
+/**
+ * alloc_etherdev - Allocates and sets up an ethernet device
+ * @sizeof_priv: Size of additional driver-private structure to be allocated
+ *	for this ethernet device
+ *
+ * Fill in the fields of the device structure with ethernet-generic
+ * values. Basically does everything except registering the device.
+ *
+ * Constructs a new net device, complete with a private data area of
+ * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * this private data area.
+ */
+
+struct net_device *alloc_etherdev(int sizeof_priv)
+{
+	return alloc_netdev(sizeof_priv, "eth%d", ether_setup);
+}
+EXPORT_SYMBOL(alloc_etherdev);
--- /dev/null	2004-08-20 00:05:11.000000000 +0200
+++ b/net/appletalk/dev.c	2004-11-01 13:49:02.111094544 +0100
@@ -0,0 +1,43 @@
+/*
+ * Moved here from drivers/net/net_init.c, which is:
+ *	Written 1993,1994,1995 by Donald Becker.
+ */
+
+#include <linux/errno.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ltalk.h>
+
+static int ltalk_change_mtu(struct net_device *dev, int mtu)
+{
+	return -EINVAL;
+}
+
+static int ltalk_mac_addr(struct net_device *dev, void *addr)
+{	
+	return -EINVAL;
+}
+
+void ltalk_setup(struct net_device *dev)
+{
+	/* Fill in the fields of the device structure with localtalk-generic values. */
+	
+	dev->change_mtu		= ltalk_change_mtu;
+	dev->hard_header	= NULL;
+	dev->rebuild_header 	= NULL;
+	dev->set_mac_address 	= ltalk_mac_addr;
+	dev->hard_header_cache	= NULL;
+	dev->header_cache_update= NULL;
+
+	dev->type		= ARPHRD_LOCALTLK;
+	dev->hard_header_len 	= LTALK_HLEN;
+	dev->mtu		= LTALK_MTU;
+	dev->addr_len		= LTALK_ALEN;
+	dev->tx_queue_len	= 10;	
+	
+	dev->broadcast[0]	= 0xFF;
+
+	dev->flags		= IFF_BROADCAST|IFF_MULTICAST|IFF_NOARP;
+}
+EXPORT_SYMBOL(ltalk_setup);
