From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][PATCH] IP: Send a fragment reassembly time exceeded packet
 when enabling connection track
Date: Wed, 23 Dec 2009 11:43:35 +0800
Message-ID: <4B3191E7.8060509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Default, a host may send a fragment reassembly time exceeded packet
(ICMP Time Exceeded Message with code value of 1) when defraging fragments timeout.
But, when enabling connection track, a host can't send the packet.

Because, the module of nf_defrag_ipv4 selected by connection track is registered 
in PRE_ROUTING HOOK and assembles all accepted fragments(here, not begin to routing).
After defrag timeout, the host can't send fragment reassembly time exceeded packet, 
because of lack of router information.

RFC 792 says:
>> > >   If a host reassembling a fragmented datagram cannot complete the
>> > >   reassembly due to missing fragments within its time limit it
>> > >   discards the datagram, and it may send a time exceeded message.
>> > > 
>> > >   If fragment zero is not available then no time exceeded need be
>> > >   sent at all.
>> > > 
>> > > 
>> > > Read more: http://www.faqs.org/rfcs/rfc792.html#ixzz0aOXRD7Wp

So, the patch try to fix it with filling router information before sending fragment reassembly
time exceeded packet when defrag timeout.

Note:
Doing local deliver, also assemble fragments. But it already routing at ip_rcv_finish(). 
So skb_dst(head) is not NULL.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv4/ip_fragment.c |   22 +++++++++++++++++++---
 1 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 86964b3..1417cb8 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -38,6 +38,7 @@
 #include <net/checksum.h>
 #include <net/inetpeer.h>
 #include <net/inet_frag.h>
+#include <net/route.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/inet.h>
@@ -204,12 +205,27 @@ static void ip_expire(unsigned long arg)
 
 	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
 		struct sk_buff *head = qp->q.fragments;
+		const struct iphdr *iph = ip_hdr(head);
 
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		rcu_read_lock();
-		head->dev = dev_get_by_index_rcu(net, qp->iif);
-		if (head->dev)
-			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
+		if ((head->dev = dev_get_by_index_rcu(net, qp->iif)) == NULL) 
+			goto unlock_out;
+
+		if (skb_dst(head) == NULL) {
+			int err = ip_route_input(head, iph->daddr, iph->saddr, 
+						 iph->tos, head->dev);
+			if (unlikely(err)) {
+				if (err == -EHOSTUNREACH)
+					IP_INC_STATS_BH(net, IPSTATS_MIB_INADDRERRORS);
+				else if (err == -ENETUNREACH)
+					IP_INC_STATS_BH(net, IPSTATS_MIB_INNOROUTES);
+				goto unlock_out;
+			}
+ 		}
+		
+		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
+unlock_out:
 		rcu_read_unlock();
 	}
 out:
-- 1.6.3.3 
