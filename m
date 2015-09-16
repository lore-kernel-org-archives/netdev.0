From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 25/30] bridge: Pass net into br_nf_push_frag_xmit
Date: Tue, 15 Sep 2015 20:04:13 -0500
Message-ID: <1442365458-16349-25-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60400 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbbIPBNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:40 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When struct net starts being passed through the ipv4 and ipv6 fragment
routines br_nf_push_frag_xmit will need to take a net parameter.
Prepare br_nf_push_frag_xmit before that is needed and introduce
br_nf_push_frag_xmit_sk for the call sites that still need the old
calling conventions.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/br_netfilter_hooks.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 971d45d24c64..e6910b71af6e 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -668,7 +668,7 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 }
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4) || IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
-static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
+static int br_nf_push_frag_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct brnf_frag_data *data;
 	int err;
@@ -692,6 +692,11 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(sk, skb);
 }
+static int br_nf_push_frag_xmit_sk(struct sock *sk, struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb_dst(skb)->dev);
+	return br_nf_push_frag_xmit(net, sk, skb);
+}
 #endif
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
@@ -760,7 +765,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
 						 data->size);
 
-		return br_nf_ip_fragment(net, sk, skb, br_nf_push_frag_xmit);
+		return br_nf_ip_fragment(net, sk, skb, br_nf_push_frag_xmit_sk);
 	}
 #endif
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
@@ -783,7 +788,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 						 data->size);
 
 		if (v6ops)
-			return v6ops->fragment(sk, skb, br_nf_push_frag_xmit);
+			return v6ops->fragment(sk, skb, br_nf_push_frag_xmit_sk);
 
 		kfree_skb(skb);
 		return -EMSGSIZE;
-- 
2.2.1
