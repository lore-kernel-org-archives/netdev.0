From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/19] netdev: change transmit to limited range type
Date: Mon, 31 Aug 2009 22:50:40 -0700
Message-ID: <20090901055128.466779045@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57429 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309AbZIAF6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:48 -0400
Content-Disposition: inline; filename=netdev-tx1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The transmit function should only return one of three possible values,
some drivers got confused and returned errno's or other values.
This changes the definition so that this can be caught at compile time.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
The patch will produce warnings until drivers are converted.


---
 include/linux/netdevice.h |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

--- a/include/linux/netdevice.h	2009-08-31 16:47:58.703591891 -0700
+++ b/include/linux/netdevice.h	2009-08-31 22:24:53.101472780 -0700
@@ -79,17 +79,19 @@ struct wireless_dev;
 #define net_xmit_eval(e)	((e) == NET_XMIT_CN? 0 : (e))
 #define net_xmit_errno(e)	((e) != NET_XMIT_CN ? -ENOBUFS : 0)
 
+/* Driver transmit return codes */
+enum netdev_tx {
+	NETDEV_TX_OK = 0,	/* driver took care of packet */
+	NETDEV_TX_BUSY,		/* driver tx path was busy*/
+	NETDEV_TX_LOCKED = -1,	/* driver tx lock was already taken */
+};
+typedef enum netdev_tx netdev_tx_t;
+
 #endif
 
 #define MAX_ADDR_LEN	32		/* Largest hardware address length */
 
-/* Driver transmit return codes */
-#define NETDEV_TX_OK 0		/* driver took care of packet */
-#define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
-#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
-
 #ifdef  __KERNEL__
-
 /*
  *	Compute the worst case header length according to the protocols
  *	used.
@@ -507,9 +509,11 @@ struct netdev_queue {
  *     This function is called when network device transistions to the down
  *     state.
  *
- * int (*ndo_start_xmit)(struct sk_buff *skb, struct net_device *dev);
+ * netdev_tx_t (*ndo_start_xmit)(struct sk_buff *skb,
+ *                               struct net_device *dev);
  *	Called when a packet needs to be transmitted.
- *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY, or NETDEV_TX_LOCKED,
+ *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY.
+ *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
  *	Required can not be NULL.
  *
  * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb);
@@ -580,7 +584,7 @@ struct net_device_ops {
 	void			(*ndo_uninit)(struct net_device *dev);
 	int			(*ndo_open)(struct net_device *dev);
 	int			(*ndo_stop)(struct net_device *dev);
-	int			(*ndo_start_xmit) (struct sk_buff *skb,
+	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
 						   struct net_device *dev);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb);

-- 

