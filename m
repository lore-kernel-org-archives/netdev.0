From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 4/8] vxlan: associate with tunnel socket on transmit
Date: Tue, 09 Oct 2012 23:35:49 -0700
Message-ID: <20121010063623.611041750@vyatta.com>
References: <20121010063545.453368147@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52282 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310Ab2JJGjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:39:23 -0400
Content-Disposition: inline; filename=vxlan-owner.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tunnelling a skb, associate it with the tunnel socket.
This allows parameters set on tunnel socket (like multicast loop
flag), to be picked up by ip_output.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vxlan.c	2012-10-09 18:08:33.466447793 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 18:08:34.066441861 -0700
@@ -637,6 +637,23 @@ static __be32 vxlan_find_dst(struct vxla
 
 }
 
+static void vxlan_sock_free(struct sk_buff *skb)
+{
+	sock_put(skb->sk);
+}
+
+/* On transmit, associate with the tunnel socket */
+static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
+{
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	struct sock *sk = vn->sock->sk;
+
+	skb_orphan(skb);
+	sock_hold(sk);
+	skb->sk = sk;
+	skb->destructor = vxlan_sock_free;
+}
+
 /* Transmit local packets over Vxlan
  *
  * Outer IP header inherits ECN and DF from inner header.
@@ -732,6 +749,8 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	iph->saddr	= fl4.saddr;
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
 
+	vxlan_set_owner(dev, skb);
+
 	/* See __IPTUNNEL_XMIT */
 	skb->ip_summed = CHECKSUM_NONE;
 	ip_select_ident(iph, &rt->dst, NULL);
