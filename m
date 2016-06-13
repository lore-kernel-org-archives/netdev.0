From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2 3/4] ovs/gre: fix rtnl notifications on iface deletion
Date: Mon, 13 Jun 2016 10:31:06 +0200
Message-ID: <1465806667-23148-4-git-send-email-nicolas.dichtel@6wind.com>
References: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
 <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, pshelar@ovn.org, jesse@kernel.org,
	linville@tuxdriver.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38145 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964919AbcFMIbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:31:13 -0400
In-Reply-To: <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
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
index 08deba679c8c..07c5cf1838d8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1149,6 +1149,10 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	if (err)
 		goto out;
 
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0)
+		goto out;
+
 	return dev;
 out:
 	ip_tunnel_dellink(dev, &list_kill);
-- 
2.4.2
