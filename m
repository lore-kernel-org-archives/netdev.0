From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,2/2] hv_netvsc: Exclude non-TCP port numbers from vRSS hashing
Date: Wed, 12 Apr 2017 11:45:18 -0700
Message-ID: <1492022718-4301-2-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

Azure hosts are not supporting non-TCP port numbers in vRSS hashing for
now. For example, UDP packet loss rate will be high if port numbers are
also included in vRSS hash.

So, we created this patch to use only IP numbers for hashing in non-TCP
traffic.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |   32 +++++++++++++++++++++++++++++++-
 1 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index e813eaf..51fa903 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -191,6 +191,36 @@ static int netvsc_close(struct net_device *net)
 	return ppi;
 }
 
+/* Azure hosts don't support non-TCP port numbers in hashing yet. We compute
+ * hash for non-TCP traffic with only IP numbers.
+ */
+static inline u32 netvsc_get_hash(struct sk_buff *skb, struct sock *sk)
+{
+	struct flow_keys flow;
+	u32 hash;
+	static u32 hashrnd __read_mostly;
+
+	net_get_random_once(&hashrnd, sizeof(hashrnd));
+
+	if (!skb_flow_dissect_flow_keys(skb, &flow, 0))
+		return 0;
+
+	if (flow.basic.ip_proto == IPPROTO_TCP) {
+		return skb_get_hash(skb);
+	} else {
+		if (flow.basic.n_proto == htons(ETH_P_IP))
+			hash = jhash2((u32 *)&flow.addrs.v4addrs, 2, hashrnd);
+		else if (flow.basic.n_proto == htons(ETH_P_IPV6))
+			hash = jhash2((u32 *)&flow.addrs.v6addrs, 8, hashrnd);
+		else
+			hash = 0;
+
+		skb_set_hash(skb, hash, PKT_HASH_TYPE_L3);
+	}
+
+	return hash;
+}
+
 static inline int netvsc_get_tx_queue(struct net_device *ndev,
 				      struct sk_buff *skb, int old_idx)
 {
@@ -198,7 +228,7 @@ static inline int netvsc_get_tx_queue(struct net_device *ndev,
 	struct sock *sk = skb->sk;
 	int q_idx;
 
-	q_idx = ndc->tx_send_table[skb_get_hash(skb) &
+	q_idx = ndc->tx_send_table[netvsc_get_hash(skb, sk) &
 				   (VRSS_SEND_TAB_SIZE - 1)];
 
 	/* If queue index changed record the new value */
-- 
1.7.1
