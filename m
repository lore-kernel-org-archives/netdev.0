From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH] can: fix WARN_ON dump in net/core/rtnetlink.c:rtmsg_ifinfo()
Date: Sat, 07 Nov 2009 10:53:13 +0100
Message-ID: <4AF54389.1090309@grandegger.com>
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

On older kernels, e.g. 2.6.27, a WARN_ON dump in rtmsg_ifinfo()
is thrown when the CAN device is registered due to insufficient
skb space, as reported by various users. This patch adds the
rtnl_link_ops "get_size" to fix the problem. I think this patch
is required for more recent kernels as well, even if no WARN_ON
dumps are triggered. Maybe we also need "get_xstats_size" for
the CAN xstats.

Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

---
 drivers/net/can/dev.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/dev.c
+++ net-next-2.6/drivers/net/can/dev.c
@@ -637,6 +637,22 @@ static int can_changelink(struct net_dev
 	return 0;
 }
 
+static size_t can_get_size(const struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+	size_t size;
+
+	size = nla_total_size(sizeof(u32));   /* IFLA_CAN_STATE */
+	size += sizeof(struct can_ctrlmode);  /* IFLA_CAN_CTRLMODE */
+	size += nla_total_size(sizeof(u32));  /* IFLA_CAN_RESTART_MS */
+	size += sizeof(struct can_bittiming); /* IFLA_CAN_BITTIMING */
+	size += sizeof(struct can_clock);     /* IFLA_CAN_CLOCK */
+	if (priv->bittiming_const)	      /* IFLA_CAN_BITTIMING_CONST */
+		size += sizeof(struct can_bittiming_const);
+
+	return size;
+}
+
 static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct can_priv *priv = netdev_priv(dev);
@@ -687,6 +703,7 @@ static struct rtnl_link_ops can_link_ops
 	.setup		= can_setup,
 	.newlink	= can_newlink,
 	.changelink	= can_changelink,
+	.get_size	= can_get_size,
 	.fill_info	= can_fill_info,
 	.fill_xstats	= can_fill_xstats,
 };
