From: Ansis Atteka <aatteka@ovn.org>
Subject: [PATCH net] udp: disable inner UDP checksum offloads in IPsec case
Date: Fri, 21 Apr 2017 15:23:05 -0700
Message-ID: <1492813385-31736-1-git-send-email-aatteka@ovn.org>
Cc: Ansis Atteka <aatteka@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:53837 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426087AbdDUWZT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 18:25:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, UDP checksum offloads could corrupt ESP packets by attempting
to calculate UDP checksum when this inner UDP packet is already protected
by IPsec.

One way to reproduce this bug is to have a VM with virtio_net driver (UFO
set to ON in the guest VM); and then encapsulate all guest's Ethernet
frames in Geneve; and then further encrypt Geneve with IPsec.  In this
case following symptoms are observed:
1. If using ixgbe NIC, then it will complain with following error message:
   ixgbe 0000:01:00.1: partial checksum but l4 proto=32!
2. Receiving IPsec stack will drop all the corrupted ESP packets and
   increase XfrmInStateProtoError counter in /proc/net/xfrm_stat.
3. iperf UDP test from the VM with packet sizes above MTU will not work at
   all.
4. iperf TCP test from the VM will get ridiculously low performance because.

Signed-off-by: Ansis Atteka <aatteka@ovn.org>
Co-authored-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/udp_offload.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index b2be1d9..7812501 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -29,6 +29,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	u16 mac_len = skb->mac_len;
 	int udp_offset, outer_hlen;
 	__wsum partial;
+	bool need_ipsec;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
@@ -62,8 +63,10 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 
 	ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
 
+	need_ipsec = skb_dst(skb) && dst_xfrm(skb_dst(skb));
 	/* Try to offload checksum if possible */
 	offload_csum = !!(need_csum &&
+			  !need_ipsec &&
 			  (skb->dev->features &
 			   (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
 				      (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM))));
-- 
1.9.1
