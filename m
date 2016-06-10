From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] ovs/gre: fix rtnl notifications on iface deletion
Date: Fri, 10 Jun 2016 11:32:27 +0200
Message-ID: <1465551147-17185-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:35185 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbcFJJcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 05:32:41 -0400
In-Reply-To: <1465551147-17185-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function gretap_fb_dev_create() (only used by ovs) never calls
rtnl_configure_link(). The consequence is that dev->rtnl_link_state is
never set to RTNL_LINK_INITIALIZED.
During the deletion phase, the function rollback_registered_many() sends
a RTM_DELLINK only if dev->rtnl_link_state is set to RTNL_LINK_INITIALIZED.

Fixes: b2acd1dc3949 ("openvswitch: Use regular GRE net_device instead of vport")
CC: Thomas Graf <tgraf@suug.ch>
CC: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_gre.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4d2025f7ec57..c6a46ee87a3a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1146,6 +1146,10 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	if (err)
 		goto out;
 
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0)
+		goto out;
+
 	return dev;
 out:
 	free_netdev(dev);
-- 
2.4.2
