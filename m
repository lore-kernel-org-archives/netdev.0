From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next] hv_netvsc: use skb_get_hash() instead of a homegrown implementation
Date: Mon, 25 Jan 2016 16:00:41 +0100
Message-ID: <1453734041-20394-1-git-send-email-vkuznets@redhat.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
VLAN ID to flow_keys")) introduced a performance regression in netvsc
driver. Is problem is, however, not the above mentioned commit but the
fact that netvsc_set_hash() function did some assumptions on the struct
flow_keys data layout and this is wrong.

Get rid of netvsc_set_hash() by switching to skb_get_hash(). This change
will also imply switching to Jenkins hash from the currently used Toeplitz
but it seems there is no good excuse for Toeplitz to stay.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
- This patch is an alternative to the previosely sent "hv_netvsc: don't make
 assumptions on struct flow_keys layout" and Haiyang's "hv_netvsc: Use simple
 parser for IPv4 and v6 headers".
---
 drivers/net/hyperv/netvsc_drv.c | 67 ++---------------------------------------
 1 file changed, 3 insertions(+), 64 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1c8db9a..1d3a665 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -196,65 +196,6 @@ static void *init_ppi_data(struct rndis_message *msg, u32 ppi_size,
 	return ppi;
 }
 
-union sub_key {
-	u64 k;
-	struct {
-		u8 pad[3];
-		u8 kb;
-		u32 ka;
-	};
-};
-
-/* Toeplitz hash function
- * data: network byte order
- * return: host byte order
- */
-static u32 comp_hash(u8 *key, int klen, void *data, int dlen)
-{
-	union sub_key subk;
-	int k_next = 4;
-	u8 dt;
-	int i, j;
-	u32 ret = 0;
-
-	subk.k = 0;
-	subk.ka = ntohl(*(u32 *)key);
-
-	for (i = 0; i < dlen; i++) {
-		subk.kb = key[k_next];
-		k_next = (k_next + 1) % klen;
-		dt = ((u8 *)data)[i];
-		for (j = 0; j < 8; j++) {
-			if (dt & 0x80)
-				ret ^= subk.ka;
-			dt <<= 1;
-			subk.k <<= 1;
-		}
-	}
-
-	return ret;
-}
-
-static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
-{
-	struct flow_keys flow;
-	int data_len;
-
-	if (!skb_flow_dissect_flow_keys(skb, &flow, 0) ||
-	    !(flow.basic.n_proto == htons(ETH_P_IP) ||
-	      flow.basic.n_proto == htons(ETH_P_IPV6)))
-		return false;
-
-	if (flow.basic.ip_proto == IPPROTO_TCP)
-		data_len = 12;
-	else
-		data_len = 8;
-
-	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, &flow, data_len);
-
-	return true;
-}
-
 static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 			void *accel_priv, select_queue_fallback_t fallback)
 {
@@ -267,11 +208,9 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 	if (nvsc_dev == NULL || ndev->real_num_tx_queues <= 1)
 		return 0;
 
-	if (netvsc_set_hash(&hash, skb)) {
-		q_idx = nvsc_dev->send_table[hash % VRSS_SEND_TAB_SIZE] %
-			ndev->real_num_tx_queues;
-		skb_set_hash(skb, hash, PKT_HASH_TYPE_L3);
-	}
+	hash = skb_get_hash(skb);
+	q_idx = nvsc_dev->send_table[hash % VRSS_SEND_TAB_SIZE] %
+		ndev->real_num_tx_queues;
 
 	if (!nvsc_dev->chn_table[q_idx])
 		q_idx = 0;
-- 
2.5.0
