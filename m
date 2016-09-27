From: Florian Westphal <fw@strlen.de>
Subject: [RFC 2/3] vti: revert flush x-netns xfrm cache when vti interface is removed
Date: Tue, 27 Sep 2016 18:05:22 +0200
Message-ID: <1474992323-11327-3-git-send-email-fw@strlen.de>
References: <1474992323-11327-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53294 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934325AbcI0QF2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:05:28 -0400
In-Reply-To: <1474992323-11327-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flow cache is removed in next patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_vti.c | 31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 5d7944f394d9..c9957edee25e 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -570,33 +570,6 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
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
@@ -604,8 +577,6 @@ static int __init vti_init(void)
 
 	pr_info("IPv4 over IPsec tunneling driver\n");
 
-	register_netdevice_notifier(&vti_notifier_block);
-
 	msg = "tunnel device";
 	err = register_pernet_device(&vti_net_ops);
 	if (err < 0)
@@ -638,7 +609,6 @@ xfrm_proto_ah_failed:
 xfrm_proto_esp_failed:
 	unregister_pernet_device(&vti_net_ops);
 pernet_dev_failed:
-	unregister_netdevice_notifier(&vti_notifier_block);
 	pr_err("vti init: failed to register %s\n", msg);
 	return err;
 }
@@ -650,7 +620,6 @@ static void __exit vti_fini(void)
 	xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH);
 	xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
 	unregister_pernet_device(&vti_net_ops);
-	unregister_netdevice_notifier(&vti_notifier_block);
 }
 
 module_init(vti_init);
-- 
2.7.3
