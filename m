From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v7 2/8] vxlan: Restructure vxlan receive.
Date: Mon, 19 Aug 2013 11:22:54 -0700
Message-ID: <1376936574-25517-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:34738 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751099Ab3HSSXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:23:00 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so4878140pab.24
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 11:23:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use iptunnel_pull_header() for better code sharing.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v5-v6:
split from second patch from v5 series.
---
 drivers/net/vxlan.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b784ee6..1afb979 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -57,6 +57,7 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
@@ -868,15 +869,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	__u32 vni;
 	int err;
 
-	/* pop off outer UDP header */
-	__skb_pull(skb, sizeof(struct udphdr));
-
 	/* Need Vxlan and inner Ethernet header to be present */
-	if (!pskb_may_pull(skb, sizeof(struct vxlanhdr)))
+	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
 
-	/* Drop packets with reserved bits set */
-	vxh = (struct vxlanhdr *) skb->data;
+	/* Return packets with reserved bits set */
+	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
 	    (vxh->vx_vni & htonl(0xff))) {
 		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
@@ -884,8 +882,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto error;
 	}
 
-	__skb_pull(skb, sizeof(struct vxlanhdr));
-
 	/* Is this VNI defined? */
 	vni = ntohl(vxh->vx_vni) >> 8;
 	port = inet_sk(sk)->inet_sport;
@@ -896,7 +892,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
-	if (!pskb_may_pull(skb, ETH_HLEN)) {
+	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB))) {
 		vxlan->dev->stats.rx_length_errors++;
 		vxlan->dev->stats.rx_errors++;
 		goto drop;
@@ -904,8 +900,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	skb_reset_mac_header(skb);
 
-	/* Re-examine inner Ethernet packet */
-	oip = ip_hdr(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -913,11 +907,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			       vxlan->dev->dev_addr) == 0)
 		goto drop;
 
+	/* Re-examine inner Ethernet packet */
+	oip = ip_hdr(skb);
 	if ((vxlan->flags & VXLAN_F_LEARN) &&
 	    vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source))
 		goto drop;
 
-	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
 
 	/* If the NIC driver gave us an encapsulated packet with
@@ -953,9 +948,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	return 0;
 error:
-	/* Put UDP header back */
-	__skb_push(skb, sizeof(struct udphdr));
-
 	return 1;
 drop:
 	/* Consume bad packet */
-- 
1.7.1
