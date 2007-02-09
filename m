From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][2/4] make sit use the xfrm4_tunnel_register
Date: Fri, 9 Feb 2007 16:12:29 +0900
Message-ID: <20070209161229.6ca3ec82.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:59922 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1946183AbXBIHhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 02:37:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes sit use xfrm4_tunnel_register instead of
inet_add_protocol. It solves conflict of sit device with
inter address family IPsec tunnel.

signed-off-by Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
 net/ipv6/Kconfig |    1 +
 net/ipv6/sit.c   |   30 ++++++++++++++++++------------
 2 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index deb4101..79682ef 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -156,6 +156,7 @@ config INET6_XFRM_MODE_ROUTEOPTIMIZATION
 config IPV6_SIT
 	tristate "IPv6: IPv6-in-IPv4 tunnel (SIT driver)"
 	depends on IPV6
+	select INET_TUNNEL
 	default y
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 77b7b09..26370dc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -216,7 +216,7 @@ static void ipip6_tunnel_uninit(struct n
 }
 
 
-static void ipip6_err(struct sk_buff *skb, u32 info)
+static int ipip6_err(struct sk_buff *skb, u32 info)
 {
 #ifndef I_WISH_WORLD_WERE_PERFECT
 
@@ -228,21 +228,22 @@ #ifndef I_WISH_WORLD_WERE_PERFECT
 	int type = skb->h.icmph->type;
 	int code = skb->h.icmph->code;
 	struct ip_tunnel *t;
+	int err;
 
 	switch (type) {
 	default:
 	case ICMP_PARAMETERPROB:
-		return;
+		return 0;
 
 	case ICMP_DEST_UNREACH:
 		switch (code) {
 		case ICMP_SR_FAILED:
 		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
-			return;
+			return 0;
 		case ICMP_FRAG_NEEDED:
 			/* Soft state for pmtu is maintained by IP core. */
-			return;
+			return 0;
 		default:
 			/* All others are translated to HOST_UNREACH.
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
@@ -253,14 +254,18 @@ #ifndef I_WISH_WORLD_WERE_PERFECT
 		break;
 	case ICMP_TIME_EXCEEDED:
 		if (code != ICMP_EXC_TTL)
-			return;
+			return 0;
 		break;
 	}
 
+	err = -ENOENT;
+
 	read_lock(&ipip6_lock);
 	t = ipip6_tunnel_lookup(iph->daddr, iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
+
+	err = 0;
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
 		goto out;
 
@@ -271,7 +276,7 @@ #ifndef I_WISH_WORLD_WERE_PERFECT
 	t->err_time = jiffies;
 out:
 	read_unlock(&ipip6_lock);
-	return;
+	return err;
 #else
 	struct iphdr *iph = (struct iphdr*)dp;
 	int hlen = iph->ihl<<2;
@@ -332,7 +337,7 @@ #else
 	/* Prepare fake skb to feed it to icmpv6_send */
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
-		return;
+		return 0;
 	dst_release(skb2->dst);
 	skb2->dst = NULL;
 	skb_pull(skb2, skb->data - (u8*)iph6);
@@ -355,7 +360,7 @@ #else
 		}
 	}
 	kfree_skb(skb2);
-	return;
+	return 0;
 #endif
 }
 
@@ -790,9 +795,10 @@ static int __init ipip6_fb_tunnel_init(s
 	return 0;
 }
 
-static struct net_protocol sit_protocol = {
+static struct xfrm_tunnel sit_handler = {
 	.handler	=	ipip6_rcv,
 	.err_handler	=	ipip6_err,
+	.priority	=	1,
 };
 
 static void __exit sit_destroy_tunnels(void)
@@ -811,7 +817,7 @@ static void __exit sit_destroy_tunnels(v
 
 static void __exit sit_cleanup(void)
 {
-	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
+	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
 	rtnl_lock();
 	sit_destroy_tunnels();
@@ -825,7 +831,7 @@ static int __init sit_init(void)
 
 	printk(KERN_INFO "IPv6 over IPv4 tunneling driver\n");
 
-	if (inet_add_protocol(&sit_protocol, IPPROTO_IPV6) < 0) {
+	if (xfrm4_tunnel_register(&sit_handler, AF_INET6) < 0) {
 		printk(KERN_INFO "sit init: Can't add protocol\n");
 		return -EAGAIN;
 	}
@@ -847,7 +853,7 @@ static int __init sit_init(void)
  err2:
 	free_netdev(ipip6_fb_tunnel_dev);
  err1:
-	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
+	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 	goto out;
 }
 
-- 
1.4.1

