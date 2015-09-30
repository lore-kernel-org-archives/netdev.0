From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 2/6] openvswitch: Pass net into ovs_fragment
Date: Wed, 30 Sep 2015 16:25:32 -0500
Message-ID: <1443648336-31741-2-git-send-email-ebiederm@xmission.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55870 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbbI3VeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:34:17 -0400
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for the ipv4 and ipv6 fragmentation code taking a net
parameter pass a struct net into ovs_fragment where the v4 and v6
fragmentation code is called.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/openvswitch/actions.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index f00c641ecd93..ba38662f9f5e 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -684,8 +684,8 @@ static void prepare_frag(struct vport *vport, struct sk_buff *skb)
 	skb_pull(skb, hlen);
 }
 
-static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
-			 __be16 ethertype)
+static void ovs_fragment(struct net *net, struct vport *vport,
+			 struct sk_buff *skb, u16 mru, __be16 ethertype)
 {
 	if (skb_network_offset(skb) > MAX_L2_LEN) {
 		OVS_NLERR(1, "L2 header too long to fragment");
@@ -748,6 +748,7 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 		if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
 			ovs_vport_send(vport, skb);
 		} else if (mru <= vport->dev->mtu) {
+			struct net *net = read_pnet(&dp->net);
 			__be16 ethertype = key->eth.type;
 
 			if (!is_flow_key_valid(key)) {
@@ -757,7 +758,7 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 					ethertype = vlan_get_protocol(skb);
 			}
 
-			ovs_fragment(vport, skb, mru, ethertype);
+			ovs_fragment(net, vport, skb, mru, ethertype);
 		} else {
 			kfree_skb(skb);
 		}
-- 
2.2.1
