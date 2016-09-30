From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] vti6: flush x-netns xfrm cache when vti interface is removed
Date: Fri, 30 Sep 2016 11:11:07 +0200
Message-ID: <1475226667-22404-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Lance Richardson <lrichard@redhat.com>
To: davem@davemloft.net, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:58962 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbcI3JLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 05:11:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the same fix than commit a5d0dc810abf ("vti: flush x-netns xfrm
cache when vti interface is removed")

This patch fixes a refcnt problem when a x-netns vti6 interface is removed:
unregister_netdevice: waiting for vti6_test to become free. Usage count = 1

Here is a script to reproduce the problem:

ip link set dev ntfp2 up
ip addr add dev ntfp2 2001::1/64
ip link add vti6_test type vti6 local 2001::1 remote 2001::2 key 1
ip netns add secure
ip link set vti6_test netns secure
ip netns exec secure ip link set vti6_test up
ip netns exec secure ip link s lo up
ip netns exec secure ip addr add dev vti6_test 2003::1/64
ip -6 xfrm policy add dir out tmpl src 2001::1 dst 2001::2 proto esp \
	   mode tunnel mark 1
ip -6 xfrm policy add dir in tmpl src 2001::2 dst 2001::1 proto esp \
	   mode tunnel mark 1
ip xfrm state add src 2001::1 dst 2001::2 proto esp spi 1 mode tunnel \
	   enc des3_ede 0x112233445566778811223344556677881122334455667788 mark 1
ip xfrm state add src 2001::2 dst 2001::1 proto esp spi 1 mode tunnel \
	   enc des3_ede 0x112233445566778811223344556677881122334455667788 mark 1
ip netns exec secure  ping6 -c 4 2003::2
ip netns del secure

CC: Lance Richardson <lrichard@redhat.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_vti.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 5bd3afdcc771..cc7f7e9a8e8d 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1138,6 +1138,33 @@ static struct xfrm6_protocol vti_ipcomp6_protocol __read_mostly = {
 	.priority	=	100,
 };
 
+static bool is_vti6_tunnel(const struct net_device *dev)
+{
+	return dev->netdev_ops == &vti6_netdev_ops;
+}
+
+static int vti6_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct ip6_tnl *t = netdev_priv(dev);
+
+	if (!is_vti6_tunnel(dev))
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_DOWN:
+		if (!net_eq(t->net, dev_net(dev)))
+			xfrm_garbage_collect(t->net);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block vti6_notifier_block __read_mostly = {
+	.notifier_call = vti6_device_event,
+};
+
 /**
  * vti6_tunnel_init - register protocol and reserve needed resources
  *
@@ -1148,6 +1175,8 @@ static int __init vti6_tunnel_init(void)
 	const char *msg;
 	int err;
 
+	register_netdevice_notifier(&vti6_notifier_block);
+
 	msg = "tunnel device";
 	err = register_pernet_device(&vti6_net_ops);
 	if (err < 0)
@@ -1180,6 +1209,7 @@ xfrm_proto_ah_failed:
 xfrm_proto_esp_failed:
 	unregister_pernet_device(&vti6_net_ops);
 pernet_dev_failed:
+	unregister_netdevice_notifier(&vti6_notifier_block);
 	pr_err("vti6 init: failed to register %s\n", msg);
 	return err;
 }
@@ -1194,6 +1224,7 @@ static void __exit vti6_tunnel_cleanup(void)
 	xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
 	xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
 	unregister_pernet_device(&vti6_net_ops);
+	unregister_netdevice_notifier(&vti6_notifier_block);
 }
 
 module_init(vti6_tunnel_init);
-- 
2.8.1
