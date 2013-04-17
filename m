From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 2/4] xen-netfront: reduce gso_max_size to account for max TCP header
Date: Wed, 17 Apr 2013 18:42:01 +0100
Message-ID: <1366220523-14579-3-git-send-email-wei.liu2@citrix.com>
References: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <ian.campbell@citrix.com>,
	<wdauchy@gmail.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:31831 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966029Ab3DQRmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 13:42:22 -0400
In-Reply-To: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum packet including header that can be handled by netfront / netback
wire format is 65535. Reduce gso_max_size accordingly.

Drop skb and print warning when skb->len > 65535. This can 1) save the effort
to send malformed packet to netback, 2) help spotting misconfiguration of
netfront in the future.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netfront.c       |   17 +++++++++++++++--
 include/xen/interface/io/netif.h |    1 +
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 1bb2e20..1db10141 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -36,7 +36,7 @@
 #include <linux/skbuff.h>
 #include <linux/ethtool.h>
 #include <linux/if_ether.h>
-#include <linux/tcp.h>
+#include <net/tcp.h>
 #include <linux/udp.h>
 #include <linux/moduleparam.h>
 #include <linux/mm.h>
@@ -547,6 +547,16 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len = skb_headlen(skb);
 	unsigned long flags;
 
+	/* If skb->len is too big for wire format, drop skb and alert
+	 * user about misconfiguration.
+	 */
+	if (unlikely(skb->len > XEN_NETIF_MAX_TX_SIZE)) {
+		net_alert_ratelimited(
+			"xennet: skb->len = %u, too big for wire format\n",
+			skb->len);
+		goto drop;
+	}
+
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
@@ -1058,7 +1068,8 @@ err:
 
 static int xennet_change_mtu(struct net_device *dev, int mtu)
 {
-	int max = xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
+	int max = xennet_can_sg(dev) ?
+		XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER : ETH_DATA_LEN;
 
 	if (mtu > max)
 		return -EINVAL;
@@ -1362,6 +1373,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
+	netif_set_gso_max_size(netdev, XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER);
+
 	np->netdev = netdev;
 
 	netif_carrier_off(netdev);
diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index 9dfc120..58fadca 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -47,6 +47,7 @@
 #define _XEN_NETTXF_extra_info		(3)
 #define  XEN_NETTXF_extra_info		(1U<<_XEN_NETTXF_extra_info)
 
+#define XEN_NETIF_MAX_TX_SIZE 0xFFFF
 struct xen_netif_tx_request {
     grant_ref_t gref;      /* Reference to buffer page */
     uint16_t offset;       /* Offset within buffer page */
-- 
1.7.10.4
