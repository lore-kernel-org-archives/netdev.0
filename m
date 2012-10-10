From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 7/8] vxlan: fix receive checksum handling
Date: Tue, 09 Oct 2012 23:35:52 -0700
Message-ID: <20121010063623.855895281@vyatta.com>
References: <20121010063545.453368147@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52294 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334Ab2JJGjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:39:24 -0400
Content-Disposition: inline; filename=vxlan-checksum.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vxlan was trying to use postpull_rcsum to allow receive checksum
offload to work on drivers using CHECKSUM_COMPLETE method. But this
doesn't work correctly. Just force full receive checksum on received
packet.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vxlan.c	2012-10-09 18:08:36.862414133 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 18:08:38.686396042 -0700
@@ -537,7 +537,6 @@ static int vxlan_udp_encap_recv(struct s
 	}
 
 	__skb_pull(skb, sizeof(struct vxlanhdr));
-	skb_postpull_rcsum(skb, eth_hdr(skb), sizeof(struct vxlanhdr));
 
 	/* Is this VNI defined? */
 	vni = ntohl(vxh->vx_vni) >> 8;
@@ -556,7 +555,6 @@ static int vxlan_udp_encap_recv(struct s
 	/* Re-examine inner Ethernet packet */
 	oip = ip_hdr(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
-	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
 	/* Ignore packet loops (and multicast echo) */
 	if (compare_ether_addr(eth_hdr(skb)->h_source,
@@ -568,6 +566,7 @@ static int vxlan_udp_encap_recv(struct s
 
 	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
+	skb->ip_summed = CHECKSUM_NONE;
 
 	err = IP_ECN_decapsulate(oip, skb);
 	if (unlikely(err)) {
