From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] sit: fix use after free of fb_tunnel_dev
Date: Wed, 13 Nov 2013 21:27:38 -0500
Message-ID: <1384396058-26850-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, edumazet@google.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f73.google.com ([209.85.128.73]:45569 "EHLO
	mail-qe0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3KNC1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:27:42 -0500
Received: by mail-qe0-f73.google.com with SMTP id t7so18353qeb.0
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 18:27:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug: The fallback device is created in sit_init_net and assumed to be
freed in sit_exit_net. First, it is dereferenced in that function, in
sit_destroy_tunnels:

        struct net *net = dev_net(sitn->fb_tunnel_dev);

Prior to this, rtnl_unlink_register has removed all devices that match
rtnl_link_ops == sit_link_ops.

Commit 205983c43700 added the line

+       sitn->fb_tunnel_dev->rtnl_link_ops = &sit_link_ops;

which cases the fallback device to match here and be freed before it
is last dereferenced.

Fix: This commit adds an explicit .delllink callback to sit_link_ops
that skips deallocation at rtnl_unlink_register for the fallback
device. This mechanism is comparable to the one in ip_tunnel.

It also modifies sit_destroy_tunnels and its only caller sit_exit_net
to avoid the offending dereference in the first place. That double
lookup is more complicated than required.

Test: The bug is only triggered when CONFIG_NET_NS is enabled. It
causes a GPF only when CONFIG_DEBUG_SLAB is enabled. Verified that
this bug exists at the mentioned commit, at davem-net HEAD and at
3.11.y HEAD. Verified that it went away after applying this patch.

Fixes: 205983c43700 ("sit: allow to use rtnl ops on fb tunnel")

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

Please also queue this patch up for 3.11 stable.
---
 net/ipv6/sit.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3a9038d..5a57f38 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1604,6 +1604,15 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
 #endif
 };
 
+static void ipip6_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net *net = dev_net(dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
+
+	if (dev != sitn->fb_tunnel_dev)
+		unregister_netdevice_queue(dev, head);
+}
+
 static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.kind		= "sit",
 	.maxtype	= IFLA_IPTUN_MAX,
@@ -1615,6 +1624,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.changelink	= ipip6_changelink,
 	.get_size	= ipip6_get_size,
 	.fill_info	= ipip6_fill_info,
+	.dellink	= ipip6_dellink,
 };
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
@@ -1629,9 +1639,10 @@ static struct xfrm_tunnel ipip_handler __read_mostly = {
 	.priority	=	2,
 };
 
-static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
+static void __net_exit sit_destroy_tunnels(struct net *net,
+					   struct list_head *head)
 {
-	struct net *net = dev_net(sitn->fb_tunnel_dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
 	struct net_device *dev, *aux;
 	int prio;
 
@@ -1706,11 +1717,10 @@ err_alloc_dev:
 
 static void __net_exit sit_exit_net(struct net *net)
 {
-	struct sit_net *sitn = net_generic(net, sit_net_id);
 	LIST_HEAD(list);
 
 	rtnl_lock();
-	sit_destroy_tunnels(sitn, &list);
+	sit_destroy_tunnels(net, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
-- 
1.8.4.1
