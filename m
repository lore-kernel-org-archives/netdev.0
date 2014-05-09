From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] bridge: superfluous skb->nfct check in br_nf_dev_queue_xmit
Date: Fri,  9 May 2014 12:56:06 +0200
Message-ID: <1399632967-4423-6-git-send-email-pablo@netfilter.org>
References: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40290 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755884AbaEIK4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 06:56:23 -0400
In-Reply-To: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@parallels.com>

Currently bridge can silently drop ipv4 fragments.
If node have loaded nf_defrag_ipv4 module but have no nf_conntrack_ipv4,
br_nf_pre_routing defragments incoming ipv4 fragments
but nfct check in br_nf_dev_queue_xmit does not allow re-fragment combined
packet back, and therefore it is dropped in br_dev_queue_push_xmit without
incrementing of any failcounters

It seems the only way to hit the ip_fragment code in the bridge xmit
path is to have a fragment list whose reassembled fragments go over
the mtu. This only happens if nf_defrag is enabled. Thanks to
Florian Westphal for providing feedback to clarify this.

Defragmentation ipv4 is required not only in conntracks but at least in
TPROXY target and socket match, therefore #ifdef is changed from
NF_CONNTRACK_IPV4 to NF_DEFRAG_IPV4

Signed-off-by: Vasily Averin <vvs@openvz.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 80e1b0f..2acf7fa 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -859,12 +859,12 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 	return NF_STOLEN;
 }
 
-#if IS_ENABLED(CONFIG_NF_CONNTRACK_IPV4)
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
 
-	if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
+	if (skb->protocol == htons(ETH_P_IP) &&
 	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
 	    !skb_is_gso(skb)) {
 		if (br_parse_ip_options(skb))
-- 
1.7.10.4
