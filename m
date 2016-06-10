From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] ovs/vxlan: fix rtnl notifications on iface deletion
Date: Fri, 10 Jun 2016 11:32:26 +0200
Message-ID: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:35190 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbcFJJcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 05:32:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function vxlan_dev_create() (only used by ovs) never calls
rtnl_configure_link(). The consequence is that dev->rtnl_link_state is
never set to RTNL_LINK_INITIALIZED.
During the deletion phase, the function rollback_registered_many() sends
a RTM_DELLINK only if dev->rtnl_link_state is set to RTNL_LINK_INITIALIZED.

Fixes: dcc38c033b32 ("openvswitch: Re-add CONFIG_OPENVSWITCH_VXLAN")
CC: Thomas Graf <tgraf@suug.ch>
CC: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f999db2f97b4..f7669d60b3f7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2972,6 +2972,12 @@ struct net_device *vxlan_dev_create(struct net *net, const char *name,
 		return ERR_PTR(err);
 	}
 
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+
 	return dev;
 }
 EXPORT_SYMBOL_GPL(vxlan_dev_create);
-- 
2.4.2
