From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 RESEND 1/4] macvlan: support mac address changes when fwd_priv is enable
Date: Sat, 7 Jun 2014 15:45:40 +0800
Message-ID: <1402127143-6456-2-git-send-email-dingtianhong@huawei.com>
References: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>, <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:32051 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbaFGHqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 03:46:20 -0400
In-Reply-To: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If lowerdev supports L2 forwarding offload, the macvlan's hw address
will be set to the rar of the lowerdev and no need to set uc list,
and when the macvlan's hw address changes, the macvlan should remove
the old fwd and rebuild a new fwd for the macvlan.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 453d55a..67485ab 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -523,6 +523,27 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
 		if (macvlan_addr_busy(vlan->port, addr))
 			return -EBUSY;
 
+		if (vlan->fwd_priv) {
+			lowerdev->netdev_ops->ndo_dfwd_del_station(lowerdev,
+								   vlan->fwd_priv);
+			vlan->fwd_priv = NULL;
+			ether_addr_copy(dev->perm_addr, dev->dev_addr);
+			ether_addr_copy(dev->dev_addr, addr);
+			vlan->fwd_priv =
+			    lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev,
+								       dev);
+			/* If we get a NULL pointer back, or if we get an error
+			 * then we should restore the old mac address and fwd.
+			 */
+			if (IS_ERR_OR_NULL(vlan->fwd_priv)) {
+				ether_addr_copy(dev->dev_addr, dev->perm_addr);
+				vlan->fwd_priv =
+				    lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev,
+									       dev);
+				return -EINVAL;
+			}
+			return 0;
+		}
 		if (!vlan->port->passthru) {
 			err = dev_uc_add(lowerdev, addr);
 			if (err)
-- 
1.8.0
