From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 5/8] skbuff: store hash type in socket buffer...
Date: Wed, 21 Oct 2015 11:36:22 +0100
Message-ID: <1445423785-4654-6-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:9593 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbbJUKhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 06:37:03 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

...rather than a boolean merely indicating a canonical L4 hash.

skb_set_hash() takes a hash type (from enum pkt_hash_types) as an
argument but information is lost since only a single bit in the skb
stores whether that hash type is PKT_HASH_TYPE_L4 or not.

By using two bits it's possible to store the complete hash type
information for use by drivers, such as xen-netback when forwarding
network packets to VM frontend drivers.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c |  2 +-
 include/linux/skbuff.h          | 53 ++++++++++++++++++++++++++++-------------
 include/net/flow_dissector.h    |  5 ++++
 include/net/sock.h              |  2 +-
 include/trace/events/net.h      |  2 +-
 net/core/flow_dissector.c       | 27 ++++++++++++++++-----
 6 files changed, 65 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d0f23cd..abf9c3f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3137,7 +3137,7 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 	u32 hash;
 
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP34 &&
-	    skb->l4_hash)
+	    skb_has_l4_hash(skb))
 		return skb->hash;
 
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER2 ||
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4398411..30e1e60 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -506,8 +506,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@xmit_more: More SKBs are pending for this queue
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
- *	@l4_hash: indicate hash is a canonical 4-tuple hash over transport
- *		ports.
+ *	@hash_type: indicates type of hash (see enum pkt_hash_types below)
  *	@sw_hash: indicates hash was computed in software stack
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
@@ -612,10 +611,10 @@ struct sk_buff {
 	__u8			nf_trace:1;
 	__u8			ip_summed:2;
 	__u8			ooo_okay:1;
-	__u8			l4_hash:1;
 	__u8			sw_hash:1;
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
+	/* 1 bit hole */
 
 	__u8			no_fcs:1;
 	/* Indicates the inner headers are valid in the skbuff. */
@@ -632,7 +631,8 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
+	__u8			hash_type:2;
+	/* 1 or 3 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
@@ -941,19 +941,35 @@ static inline void skb_clear_hash(struct sk_buff *skb)
 {
 	skb->hash = 0;
 	skb->sw_hash = 0;
-	skb->l4_hash = 0;
+	skb->hash_type = 0;
+}
+
+static inline enum pkt_hash_types skb_hash_type(struct sk_buff *skb)
+{
+	return skb->hash_type;
+}
+
+static inline bool skb_has_l4_hash(struct sk_buff *skb)
+{
+	return skb_hash_type(skb) == PKT_HASH_TYPE_L4;
+}
+
+static inline bool skb_has_sw_hash(struct sk_buff *skb)
+{
+	return !!skb->sw_hash;
 }
 
 static inline void skb_clear_hash_if_not_l4(struct sk_buff *skb)
 {
-	if (!skb->l4_hash)
+	if (!skb_has_l4_hash(skb))
 		skb_clear_hash(skb);
 }
 
 static inline void
-__skb_set_hash(struct sk_buff *skb, __u32 hash, bool is_sw, bool is_l4)
+__skb_set_hash(struct sk_buff *skb, __u32 hash, bool is_sw,
+	       enum pkt_hash_types type)
 {
-	skb->l4_hash = is_l4;
+	skb->hash_type = type;
 	skb->sw_hash = is_sw;
 	skb->hash = hash;
 }
@@ -962,13 +978,13 @@ static inline void
 skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
 {
 	/* Used by drivers to set hash from HW */
-	__skb_set_hash(skb, hash, false, type == PKT_HASH_TYPE_L4);
+	__skb_set_hash(skb, hash, false, type);
 }
 
 static inline void
-__skb_set_sw_hash(struct sk_buff *skb, __u32 hash, bool is_l4)
+__skb_set_sw_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
 {
-	__skb_set_hash(skb, hash, true, is_l4);
+	__skb_set_hash(skb, hash, true, type);
 }
 
 void __skb_get_hash(struct sk_buff *skb);
@@ -1021,9 +1037,10 @@ static inline bool skb_flow_dissect_flow_keys_buf(struct flow_keys *flow,
 				  data, proto, nhoff, hlen, flags);
 }
 
+
 static inline __u32 skb_get_hash(struct sk_buff *skb)
 {
-	if (!skb->l4_hash && !skb->sw_hash)
+	if (!skb_has_l4_hash(skb) && !skb_has_sw_hash(skb))
 		__skb_get_hash(skb);
 
 	return skb->hash;
@@ -1033,11 +1050,12 @@ __u32 __skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6);
 
 static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6)
 {
-	if (!skb->l4_hash && !skb->sw_hash) {
+	if (!skb_has_l4_hash(skb) && !skb_has_sw_hash(skb)) {
 		struct flow_keys keys;
 		__u32 hash = __get_hash_from_flowi6(fl6, &keys);
 
-		__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys));
+		__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys) ?
+				  PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 	}
 
 	return skb->hash;
@@ -1047,11 +1065,12 @@ __u32 __skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl);
 
 static inline __u32 skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl4)
 {
-	if (!skb->l4_hash && !skb->sw_hash) {
+	if (!skb_has_l4_hash(skb) && !skb_has_sw_hash(skb)) {
 		struct flow_keys keys;
 		__u32 hash = __get_hash_from_flowi4(fl4, &keys);
 
-		__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys));
+		__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys) ?
+				  PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 	}
 
 	return skb->hash;
@@ -1068,7 +1087,7 @@ static inline void skb_copy_hash(struct sk_buff *to, const struct sk_buff *from)
 {
 	to->hash = from->hash;
 	to->sw_hash = from->sw_hash;
-	to->l4_hash = from->l4_hash;
+	to->hash_type = from->hash_type;
 };
 
 static inline void skb_sender_cpu_clear(struct sk_buff *skb)
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 8c8548c..418b8c5 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -182,6 +182,11 @@ static inline bool flow_keys_have_l4(struct flow_keys *keys)
 	return (keys->ports.ports || keys->tags.flow_label);
 }
 
+static inline bool flow_keys_have_l3(struct flow_keys *keys)
+{
+	return !!keys->control.addr_type;
+}
+
 u32 flow_hash_from_keys(struct flow_keys *keys);
 
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 64a7545..b9f68db 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1938,7 +1938,7 @@ static inline void sock_poll_wait(struct file *filp,
 static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 {
 	if (sk->sk_txhash) {
-		skb->l4_hash = 1;
+		skb->hash_type = PKT_HASH_TYPE_L4;
 		skb->hash = sk->sk_txhash;
 	}
 }
diff --git a/include/trace/events/net.h b/include/trace/events/net.h
index 49cc7c3..25e7979 100644
--- a/include/trace/events/net.h
+++ b/include/trace/events/net.h
@@ -180,7 +180,7 @@ DECLARE_EVENT_CLASS(net_dev_rx_verbose_template,
 		__entry->protocol = ntohs(skb->protocol);
 		__entry->ip_summed = skb->ip_summed;
 		__entry->hash = skb->hash;
-		__entry->l4_hash = skb->l4_hash;
+		__entry->l4_hash = skb->hash_type == PKT_HASH_TYPE_L4;
 		__entry->len = skb->len;
 		__entry->data_len = skb->data_len;
 		__entry->truesize = skb->truesize;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d79699c..956208b 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -658,17 +658,30 @@ EXPORT_SYMBOL(make_flow_keys_digest);
  *
  * This function calculates a flow hash based on src/dst addresses
  * and src/dst port numbers.  Sets hash in skb to non-zero hash value
- * on success, zero indicates no valid hash.  Also, sets l4_hash in skb
- * if hash is a canonical 4-tuple hash over transport ports.
+ * on success, zero indicates no valid hash in which case the hash type
+ * is set to NONE. If the hash is a canonical 4-tuple hash over transport
+ * ports then type is set to L4. If the hash did not include transport
+ * then type is set to L3, otherwise it is assumed to be L2 only.
  */
 void __skb_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys keys;
+	u32 hash;
+	enum pkt_hash_types type;
 
 	__flow_hash_secret_init();
 
-	__skb_set_sw_hash(skb, ___skb_get_hash(skb, &keys, hashrnd),
-			  flow_keys_have_l4(&keys));
+	hash = ___skb_get_hash(skb, &keys, hashrnd);
+	if (hash == 0)
+		type = PKT_HASH_TYPE_NONE;
+	else if (flow_keys_have_l4(&keys))
+		type = PKT_HASH_TYPE_L4;
+	else if (flow_keys_have_l3(&keys))
+		type = PKT_HASH_TYPE_L3;
+	else
+		type = PKT_HASH_TYPE_L2;
+
+	__skb_set_sw_hash(skb, hash, type);
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
@@ -698,7 +711,8 @@ __u32 __skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6)
 	keys.basic.ip_proto = fl6->flowi6_proto;
 
 	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys),
-			  flow_keys_have_l4(&keys));
+			  flow_keys_have_l4(&keys) ?
+			  PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 
 	return skb->hash;
 }
@@ -719,7 +733,8 @@ __u32 __skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl4)
 	keys.basic.ip_proto = fl4->flowi4_proto;
 
 	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys),
-			  flow_keys_have_l4(&keys));
+			  flow_keys_have_l4(&keys) ?
+			  PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 
 	return skb->hash;
 }
-- 
2.1.4
