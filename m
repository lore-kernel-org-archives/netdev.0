From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 3/3] ipv6: Pass struct net into nf_ct_frag6_gather
Date: Fri,  9 Oct 2015 13:44:55 -0500
Message-ID: <1444416295-31683-3-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59653 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755954AbbJISw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 14:52:57 -0400
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function nf_ct_frag6_gather is called on both the input and the
output paths of the networking stack.  In particular ipv6_defrag which
calls nf_ct_frag6_gather is called from both the the PRE_ROUTING chain
on input and the LOCAL_OUT chain on output.

The addition of a net parameter makes it explicit which network
namespace the packets are being reassembled in, and removes the need
for nf_ct_frag6_gather to guess.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h | 2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c     | 4 +---
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c   | 3 ++-
 net/openvswitch/conntrack.c                 | 2 +-
 4 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index 27666d8a0bd0..fb7da5bb76cc 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -5,7 +5,7 @@ void nf_defrag_ipv6_enable(void);
 
 int nf_ct_frag6_init(void);
 void nf_ct_frag6_cleanup(void);
-struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user);
+struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user);
 void nf_ct_frag6_consume_orig(struct sk_buff *skb);
 
 struct inet_frags_ctl;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 701cd2bae0a9..2fb86a99bf5f 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -563,12 +563,10 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 	return 0;
 }
 
-struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
+struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct sk_buff *clone;
 	struct net_device *dev = skb->dev;
-	struct net *net = skb_dst(skb) ? dev_net(skb_dst(skb)->dev)
-				       : dev_net(skb->dev);
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index a99baf63eccf..5173a89a238e 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -63,7 +63,8 @@ static unsigned int ipv6_defrag(void *priv,
 		return NF_ACCEPT;
 #endif
 
-	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(state->hook, skb));
+	reasm = nf_ct_frag6_gather(state->net, skb,
+				   nf_ct6_defrag_user(state->hook, skb));
 	/* queued */
 	if (reasm == NULL)
 		return NF_STOLEN;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index cb76076a7a42..ad614267cc2a 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -315,7 +315,7 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 		struct sk_buff *reasm;
 
 		memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
-		reasm = nf_ct_frag6_gather(skb, user);
+		reasm = nf_ct_frag6_gather(net, skb, user);
 		if (!reasm)
 			return -EINPROGRESS;
 
-- 
2.2.1
