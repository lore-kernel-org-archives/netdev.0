From: Jonathan Davies <jonathan.davies@citrix.com>
Subject: [PATCH v2] xen-netfront: transmit fully GSO-sized packets
Date: Tue, 31 Mar 2015 11:05:15 +0100
Message-ID: <1427796315-17655-1-git-send-email-jonathan.davies@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jonathan Davies <jonathan.davies@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Eric Dumazet <edumazet@google.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:62648 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbbCaKFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 06:05:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xen-netfront limits transmitted skbs to be at most 44 segments in size. However,
GSO permits up to 65536 bytes, which means a maximum of 45 segments of 1448
bytes each. This slight reduction in the size of packets means a slight loss in
efficiency.

Since c/s 9ecd1a75d, xen-netfront sets gso_max_size to
    XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER,
where XEN_NETIF_MAX_TX_SIZE is 65535 bytes.

The calculation used by tcp_tso_autosize (and also tcp_xmit_size_goal since c/s
6c09fa09d) in determining when to split an skb into two is
    sk->sk_gso_max_size - 1 - MAX_TCP_HEADER.

So the maximum permitted size of an skb is calculated to be
    (XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER) - 1 - MAX_TCP_HEADER.

Intuitively, this looks like the wrong formula -- we don't need two TCP headers.
Instead, there is no need to deviate from the default gso_max_size of 65536 as
this already accommodates the size of the header.

Currently, the largest skb transmitted by netfront is 63712 bytes (44 segments
of 1448 bytes each), as observed via tcpdump. This patch makes netfront send
skbs of up to 65160 bytes (45 segments of 1448 bytes each).

Similarly, the maximum allowable mtu does not need to subtract MAX_TCP_HEADER as
it relates to the size of the whole packet, including the header.

Fixes: 9ecd1a75d977 ("xen-netfront: reduce gso_max_size to account for max TCP header")
Signed-off-by: Jonathan Davies <jonathan.davies@citrix.com>

---
Changes in v2:
 - Also correct max mtu in xennet_change_mtu.
---
 drivers/net/xen-netfront.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e9b960f..720aaf6 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1008,8 +1008,7 @@ err:
 
 static int xennet_change_mtu(struct net_device *dev, int mtu)
 {
-	int max = xennet_can_sg(dev) ?
-		XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER : ETH_DATA_LEN;
+	int max = xennet_can_sg(dev) ? XEN_NETIF_MAX_TX_SIZE : ETH_DATA_LEN;
 
 	if (mtu > max)
 		return -EINVAL;
@@ -1279,8 +1278,6 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	netdev->ethtool_ops = &xennet_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
-	netif_set_gso_max_size(netdev, XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER);
-
 	np->netdev = netdev;
 
 	netif_carrier_off(netdev);
-- 
1.9.1
