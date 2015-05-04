From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 4/5] net: ip_fragment: attempt to preserve frag sizes for netfilter defragmented skbs
Date: Mon,  4 May 2015 22:54:47 +0200
Message-ID: <1430772888-5682-5-git-send-email-fw@strlen.de>
References: <1430772888-5682-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org, jesse@nicira.com,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47182 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751650AbbEDUzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:55:17 -0400
In-Reply-To: <1430772888-5682-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was interest in allowing us to record the original fragment sizes
in more detail, i.e. preserve length of all individual fragments.

This (re)enables this capability. Caveats are:

1. - this disables the optimizations made in
commit 3cc4949269e01f39443d0 ("ipv4: use skb coalescing in defragmentation")
for everyone as soon as nf_defrag_ipv4 module is loaded (it hooks earlier
than ipv4 stacks own defragmentation for local delivery).

Unfortunately there is no (easy) way to determine if we will forward the skb
at that stage.

2. - it doesn't work when skb_linearize() and friends are invoked later.

3. - we still call ip_fragment() when skbs are forwarded to (re-)create
the fragment headers.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 I don't think this patch (and 5/5) is needed, but there was interest
 in allowing to 'replay' original fragment geometry in more detail
 when refragmenting, and this is one way of allowing this at least in
 some cases.

 net/ipv4/ip_fragment.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index ad2404f..2326ae8 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -94,7 +94,7 @@ int ip_frag_mem(struct net *net)
 }
 
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
-			 struct net_device *dev);
+			 struct net_device *dev, bool preserve_frags);
 
 struct ip4_create_arg {
 	struct iphdr *iph;
@@ -316,7 +316,8 @@ static int ip_frag_reinit(struct ipq *qp)
 }
 
 /* Add new segment to existing queue. */
-static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
+static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb,
+			 bool preserve_frags)
 {
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
@@ -490,7 +491,7 @@ found:
 		unsigned long orefdst = skb->_skb_refdst;
 
 		skb->_skb_refdst = 0UL;
-		err = ip_frag_reasm(qp, prev, dev);
+		err = ip_frag_reasm(qp, prev, dev, preserve_frags);
 		skb->_skb_refdst = orefdst;
 		return err;
 	}
@@ -507,7 +508,7 @@ err:
 /* Build a new IP datagram from all its fragments. */
 
 static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
-			 struct net_device *dev)
+			 struct net_device *dev, bool preserve_frags)
 {
 	struct net *net = container_of(qp->q.net, struct net, ipv4.frags);
 	struct iphdr *iph;
@@ -597,7 +598,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 
-		if (skb_try_coalesce(head, fp, &headstolen, &delta)) {
+		if (!preserve_frags &&
+		    skb_try_coalesce(head, fp, &headstolen, &delta)) {
 			kfree_skb_partial(fp, headstolen);
 		} else {
 			if (!skb_shinfo(head)->frag_list)
@@ -650,6 +652,11 @@ out_fail:
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
@@ -666,7 +673,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 
 		spin_lock(&qp->q.lock);
 
-		ret = ip_frag_queue(qp, skb);
+		ret = ip_frag_queue(qp, skb, preserve_fraglist(user));
 
 		spin_unlock(&qp->q.lock);
 		ipq_put(qp);
-- 
2.0.5
