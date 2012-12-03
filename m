From: Dries De Winter <dries.dewinter@gmail.com>
Subject: [PATCH] net: ICMPv6 packets transmitted on wrong interface if nfmark is mangled
Date: Mon,  3 Dec 2012 13:46:03 +0100
Message-ID: <1354538763-2678-1-git-send-email-dries.dewinter@gmail.com>
References: <20121130.122243.710720011890818822.davem@davemloft.net>
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dries De Winter <dries.dewinter@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121130.122243.710720011890818822.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IPv6 mangle table may change the source/destination address and skb->mark
of a packet. Therefore it may be necessary to "reroute" a packet after it
traversed this table. But this should not happen for some special packets like
neighbour solicitations and MLD reports: they have an explicit destination, not
originating from the routing table. Rerouting these packets may cause them to
go out on the wrong interface or not to go out at all depending on the routing
table.

This patch allows to mark a dst_entry as "non-reroutable". icmp6_dst_alloc()
(used by ndisc and MLD implementation) will always mark the allocated dst_entry
as such. A check is added to netfilter (IPv6-only) so packets heading for a
non-reroutable destination are never rerouted.

Remarks:

(1) dst entries allocated by addrconf_dst_alloc() are added to the routing
table like normal routes and skbuffs get assigned such dst entries by normal
rule lookup / route lookup. Therefore it's not needed to mark those dst
entries as non-reroutable: if an skbuff got assigned such a dst entry by
normal routing in the first place, and the changes done by the mangle table
don't affect routing, rerouting the packet will get it there too.

(2) Similar logic exists in IPv4 so local multicast/broadcast messages are
potentially transmitted on the wrong interface. However, it's a less likely
corner case there because those packets are treated differently by local
output routing: multicast/broadcast messages are by default routed to the
interface with a matching source IP-address. But this logic is invalid because
it is allowed to (1) send messages with a source IP-address different from
your own and (2) to assign the same IP-address on multiple interfaces.
So ideally in IPv4 some dsts should be marked as non-reroutable as well.

Signed-off-by: Dries De Winter <dries.dewinter@gmail.com>
---
 include/net/dst.h    |    1 +
 net/ipv6/netfilter.c |    4 ++++
 net/ipv6/route.c     |    2 +-
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 9a78810..cb6ae51 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -61,6 +61,7 @@ struct dst_entry {
 #define DST_NOPEER		0x0040
 #define DST_FAKE_RTABLE		0x0080
 #define DST_XFRM_TUNNEL		0x0100
+#define DST_NOREROUTE		0x0200
 
 	unsigned short		pending_confirm;
 
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 429089c..cf9e871 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -24,6 +24,10 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		.saddr = iph->saddr,
 	};
 
+	dst = skb_dst(skb);
+	if (dst && (dst->flags & DST_NOREROUTE))
+		return 0;
+
 	dst = ip6_route_output(net, skb->sk, &fl6);
 	if (dst->error) {
 		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b1e6cf0..8fa7db5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1225,7 +1225,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 		}
 	}
 
-	rt->dst.flags |= DST_HOST;
+	rt->dst.flags |= DST_HOST | DST_NOREROUTE;
 	rt->dst.output  = ip6_output;
 	rt->n = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
-- 
1.7.10.4

