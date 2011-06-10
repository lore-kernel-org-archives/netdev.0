From: Nicolas Cavallari <Nicolas.Cavallari@lri.fr>
Subject: [PATCH] netfilter: fix looped (broad|multi)cast's MAC handling.
Date: Fri, 10 Jun 2011 09:20:40 +0200
Message-ID: <1307690440-18760-1-git-send-email-cavallar@lri.fr>
References: <4DF0EFE6.4010206@trash.net>
Cc: Nicolas Cavallari <cavallar@lri.fr>
To: kaber@trash.net, fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DF0EFE6.4010206@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By default, when broadcast or multicast packet are sent from a local
application, they are sent to the interface then looped by the kernel
to other local applications, going throught netfilter hooks in the process.

These looped packet have their MAC header removed from the skb by the kernel
looping code.
This confuse various netfilter's netlink queue, netlink log and the
legacy ip_queue, because they try to extract a hardware
address from these packets, but extracts a part of the IP header instead.

This patch prevent NFQUEUE, NFLOG and ip_QUEUE to include a MAC header
if there is none in the packet.

Signed-off-by: Nicolas Cavallari <cavallar@lri.fr>
---
 net/ipv4/netfilter/ip_queue.c   |    3 ++-
 net/ipv6/netfilter/ip6_queue.c  |    3 ++-
 net/netfilter/nfnetlink_log.c   |    3 ++-
 net/netfilter/nfnetlink_queue.c |    3 ++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index f7f9bd7..5c9b9d9 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -203,7 +203,8 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 	else
 		pmsg->outdev_name[0] = '\0';
 
-	if (entry->indev && entry->skb->dev) {
+	if (entry->indev && entry->skb->dev &&
+	    entry->skb->mac_header != entry->skb->network_header) {
 		pmsg->hw_type = entry->skb->dev->type;
 		pmsg->hw_addrlen = dev_parse_header(entry->skb,
 						    pmsg->hw_addr);
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 065fe40..2493948 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -204,7 +204,8 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 	else
 		pmsg->outdev_name[0] = '\0';
 
-	if (entry->indev && entry->skb->dev) {
+	if (entry->indev && entry->skb->dev &&
+	    entry->skb->mac_header != entry->skb->network_header) {
 		pmsg->hw_type = entry->skb->dev->type;
 		pmsg->hw_addrlen = dev_parse_header(entry->skb, pmsg->hw_addr);
 	}
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index e0ee010..2e7ccbb 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -456,7 +456,8 @@ __build_packet_message(struct nfulnl_instance *inst,
 	if (skb->mark)
 		NLA_PUT_BE32(inst->skb, NFULA_MARK, htonl(skb->mark));
 
-	if (indev && skb->dev) {
+	if (indev && skb->dev &&
+	    skb->mac_header != skb->network_header) {
 		struct nfulnl_msg_packet_hw phw;
 		int len = dev_parse_header(skb, phw.hw_addr);
 		if (len > 0) {
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index b83123f..fdd2faf 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -335,7 +335,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (entskb->mark)
 		NLA_PUT_BE32(skb, NFQA_MARK, htonl(entskb->mark));
 
-	if (indev && entskb->dev) {
+	if (indev && entskb->dev &&
+	    entskb->mac_header != entskb->network_header) {
 		struct nfqnl_msg_packet_hw phw;
 		int len = dev_parse_header(entskb, phw.hw_addr);
 		if (len) {
-- 
1.7.5.3

