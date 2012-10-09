From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] vxlan: associate with tunnel socket on xmit
Date: Tue, 09 Oct 2012 10:56:40 -0700
Message-ID: <20121009175714.612852097@vyatta.com>
References: <20121009175637.048993312@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:51697 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756599Ab2JISB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 14:01:29 -0400
Content-Disposition: inline; filename=vxlan-owner.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tunnelling a skb, associate it with the tunnel socket.
This allows paramaters set on tunnel socket (like multicast loop
flag), to be picked up by ip_output.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/vxlan.c	2012-10-09 10:49:01.334832146 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 10:49:05.318792637 -0700
@@ -633,6 +633,23 @@ static __be32 vxlan_find_dst(struct vxla
 		return f->remote_ip;
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
@@ -726,6 +743,8 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	iph->saddr	= fl4.saddr;
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
 
+	vxlan_set_owner(dev, skb);
+
 	/* See __IPTUNNEL_XMIT */
 	skb->ip_summed = CHECKSUM_NONE;
 	ip_select_ident(iph, &rt->dst, NULL);
