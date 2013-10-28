From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH stable 3.10] ip_gre: Fix WCCPv2 header parsing.
Date: Mon, 28 Oct 2013 10:38:55 -0700
Message-ID: <1382981935-7282-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, peter.schmitt82@yahoo.de,
	eric.dumazet@gmail.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:40229 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932155Ab3J1RjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 13:39:01 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so2077231pbb.17
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 10:39:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of WCCPv2 GRE header has extra four bytes.  Following
patch pull those extra four bytes so that skb offsets are set
correctly.

CC: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Peter Schmitt <peter.schmitt82@yahoo.de>
Tested-by: Peter Schmitt <peter.schmitt82@yahoo.de>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h |    2 +-
 net/ipv4/ip_gre.c        |    2 +-
 net/ipv4/ip_tunnel.c     |    4 ++--
 net/ipv4/ipip.c          |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 09b1360..79cf958 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -113,7 +113,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 				   __be32 key);
 
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
-		  const struct tnl_ptk_info *tpi, bool log_ecn_error);
+		  const struct tnl_ptk_info *tpi, int hdr_len, bool log_ecn_error);
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 			 struct ip_tunnel_parm *p);
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 855004f..3ddc8df 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -335,7 +335,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 				  iph->saddr, iph->daddr, tpi.key);
 
 	if (tunnel) {
-		ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
+		ip_tunnel_rcv(tunnel, skb, &tpi, hdr_len, log_ecn_error);
 		return 0;
 	}
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index cbfc37f..49fb608 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -402,7 +402,7 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 }
 
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
-		  const struct tnl_ptk_info *tpi, bool log_ecn_error)
+		  const struct tnl_ptk_info *tpi, int hdr_len, bool log_ecn_error)
 {
 	struct pcpu_tstats *tstats;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -413,7 +413,7 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	skb->protocol = tpi->proto;
 
 	skb->mac_header = skb->network_header;
-	__pskb_pull(skb, tunnel->hlen);
+	__pskb_pull(skb, hdr_len);
 	skb_postpull_rcsum(skb, skb_transport_header(skb), tunnel->hlen);
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 	if (ipv4_is_multicast(iph->daddr)) {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 7cfc456..f5cc7b3 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -195,7 +195,7 @@ static int ipip_rcv(struct sk_buff *skb)
 	if (tunnel) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
-		return ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
+		return ip_tunnel_rcv(tunnel, skb, &tpi, 0, log_ecn_error);
 	}
 
 	return -1;
-- 
1.7.1
