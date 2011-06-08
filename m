From: Nicolas Cavallari <Nicolas.Cavallari@lri.fr>
Subject: [PATCH] netfilter: fix looped (broad|multi)cast's bogus MACs in NFQUEUE
Date: Wed,  8 Jun 2011 17:18:17 +0200 (CEST)
Message-ID: <20110608151817.C95E24587D@pc11-132.lri.fr>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By default, when broadcast or multicast packet are sent from a local
application, they are sent to the interface then looped by the kernel
to other local applications, going throught netfilter hooks in the process.

These looped packet have their MAC header removed from the skb by the kernel
looping code.
This confuse netfilter's netlink queue because it tries to extract a hardware
address from these packets, but extracts a part of the IP header instead.

This patch prevent NFQUEUE to include a MAC header in the netlink message
if there is none.

Signed-off-by: Nicolas Cavallari <cavallar@lri.fr>
---
To reproduce the bug, run libnetfilter_queue's nfqnl_test.c and add
some iptables -j NFQUEUE rule in PREROUTING.
Then, either ping -b 255.255.255.255 or ping nonexistenthost.local (if
avahi or another multicast dns client is configured)

If you see MAC addresses like 40:00:ff:11:0d::70 (for mdns) or
 00:00:80:11:70:62 then you can see that they match this part of the packet's
ip header :

               |flags| fragment offset|
 |ttl| protocol|       checksum       |

patch done against 2.6.39.1 but should also apply to nf-next
---
--- linux-2.6.39.1/net/netfilter/nfnetlink_queue.c	2011-06-08 14:43:41.188003302 +0200
+++ linux-2.6.39.1/net/netfilter/nfnetlink_queue.c	2011-06-08 14:46:10.892003541 +0200
@@ -335,7 +335,8 @@ nfqnl_build_packet_message(struct nfqnl_
 	if (entskb->mark)
 		NLA_PUT_BE32(skb, NFQA_MARK, htonl(entskb->mark));
 
-	if (indev && entskb->dev) {
+	if (indev && entskb->dev &&
+	    entskb->network_header != entskb->mac_header) {
 		struct nfqnl_msg_packet_hw phw;
 		int len = dev_parse_header(entskb, phw.hw_addr);
 		if (len) {
