From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [PATCH v2] net: add skb allocation flags to pskb_copy
Date: Sun,  8 Jun 2014 23:56:18 +0300
Message-ID: <1402260978-28800-1-git-send-email-octavian.purdila@intel.com>
Cc: christoph.paasch@uclouvain.be,
	Octavian Purdila <octavian.purdila@intel.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Arvid Brodin <arvid.brodin@alten.se>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Eric Dumazet <edumazet
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24750 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711AbaFHU4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 16:56:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several instances where a pskb_copy or __pskb_copy is
immediately followed by an skb_clone. Add a new parameter to allow the
skb to be allocated from the fclone cache and thus speed up subsequent
skb_clone calls.

Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: Marek Lindner <mareklindner@neomailbox.ch>
Cc: Simon Wunderlich <sw@simonwunderlich.de>
Cc: Antonio Quartulli <antonio@meshcoding.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Cc: Arvid Brodin <arvid.brodin@alten.se>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Cc: Andrew Hendry <andrew.hendry@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 drivers/net/ieee802154/fakelb.c        | 2 +-
 include/linux/skbuff.h                 | 8 ++++----
 net/batman-adv/distributed-arp-table.c | 2 +-
 net/batman-adv/network-coding.c        | 2 +-
 net/bluetooth/hci_sock.c               | 5 +++--
 net/core/skbuff.c                      | 9 ++++++---
 net/hsr/hsr_device.c                   | 2 +-
 net/hsr/hsr_main.c                     | 2 +-
 net/ipv4/tcp_output.c                  | 6 +++---
 net/netfilter/xt_TEE.c                 | 4 ++--
 net/nfc/llcp_core.c                    | 2 +-
 net/nfc/rawsock.c                      | 2 +-
 net/tipc/bcast.c                       | 2 +-
 net/x25/x25_forward.c                  | 4 ++--
 14 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ieee802154/fakelb.c b/drivers/net/ieee802154/fakelb.c
index 27d8320..6579fd5 100644
--- a/drivers/net/ieee802154/fakelb.c
+++ b/drivers/net/ieee802154/fakelb.c
@@ -77,7 +77,7 @@ fakelb_hw_deliver(struct fakelb_dev_priv *priv, struct sk_buff *skb)
 
 	spin_lock(&priv->lock);
 	if (priv->working) {
-		newskb = pskb_copy(skb, GFP_ATOMIC);
+		newskb = pskb_copy(skb, GFP_ATOMIC, 0);
 		ieee802154_rx_irqsafe(priv->dev, newskb, 0xcc);
 	}
 	spin_unlock(&priv->lock);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c705808..5d4d341 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -744,8 +744,8 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
 struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t priority);
 struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t priority);
-struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask);
-
+struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask,
+			    int flags);
 int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail, gfp_t gfp_mask);
 struct sk_buff *skb_realloc_headroom(struct sk_buff *skb,
 				     unsigned int headroom);
@@ -2233,9 +2233,9 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
 }
 
 static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
-					gfp_t gfp_mask)
+					gfp_t gfp_mask, int flags)
 {
-	return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
+	return __pskb_copy(skb, skb_headroom(skb), gfp_mask, flags);
 }
 
 /**
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index dcd99b2..a8fa7f8 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -594,7 +594,7 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 		if (!neigh_node)
 			goto free_orig;
 
-		tmp_skb = pskb_copy(skb, GFP_ATOMIC);
+		tmp_skb = pskb_copy(skb, GFP_ATOMIC, SKB_ALLOC_FCLONE);
 		if (!batadv_send_skb_prepare_unicast_4addr(bat_priv, tmp_skb,
 							   cand[i].orig_node,
 							   packet_subtype)) {
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 40a2fc4..79032f8 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1344,7 +1344,7 @@ static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_priv,
 	struct ethhdr *ethhdr;
 
 	/* Copy skb header to change the mac header */
-	skb = pskb_copy(skb, GFP_ATOMIC);
+	skb = pskb_copy(skb, GFP_ATOMIC, SKB_ALLOC_FCLONE);
 	if (!skb)
 		return;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index f608bff..c2f5db3 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -143,7 +143,8 @@ void hci_send_to_sock(struct hci_dev *hdev, struct sk_buff *skb)
 
 		if (!skb_copy) {
 			/* Create a private copy with headroom */
-			skb_copy = __pskb_copy(skb, 1, GFP_ATOMIC);
+			skb_copy = __pskb_copy(skb, 1, GFP_ATOMIC,
+					       SKB_ALLOC_FCLONE);
 			if (!skb_copy)
 				continue;
 
@@ -248,7 +249,7 @@ void hci_send_to_monitor(struct hci_dev *hdev, struct sk_buff *skb)
 
 			/* Create a private copy with headroom */
 			skb_copy = __pskb_copy(skb, HCI_MON_HDR_SIZE,
-					       GFP_ATOMIC);
+					       GFP_ATOMIC, SKB_ALLOC_FCLONE);
 			if (!skb_copy)
 				continue;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 05f4bef..30d55b3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -955,6 +955,7 @@ EXPORT_SYMBOL(skb_copy);
  *	@skb: buffer to copy
  *	@headroom: headroom of new skb
  *	@gfp_mask: allocation priority
+ *	@flags: skb allocation flags (e.g. SKB_ALLOC_FCLONE)
  *
  *	Make a copy of both an &sk_buff and part of its data, located
  *	in header. Fragmented data remain shared. This is used when
@@ -964,11 +965,13 @@ EXPORT_SYMBOL(skb_copy);
  *	The returned buffer has a reference count of 1.
  */
 
-struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
+struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask,
+			    int flags)
 {
 	unsigned int size = skb_headlen(skb) + headroom;
 	struct sk_buff *n = __alloc_skb(size, gfp_mask,
-					skb_alloc_rx_flag(skb), NUMA_NO_NODE);
+					flags | skb_alloc_rx_flag(skb),
+					NUMA_NO_NODE);
 
 	if (!n)
 		goto out;
@@ -1111,7 +1114,7 @@ struct sk_buff *skb_realloc_headroom(struct sk_buff *skb, unsigned int headroom)
 	int delta = headroom - skb_headroom(skb);
 
 	if (delta <= 0)
-		skb2 = pskb_copy(skb, GFP_ATOMIC);
+		skb2 = pskb_copy(skb, GFP_ATOMIC, 0);
 	else {
 		skb2 = skb_clone(skb, GFP_ATOMIC);
 		if (skb2 && pskb_expand_head(skb2, SKB_DATA_ALIGN(delta), 0,
diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index e5302b7..ff30ba3 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -231,7 +231,7 @@ static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb->protocol = htons(ETH_P_PRP);
 	}
 
-	skb2 = pskb_copy(skb, GFP_ATOMIC);
+	skb2 = pskb_copy(skb, GFP_ATOMIC, 0);
 
 	res1 = NET_XMIT_DROP;
 	if (likely(hsr_priv->slave[HSR_DEV_SLAVE_A]))
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index 3fee521..ff5331c 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -365,7 +365,7 @@ static int hsr_rcv(struct sk_buff *skb, struct net_device *dev,
 		/* skb_clone() is not enough since we will strip the hsr tag
 		 * and do address substitution below
 		 */
-		skb_deliver = pskb_copy(skb, GFP_ATOMIC);
+		skb_deliver = pskb_copy(skb, GFP_ATOMIC, 0);
 		if (!skb_deliver) {
 			deliver_to_self = false;
 			hsr_priv->dev->stats.rx_dropped++;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d463c35..eab68f4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -881,7 +881,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		skb_mstamp_get(&skb->skb_mstamp);
 
 		if (unlikely(skb_cloned(skb)))
-			skb = pskb_copy(skb, gfp_mask);
+			skb = pskb_copy(skb, gfp_mask, 0);
 		else
 			skb = skb_clone(skb, gfp_mask);
 		if (unlikely(!skb))
@@ -2490,7 +2490,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	if (unlikely((NET_IP_ALIGN && ((unsigned long)skb->data & 3)) ||
 		     skb_headroom(skb) >= 0xFFFF)) {
 		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
-						   GFP_ATOMIC);
+						   GFP_ATOMIC, 0);
 		err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
 			     -ENOBUFS;
 	} else {
@@ -3009,7 +3009,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	}
 
 	/* Queue a data-only packet after the regular SYN for retransmission */
-	data = pskb_copy(syn_data, sk->sk_allocation);
+	data = pskb_copy(syn_data, sk->sk_allocation, 0);
 	if (data == NULL)
 		goto fallback;
 	TCP_SKB_CB(data)->seq++;
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 292934d..19bf330 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -96,7 +96,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	 * happened. The copy should be independently delivered to the TEE
 	 * --gateway.
 	 */
-	skb = pskb_copy(skb, GFP_ATOMIC);
+	skb = pskb_copy(skb, GFP_ATOMIC, 0);
 	if (skb == NULL)
 		return XT_CONTINUE;
 
@@ -171,7 +171,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 
 	if (__this_cpu_read(tee_active))
 		return XT_CONTINUE;
-	skb = pskb_copy(skb, GFP_ATOMIC);
+	skb = pskb_copy(skb, GFP_ATOMIC, 0);
 	if (skb == NULL)
 		return XT_CONTINUE;
 
diff --git a/net/nfc/llcp_core.c b/net/nfc/llcp_core.c
index f6278da..df960a3 100644
--- a/net/nfc/llcp_core.c
+++ b/net/nfc/llcp_core.c
@@ -681,7 +681,7 @@ void nfc_llcp_send_to_raw_sock(struct nfc_llcp_local *local,
 
 		if (skb_copy == NULL) {
 			skb_copy = __pskb_copy(skb, NFC_RAW_HEADER_SIZE,
-					       GFP_ATOMIC);
+					       GFP_ATOMIC, SKB_ALLOC_FCLONE);
 
 			if (skb_copy == NULL)
 				continue;
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 55eefee..e8c1805 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -379,7 +379,7 @@ void nfc_send_to_raw_sock(struct nfc_dev *dev, struct sk_buff *skb,
 	sk_for_each(sk, &raw_sk_list.head) {
 		if (!skb_copy) {
 			skb_copy = __pskb_copy(skb, NFC_RAW_HEADER_SIZE,
-				     GFP_ATOMIC);
+					       GFP_ATOMIC, SKB_ALLOC_FCLONE);
 			if (!skb_copy)
 				continue;
 
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 671f981..b02641f 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -653,7 +653,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 			tipc_bearer_send(b->identity, buf, &b->bcast_addr);
 		} else {
 			/* Avoid concurrent buffer access */
-			tbuf = pskb_copy(buf, GFP_ATOMIC);
+			tbuf = pskb_copy(buf, GFP_ATOMIC, SKB_ALLOC_FCLONE);
 			if (!tbuf)
 				break;
 			tipc_bearer_send(b->identity, tbuf, &b->bcast_addr);
diff --git a/net/x25/x25_forward.c b/net/x25/x25_forward.c
index cf561f1..892ad05 100644
--- a/net/x25/x25_forward.c
+++ b/net/x25/x25_forward.c
@@ -121,10 +121,10 @@ int x25_forward_data(int lci, struct x25_neigh *from, struct sk_buff *skb) {
 	if ( (nb = x25_get_neigh(peer)) == NULL)
 		goto out;
 
-	if ( (skbn = pskb_copy(skb, GFP_ATOMIC)) == NULL){
+	skbn = pskb_copy(skb, GFP_ATOMIC, 0);
+	if (skbn == NULL)
 		goto output;
 
-	}
 	x25_transmit_link(skbn, nb);
 
 	rc = 1;
-- 
1.8.3.2
