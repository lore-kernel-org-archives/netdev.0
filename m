From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ip6tnl: fix use after free of fb_tnl_dev
Date: Thu, 14 Nov 2013 15:47:03 +0100
Message-ID: <1384440423-4275-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20131113211430.1ad3bb7d@gandalf.local.home>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	gregkh@linuxfoundation.org, williams@redhat.com,
	linux-rt-users@vger.kernel.org, lclaudio@uudg.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Willem de Bruijn <willemb@google.com>
To: rostedt@goodmis.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45517 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab3KNOrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:47:16 -0500
In-Reply-To: <20131113211430.1ad3bb7d@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug has been introduced by commit bb8140947a24 ("ip6tnl: allow to use rtnl ops
on fb tunnel").

When ip6_tunnel.ko is unloaded, FB device is delete by rtnl_link_unregister()
and then we try to use the pointer in ip6_tnl_destroy_tunnels().

Let's add an handler for dellink, which will never remove the FB tunnel. With
this patch it will no more be possible to remove it via 'ip link del ip6tnl0',
but it's safer.

The same fix was already proposed by Willem de Bruijn <willemb@google.com> for
sit interfaces.

CC: Willem de Bruijn <willemb@google.com>
Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 583b77e2f69b..c1e11b5d6ccc 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1635,6 +1635,15 @@ static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
 	return ip6_tnl_update(t, &p);
 }
 
+static void ip6_tnl_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net *net = dev_net(dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+
+	if (dev != ip6n->fb_tnl_dev)
+		unregister_netdevice_queue(dev, head);
+}
+
 static size_t ip6_tnl_get_size(const struct net_device *dev)
 {
 	return
@@ -1699,6 +1708,7 @@ static struct rtnl_link_ops ip6_link_ops __read_mostly = {
 	.validate	= ip6_tnl_validate,
 	.newlink	= ip6_tnl_newlink,
 	.changelink	= ip6_tnl_changelink,
+	.dellink	= ip6_tnl_dellink,
 	.get_size	= ip6_tnl_get_size,
 	.fill_info	= ip6_tnl_fill_info,
 };
@@ -1715,9 +1725,9 @@ static struct xfrm6_tunnel ip6ip6_handler __read_mostly = {
 	.priority	=	1,
 };
 
-static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
+static void __net_exit ip6_tnl_destroy_tunnels(struct net *net)
 {
-	struct net *net = dev_net(ip6n->fb_tnl_dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 	struct net_device *dev, *aux;
 	int h;
 	struct ip6_tnl *t;
@@ -1785,10 +1795,8 @@ err_alloc_dev:
 
 static void __net_exit ip6_tnl_exit_net(struct net *net)
 {
-	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
-
 	rtnl_lock();
-	ip6_tnl_destroy_tunnels(ip6n);
+	ip6_tnl_destroy_tunnels(net);
 	rtnl_unlock();
 }
 
-- 
1.8.4.1
