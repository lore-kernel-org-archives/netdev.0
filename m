From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [PATCH net-next] net: add skb allocation flags to __pskb_copy
Date: Sun,  8 Jun 2014 01:19:29 +0300
Message-ID: <1402179569-19394-1-git-send-email-octavian.purdila@intel.com>
Cc: christoph.paasch@uclouvain.be,
	Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27136 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbaFGWUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2014 18:20:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several instances where a __pskb_copy is immediately
followed by an skb_clone. Add a new parameter to __pskb_copy to allow
the skb to be allocated from the fclone cache and thus speed up
subsequent skb_clone calls.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/linux/skbuff.h   | 6 +++---
 net/bluetooth/hci_sock.c | 5 +++--
 net/core/skbuff.c        | 7 +++++--
 net/ipv4/tcp_output.c    | 2 +-
 net/nfc/llcp_core.c      | 2 +-
 net/nfc/rawsock.c        | 2 +-
 6 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c705808..7c5b56a 100644
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
@@ -2235,7 +2235,7 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
 static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
 					gfp_t gfp_mask)
 {
-	return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
+	return __pskb_copy(skb, skb_headroom(skb), gfp_mask, 0);
 }
 
 /**
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
index 05f4bef..03863be 100644
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
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d463c35..17fe18d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2490,7 +2490,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	if (unlikely((NET_IP_ALIGN && ((unsigned long)skb->data & 3)) ||
 		     skb_headroom(skb) >= 0xFFFF)) {
 		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
-						   GFP_ATOMIC);
+						   GFP_ATOMIC, 0);
 		err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
 			     -ENOBUFS;
 	} else {
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
 
-- 
1.8.3.2
