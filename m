From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [PATCH net-next v4] net: add __pskb_copy_fclone and pskb_copy_for_clone
Date: Thu, 12 Jun 2014 00:41:27 +0300
Message-ID: <1402522887-10600-1-git-send-email-octavian.purdila@intel.com>
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
Received: from mga01.intel.com ([192.55.52.88]:53635 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbaFKVll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 17:41:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several instances where a pskb_copy or __pskb_copy is
immediately followed by an skb_clone.

Add a couple of new functions to allow the copy skb to be allocated
from the fclone cache and thus speed up subsequent skb_clone calls.

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
Reviewed-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
Changes since v3:
 * As suggested by David and Dave add new functions to keep the
   existing signatures unchanged and avoid unnecessary changes  

Changes since v2:
 * As suggested by Dave, use a bool instead of directly exposing the
   internal allocation flags


Changes since v1:
 * add new parameter to pskb_copy as well, as suggested by Christoph

 include/linux/skbuff.h                 | 18 ++++++++++++++++--
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/network-coding.c        |  2 +-
 net/bluetooth/hci_sock.c               |  6 +++---
 net/core/skbuff.c                      | 14 +++++++++-----
 net/nfc/llcp_core.c                    |  4 ++--
 net/nfc/rawsock.c                      |  4 ++--
 net/tipc/bcast.c                       |  2 +-
 8 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c705808..db756a0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -744,7 +744,13 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
 struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t priority);
 struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t priority);
-struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask);
+struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
+				   gfp_t gfp_mask, bool fclone);
+static inline struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom,
+					  gfp_t gfp_mask)
+{
+	return __pskb_copy_fclone(skb, headroom, gfp_mask, false);
+}
 
 int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail, gfp_t gfp_mask);
 struct sk_buff *skb_realloc_headroom(struct sk_buff *skb,
@@ -2235,9 +2241,17 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
 static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
 					gfp_t gfp_mask)
 {
-	return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
+	return __pskb_copy_fclone(skb, skb_headroom(skb), gfp_mask, false);
 }
 
+
+static inline struct sk_buff *pskb_copy_for_clone(struct sk_buff *skb,
+						  gfp_t gfp_mask)
+{
+	return __pskb_copy_fclone(skb, skb_headroom(skb), gfp_mask, true);
+}
+
+
 /**
  *	skb_clone_writable - is the header of a clone writable
  *	@skb: buffer to check
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index dcd99b2..f2c066b 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -594,7 +594,7 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 		if (!neigh_node)
 			goto free_orig;
 
-		tmp_skb = pskb_copy(skb, GFP_ATOMIC);
+		tmp_skb = pskb_copy_for_clone(skb, GFP_ATOMIC);
 		if (!batadv_send_skb_prepare_unicast_4addr(bat_priv, tmp_skb,
 							   cand[i].orig_node,
 							   packet_subtype)) {
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 40a2fc4..8d04d17 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1344,7 +1344,7 @@ static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_priv,
 	struct ethhdr *ethhdr;
 
 	/* Copy skb header to change the mac header */
-	skb = pskb_copy(skb, GFP_ATOMIC);
+	skb = pskb_copy_for_clone(skb, GFP_ATOMIC);
 	if (!skb)
 		return;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index f608bff..80d25c1 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -143,7 +143,7 @@ void hci_send_to_sock(struct hci_dev *hdev, struct sk_buff *skb)
 
 		if (!skb_copy) {
 			/* Create a private copy with headroom */
-			skb_copy = __pskb_copy(skb, 1, GFP_ATOMIC);
+			skb_copy = __pskb_copy_fclone(skb, 1, GFP_ATOMIC, true);
 			if (!skb_copy)
 				continue;
 
@@ -247,8 +247,8 @@ void hci_send_to_monitor(struct hci_dev *hdev, struct sk_buff *skb)
 			struct hci_mon_hdr *hdr;
 
 			/* Create a private copy with headroom */
-			skb_copy = __pskb_copy(skb, HCI_MON_HDR_SIZE,
-					       GFP_ATOMIC);
+			skb_copy = __pskb_copy_fclone(skb, HCI_MON_HDR_SIZE,
+						      GFP_ATOMIC, true);
 			if (!skb_copy)
 				continue;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 05f4bef..b9e85e6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -951,10 +951,13 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 EXPORT_SYMBOL(skb_copy);
 
 /**
- *	__pskb_copy	-	create copy of an sk_buff with private head.
+ *	__pskb_copy_fclone	-  create copy of an sk_buff with private head.
  *	@skb: buffer to copy
  *	@headroom: headroom of new skb
  *	@gfp_mask: allocation priority
+ *	@fclone: if true allocate the copy of the skb from the fclone
+ *	cache instead of the head cache; it is recommended to set this
+ *	to true for the cases where the copy will likely be cloned
  *
  *	Make a copy of both an &sk_buff and part of its data, located
  *	in header. Fragmented data remain shared. This is used when
@@ -964,11 +967,12 @@ EXPORT_SYMBOL(skb_copy);
  *	The returned buffer has a reference count of 1.
  */
 
-struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
+struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
+				   gfp_t gfp_mask, bool fclone)
 {
 	unsigned int size = skb_headlen(skb) + headroom;
-	struct sk_buff *n = __alloc_skb(size, gfp_mask,
-					skb_alloc_rx_flag(skb), NUMA_NO_NODE);
+	int flags = skb_alloc_rx_flag(skb) | (fclone ? SKB_ALLOC_FCLONE : 0);
+	struct sk_buff *n = __alloc_skb(size, gfp_mask, flags, NUMA_NO_NODE);
 
 	if (!n)
 		goto out;
@@ -1008,7 +1012,7 @@ struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask)
 out:
 	return n;
 }
-EXPORT_SYMBOL(__pskb_copy);
+EXPORT_SYMBOL(__pskb_copy_fclone);
 
 /**
  *	pskb_expand_head - reallocate header of &sk_buff
diff --git a/net/nfc/llcp_core.c b/net/nfc/llcp_core.c
index f6278da..51e7887 100644
--- a/net/nfc/llcp_core.c
+++ b/net/nfc/llcp_core.c
@@ -680,8 +680,8 @@ void nfc_llcp_send_to_raw_sock(struct nfc_llcp_local *local,
 			continue;
 
 		if (skb_copy == NULL) {
-			skb_copy = __pskb_copy(skb, NFC_RAW_HEADER_SIZE,
-					       GFP_ATOMIC);
+			skb_copy = __pskb_copy_fclone(skb, NFC_RAW_HEADER_SIZE,
+						      GFP_ATOMIC, true);
 
 			if (skb_copy == NULL)
 				continue;
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 55eefee..11c3544 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -378,8 +378,8 @@ void nfc_send_to_raw_sock(struct nfc_dev *dev, struct sk_buff *skb,
 
 	sk_for_each(sk, &raw_sk_list.head) {
 		if (!skb_copy) {
-			skb_copy = __pskb_copy(skb, NFC_RAW_HEADER_SIZE,
-				     GFP_ATOMIC);
+			skb_copy = __pskb_copy_fclone(skb, NFC_RAW_HEADER_SIZE,
+						      GFP_ATOMIC, true);
 			if (!skb_copy)
 				continue;
 
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 671f981..2663167 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -653,7 +653,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 			tipc_bearer_send(b->identity, buf, &b->bcast_addr);
 		} else {
 			/* Avoid concurrent buffer access */
-			tbuf = pskb_copy(buf, GFP_ATOMIC);
+			tbuf = pskb_copy_for_clone(buf, GFP_ATOMIC);
 			if (!tbuf)
 				break;
 			tipc_bearer_send(b->identity, tbuf, &b->bcast_addr);
-- 
1.8.3.2
