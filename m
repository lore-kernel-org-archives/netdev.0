From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH v2] ipv6: Use inbound ifaddr as source addresses for ICMPv6 errors
Date: Sun, 28 Aug 2016 11:34:06 +0800
Message-ID: <20160828033406.11269-1-elicooper@gmx.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:54194 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754831AbcH1Der (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 27 Aug 2016 23:34:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to RFC 1885 2.2(c), the source address of ICMPv6
errors in response to forwarded packets should be set to the
unicast address of the forwarding interface in order to be helpful
in diagnosis. Currently the selection of source address is based
on the default route, without respect to the inbound interface.

This patch sets the source address of ICMPv6 error messages to
the address of inbound interface, with the exception of
'time exceeded' and 'packet to big' messages sent in ip6_forward(),
where the address of OUTPUT device is forced as source address
(however, it is NOT enforced as claimed without this patch).

Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
v2: changed to a switch statement

 net/ipv6/icmp.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index bd59c34..edb50b6 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -397,6 +397,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	struct sock *sk;
 	struct ipv6_pinfo *np;
 	const struct in6_addr *saddr = NULL;
+	struct in6_addr tmp_saddr;
 	struct dst_entry *dst;
 	struct icmp6hdr tmp_hdr;
 	struct flowi6 fl6;
@@ -421,6 +422,17 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	 */
 	addr_type = ipv6_addr_type(&hdr->daddr);
 
+	switch (type) {
+	case ICMPV6_DEST_UNREACH:
+	case ICMPV6_PKT_TOOBIG:
+	case ICMPV6_TIME_EXCEED:
+	case ICMPV6_PARAMPROB:
+		if (!ipv6_dev_get_saddr(net, skb->dev, &hdr->saddr, 0,
+					&tmp_saddr))
+			saddr = &tmp_saddr;
+		break;
+	}
+
 	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0) ||
 	    ipv6_chk_acast_addr_src(net, skb->dev, &hdr->daddr))
 		saddr = &hdr->daddr;
-- 
2.9.3
