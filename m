From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 2/2] sit: fix use after free of fb_tunnel_dev
Date: Tue, 28 Jan 2014 15:57:58 -0500
Message-ID: <20140128210543.325834094@goodmis.org>
References: <20140128205756.074448668@goodmis.org>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:61805 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755539AbaA1VFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 16:05:45 -0500
Content-Disposition: inline; filename=0002-sit-fix-use-after-free-of-fb_tunnel_dev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

[ Upstream commit 9434266f2c645d4fcf62a03a8e36ad8075e37943 ]

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
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 net/ipv6/sit.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3652033..d80055a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1507,6 +1507,15 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
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
@@ -1517,6 +1526,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.changelink	= ipip6_changelink,
 	.get_size	= ipip6_get_size,
 	.fill_info	= ipip6_fill_info,
+	.dellink	= ipip6_dellink,
 };
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
@@ -1525,8 +1535,11 @@ static struct xfrm_tunnel sit_handler __read_mostly = {
 	.priority	=	1,
 };
 
-static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
+static void __net_exit sit_destroy_tunnels(struct net *net,
+					   struct list_head *head)
 {
+	struct sit_net *sitn = net_generic(net, sit_net_id);
+	struct net_device *dev, *aux;
 	int prio;
 
 	for_each_netdev_safe(net, dev, aux)
@@ -1596,12 +1609,10 @@ err_alloc_dev:
 
 static void __net_exit sit_exit_net(struct net *net)
 {
-	struct sit_net *sitn = net_generic(net, sit_net_id);
 	LIST_HEAD(list);
 
 	rtnl_lock();
-	sit_destroy_tunnels(sitn, &list);
-	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
+	sit_destroy_tunnels(net, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
-- 
1.8.4.3
