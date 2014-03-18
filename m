From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 09/13] vti6: Update the ipv6 side to use its own receive hook.
Date: Tue, 18 Mar 2014 08:21:34 +0100
Message-ID: <1395127298-24083-10-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53252 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753539AbaCRHV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:58 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, vti6 uses the IPsec protocol multiplexer to
register its own receive side hooks for ESP, AH and IPCOMP.

Vti6 now does the following on receive side:

1. Do an input policy check for the IPsec packet we received.
   This is required because this packet could be already
   prosecces by IPsec, so an inbuond policy check is needed.

2. Mark the packet with the i_key. The policy and the state
   must match this key now. Policy and state belong to the vti
   namespace and policy enforcement is done at the further layers.

3. Call the generic xfrm layer to do decryption and decapsulation.

4. Wait for a callback from the xfrm layer to properly clean the
   skb to not leak informations on namespace transitions and
    update the device statistics.

On transmit side:

1. Mark the packet with the o_key. The policy and the state
   must match this key now.

2. Do a xfrm_lookup on the original packet with the mark applied.

3. Check if we got an IPsec route.

4. Clean the skb to not leak informations on namespace
   transitions.

5. Attach the dst_enty we got from the xfrm_lookup to the skb.

6. Call dst_output to do the IPsec processing.

7. Do the device statistics.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c |  176 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 149 insertions(+), 27 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index cc4a758..226854a 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -287,11 +287,8 @@ static int vti6_rcv(struct sk_buff *skb)
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 
 	rcu_read_lock();
-
 	if ((t = vti6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
 				 &ipv6h->daddr)) != NULL) {
-		struct pcpu_sw_netstats *tstats;
-
 		if (t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) {
 			rcu_read_unlock();
 			goto discard;
@@ -308,27 +305,58 @@ static int vti6_rcv(struct sk_buff *skb)
 			goto discard;
 		}
 
-		tstats = this_cpu_ptr(t->dev->tstats);
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->rx_packets++;
-		tstats->rx_bytes += skb->len;
-		u64_stats_update_end(&tstats->syncp);
-
-		skb->mark = 0;
-		secpath_reset(skb);
-		skb->dev = t->dev;
+		XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = t;
+		skb->mark = be32_to_cpu(t->parms.i_key);
 
 		rcu_read_unlock();
-		return 0;
+
+		return xfrm6_rcv(skb);
 	}
 	rcu_read_unlock();
-	return 1;
-
+	return -EINVAL;
 discard:
 	kfree_skb(skb);
 	return 0;
 }
 
+static int vti6_rcv_cb(struct sk_buff *skb, int err)
+{
+	unsigned short family;
+	struct net_device *dev;
+	struct pcpu_sw_netstats *tstats;
+	struct xfrm_state *x;
+	struct ip6_tnl *t = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6;
+
+	if (!t)
+		return 1;
+
+	dev = t->dev;
+
+	if (err) {
+		dev->stats.rx_errors++;
+		dev->stats.rx_dropped++;
+
+		return 0;
+	}
+
+	x = xfrm_input_state(skb);
+	family = x->inner_mode->afinfo->family;
+
+	if (!xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family))
+		return -EPERM;
+
+	skb_scrub_packet(skb, !net_eq(t->net, dev_net(skb->dev)));
+	skb->dev = dev;
+
+	tstats = this_cpu_ptr(dev->tstats);
+	u64_stats_update_begin(&tstats->syncp);
+	tstats->rx_packets++;
+	tstats->rx_bytes += skb->len;
+	u64_stats_update_end(&tstats->syncp);
+
+	return 0;
+}
+
 /**
  * vti6_addr_conflict - compare packet addresses to tunnel's own
  *   @t: the outgoing tunnel device
@@ -394,7 +422,6 @@ static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_err_dst_release;
 	}
 
-
 	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
 	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
 	skb_dst_set(skb, dst);
@@ -438,9 +465,60 @@ tx_err:
 	return NETDEV_TX_OK;
 }
 
+static int vti6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+		    u8 type, u8 code, int offset, __be32 info)
+{
+	__be32 spi;
+	struct xfrm_state *x;
+	struct ip6_tnl *t;
+	struct ip_esp_hdr *esph;
+	struct ip_auth_hdr *ah;
+	struct ip_comp_hdr *ipch;
+	struct net *net = dev_net(skb->dev);
+	const struct ipv6hdr *iph = (const struct ipv6hdr *)skb->data;
+	int protocol = iph->nexthdr;
+
+	t = vti6_tnl_lookup(dev_net(skb->dev), &iph->daddr, &iph->saddr);
+	if (!t)
+		return -1;
+
+	switch (protocol) {
+	case IPPROTO_ESP:
+		esph = (struct ip_esp_hdr *)(skb->data + offset);
+		spi = esph->spi;
+		break;
+	case IPPROTO_AH:
+		ah = (struct ip_auth_hdr *)(skb->data + offset);
+		spi = ah->spi;
+		break;
+	case IPPROTO_COMP:
+		ipch = (struct ip_comp_hdr *)(skb->data + offset);
+		spi = htonl(ntohs(ipch->cpi));
+		break;
+	default:
+		return 0;
+	}
+
+	if (type != ICMPV6_PKT_TOOBIG &&
+	    type != NDISC_REDIRECT)
+		return 0;
+
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+			      spi, protocol, AF_INET6);
+	if (!x)
+		return 0;
+
+	if (type == NDISC_REDIRECT)
+		ip6_redirect(skb, net, skb->dev->ifindex, 0);
+	else
+		ip6_update_pmtu(skb, net, info, 0, 0);
+	xfrm_state_put(x);
+
+	return 0;
+}
+
 static void vti6_link_config(struct ip6_tnl *t)
 {
-	struct dst_entry *dst;
 	struct net_device *dev = t->dev;
 	struct __ip6_tnl_parm *p = &t->parms;
 
@@ -871,11 +949,6 @@ static struct rtnl_link_ops vti6_link_ops __read_mostly = {
 	.fill_info	= vti6_fill_info,
 };
 
-static struct xfrm_tunnel_notifier vti6_handler __read_mostly = {
-	.handler	= vti6_rcv,
-	.priority	=	1,
-};
-
 static void __net_exit vti6_destroy_tunnels(struct vti6_net *ip6n)
 {
 	int h;
@@ -947,6 +1020,27 @@ static struct pernet_operations vti6_net_ops = {
 	.size = sizeof(struct vti6_net),
 };
 
+static struct xfrm6_protocol vti_esp6_protocol __read_mostly = {
+	.handler	=	vti6_rcv,
+	.cb_handler	=	vti6_rcv_cb,
+	.err_handler	=	vti6_err,
+	.priority	=	100,
+};
+
+static struct xfrm6_protocol vti_ah6_protocol __read_mostly = {
+	.handler	=	vti6_rcv,
+	.cb_handler	=	vti6_rcv_cb,
+	.err_handler	=	vti6_err,
+	.priority	=	100,
+};
+
+static struct xfrm6_protocol vti_ipcomp6_protocol __read_mostly = {
+	.handler	=	vti6_rcv,
+	.cb_handler	=	vti6_rcv_cb,
+	.err_handler	=	vti6_err,
+	.priority	=	100,
+};
+
 /**
  * vti6_tunnel_init - register protocol and reserve needed resources
  *
@@ -960,11 +1054,33 @@ static int __init vti6_tunnel_init(void)
 	if (err < 0)
 		goto out_pernet;
 
-	err = xfrm6_mode_tunnel_input_register(&vti6_handler);
+	err = xfrm6_protocol_register(&vti_esp6_protocol, IPPROTO_ESP);
 	if (err < 0) {
-		pr_err("%s: can't register vti6\n", __func__);
+		unregister_pernet_device(&vti6_net_ops);
+		pr_err("%s: can't register vti6 protocol\n", __func__);
+
 		goto out;
 	}
+
+	err = xfrm6_protocol_register(&vti_ah6_protocol, IPPROTO_AH);
+	if (err < 0) {
+		xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
+		unregister_pernet_device(&vti6_net_ops);
+		pr_err("%s: can't register vti6 protocol\n", __func__);
+
+		goto out;
+	}
+
+	err = xfrm6_protocol_register(&vti_ipcomp6_protocol, IPPROTO_COMP);
+	if (err < 0) {
+		xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
+		xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
+		unregister_pernet_device(&vti6_net_ops);
+		pr_err("%s: can't register vti6 protocol\n", __func__);
+
+		goto out;
+	}
+
 	err = rtnl_link_register(&vti6_link_ops);
 	if (err < 0)
 		goto rtnl_link_failed;
@@ -972,7 +1088,9 @@ static int __init vti6_tunnel_init(void)
 	return 0;
 
 rtnl_link_failed:
-	xfrm6_mode_tunnel_input_deregister(&vti6_handler);
+	xfrm6_protocol_deregister(&vti_ipcomp6_protocol, IPPROTO_COMP);
+	xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH);
+	xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP);
 out:
 	unregister_pernet_device(&vti6_net_ops);
 out_pernet:
@@ -985,8 +1103,12 @@ out_pernet:
 static void __exit vti6_tunnel_cleanup(void)
 {
 	rtnl_link_unregister(&vti6_link_ops);
-	if (xfrm6_mode_tunnel_input_deregister(&vti6_handler))
-		pr_info("%s: can't deregister vti6\n", __func__);
+	if (xfrm6_protocol_deregister(&vti_ipcomp6_protocol, IPPROTO_COMP))
+		pr_info("%s: can't deregister protocol\n", __func__);
+	if (xfrm6_protocol_deregister(&vti_ah6_protocol, IPPROTO_AH))
+		pr_info("%s: can't deregister protocol\n", __func__);
+	if (xfrm6_protocol_deregister(&vti_esp6_protocol, IPPROTO_ESP))
+		pr_info("%s: can't deregister protocol\n", __func__);
 
 	unregister_pernet_device(&vti6_net_ops);
 }
-- 
1.7.9.5
