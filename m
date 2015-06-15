From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/32] netfilter: bridge: restore vlan tag when refragmenting
Date: Mon, 15 Jun 2015 23:26:07 +0200
Message-ID: <1434403589-24796-11-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58795 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756164AbbFOVVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:32 -0400
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

If bridge netfilter is used with both
bridge-nf-call-iptables and bridge-nf-filter-vlan-tagged enabled
then ip fragments in VLAN frames are sent without the vlan header.

This has never worked reliably.  Turns out this relied on pre-3.5
behaviour where skb frag_list was used to store ip fragments;
ip_fragment() then re-used these skbs.

But since commit 3cc4949269e01f39443d0fcfffb5bc6b47878d45
("ipv4: use skb coalescing in defragmentation") this is no longer
the case.  ip_do_fragment now needs to allocate new skbs, but these
don't contain the vlan tag information anymore.

Fix it by storing vlan information of the ressembled skb in the
br netfilter percpu frag area, and restore them for each of the
fragments.

Fixes: 3cc4949269e01f3 ("ipv4: use skb coalescing in defragmentation")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 1e62ae5..e4e5f2f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -116,6 +116,8 @@ struct brnf_frag_data {
 	char mac[NF_BRIDGE_MAX_MAC_HEADER_LENGTH];
 	u8 encap_size;
 	u8 size;
+	u16 vlan_tci;
+	__be16 vlan_proto;
 };
 
 static DEFINE_PER_CPU(struct brnf_frag_data, brnf_frag_data_storage);
@@ -909,6 +911,11 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	if (data->vlan_tci) {
+		skb->vlan_tci = data->vlan_tci;
+		skb->vlan_proto = data->vlan_proto;
+	}
+
 	skb_copy_to_linear_data_offset(skb, -data->size, data->mac, data->size);
 	__skb_push(skb, data->encap_size);
 
@@ -972,6 +979,9 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		nf_bridge_update_protocol(skb);
 
 		data = this_cpu_ptr(&brnf_frag_data_storage);
+
+		data->vlan_tci = skb->vlan_tci;
+		data->vlan_proto = skb->vlan_proto;
 		data->encap_size = nf_bridge_encap_header_len(skb);
 		data->size = ETH_HLEN + data->encap_size;
 
-- 
1.7.10.4
