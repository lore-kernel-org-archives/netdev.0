From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 2/5] openvswitch: Fix checksum calculation when modifying ICMPv6 packets.
Date: Fri, 14 Nov 2014 17:37:34 -0800
Message-ID: <1416015454-1577-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:49232 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755233AbaKOBhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 20:37:39 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so17753921pdi.30
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:37:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

The checksum of ICMPv6 packets uses the IP pseudoheader as part of
the calculation, unlike ICMP in IPv4. This was not implemented,
which means that modifying the IP addresses of an ICMPv6 packet
would cause the checksum to no longer be correct as the psuedoheader
did not match.
Introduced by commit 3fdbd1ce11e5 ("openvswitch: add ipv6 'set' action").

Reported-by: Neal Shrader <icosahedral@gmail.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 00e447a..8c4229b 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -246,11 +246,11 @@ static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
 {
 	int transport_len = skb->len - skb_transport_offset(skb);
 
-	if (l4_proto == IPPROTO_TCP) {
+	if (l4_proto == NEXTHDR_TCP) {
 		if (likely(transport_len >= sizeof(struct tcphdr)))
 			inet_proto_csum_replace16(&tcp_hdr(skb)->check, skb,
 						  addr, new_addr, 1);
-	} else if (l4_proto == IPPROTO_UDP) {
+	} else if (l4_proto == NEXTHDR_UDP) {
 		if (likely(transport_len >= sizeof(struct udphdr))) {
 			struct udphdr *uh = udp_hdr(skb);
 
@@ -261,6 +261,10 @@ static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
 					uh->check = CSUM_MANGLED_0;
 			}
 		}
+	} else if (l4_proto == NEXTHDR_ICMP) {
+		if (likely(transport_len >= sizeof(struct icmp6hdr)))
+			inet_proto_csum_replace16(&icmp6_hdr(skb)->icmp6_cksum,
+						  skb, addr, new_addr, 1);
 	}
 }
 
-- 
1.9.3
