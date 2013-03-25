From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 2/6] xen-netfront: reduce gso_max_size to account for ethernet header
Date: Mon, 25 Mar 2013 11:08:18 +0000
Message-ID: <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <annie.li@oracle.com>,
	<konrad.wilk@oracle.com>, <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:64946 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756560Ab3CYLJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 07:09:04 -0400
In-Reply-To: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum packet including ethernet header that can be handled by netfront /
netback wire format is 65535. Reduce gso_max_size accordingly.

Drop skb and print warning when skb->len > 65535. This can 1) save the effort
to send malformed packet to netback, 2) help spotting misconfiguration of
netfront in the future.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 5527663..3ae9dc1 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -547,6 +547,18 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len = skb_headlen(skb);
 	unsigned long flags;
 
+	/* Wire format of xen_netif_tx_request only supports skb->len
+	 * < 64K, because size field in xen_netif_tx_request is
+	 * uint16_t. If skb->len is too big, drop it and alert user about
+	 * misconfiguration.
+	 */
+	if (unlikely(skb->len >= (uint16_t)(~0))) {
+		net_alert_ratelimited(
+			"xennet: skb->len = %u, too big for wire format\n",
+			skb->len);
+		goto drop;
+	}
+
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
@@ -1362,6 +1374,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
+	netif_set_gso_max_size(netdev, 65535 - ETH_HLEN);
+
 	np->netdev = netdev;
 
 	netif_carrier_off(netdev);
-- 
1.7.10.4
