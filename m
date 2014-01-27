From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v3 07/12] vti: Update the ipv4 side to use it's own receive hook.
Date: Mon, 27 Jan 2014 11:29:32 +0100
Message-ID: <1390818577-19589-8-git-send-email-steffen.klassert@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43188 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753821AbaA0KaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 05:30:13 -0500
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, vti uses the IPsec protocol multiplexer to
register it's own receive side hooks for ESP, AH and IPCOMP.

Vti now does the following on receive side:

1. Do an input policy check for the IPsec packet we received.
   This is required because this packet could be already
   prosecces by IPsec, so an inbuond policy check is needed.

2. Mark the packet with the i_key. The policy and the state
   must match this key now. Policy and state belong to the outer
   namespace and policy enforcement is done at the further layers.

3. Call the generic xfrm layer to do decryption and decapsulation.

4. Wait for a callback from the xfrm layer to properly clean the
   skb to not leak informations on namespace and to update the
   device statistics.

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
 net/ipv4/ip_vti.c |  212 +++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 166 insertions(+), 46 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 48eafae..1432bec 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -49,7 +49,6 @@ static struct rtnl_link_ops vti_link_ops __read_mostly;
 static int vti_net_id __read_mostly;
 static int vti_tunnel_init(struct net_device *dev);
 
-/* We dont digest the packet therefore let the packet pass */
 static int vti_rcv(struct sk_buff *skb)
 {
 	struct ip_tunnel *tunnel;
@@ -60,66 +59,82 @@ static int vti_rcv(struct sk_buff *skb)
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 				  iph->saddr, iph->daddr, 0);
 	if (tunnel != NULL) {
-		struct pcpu_sw_netstats *tstats;
-		u32 oldmark = skb->mark;
-		int ret;
-
-
-		/* temporarily mark the skb with the tunnel o_key, to
-		 * only match policies with this mark.
-		 */
-		skb->mark = be32_to_cpu(tunnel->parms.o_key);
-		ret = xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb);
-		skb->mark = oldmark;
-		if (!ret)
-			return -1;
-
-		tstats = this_cpu_ptr(tunnel->dev->tstats);
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->rx_packets++;
-		tstats->rx_bytes += skb->len;
-		u64_stats_update_end(&tstats->syncp);
-
-		secpath_reset(skb);
-		skb->dev = tunnel->dev;
-		return 1;
+		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
+			goto drop;
+
+		XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = tunnel;
+		skb->mark = be32_to_cpu(tunnel->parms.i_key);
+
+		return xfrm4_rcv(skb);
 	}
 
 	return -1;
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
+static int vti_rcv_cb(struct sk_buff *skb, int err)
+{
+	struct net_device *dev;
+	struct pcpu_sw_netstats *tstats;
+	struct ip_tunnel *tunnel = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4;
+
+	if (!tunnel)
+		return -1;
+
+	dev = tunnel->dev;
+
+	if (err) {
+		dev->stats.rx_errors++;
+		dev->stats.rx_dropped++;
+
+		return 0;
+	}
+
+	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(skb->dev)));
+	skb->dev = dev;
+
+	tstats = this_cpu_ptr(dev->tstats);
+
+	u64_stats_update_begin(&tstats->syncp);
+	tstats->rx_packets++;
+	tstats->rx_bytes += skb->len;
+	u64_stats_update_end(&tstats->syncp);
+
+	return 0;
 }
 
 /* This function assumes it is being called from dev_queue_xmit()
  * and that skb is filled properly by that function.
  */
-
 static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct iphdr  *tiph = &tunnel->parms.iph;
-	u8     tos;
 	struct rtable *rt;		/* Route to the other host */
 	struct net_device *tdev;	/* Device to other host */
-	struct iphdr  *old_iph = ip_hdr(skb);
-	__be32 dst = tiph->daddr;
-	struct flowi4 fl4;
+	struct flowi fl;
 	int err;
 
 	if (skb->protocol != htons(ETH_P_IP))
 		goto tx_error;
 
-	tos = old_iph->tos;
+	memset(&fl, 0, sizeof(fl));
+	skb->mark = be32_to_cpu(tunnel->parms.o_key);
+	xfrm_decode_session(skb, &fl, AF_INET);
+
+	if (!skb_dst(skb)) {
+		dev->stats.tx_carrier_errors++;
+		goto tx_error_icmp;
+	}
 
-	memset(&fl4, 0, sizeof(fl4));
-	flowi4_init_output(&fl4, tunnel->parms.link,
-			   be32_to_cpu(tunnel->parms.o_key), RT_TOS(tos),
-			   RT_SCOPE_UNIVERSE,
-			   IPPROTO_IPIP, 0,
-			   dst, tiph->saddr, 0, 0);
-	rt = ip_route_output_key(dev_net(dev), &fl4);
+	dst_hold(skb_dst(skb));
+	rt = (struct rtable *)xfrm_lookup(tunnel->net, skb_dst(skb), &fl, NULL, 0);
 	if (IS_ERR(rt)) {
 		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
+
 	/* if there is no transform then this tunnel is not functional.
 	 * Or if the xfrm is not mode tunnel.
 	 */
@@ -147,9 +162,8 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
-	skb_dst_drop(skb);
+	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
 	skb_dst_set(skb, &rt->dst);
-	nf_reset(skb);
 	skb->dev = skb_dst(skb)->dev;
 
 	err = dst_output(skb);
@@ -166,6 +180,65 @@ tx_error:
 	return NETDEV_TX_OK;
 }
 
+static int vti4_err(struct sk_buff *skb, u32 info)
+{
+	__be32 spi;
+	struct xfrm_state *x;
+	struct ip_tunnel *tunnel;
+	struct ip_esp_hdr *esph;
+	struct ip_auth_hdr *ah ;
+	struct ip_comp_hdr *ipch;
+	struct net *net = dev_net(skb->dev);
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
+	int protocol = iph->protocol;
+	struct ip_tunnel_net *itn = net_generic(net, vti_net_id);
+
+	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
+				  iph->daddr, iph->saddr, 0);
+	if (!tunnel)
+		return -1;
+
+	switch (protocol) {
+	case IPPROTO_ESP:
+		esph = (struct ip_esp_hdr *)(skb->data+(iph->ihl<<2));
+		spi = esph->spi;
+		break;
+	case IPPROTO_AH:
+		ah = (struct ip_auth_hdr *)(skb->data+(iph->ihl<<2));
+		spi = ah->spi;
+		break;
+	case IPPROTO_COMP:
+		ipch = (struct ip_comp_hdr *)(skb->data+(iph->ihl<<2));
+		spi = htonl(ntohs(ipch->cpi));
+		break;
+	default:
+		return 0;
+	}
+
+	switch (icmp_hdr(skb)->type) {
+	case ICMP_DEST_UNREACH:
+		if (icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
+			return 0;
+	case ICMP_REDIRECT:
+		break;
+	default:
+		return 0;
+	}
+
+	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+			      spi, protocol, AF_INET);
+	if (!x)
+		return 0;
+
+	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
+		ipv4_update_pmtu(skb, net, info, 0, 0, protocol, 0);
+	else
+		ipv4_redirect(skb, net, 0, 0, protocol, 0);
+	xfrm_state_put(x);
+
+	return 0;
+}
+
 static int
 vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -181,12 +254,13 @@ vti_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EINVAL;
 	}
 
+	p.i_flags |= VTI_ISVTI;
 	err = ip_tunnel_ioctl(dev, &p, cmd);
 	if (err)
 		return err;
 
 	if (cmd != SIOCDELTUNNEL) {
-		p.i_flags |= GRE_KEY | VTI_ISVTI;
+		p.i_flags |= GRE_KEY;
 		p.o_flags |= GRE_KEY;
 	}
 
@@ -241,9 +315,25 @@ static void __net_init vti_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 }
 
-static struct xfrm_tunnel_notifier vti_handler __read_mostly = {
+static struct xfrm4_protocol vti_esp4_protocol __read_mostly = {
+	.handler	=	vti_rcv,
+	.cb_handler	=	vti_rcv_cb,
+	.err_handler	=	vti4_err,
+	.priority	=	100,
+};
+
+static struct xfrm4_protocol vti_ah4_protocol __read_mostly = {
+	.handler	=	vti_rcv,
+	.cb_handler	=	vti_rcv_cb,
+	.err_handler	=	vti4_err,
+	.priority	=	100,
+};
+
+static struct xfrm4_protocol vti_ipcomp4_protocol __read_mostly = {
 	.handler	=	vti_rcv,
-	.priority	=	1,
+	.cb_handler	=	vti_rcv_cb,
+	.err_handler	=	vti4_err,
+	.priority	=	100,
 };
 
 static int __net_init vti_init_net(struct net *net)
@@ -287,6 +377,8 @@ static void vti_netlink_parms(struct nlattr *data[],
 	if (!data)
 		return;
 
+	parms->i_flags = VTI_ISVTI;
+
 	if (data[IFLA_VTI_LINK])
 		parms->link = nla_get_u32(data[IFLA_VTI_LINK]);
 
@@ -382,10 +474,31 @@ static int __init vti_init(void)
 	err = register_pernet_device(&vti_net_ops);
 	if (err < 0)
 		return err;
-	err = xfrm4_mode_tunnel_input_register(&vti_handler);
+	err = xfrm4_protocol_register(&vti_esp4_protocol, IPPROTO_ESP);
+	if (err < 0) {
+		unregister_pernet_device(&vti_net_ops);
+		pr_info("vti init: can't register tunnel\n");
+
+		return err;
+	}
+
+	err = xfrm4_protocol_register(&vti_ah4_protocol, IPPROTO_AH);
+	if (err < 0) {
+		xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
+		unregister_pernet_device(&vti_net_ops);
+		pr_info("vti init: can't register tunnel\n");
+
+		return err;
+	}
+
+	err = xfrm4_protocol_register(&vti_ipcomp4_protocol, IPPROTO_COMP);
 	if (err < 0) {
+		xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH);
+		xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
 		unregister_pernet_device(&vti_net_ops);
 		pr_info("vti init: can't register tunnel\n");
+
+		return err;
 	}
 
 	err = rtnl_link_register(&vti_link_ops);
@@ -395,7 +508,9 @@ static int __init vti_init(void)
 	return err;
 
 rtnl_link_failed:
-	xfrm4_mode_tunnel_input_deregister(&vti_handler);
+	xfrm4_protocol_deregister(&vti_ipcomp4_protocol, IPPROTO_COMP);
+	xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH);
+	xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP);
 	unregister_pernet_device(&vti_net_ops);
 	return err;
 }
@@ -403,8 +518,13 @@ rtnl_link_failed:
 static void __exit vti_fini(void)
 {
 	rtnl_link_unregister(&vti_link_ops);
-	if (xfrm4_mode_tunnel_input_deregister(&vti_handler))
+	if (xfrm4_protocol_deregister(&vti_ipcomp4_protocol, IPPROTO_COMP))
+		pr_info("vti close: can't deregister tunnel\n");
+	if (xfrm4_protocol_deregister(&vti_ah4_protocol, IPPROTO_AH))
 		pr_info("vti close: can't deregister tunnel\n");
+	if (xfrm4_protocol_deregister(&vti_esp4_protocol, IPPROTO_ESP))
+		pr_info("vti close: can't deregister tunnel\n");
+
 
 	unregister_pernet_device(&vti_net_ops);
 }
-- 
1.7.9.5
