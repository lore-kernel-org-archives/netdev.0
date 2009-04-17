From: Saikiran Madugula <hummerbliss@gmail.com>
Subject: [PATCH] Allow fragmentation of VLAN packets traversing a bridge.
Date: Fri, 17 Apr 2009 23:51:14 +0100
Message-ID: <49E907E2.3020304@gmail.com>
References: <49E89E0D.5080000@gmail.com> <49E8A6DF.3040905@trash.net> <49E8B73C.7080004@gmail.com> <49E8BA68.50605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Saikiran Madugula <hummerbliss@gmail.com>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E8BA68.50605@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

br_nf_dev_queue_xmit only checks for ETH_P_IP packets for fragmenting but not
VLAN packets. This results in dropping of large VLAN packets. This can be
observed when connection tracking is enabled. Connection tracking re-assembles
fragmented packets, and these have to re-fragmented when transmitting out. Also,
make sure only refragmented packets are defragmented as per suggestion from
Patrick McHardy.

Signed-off-by: Saikiran Madugula <hummerbliss@gmail.com>
---
 net/bridge/br_netfilter.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

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
-- 
1.5.6.3
