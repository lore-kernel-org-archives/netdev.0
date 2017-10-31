From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net 2/2] macvlan: NULL pointer dereference panic in macvlan_port_destroy
Date: Tue, 31 Oct 2017 09:39:47 -0700
Message-ID: <1509467987-20050-3-git-send-email-girish.moodalbail@oracle.com>
References: <1509467987-20050-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48635 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932413AbdJaRDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:03:09 -0400
In-Reply-To: <1509467987-20050-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When call to register_netdevice() (called from macvlan_common_newlink())
fails, we call macvlan_uninit() (through ndo_uninit()) to destroy the
macvlan port. Upon returning unsuccessfully from register_netdevice() we
go ahead and call macvlan_port_destroy() again which causes NULL pointer
dereference panic. Fix it.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/macvlan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d2aea96..2520de8 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1189,6 +1189,9 @@ static void macvlan_port_destroy(struct net_device *dev)
 	struct macvlan_port *port = macvlan_port_get_rtnl(dev);
 	struct sk_buff *skb;
 
+	if (!port)
+		return;
+
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
 
@@ -1444,7 +1447,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	unregister_netdevice(dev);
 destroy_macvlan_port:
 	if (create)
-		macvlan_port_destroy(port->dev);
+		macvlan_port_destroy(lowerdev);
 	return err;
 }
 EXPORT_SYMBOL_GPL(macvlan_common_newlink);
-- 
1.8.3.1
