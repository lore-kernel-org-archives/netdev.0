From: Dries De Winter <dries.dewinter@gmail.com>
Subject: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Wed, 28 Nov 2012 10:09:55 +0100 (CET)
Message-ID: <14515182.2480.1354093791878.JavaMail.driesdw@sahwcmp0020>
References: <22884633.2468.1354092935228.JavaMail.driesdw@sahwcmp0020>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46147 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab2K1JJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 04:09:59 -0500
In-Reply-To: <22884633.2468.1354092935228.JavaMail.driesdw@sahwcmp0020>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dries De Winter <dries.dewinter@gmail.com>

The IPv6 mangle table may change the source/destination address and skb->mark
of a packet. Therefore it may be necessary to "reroute" a packet after it
traversed this table. But this should not happen for some special packets like
neighbour solicitations and MLD reports: they have an explicit destination, not
originating from the routing table. Rerouting these packets may cause them to
go out on the wrong interface or not to go out at all depending on the routing
table.

I propose a patch which allows to mark a dst_entry as "non-reroutable".
icmp6_dst_alloc() (used by ndisc and MLD implementation) will always mark the
allocated dst_entry as such. A check is added to netfilter (IPv6-only) so
packets heading for a non-reroutable destination are never rerouted.

Detailed discussion about the patch:
- It is based on 3.6.7.
- Are there other examples of dsts but ICMPv6 that should be non-reroutable?
- Are there other situations but rerouting by netfilter in which this new flag
  should be considered?
- Similar logic exists in IPv4 so local multicast/broadcast messages are
  potentially transmitted on the wrong interface. However, it's a less likely
  corner case there because those packets are treated differently by
  local output routing: multicast/broadcast messages are by default routed to
  the interface with a matching source IP-address. But this logic is invalid
  because (1) it is allowed to send messages with a source IP-address
  different from your own and (2) it is allowed to assign the same IP-address
  on multiple interfaces. So I feel that also in the case of IPv4 it should
  be possible to forbid rerouting for some special packets.

Regards,

Dries De Winter
SoftAtHome

Signed-off-by: Dries De Winter <dries.dewinter@gmail.com>
---
diff --git a/include/net/dst.h b/include/net/dst.h
index 621e351..8b92678 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -61,6 +61,7 @@ struct dst_entry {
 #define DST_NOPEER                0x0040
 #define DST_FAKE_RTABLE                0x0080
 #define DST_XFRM_TUNNEL                0x0100
+#define DST_NOREROUTE                0x0200
 
         unsigned short                pending_confirm;
 
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index db31561..5b98145 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -23,6 +23,10 @@ int ip6_route_me_harder(struct sk_buff *skb)
                 .saddr = iph->saddr,
         };
 
+        dst = skb_dst(skb);
+        if (dst && (dst->flags & DST_NOREROUTE))
+                return 0;
+
         dst = ip6_route_output(net, skb->sk, &fl6);
         if (dst->error) {
                 IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 070a3ce..1c7d377 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1234,7 +1234,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
                 }
         }
 
-        rt->dst.flags |= DST_HOST;
+        rt->dst.flags |= DST_HOST | DST_NOREROUTE;
         rt->dst.output  = ip6_output;
         rt->n = neigh;
         atomic_set(&rt->dst.__refcnt, 1);
