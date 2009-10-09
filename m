From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: can: make the number of echo skb's configurable
Date: Fri, 09 Oct 2009 10:09:10 +0200
Message-ID: <4ACEEFA6.1000904@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch allows the CAN controller driver to define the number of echo
skb's used for the local loopback (echo), as suggested by Kurt Van
Dijck, with the function:

  struct net_device *alloc_candev(int sizeof_priv,
                                  unsigned int echo_skb_max);

The CAN drivers have been adapted accordingly. For the ems_usb driver,
as suggested by Sebastian Haas, the number of echo skb's has been
increased to 10, which improves the transmission performance a lot.

Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
---
 drivers/net/can/at91_can.c        |    2 +-
 drivers/net/can/dev.c             |   32 ++++++++++++++++++++++++++------
 drivers/net/can/sja1000/sja1000.c |    3 ++-
 drivers/net/can/sja1000/sja1000.h |    2 ++
 drivers/net/can/ti_hecc.c         |    6 +-----
 drivers/net/can/usb/ems_usb.c     |    4 ++--
 include/linux/can/dev.h           |   16 ++++++++--------
 7 files changed, 42 insertions(+), 23 deletions(-)

Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/dev.c
+++ net-next-2.6/drivers/net/can/dev.c
@@ -245,7 +245,7 @@ static void can_flush_echo_skb(struct ne
 	struct net_device_stats *stats = &dev->stats;
 	int i;
 
-	for (i = 0; i < CAN_ECHO_SKB_MAX; i++) {
+	for (i = 0; i < priv->echo_skb_max; i++) {
 		if (priv->echo_skb[i]) {
 			kfree_skb(priv->echo_skb[i]);
 			priv->echo_skb[i] = NULL;
@@ -262,10 +262,13 @@ static void can_flush_echo_skb(struct ne
  * of the device driver. The driver must protect access to
  * priv->echo_skb, if necessary.
  */
-void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int idx)
+void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
+		      unsigned int idx)
 {
 	struct can_priv *priv = netdev_priv(dev);
 
+	BUG_ON(idx >= priv->echo_skb_max);
+
 	/* check flag whether this packet has to be looped back */
 	if (!(dev->flags & IFF_ECHO) || skb->pkt_type != PACKET_LOOPBACK) {
 		kfree_skb(skb);
@@ -311,10 +314,12 @@ EXPORT_SYMBOL_GPL(can_put_echo_skb);
  * is handled in the device driver. The driver must protect
  * access to priv->echo_skb, if necessary.
  */
-void can_get_echo_skb(struct net_device *dev, int idx)
+void can_get_echo_skb(struct net_device *dev, unsigned int idx)
 {
 	struct can_priv *priv = netdev_priv(dev);
 
+	BUG_ON(idx >= priv->echo_skb_max);
+
 	if (priv->echo_skb[idx]) {
 		netif_rx(priv->echo_skb[idx]);
 		priv->echo_skb[idx] = NULL;
@@ -327,10 +332,12 @@ EXPORT_SYMBOL_GPL(can_get_echo_skb);
   *
   * The function is typically called when TX failed.
   */
-void can_free_echo_skb(struct net_device *dev, int idx)
+void can_free_echo_skb(struct net_device *dev, unsigned int idx)
 {
 	struct can_priv *priv = netdev_priv(dev);
 
+	BUG_ON(idx >= priv->echo_skb_max);
+
 	if (priv->echo_skb[idx]) {
 		kfree_skb(priv->echo_skb[idx]);
 		priv->echo_skb[idx] = NULL;
@@ -445,17 +452,30 @@ static void can_setup(struct net_device 
 /*
  * Allocate and setup space for the CAN network device
  */
-struct net_device *alloc_candev(int sizeof_priv)
+struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max)
 {
 	struct net_device *dev;
 	struct can_priv *priv;
+	int size;
 
-	dev = alloc_netdev(sizeof_priv, "can%d", can_setup);
+	if (echo_skb_max)
+		size = ALIGN(sizeof_priv, sizeof(struct sk_buff *)) +
+			echo_skb_max * sizeof(struct sk_buff *);
+	else
+		size = sizeof_priv;
+
+	dev = alloc_netdev(size, "can%d", can_setup);
 	if (!dev)
 		return NULL;
 
 	priv = netdev_priv(dev);
 
+	if (echo_skb_max) {
+		priv->echo_skb_max = echo_skb_max;
+		priv->echo_skb = (void *)priv +
+			ALIGN(sizeof_priv, sizeof(struct sk_buff *));
+	}
+
 	priv->state = CAN_STATE_STOPPED;
 
 	init_timer(&priv->restart_timer);
Index: net-next-2.6/include/linux/can/dev.h
===================================================================
--- net-next-2.6.orig/include/linux/can/dev.h
+++ net-next-2.6/include/linux/can/dev.h
@@ -29,8 +29,6 @@ enum can_mode {
 /*
  * CAN common private data
  */
-#define CAN_ECHO_SKB_MAX  4
-
 struct can_priv {
 	struct can_device_stats can_stats;
 
@@ -44,15 +42,16 @@ struct can_priv {
 	int restart_ms;
 	struct timer_list restart_timer;
 
-	struct sk_buff *echo_skb[CAN_ECHO_SKB_MAX];
-
 	int (*do_set_bittiming)(struct net_device *dev);
 	int (*do_set_mode)(struct net_device *dev, enum can_mode mode);
 	int (*do_get_state)(const struct net_device *dev,
 			    enum can_state *state);
+
+	unsigned int echo_skb_max;
+	struct sk_buff **echo_skb;
 };
 
-struct net_device *alloc_candev(int sizeof_priv);
+struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max);
 void free_candev(struct net_device *dev);
 
 int open_candev(struct net_device *dev);
@@ -64,8 +63,9 @@ void unregister_candev(struct net_device
 int can_restart_now(struct net_device *dev);
 void can_bus_off(struct net_device *dev);
 
-void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int idx);
-void can_get_echo_skb(struct net_device *dev, int idx);
-void can_free_echo_skb(struct net_device *dev, int idx);
+void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
+		      unsigned int idx);
+void can_get_echo_skb(struct net_device *dev, unsigned int idx);
+void can_free_echo_skb(struct net_device *dev, unsigned int idx);
 
 #endif /* CAN_DEV_H */
Index: net-next-2.6/drivers/net/can/at91_can.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/at91_can.c
+++ net-next-2.6/drivers/net/can/at91_can.c
@@ -1087,7 +1087,7 @@ static int __init at91_can_probe(struct 
 		goto exit_release;
 	}
 
-	dev = alloc_candev(sizeof(struct at91_priv));
+	dev = alloc_candev(sizeof(struct at91_priv), AT91_MB_TX_NUM);
 	if (!dev) {
 		err = -ENOMEM;
 		goto exit_iounmap;
Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c
@@ -565,7 +565,8 @@ struct net_device *alloc_sja1000dev(int 
 	struct net_device *dev;
 	struct sja1000_priv *priv;
 
-	dev = alloc_candev(sizeof(struct sja1000_priv) + sizeof_priv);
+	dev = alloc_candev(sizeof(struct sja1000_priv) + sizeof_priv,
+		SJA1000_ECHO_SKB_MAX);
 	if (!dev)
 		return NULL;
 
Index: net-next-2.6/drivers/net/can/sja1000/sja1000.h
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.h
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.h
@@ -50,6 +50,8 @@
 #include <linux/can/dev.h>
 #include <linux/can/platform/sja1000.h>
 
+#define SJA1000_ECHO_SKB_MAX	1 /* the SJA1000 has one TX buffer object */
+
 #define SJA1000_MAX_IRQ 20	/* max. number of interrupts handled in ISR */
 
 /* SJA1000 registers - manual section 6.4 (Pelican Mode) */
Index: net-next-2.6/drivers/net/can/usb/ems_usb.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/usb/ems_usb.c
+++ net-next-2.6/drivers/net/can/usb/ems_usb.c
@@ -232,7 +232,7 @@ MODULE_DEVICE_TABLE(usb, ems_usb_table);
 #define INTR_IN_BUFFER_SIZE 4
 
 #define MAX_RX_URBS 10
-#define MAX_TX_URBS CAN_ECHO_SKB_MAX
+#define MAX_TX_URBS 10
 
 struct ems_usb;
 
@@ -1012,7 +1012,7 @@ static int ems_usb_probe(struct usb_inte
 	struct ems_usb *dev;
 	int i, err = -ENOMEM;
 
-	netdev = alloc_candev(sizeof(struct ems_usb));
+	netdev = alloc_candev(sizeof(struct ems_usb), MAX_TX_URBS);
 	if (!netdev) {
 		dev_err(netdev->dev.parent, "Couldn't alloc candev\n");
 		return -ENOMEM;
Index: net-next-2.6/drivers/net/can/ti_hecc.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/ti_hecc.c
+++ net-next-2.6/drivers/net/can/ti_hecc.c
@@ -74,10 +74,6 @@ MODULE_VERSION(HECC_MODULE_VERSION);
 #define HECC_MB_TX_SHIFT	2 /* as per table above */
 #define HECC_MAX_TX_MBOX	BIT(HECC_MB_TX_SHIFT)
 
-#if (HECC_MAX_TX_MBOX > CAN_ECHO_SKB_MAX)
-#error "HECC: MAX TX mailboxes should be equal or less than CAN_ECHO_SKB_MAX"
-#endif
-
 #define HECC_TX_PRIO_SHIFT	(HECC_MB_TX_SHIFT)
 #define HECC_TX_PRIO_MASK	(MAX_TX_PRIO << HECC_MB_TX_SHIFT)
 #define HECC_TX_MB_MASK		(HECC_MAX_TX_MBOX - 1)
@@ -902,7 +898,7 @@ static int ti_hecc_probe(struct platform
 		goto probe_exit_free_region;
 	}
 
-	ndev = alloc_candev(sizeof(struct ti_hecc_priv));
+	ndev = alloc_candev(sizeof(struct ti_hecc_priv), HECC_MAX_TX_MBOX);
 	if (!ndev) {
 		dev_err(&pdev->dev, "alloc_candev failed\n");
 		err = -ENOMEM;
