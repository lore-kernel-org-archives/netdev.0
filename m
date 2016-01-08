From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: [PATCH v2] net: preserve IP control block during GSO segmentation
Date: Fri, 08 Jan 2016 15:21:46 +0300
Message-ID: <145225570625.30903.13936642758071448458.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Skb_gso_segment() uses skb control block during segmentation.
This patch adds 32-bytes room for previous control block which
will be copied into all resulting segments.

This patch fixes kernel crash during fragmenting forwarded packets.
Fragmentation requires valid IP CB in skb for clearing ip options.
Also patch removes custom save/restore in ovs code, now it's redundant.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Link: http://lkml.kernel.org/r/CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com
---
 include/linux/skbuff.h     |    3 ++-
 net/core/dev.c             |    5 +++++
 net/ipv4/ip_output.c       |    1 +
 net/openvswitch/datapath.c |    5 +----
 net/xfrm/xfrm_output.c     |    2 ++
 5 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4355129fff91..9147f9f34cbe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3446,7 +3446,8 @@ struct skb_gso_cb {
 	int	encap_level;
 	__u16	csum_start;
 };
-#define SKB_GSO_CB(skb) ((struct skb_gso_cb *)(skb)->cb)
+#define SKB_SGO_CB_OFFSET	32
+#define SKB_GSO_CB(skb) ((struct skb_gso_cb *)((skb)->cb + SKB_SGO_CB_OFFSET))
 
 static inline int skb_tnl_header_len(const struct sk_buff *inner_skb)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index ae00b894e675..7f00f2439770 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2542,6 +2542,8 @@ static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
  *
  *	It may return NULL if the skb requires no segmentation.  This is
  *	only possible when GSO is used for verifying header integrity.
+ *
+ *	Segmentation preserves SKB_SGO_CB_OFFSET bytes of previous skb cb.
  */
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path)
@@ -2556,6 +2558,9 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 			return ERR_PTR(err);
 	}
 
+	BUILD_BUG_ON(SKB_SGO_CB_OFFSET +
+		     sizeof(*SKB_GSO_CB(skb)) > sizeof(skb->cb));
+
 	SKB_GSO_CB(skb)->mac_offset = skb_headroom(skb);
 	SKB_GSO_CB(skb)->encap_level = 0;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4233cbe47052..59ed4b89b67a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -240,6 +240,7 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	 * from host network stack.
 	 */
 	features = netif_skb_features(skb);
+	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
 	if (IS_ERR_OR_NULL(segs)) {
 		kfree_skb(skb);
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 91a8b004dc51..deadfdab1bc3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -336,12 +336,10 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	unsigned short gso_type = skb_shinfo(skb)->gso_type;
 	struct sw_flow_key later_key;
 	struct sk_buff *segs, *nskb;
-	struct ovs_skb_cb ovs_cb;
 	int err;
 
-	ovs_cb = *OVS_CB(skb);
+	BUILD_BUG_ON(sizeof(*OVS_CB(skb)) > SKB_SGO_CB_OFFSET);
 	segs = __skb_gso_segment(skb, NETIF_F_SG, false);
-	*OVS_CB(skb) = ovs_cb;
 	if (IS_ERR(segs))
 		return PTR_ERR(segs);
 	if (segs == NULL)
@@ -359,7 +357,6 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	/* Queue all of the segments. */
 	skb = segs;
 	do {
-		*OVS_CB(skb) = ovs_cb;
 		if (gso_type & SKB_GSO_UDP && skb != segs)
 			key = &later_key;
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index cc3676eb6239..ff4a91fcab9f 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -167,6 +167,8 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
 {
 	struct sk_buff *segs;
 
+	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
+	BUILD_BUG_ON(sizeof(*IP6CB(skb)) > SKB_SGO_CB_OFFSET);
 	segs = skb_gso_segment(skb, 0);
 	kfree_skb(skb);
 	if (IS_ERR(segs))
