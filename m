From: Ben Cartwright-Cox <Ben@Benjojo.co.uk>
Subject: [PATCH v2 net] raw: increment correct SNMP counters for ICMP
 messages
Date: Sat, 14 Nov 2015 15:13:58 +0000
Message-ID: <20151114151358.GA11387@benjojo.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ben+patches@benjojo.co.uk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from storm.benjojo.co.uk ([209.141.52.31]:44325 "EHLO
	storm.benjojo.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbbKNPOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 10:14:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending ICMP packets with raw sockets ends up in the SNMP counters
logging the type as the first byte of the IPv4 header rather than
the ICMP header. This is fixed by adding the IP Header Length to
the casting into a icmphdr struct.

Signed-off-by: Ben Cartwright-Cox <ben@benjojo.co.uk>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/raw.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 561cd4b..ef3c9ba 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -406,10 +406,12 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 			ip_select_ident(net, skb, NULL);
 
 		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+		skb->transport_header += iphlen;
+		if (iph->protocol == IPPROTO_ICMP &&
+		    length >= iphlen + sizeof(struct icmphdr))
+			icmp_out_count(net, ((struct icmphdr *)
+				skb_transport_header(skb))->type);
 	}
-	if (iph->protocol == IPPROTO_ICMP)
-		icmp_out_count(net, ((struct icmphdr *)
-			skb_transport_header(skb))->type);
 
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
 		      NULL, rt->dst.dev, dst_output_sk);
-- 
1.9.1
