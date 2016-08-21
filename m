From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] net: ip_finish_output_gso: Allow fragmenting segments of tunneled skbs if their DF is unset
Date: Sun, 21 Aug 2016 11:22:32 +0300
Message-ID: <1471767752-7849-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: pravin shelar <pshelar@ovn.org>, wenxu <wenxu@ucloud.cn>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36434 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbcHUIXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2016 04:23:04 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so8991082wmf.3
        for <netdev@vger.kernel.org>; Sun, 21 Aug 2016 01:23:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In b8247f095e,

   "net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs"

gso skbs arriving from an ingress interface that go through UDP
tunneling, are allowed to be fragmented if the resulting encapulated
segments exceed the dst mtu of the egress interface.

This aligned the behavior of gso skbs to non-gso skbs going through udp
encapsulation path.

However the non-gso vs gso anomaly is present also in the following
cases of a GRE tunnel:
 - ip_gre in collect_md mode, where TUNNEL_DONT_FRAGMENT is not set
   (e.g. OvS vport-gre with df_default=false)
 - ip_gre in nopmtudisc mode, where IFLA_GRE_IGNORE_DF is set

In both of the above cases, the non-gso skbs get fragmented, whereas the
gso skbs (having skb_gso_network_seglen that exceeds dst mtu) get dropped,
as they don't go through the segment+fragment code path.

Fix: Setting IPSKB_FRAG_SEGS if the tunnel specified IP_DF bit is NOT set.

Tunnels that do set IP_DF, will not go to fragmentation of segments.
This preserves behavior of ip_gre in (the default) pmtudisc mode.

Fixes: b8247f095e ("net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs")
Reported-by: wenxu <wenxu@ucloud.cn>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 
 wenxu, can you please add a Tested-by?

 net/ipv4/ip_tunnel_core.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 9d847c3025..0f227db0e9 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -73,9 +73,11 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
-	if (skb_iif && proto == IPPROTO_UDP) {
-		/* Arrived from an ingress interface and got udp encapuslated.
-		 * The encapsulated network segment length may exceed dst mtu.
+	if (skb_iif && !(df & htons(IP_DF))) {
+		/* Arrived from an ingress interface, got encapsulated, with
+		 * fragmentation of encapulating frames allowed.
+		 * If skb is gso, the resulting encapsulated network segments
+		 * may exceed dst mtu.
 		 * Allow IP Fragmentation of segments.
 		 */
 		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
-- 
2.7.4
