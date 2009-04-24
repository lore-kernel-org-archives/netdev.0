From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/05: bridge: allow fragmentation of VLAN packets traversing a bridge
Date: Fri, 24 Apr 2009 17:44:02 +0200 (MEST)
Message-ID: <20090424154357.28952.32926.sendpatchset@x2.localnet>
References: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit c197facc8ea08062f8f949aade6a33649ee06771
Author: hummerbliss@gmail.com <hummerbliss@gmail.com>
Date:   Mon Apr 20 17:12:35 2009 +0200

    netfilter: bridge: allow fragmentation of VLAN packets traversing a bridge
    
    br_nf_dev_queue_xmit only checks for ETH_P_IP packets for fragmenting but not
    VLAN packets. This results in dropping of large VLAN packets. This can be
    observed when connection tracking is enabled. Connection tracking re-assembles
    fragmented packets, and these have to re-fragmented when transmitting out. Also,
    make sure only refragmented packets are defragmented as per suggestion from
    Patrick McHardy.
    
    Signed-off-by: Saikiran Madugula <hummerbliss@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 3953ac4..e4a418f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -788,15 +788,23 @@ static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff *skb,
 	return NF_STOLEN;
 }
 
+#if defined(CONFIG_NF_CONNTRACK_IPV4) || defined(CONFIG_NF_CONNTRACK_IPV4_MODULE)
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
-	if (skb->protocol == htons(ETH_P_IP) &&
+	if (skb->nfct != NULL &&
+	    (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb)) &&
 	    skb->len > skb->dev->mtu &&
 	    !skb_is_gso(skb))
 		return ip_fragment(skb, br_dev_queue_push_xmit);
 	else
 		return br_dev_queue_push_xmit(skb);
 }
+#else
+static int br_nf_dev_queue_xmit(struct sk_buff *skb)
+{
+        return br_dev_queue_push_xmit(skb);
+}
+#endif
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
 static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
