From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] gre: Fix GREv4 TCPv6 segmentation.
Date: Thu,  2 May 2013 19:14:19 -0700
Message-ID: <1367547259-17919-1-git-send-email-pshelar@nicira.com>
Cc: sesse@google.com, Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:45093 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752505Ab3ECCOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 22:14:24 -0400
Received: by mail-da0-f72.google.com with SMTP id a4so1120748dad.7
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 19:14:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ipv6 traffic, GRE can generate packet with strange GSO
bits, e.g. ipv4 packet with SKB_GSO_TCPV6 flag set.  Therefore
following patch relaxes check in inet gso handler to allow
such packet for segmentation.
This patch also fixes wrong skb->protocol set that was done in
gre_gso_segment() handler.

Reported-by: Steinar H. Gunderson <sesse@google.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Same issue exist in 3.8.
---
 net/ipv4/af_inet.c |    1 +
 net/ipv4/gre.c     |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c61b3bb..d01be2a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1293,6 +1293,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
+		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
 		       0)))
 		goto out;
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index d2d5a99..cc22363 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -121,6 +121,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	int ghl = GRE_HEADER_SECTION;
 	struct gre_base_hdr *greh;
 	int mac_len = skb->mac_len;
+	__be16 protocol = skb->protocol;
 	int tnl_hlen;
 	bool csum;
 
@@ -150,7 +151,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 
 	/* setup inner skb. */
 	if (greh->protocol == htons(ETH_P_TEB)) {
-		struct ethhdr *eth = eth_hdr(skb);
+		struct ethhdr *eth = (struct ethhdr *)skb_inner_mac_header(skb);
 		skb->protocol = eth->h_proto;
 	} else {
 		skb->protocol = greh->protocol;
@@ -199,6 +200,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		skb_reset_mac_header(skb);
 		skb_set_network_header(skb, mac_len);
 		skb->mac_len = mac_len;
+		skb->protocol = protocol;
 	} while ((skb = skb->next));
 out:
 	return segs;
-- 
1.7.1
