From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net 1/2] ipvlan: NULL pointer dereference panic in ipvlan_port_destroy
Date: Tue, 31 Oct 2017 09:39:46 -0700
Message-ID: <1509467987-20050-2-git-send-email-girish.moodalbail@oracle.com>
References: <1509467987-20050-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48638 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932374AbdJaRDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:03:09 -0400
In-Reply-To: <1509467987-20050-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When call to register_netdevice() (called from ipvlan_link_new()) fails,
we call ipvlan_uninit() (through ndo_uninit()) to destroy the ipvlan
port. Upon returning unsuccessfully from register_netdevice() we go
ahead and call ipvlan_port_destroy() again which causes NULL pointer
dereference panic. Fix it.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index c74893c..00a62a1 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -602,6 +602,12 @@ int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 unregister_netdev:
 	unregister_netdevice(dev);
 remove_ida:
+	/* Through the call to ipvlan_uninit (ndo_uninit callback) IPvlan port
+	 * might be already destroyed in failure path in register_netdevice()
+	 * or the above call in unregister_netdevice().
+	 */
+	if (!ipvlan_port_get_rtnl(phy_dev))
+		return err;
 	ida_simple_remove(&port->ida, dev->dev_id);
 destroy_ipvlan_port:
 	if (create)
-- 
1.8.3.1
