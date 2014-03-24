From: Pravin <pshelar@nicira.com>
Subject: [PATCH net] ip_tunnel: Fix dst ref-count.
Date: Sun, 23 Mar 2014 22:06:36 -0700
Message-ID: <1395637596-28064-1-git-send-email-pshelar@nicira.com>
Cc: Pravin <pshelar@nicira.com>, Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:48205 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751000AbaCXFGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 01:06:40 -0400
Received: by mail-pd0-f179.google.com with SMTP id w10so4850878pde.10
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 22:06:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 10ddceb22ba (ip_tunnel:multicast process cause panic due
to skb->_skb_refdst NULL pointer) removed dst-drop call from
ip-tunnel-recv.

Following commit reintroduce dst-drop and fix the original bug by
checking loopback packet before releasing dst.
Original bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681

CC: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/gre_demux.c      |    8 ++++++++
 net/ipv4/ip_tunnel.c      |    3 ---
 net/ipv4/ip_tunnel_core.c |    1 +
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 1863422f..250be74 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -182,6 +182,14 @@ static int gre_cisco_rcv(struct sk_buff *skb)
 	int i;
 	bool csum_err = false;
 
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	if (ipv4_is_multicast(ip_hdr(skb)->daddr)) {
+		/* Looped back packet, drop it! */
+		if (rt_is_output_route(skb_rtable(skb)))
+			goto drop;
+	}
+#endif
+
 	if (parse_gre_header(skb, &tpi, &csum_err) < 0)
 		goto drop;
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 78a89e6..a82a22d 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -416,9 +416,6 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 	if (ipv4_is_multicast(iph->daddr)) {
-		/* Looped back packet, drop it! */
-		if (rt_is_output_route(skb_rtable(skb)))
-			goto drop;
 		tunnel->dev->stats.multicast++;
 		skb->pkt_type = PACKET_BROADCAST;
 	}
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6f847dd..8d69626 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -108,6 +108,7 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 	nf_reset(skb);
 	secpath_reset(skb);
 	skb_clear_hash_if_not_l4(skb);
+	skb_dst_drop(skb);
 	skb->vlan_tci = 0;
 	skb_set_queue_mapping(skb, 0);
 	skb->pkt_type = PACKET_HOST;
-- 
1.7.9.5
