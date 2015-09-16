From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 24/30] bridge: Pass net into br_nf_ip_fragment
Date: Tue, 15 Sep 2015 20:04:12 -0500
Message-ID: <1442365458-16349-24-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39393 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbbIPBNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:40 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a prep work for passing struct net through ip_do_fragment and
later the netfilter okfn.   Doing this independently makes the later
code changes clearer.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/br_netfilter_hooks.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 0a6f095bb0c9..971d45d24c64 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -695,18 +695,17 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 #endif
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
-static int br_nf_ip_fragment(struct sock *sk, struct sk_buff *skb,
-			     int (*output)(struct sock *, struct sk_buff *))
+static int
+br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
+		  int (*output)(struct sock *, struct sk_buff *))
 {
 	unsigned int mtu = ip_skb_dst_mtu(skb);
 	struct iphdr *iph = ip_hdr(skb);
-	struct rtable *rt = skb_rtable(skb);
-	struct net_device *dev = rt->dst.dev;
 
 	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
 		     (IPCB(skb)->frag_max_size &&
 		      IPCB(skb)->frag_max_size > mtu))) {
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
@@ -726,6 +725,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge;
 	unsigned int mtu_reserved;
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	mtu_reserved = nf_bridge_mtu_reduction(skb);
 
@@ -760,7 +760,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
 						 data->size);
 
-		return br_nf_ip_fragment(sk, skb, br_nf_push_frag_xmit);
+		return br_nf_ip_fragment(net, sk, skb, br_nf_push_frag_xmit);
 	}
 #endif
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
-- 
2.2.1
