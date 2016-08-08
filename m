From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net] vti: flush x-netns xfrm cache when vti interface is removed
Date: Mon,  8 Aug 2016 18:22:45 -0400
Message-ID: <1470694965-17978-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929AbcHHWWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2016 18:22:49 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 36C414C655
	for <netdev@vger.kernel.org>; Mon,  8 Aug 2016 22:22:48 +0000 (UTC)
Received: from thinkcentre.nc.rr.com (unused [10.10.51.113] (may be forged))
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u78MMlbd008562
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2016 18:22:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When executing the script included below, the netns delete operation
hangs with the following message (repeated at 10 second intervals):

  kernel:unregister_netdevice: waiting for lo to become free. Usage count = 1

This occurs because a reference to the lo interface in the "secure" netns
is still held by a dst entry in the xfrm bundle cache in the init netns.

Prevent this problem by garbage collecting the tunnel namespace flow cache
when a vti interface is deleted from a namespace that is different from
the tunnel namepace.

A more detailed description of the problem scenario (referencing commands
in the problem script) is as follows:

(1) ip link add vti_test type vti local 1.1.1.1 remote 1.1.1.2 key 1

  The vti_test interface is created in the init namespace. vti_tunnel_init()
  attaches a struct ip_tunnel to the vti interface's netdev_priv(dev),
  setting tunnel->net to &init_net.

(2) ip link set vti_test netns secure

  The vti_test interface is moved to the "secure" netns. Note that
  the associated struct ip_tunnel still has tunnel->net set to &init_net.

(3) ip netns exec secure ping -c 4 -i 0.02 -I 192.168.100.1 192.168.200.1

  The first packet sent using the vti device causes xfrm_lookup() to be
  called as follows:

      dst = xfrm_lookup(tunnel->net, skb_dst(skb), fl, NULL, 0);

  Note that tunnel->net is the init namespace, while skb_dst(skb) references
  the vti_test interface in the "secure" namespace. The returned dst
  references an interface in the init namespace.

  Also note that the first parameter to xfrm_lookup() determines which flow
  cache is used to store the computed xfrm bundle, so after xfrm_lookup()
  returns there will be a cached bundle in the init namespace flow cache
  with a dst referencing a device in the "secure" namespace.

(4) ip netns del secure

  Kernel begins to delete the "secure" namespace.  At some point the
  vti_test interface is deleted, at which point dst_ifdown() changes
  the dst->dev in the cached xfrm bundle flow from vti_test to lo (still
  in the "secure" namespace however).

  Since nothing has happened to cause the init namespace's flow cache
  to be garbage collected, this dst remains attached to the flow cache,
  so the kernel loops waiting for the last reference to lo to go away.

<Begin script>
ip link add br1 type bridge
ip link set dev br1 up
ip addr add dev br1 1.1.1.1/8

ip netns add secure
ip link add vti_test type vti local 1.1.1.1 remote 1.1.1.2 key 1
ip link set vti_test netns secure
ip netns exec secure ip link set vti_test up
ip netns exec secure ip link s lo up
ip netns exec secure ip addr add dev lo 192.168.100.1/24
ip netns exec secure ip route add 192.168.200.0/24 dev vti_test
ip xfrm policy flush
ip xfrm state flush
ip xfrm policy add dir out tmpl src 1.1.1.1 dst 1.1.1.2 \
   proto esp mode tunnel mark 1
ip xfrm policy add dir in tmpl src 1.1.1.2 dst 1.1.1.1 \
   proto esp mode tunnel mark 1
ip xfrm state add src 1.1.1.1 dst 1.1.1.2 proto esp spi 1 \
   mode tunnel enc des3_ede 0x112233445566778811223344556677881122334455667788
ip xfrm state add src 1.1.1.2 dst 1.1.1.1 proto esp spi 1 \
   mode tunnel enc des3_ede 0x112233445566778811223344556677881122334455667788

ip netns exec secure ping -c 4 -i 0.02 -I 192.168.100.1 192.168.200.1

ip netns del secure
<End script>

Reported-by: Hangbin Liu <haliu@redhat.com>
Reported-by: Jan Tluka <jtluka@redhat.com>
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 net/ipv4/ip_vti.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index a917903..a815735 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -48,6 +48,7 @@ static struct rtnl_link_ops vti_link_ops __read_mostly;
 
 static int vti_net_id __read_mostly;
 static int vti_tunnel_init(struct net_device *dev);
+static void vti_tunnel_uninit(struct net_device *dev);
 
 static int vti_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 		     int encap_type)
@@ -359,7 +360,7 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static const struct net_device_ops vti_netdev_ops = {
 	.ndo_init	= vti_tunnel_init,
-	.ndo_uninit	= ip_tunnel_uninit,
+	.ndo_uninit	= vti_tunnel_uninit,
 	.ndo_start_xmit	= vti_tunnel_xmit,
 	.ndo_do_ioctl	= vti_tunnel_ioctl,
 	.ndo_change_mtu	= ip_tunnel_change_mtu,
@@ -392,6 +393,17 @@ static int vti_tunnel_init(struct net_device *dev)
 	return ip_tunnel_init(dev);
 }
 
+static void vti_tunnel_uninit(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct net *net = tunnel->net;
+
+	ip_tunnel_uninit(dev);
+
+	if (!net_eq(net, dev_net(dev)))
+		xfrm_garbage_collect(net);
+}
+
 static void __net_init vti_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-- 
2.5.5
