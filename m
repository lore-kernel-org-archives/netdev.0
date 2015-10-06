From: Maxime Bizon <mbizon@freebox.fr>
Subject: [PATCH] netfilter: fix bad checksum on IPv6 when NAT is performed
Date: Tue, 06 Oct 2015 16:10:52 +0200
Message-ID: <1444140652.14655.340.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, kaber <kaber@trash.net>,
	pablo@netfilter.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:46451 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752578AbbJFOKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 10:10:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With this setup:

* non IPv6 checksumming capable network hardware
* GRO off
* IPv6 SNAT

I get this when I receive an UDPv6 reply: "<unknown>: hw csum failure"

Call trace:

* nf_ip6_checksum() calls __skb_checksum_complete()
* nf_nat_ipv6_csum_update() & nf_nat_ipv6_manip_pkt()
* __udp6_lib_rcv() => udp6_csum_init()
* __skb_checksum_validate_complete() "fastpath" fails because
  skb->csum is incorrect.
* udpv6_recvmsg() => skb_copy_and_csum_datagram_msg()

The last call computes a valid checksum despite CHECKSUM_COMPLETE and
triggers the warning.

When we perform NAT on IPv4, we also update the IPv4 checksum, so
there is no side effect on skb->csum (since the csum over a valid IPv4
header area is zero).

But IPv6 doesn't have such header checksum, so when performing NAT we need to
update skb->csum.

Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
---
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 70fbaed..e9917d74 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -81,6 +81,8 @@ static bool nf_nat_ipv6_manip_pkt(struct sk_buff *skb,
 				  enum nf_nat_manip_type maniptype)
 {
 	struct ipv6hdr *ipv6h;
+	const __be32 *to;
+	__be32 *from;
 	__be16 frag_off;
 	int hdroff;
 	u8 nexthdr;
@@ -100,11 +102,24 @@ static bool nf_nat_ipv6_manip_pkt(struct sk_buff *skb,
 				target, maniptype))
 		return false;
 manip_addr:
-	if (maniptype == NF_NAT_MANIP_SRC)
-		ipv6h->saddr = target->src.u3.in6;
-	else
-		ipv6h->daddr = target->dst.u3.in6;
+	if (maniptype == NF_NAT_MANIP_SRC) {
+		from = ipv6h->saddr.s6_addr32;
+		to = target->src.u3.in6.s6_addr32;
+	} else {
+		from = ipv6h->daddr.s6_addr32;
+		to = target->src.u3.in6.s6_addr32;
+	}
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		__be32 diff[] = {
+			~from[0], ~from[1], ~from[2], ~from[3],
+			to[0], to[1], to[2], to[3],
+		};
+
+		skb->csum = ~csum_partial(diff, sizeof(diff), ~skb->csum);
+	}
 
+	memcpy(from, to, sizeof (struct in6_addr));
 	return true;
 }
 
-- 
1.9.1



-- 
Maxime
