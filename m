From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: preserve geometry of fragment sizes when forwarding
Date: Thu,  7 May 2015 23:04:24 +0200
Message-ID: <1431032664-6478-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org, Florian Westphal <fw@strlen.de>,
	Eric Dumazet <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56522 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751545AbbEGVEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 17:04:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was interest in keeping geometry of original fragments on forward.

This (re)enables this feature.

on router with mtu 1500 on all interfaces and netfilter conntrack enabled:

incoming packet on router:
IP (ttl 64, offset 0, flags [+], ICMP, length 1276) 192.168.7.1 > 10.0.0.2: ICMP echo request, length 1256
IP (ttl 64, offset 1256, flags [+], ICMP, length 1276) 192.168.7.1 > 10.0.0.2: ip-proto-1
IP (ttl 64, offset 2512, flags [none], ICMP, length 516) 192.168.7.1 > 10.0.0.2: ip-proto-1

Without patch, refragmentation uses device mtu. incoming packet on destination host:
IP (ttl 63, offset 0, flags [+], ICMP, length 1500) 192.168.7.1 > 10.0.0.2: ICMP echo request, length 1480
IP (ttl 63, offset 1480, flags [+], ICMP, length 1500) 192.168.7.1 > 10.0.0.2: ip-proto-1
IP (ttl 63, offset 2960, flags [none], ICMP, length 68) 192.168.7.1 > 10.0.0.2: ip-proto-1

With patch, ip_fragment skb_has_frag_list fastpath gets used:
IP (ttl 63, offset 0, flags [+], ICMP, length 1276) 192.168.7.1 > 10.0.0.2: ICMP echo request, length 1256
IP (ttl 63, offset 1256, flags [+], ICMP, length 1276) 192.168.7.1 > 10.0.0.2: ip-proto-1
IP (ttl 63, offset 2512, flags [none], ICMP, length 516) 192.168.7.1 > 10.0.0.2: ip-proto-1

Caveat:
This disables the optimization made in commit
3cc4949269e01f39443d0 ("ipv4: use skb coalescing in defragmentation") for
everyone as soon as nf_defrag_ipv4 modules are loaded (conntrack defrag
hooks earlier than ipv4 stacks own defragmentation for local delivery),
and there is no way to easily determine if we will forward the skb at that
stage.

ip_fragment checks the size of the frag skbs vs. the outgoing device mtu
before using them so if device mtu is smaller than the frag skb length
the device mtu will be used instead for refragmentation.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_fragment.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cc1da6d..31fbb18 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -93,7 +93,7 @@ int ip_frag_mem(struct net *net)
 }
 
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
-			 struct net_device *dev);
+			 struct net_device *dev, bool preserve_frags);
 
 struct ip4_create_arg {
 	struct iphdr *iph;
@@ -315,7 +315,8 @@ static int ip_frag_reinit(struct ipq *qp)
 }
 
 /* Add new segment to existing queue. */
-static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
+static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb,
+			 bool preserve_frags)
 {
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
@@ -483,7 +484,7 @@ found:
 		unsigned long orefdst = skb->_skb_refdst;
 
 		skb->_skb_refdst = 0UL;
-		err = ip_frag_reasm(qp, prev, dev);
+		err = ip_frag_reasm(qp, prev, dev, preserve_frags);
 		skb->_skb_refdst = orefdst;
 		return err;
 	}
@@ -500,7 +501,7 @@ err:
 /* Build a new IP datagram from all its fragments. */
 
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
-			 struct net_device *dev)
+			 struct net_device *dev, bool preserve_frags)
 {
 	struct net *net = container_of(qp->q.net, struct net, ipv4.frags);
 	struct iphdr *iph;
@@ -590,7 +591,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 
-		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
+		if (!preserve_frags &&
+		    skb_try_coalesce(head, fp, &headstolen, &delta)) {
 			kfree_skb_partial(fp, headstolen);
 		} else {
 			if (!skb_shinfo(head)->frag_list)
@@ -629,6 +631,11 @@ out_fail:
 	return err;
 }
 
+static bool preserve_fraglist(u32 user)
+{
+	return user != IP_DEFRAG_LOCAL_DELIVER;
+}
+
 /* Process an incoming IP datagram fragment. */
 int ip_defrag(struct sk_buff *skb, u32 user)
 {
@@ -645,7 +652,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 
 		spin_lock(&qp->q.lock);
 
-		ret = ip_frag_queue(qp, skb);
+		ret = ip_frag_queue(qp, skb, preserve_fraglist(user));
 
 		spin_unlock(&qp->q.lock);
 		ipq_put(qp);
-- 
2.0.5
