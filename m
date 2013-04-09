From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 5/7] xen-netfront: reduce gso_max_size to account for ethernet header
Date: Tue, 9 Apr 2013 12:07:33 +0100
Message-ID: <1365505655-8021-6-git-send-email-wei.liu2@citrix.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<konrad.wilk@oracle.com>, <annie.li@oracle.com>,
	<wdauchy@gmail.com>, Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:52765 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933562Ab3DILWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:22:06 -0400
In-Reply-To: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum packet including ethernet header that can be handled by netfront /
netback wire format is 65535. Reduce gso_max_size accordingly.

Drop skb and print warning when skb->len > 65535. This can 1) save the effort
to send malformed packet to netback, 2) help spotting misconfiguration of
netfront in the future.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 1bb2e20..42ef4a8 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -547,6 +547,16 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len = skb_headlen(skb);
 	unsigned long flags;
 
+	/* If skb->len is too big for wire format, drop skb and alert
+	 * user about misconfiguration.
+	 */
+	if (unlikely(skb->len > (typeof(tx->size))(~0))) {
+		net_alert_ratelimited(
+			"xennet: skb->len = %u, too big for wire format\n",
+			skb->len);
+		goto drop;
+	}
+
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
@@ -1058,7 +1068,7 @@ err:
 
 static int xennet_change_mtu(struct net_device *dev, int mtu)
 {
-	int max = xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
+	int max = xennet_can_sg(dev) ? 65535 - VLAN_ETH_HLEN : ETH_DATA_LEN;
 
 	if (mtu > max)
 		return -EINVAL;
@@ -1362,6 +1372,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
+	netif_set_gso_max_size(netdev, 65535 - VLAN_ETH_HLEN);
+
 	np->netdev = netdev;
 
 	netif_carrier_off(netdev);
-- 
1.7.10.4
