From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: reorder some fields of net_device
Date: Sat, 30 Mar 2013 09:31:03 -0700
Message-ID: <1364661063.5113.116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:35824 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756639Ab3C3QbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 12:31:06 -0400
Received: by mail-da0-f49.google.com with SMTP id t11so556476daj.22
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 09:31:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As time passed, some fields were added in net_device, and not
at sensible offsets.

Lets reorder some fields to reduce number of cache lines in RX path.
Fields not used in data path should be moved out of this critical cache
line.

In particular, move broadcast[] to the end of the rx section,
as it is less used, and ethernet uses only the beginning of the 32bytes
field.

Before patch :

offsetof(struct net_device,dev_addr)=0x258
offsetof(struct net_device,rx_handler)=0x2b8
offsetof(struct net_device,ingress_queue)=0x2c8
offsetof(struct net_device,broadcast)=0x278

After :

offsetof(struct net_device,dev_addr)=0x280
offsetof(struct net_device,rx_handler)=0x298
offsetof(struct net_device,ingress_queue)=0x2a8
offsetof(struct net_device,broadcast)=0x2b0


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |   33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1dbb02c..4491414 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1071,6 +1071,8 @@ struct net_device {
 	struct list_head	dev_list;
 	struct list_head	napi_list;
 	struct list_head	unreg_list;
+	struct list_head	upper_dev_list; /* List of upper devices */
+
 
 	/* currently active device features */
 	netdev_features_t	features;
@@ -1143,6 +1145,13 @@ struct net_device {
 	spinlock_t		addr_list_lock;
 	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
 	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
+	struct netdev_hw_addr_list	dev_addrs; /* list of device
+						    * hw addresses
+						    */
+#ifdef CONFIG_SYSFS
+	struct kset		*queues_kset;
+#endif
+
 	bool			uc_promisc;
 	unsigned int		promiscuity;
 	unsigned int		allmulti;
@@ -1175,21 +1184,11 @@ struct net_device {
 						 * avoid dirtying this cache line.
 						 */
 
-	struct list_head	upper_dev_list; /* List of upper devices */
-
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		*dev_addr;	/* hw address, (before bcast
 						   because most packets are
 						   unicast) */
 
-	struct netdev_hw_addr_list	dev_addrs; /* list of device
-						      hw addresses */
-
-	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
-
-#ifdef CONFIG_SYSFS
-	struct kset		*queues_kset;
-#endif
 
 #ifdef CONFIG_RPS
 	struct netdev_rx_queue	*_rx;
@@ -1200,18 +1199,14 @@ struct net_device {
 	/* Number of RX queues currently active in device */
 	unsigned int		real_num_rx_queues;
 
-#ifdef CONFIG_RFS_ACCEL
-	/* CPU reverse-mapping for RX completion interrupts, indexed
-	 * by RX queue number.  Assigned by driver.  This must only be
-	 * set if the ndo_rx_flow_steer operation is defined. */
-	struct cpu_rmap		*rx_cpu_rmap;
-#endif
 #endif
 
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
 
 	struct netdev_queue __rcu *ingress_queue;
+	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
+
 
 /*
  * Cache lines mostly used on transmit path
@@ -1233,6 +1228,12 @@ struct net_device {
 #ifdef CONFIG_XPS
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
+#ifdef CONFIG_RFS_ACCEL
+	/* CPU reverse-mapping for RX completion interrupts, indexed
+	 * by RX queue number.  Assigned by driver.  This must only be
+	 * set if the ndo_rx_flow_steer operation is defined. */
+	struct cpu_rmap		*rx_cpu_rmap;
+#endif
 
 	/* These may be needed for future network-power-down code. */
 
