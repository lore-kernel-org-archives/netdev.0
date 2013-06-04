From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] netpoll: fix position of network header
Date: Tue,  4 Jun 2013 10:31:36 +0800
Message-ID: <1370313096-4527-1-git-send-email-amwang@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkmann@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755301Ab3FDCcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 22:32:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to the problem in pktgen, netpoll uses skb_tail_offset()
too, as the code is copied from pktgen.

Also use return values of skb_put() directly, this will simiplify
the code.

Reported-by: Thomas Graf <tgraf@suug.ch>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Daniel Borkmann <dborkmann@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 688517c..03c8ec3 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -676,8 +676,6 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
-			unsigned long tail_offset;
-
 			if (!ipv6_addr_equal(daddr, &np->local_ip.in6))
 				continue;
 
@@ -691,30 +689,20 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 			send_skb->dev = skb->dev;
 
 			skb_reset_network_header(send_skb);
-			skb_put(send_skb, sizeof(struct ipv6hdr));
-			hdr = ipv6_hdr(send_skb);
-
+			hdr = (struct ipv6hdr *) skb_put(send_skb, sizeof(struct ipv6hdr));
 			*(__be32*)hdr = htonl(0x60000000);
-
 			hdr->payload_len = htons(size);
 			hdr->nexthdr = IPPROTO_ICMPV6;
 			hdr->hop_limit = 255;
 			hdr->saddr = *saddr;
 			hdr->daddr = *daddr;
 
-			tail_offset = skb_tail_offset(skb);
-			if (tail_offset > 0xffff) {
-				kfree_skb(send_skb);
-				continue;
-			}
-			skb_set_network_header(send_skb, tail_offset);
-			skb_put(send_skb, size);
-
-			icmp6h = (struct icmp6hdr *)skb_transport_header(skb);
+			icmp6h = (struct icmp6hdr *) skb_put(send_skb, sizeof(struct icmp6hdr));
 			icmp6h->icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
 			icmp6h->icmp6_router = 0;
 			icmp6h->icmp6_solicited = 1;
-			target = (struct in6_addr *)(skb_transport_header(send_skb) + sizeof(struct icmp6hdr));
+
+			target = (struct in6_addr *) skb_put(send_skb, sizeof(struct in6_addr));
 			*target = msg->target;
 			icmp6h->icmp6_cksum = csum_ipv6_magic(saddr, daddr, size,
 							      IPPROTO_ICMPV6,
