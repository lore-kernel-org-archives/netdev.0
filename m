From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v6 2/8] vxlan: Restructure vxlan receive.
Date: Thu,  1 Aug 2013 11:44:45 -0700
Message-ID: <1375382685-3177-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:45549 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755176Ab3HASos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 14:44:48 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so2341435pdi.13
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 11:44:47 -0700 (PDT)
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
index 548294a..0ba2f24 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -57,6 +57,7 @@
 #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
+#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
 #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
 
@@ -844,15 +845,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -860,8 +858,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto error;
 	}
 
-	__skb_pull(skb, sizeof(struct vxlanhdr));
-
 	/* Is this VNI defined? */
 	vni = ntohl(vxh->vx_vni) >> 8;
 	port = inet_sk(sk)->inet_sport;
@@ -872,7 +868,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
-	if (!pskb_may_pull(skb, ETH_HLEN)) {
+	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB))) {
 		vxlan->dev->stats.rx_length_errors++;
 		vxlan->dev->stats.rx_errors++;
 		goto drop;
@@ -880,8 +876,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	skb_reset_mac_header(skb);
 
-	/* Re-examine inner Ethernet packet */
-	oip = ip_hdr(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
@@ -889,11 +883,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -929,9 +924,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
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
