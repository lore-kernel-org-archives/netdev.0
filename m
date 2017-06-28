From: Florian Westphal <fw@strlen.de>
Subject: [RFC net-next 1/9] vti: revert flush x-netns xfrm cache when vti interface is removed
Date: Wed, 28 Jun 2017 15:26:44 +0200
Message-ID: <20170628132652.1275-2-fw@strlen.de>
References: <20170628132652.1275-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34202 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751642AbdF1N0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 09:26:42 -0400
In-Reply-To: <20170628132652.1275-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flow cache is removed in next commit.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_vti.c  | 31 -------------------------------
 net/ipv6/ip6_vti.c | 31 -------------------------------
 2 files changed, 62 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 0192c255e508..5ed63d250950 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -584,33 +584,6 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 	.get_link_net	= ip_tunnel_get_link_net,
 };
 
-static bool is_vti_tunnel(const struct net_device *dev)
-{
-	return dev->netdev_ops == &vti_netdev_ops;
-}
-
-static int vti_device_event(struct notifier_block *unused,
-			    unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-
-	if (!is_vti_tunnel(dev))
-		return NOTIFY_DONE;
-
-	switch (event) {
-	case NETDEV_DOWN:
-		if (!net_eq(tunnel->net, dev_net(dev)))
-			xfrm_garbage_collect(tunnel->net);
-		break;
-	}
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block vti_notifier_block __read_mostly = {
-	.notifier_call = vti_device_event,
-};
-
 static int __init vti_init(void)
 {
 	const char *msg;
@@ -618,8 +591,6 @@ static int __init vti_init(void)
 
 	pr_info("IPv4 over IPsec tunneling driver\n");
 
-	register_netdevice_notifier(&vti_notifier_block);
-
 	msg = "tunnel device";
 	err = register_pernet_device(&vti_net_ops);
 	if (err < 0)
@@ -652,7 +623,6 @@ static int __init vti_init(void)
 xfrm_proto_esp_failed:
 	unregister_pernet_device(&vti_net_ops);
 pernet_dev_failed:
-	unregister_netdevice_notifier(&vti_notifier_block);
 	pr_err("vti init: failed to register %s\n", msg);
 	return err;
 }
@@ -664,7 +634,6 @@ static void __exit vti_fini(void)
 	xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH);
 	xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
 	unregister_pernet_device(&vti_net_ops);
-	unregister_netdevice_notifier(&vti_notifier_block);
 }
 
 module_init(vti_init);
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 486c2305f53c..79444a4bfd6d 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1145,33 +1145,6 @@ static struct xfrm6_protocol vti_ipcomp6_protocol __read_mostly = {
 	.priority	=	100,
 };
 
-static bool is_vti6_tunnel(const struct net_device *dev)
-{
-	return dev->netdev_ops == &vti6_netdev_ops;
-}
-
-static int vti6_device_event(struct notifier_block *unused,
-			     unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct ip6_tnl *t = netdev_priv(dev);
-
-	if (!is_vti6_tunnel(dev))
-		return NOTIFY_DONE;
-
-	switch (event) {
-	case NETDEV_DOWN:
-		if (!net_eq(t->net, dev_net(dev)))
-			xfrm_garbage_collect(t->net);
-		break;
-	}
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block vti6_notifier_block __read_mostly = {
-	.notifier_call = vti6_device_event,
-};
-
 /**
  * vti6_tunnel_init - register protocol and reserve needed resources
  *
@@ -1182,8 +1155,6 @@ static int __init vti6_tunnel_init(void)
 	const char *msg;
 	int err;
 
-	register_netdevice_notifier(&vti6_notifier_block);
-
 	msg = "tunnel device";
 	err = register_pernet_device(&vti6_net_ops);
 	if (err < 0)
@@ -1216,7 +1187,6 @@ static int __init vti6_tunnel_init(void)
 xfrm_proto_esp_failed:
 	unregister_pernet_device(&vti6_net_ops);
 pernet_dev_failed:
-	unregister_netdevice_notifier(&vti6_notifier_block);
 	pr_err("vti6 init: failed to register %s\n", msg);
 	return err;
 }
@@ -1231,7 +1201,6 @@ static void __exit vti6_tunnel_cleanup(void)
 	xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
 	xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
 	unregister_pernet_device(&vti6_net_ops);
-	unregister_netdevice_notifier(&vti6_notifier_block);
 }
 
 module_init(vti6_tunnel_init);
-- 
2.13.0
