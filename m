From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ip6_gre: don't allow to remove the fb_tunnel_dev
Date: Mon, 14 Apr 2014 17:11:38 +0200
Message-ID: <1397488298-19931-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Dmitry Kozlov <xeb@mail.ru>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40715 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607AbaDNPLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 11:11:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's possible to remove the FB tunnel with the command 'ip link del ip6gre0' but
this is unsafe, the module always supposes that this device exists. For example,
ip6gre_tunnel_lookup() may use it unconditionally.

Let's add a rtnl handler for dellink, which will never remove the FB tunnel (we
let ip6gre_destroy_tunnels() do the job).

Introduced by commit c12b395a4664 ("gre: Support GRE over IPv6").

CC: Dmitry Kozlov <xeb@mail.ru>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_gre.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c98338b81d30..9d921462b57f 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1559,6 +1559,15 @@ static int ip6gre_changelink(struct net_device *dev, struct nlattr *tb[],
 	return 0;
 }
 
+static void ip6gre_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net *net = dev_net(dev);
+	struct ip6gre_net *ign = net_generic(net, ip6gre_net_id);
+
+	if (dev != ign->fb_tunnel_dev)
+		unregister_netdevice_queue(dev, head);
+}
+
 static size_t ip6gre_get_size(const struct net_device *dev)
 {
 	return
@@ -1636,6 +1645,7 @@ static struct rtnl_link_ops ip6gre_link_ops __read_mostly = {
 	.validate	= ip6gre_tunnel_validate,
 	.newlink	= ip6gre_newlink,
 	.changelink	= ip6gre_changelink,
+	.dellink	= ip6gre_dellink,
 	.get_size	= ip6gre_get_size,
 	.fill_info	= ip6gre_fill_info,
 };
-- 
1.9.0
