From: kaber@trash.net
Subject: [PATCH 2/8] netfilter: ip_queue: Fix small leak in ipq_build_packet_message()
Date: Tue, 30 Aug 2011 16:41:15 +0200
Message-ID: <1314715281-26233-3-git-send-email-kaber@trash.net>
References: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56977 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533Ab1H3Ol1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:41:27 -0400
In-Reply-To: <1314715281-26233-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>

ipq_build_packet_message() in net/ipv4/netfilter/ip_queue.c and
net/ipv6/netfilter/ip6_queue.c contain a small potential mem leak as
far as I can tell.

We allocate memory for 'skb' with alloc_skb() annd then call
 nlh = NLMSG_PUT(skb, 0, 0, IPQM_PACKET, size - sizeof(*nlh));

NLMSG_PUT is a macro
 NLMSG_PUT(skb, pid, seq, type, len) \
  		NLMSG_NEW(skb, pid, seq, type, len, 0)

that expands to NLMSG_NEW, which is also a macro which expands to:
 NLMSG_NEW(skb, pid, seq, type, len, flags) \
  	({	if (unlikely(skb_tailroom(skb) < (int)NLMSG_SPACE(len))) \
  			goto nlmsg_failure; \
  		__nlmsg_put(skb, pid, seq, type, len, flags); })

If we take the true branch of the 'if' statement and 'goto
nlmsg_failure', then we'll, at that point, return from
ipq_build_packet_message() without having assigned 'skb' to anything
and we'll leak the memory we allocated for it when it goes out of
scope.

Fix this by placing a 'kfree(skb)' at 'nlmsg_failure'.

I admit that I do not know how likely this to actually happen or even
if there's something that guarantees that it will never happen - I'm
not that familiar with this code, but if that is so, I've not been
able to spot it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_queue.c  |    1 +
 net/ipv6/netfilter/ip6_queue.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 5c9b9d9..48f7d5b 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -218,6 +218,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 	return skb;
 
 nlmsg_failure:
+	kfree_skb(skb);
 	*errp = -EINVAL;
 	printk(KERN_ERR "ip_queue: error creating packet message\n");
 	return NULL;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 2493948..87b243a 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -218,6 +218,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 	return skb;
 
 nlmsg_failure:
+	kfree_skb(skb);
 	*errp = -EINVAL;
 	printk(KERN_ERR "ip6_queue: error creating packet message\n");
 	return NULL;
-- 
1.7.2.3
