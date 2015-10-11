From: Ben Cartwright-Cox <ben@benjojo.co.uk>
Subject: [PATCH] icmp: Fixed bug in raw sockets causing incorrect ICMP SNMP
 counter values
Date: Sun, 11 Oct 2015 20:55:28 +0000
Message-ID: <20151011205528.GA4322@benjojo.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben+patches@benjojo.co.uk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from storm.benjojo.co.uk ([209.141.52.31]:45406 "EHLO
	storm.benjojo.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbbJKVbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 17:31:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending ICMP packets with raw sockets ends up in the SNMP counters
logging the type as the first byte of the IPv4 header rather than
the ICMP header (in nearly all cases this is seen as "OutType69".
This is fixed by adding the IP Header Length to the casting into
a icmphdr struct.

Signed-off-by: Ben Cartwright-Cox <ben@benjojo.co.uk>
---
 net/ipv4/raw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 561cd4b..1ad8bae 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -409,7 +409,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	}
 	if (iph->protocol == IPPROTO_ICMP)
 		icmp_out_count(net, ((struct icmphdr *)
-			skb_transport_header(skb))->type);
+			skb_transport_header(skb) + iphlen)->type);
 
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
 		      NULL, rt->dst.dev, dst_output_sk);
-- 
1.9.1
