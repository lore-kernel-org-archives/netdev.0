From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 05/11] flow_dissector: Add flags argument to skb_flow_dissector functions
Date: Tue, 1 Sep 2015 09:24:27 -0700
Message-ID: <1441124673-3438470-6-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60323 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753410AbbIAQZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:17 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GKa08018174
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wnf3m04hd-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:17 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 06d6f21e50c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:15 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flags argument will allow control of the dissection process (for
instance whether to parse beyond L3).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/bonding/bond_main.c             |  2 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c |  2 +-
 drivers/net/hyperv/netvsc_drv.c             |  2 +-
 include/linux/skbuff.h                      | 19 +++++++++++--------
 net/core/flow_dissector.c                   |  7 ++++---
 net/ethernet/eth.c                          |  2 +-
 net/sched/cls_flow.c                        |  2 +-
 net/sched/cls_flower.c                      |  2 +-
 net/sched/sch_choke.c                       |  4 ++--
 9 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 06e2d01..771a449 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3095,7 +3095,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 	int noff, proto = -1;
 
 	if (bond->params.xmit_policy > BOND_XMIT_POLICY_LAYER23)
-		return skb_flow_dissect_flow_keys(skb, fk);
+		return skb_flow_dissect_flow_keys(skb, fk, 0);
 
 	fk->ports.ports = 0;
 	noff = skb_network_offset(skb);
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index d106186..3c677ed 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -177,7 +177,7 @@ int enic_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 	int res, i;
 
 	enic = netdev_priv(dev);
-	res = skb_flow_dissect_flow_keys(skb, &keys);
+	res = skb_flow_dissect_flow_keys(skb, &keys, 0);
 	if (!res || keys.basic.n_proto != htons(ETH_P_IP) ||
 	    (keys.basic.ip_proto != IPPROTO_TCP &&
 	     keys.basic.ip_proto != IPPROTO_UDP))
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 2990024..409b48e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -239,7 +239,7 @@ static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 	struct flow_keys flow;
 	int data_len;
 
-	if (!skb_flow_dissect_flow_keys(skb, &flow) ||
+	if (!skb_flow_dissect_flow_keys(skb, &flow, 0) ||
 	    !(flow.basic.n_proto == htons(ETH_P_IP) ||
 	      flow.basic.n_proto == htons(ETH_P_IPV6)))
 		return false;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bbe41bc..9e62687 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -991,31 +991,34 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 bool __skb_flow_dissect(const struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
 			void *target_container,
-			void *data, __be16 proto, int nhoff, int hlen);
+			void *data, __be16 proto, int nhoff, int hlen,
+			unsigned int flags);
 
 static inline bool skb_flow_dissect(const struct sk_buff *skb,
 				    struct flow_dissector *flow_dissector,
-				    void *target_container)
+				    void *target_container, unsigned int flags)
 {
 	return __skb_flow_dissect(skb, flow_dissector, target_container,
-				  NULL, 0, 0, 0);
+				  NULL, 0, 0, 0, flags);
 }
 
 static inline bool skb_flow_dissect_flow_keys(const struct sk_buff *skb,
-					      struct flow_keys *flow)
+					      struct flow_keys *flow,
+					      unsigned int flags)
 {
 	memset(flow, 0, sizeof(*flow));
 	return __skb_flow_dissect(skb, &flow_keys_dissector, flow,
-				  NULL, 0, 0, 0);
+				  NULL, 0, 0, 0, flags);
 }
 
 static inline bool skb_flow_dissect_flow_keys_buf(struct flow_keys *flow,
 						  void *data, __be16 proto,
-						  int nhoff, int hlen)
+						  int nhoff, int hlen,
+						  unsigned int flags)
 {
 	memset(flow, 0, sizeof(*flow));
 	return __skb_flow_dissect(NULL, &flow_keys_buf_dissector, flow,
-				  data, proto, nhoff, hlen);
+				  data, proto, nhoff, hlen, flags);
 }
 
 static inline __u32 skb_get_hash(struct sk_buff *skb)
@@ -2046,7 +2049,7 @@ static inline void skb_probe_transport_header(struct sk_buff *skb,
 
 	if (skb_transport_header_was_set(skb))
 		return;
-	else if (skb_flow_dissect_flow_keys(skb, &keys))
+	else if (skb_flow_dissect_flow_keys(skb, &keys, 0))
 		skb_set_transport_header(skb, keys.control.thoff);
 	else
 		skb_set_transport_header(skb, offset_hint);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 22f3d76..c3d9807 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -121,7 +121,8 @@ EXPORT_SYMBOL(__skb_flow_get_ports);
 bool __skb_flow_dissect(const struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
 			void *target_container,
-			void *data, __be16 proto, int nhoff, int hlen)
+			void *data, __be16 proto, int nhoff, int hlen,
+			unsigned int flags)
 {
 	struct flow_dissector_key_control *key_control;
 	struct flow_dissector_key_basic *key_basic;
@@ -556,7 +557,7 @@ EXPORT_SYMBOL(flow_hash_from_keys);
 static inline u32 ___skb_get_hash(const struct sk_buff *skb,
 				  struct flow_keys *keys, u32 keyval)
 {
-	if (!skb_flow_dissect_flow_keys(skb, keys))
+	if (!skb_flow_dissect_flow_keys(skb, keys, 0))
 		return 0;
 
 	return __flow_hash_from_keys(keys, keyval);
@@ -726,7 +727,7 @@ u32 skb_get_poff(const struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
-	if (!skb_flow_dissect_flow_keys(skb, &keys))
+	if (!skb_flow_dissect_flow_keys(skb, &keys, 0))
 		return 0;
 
 	return __skb_get_poff(skb, skb->data, &keys, skb_headlen(skb));
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 217127c..d850fdc 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -132,7 +132,7 @@ u32 eth_get_headlen(void *data, unsigned int len)
 
 	/* parse any remaining L2/L3 headers, check for L4 */
 	if (!skb_flow_dissect_flow_keys_buf(&keys, data, eth->h_proto,
-					    sizeof(*eth), len))
+					    sizeof(*eth), len, 0))
 		return max_t(u32, keys.control.thoff, sizeof(*eth));
 
 	/* parse for any L4 headers */
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index bb2a0f5..536838b 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -301,7 +301,7 @@ static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 		keymask = f->keymask;
 		if (keymask & FLOW_KEYS_NEEDED)
-			skb_flow_dissect_flow_keys(skb, &flow_keys);
+			skb_flow_dissect_flow_keys(skb, &flow_keys, 0);
 
 		for (n = 0; n < f->nkeys; n++) {
 			key = ffs(keymask) - 1;
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 2f3d03f..5769294 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -129,7 +129,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	 * so do it rather here.
 	 */
 	skb_key.basic.n_proto = skb->protocol;
-	skb_flow_dissect(skb, &head->dissector, &skb_key);
+	skb_flow_dissect(skb, &head->dissector, &skb_key, 0);
 
 	fl_set_masked_key(&skb_mkey, &skb_key, &head->mask);
 
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 665bde0..02bfd3d 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -170,13 +170,13 @@ static bool choke_match_flow(struct sk_buff *skb1,
 
 	if (!choke_skb_cb(skb1)->keys_valid) {
 		choke_skb_cb(skb1)->keys_valid = 1;
-		skb_flow_dissect_flow_keys(skb1, &temp);
+		skb_flow_dissect_flow_keys(skb1, &temp, 0);
 		make_flow_keys_digest(&choke_skb_cb(skb1)->keys, &temp);
 	}
 
 	if (!choke_skb_cb(skb2)->keys_valid) {
 		choke_skb_cb(skb2)->keys_valid = 1;
-		skb_flow_dissect_flow_keys(skb2, &temp);
+		skb_flow_dissect_flow_keys(skb2, &temp, 0);
 		make_flow_keys_digest(&choke_skb_cb(skb2)->keys, &temp);
 	}
 
-- 
1.8.1
