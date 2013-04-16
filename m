From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 1/3] skb: wrap skb_shared_info->destructor_arg access
 with set and get functions
Date: Tue, 16 Apr 2013 16:39:11 -0400
Message-ID: <20130416203911.10474.86849.stgit@localhost>
References: <20130416202437.10474.45713.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965164Ab3DPUjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 16:39:14 -0400
In-Reply-To: <20130416202437.10474.45713.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Abstract away direct access to the "destructor_arg" field in the
skb_shared_info struct via skb_destructor_arg_{set,get}() which is
defined as a static inline in include/linux/skbuff.h.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 drivers/net/macvtap.c  |    2 +-
 drivers/net/tun.c      |    2 +-
 include/linux/skbuff.h |   19 +++++++++++++++++++
 net/core/skbuff.c      |    6 +++---
 net/packet/af_packet.c |    4 ++--
 5 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a449439..8179df0 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -729,7 +729,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	vlan = rcu_dereference_bh(q->vlan);
 	/* copy skb_ubuf_info for callback when skb has no error */
 	if (zerocopy) {
-		skb_shinfo(skb)->destructor_arg = m->msg_control;
+		skb_destructor_arg_set(skb, m->msg_control);
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	}
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b7c457a..3cea09d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1199,7 +1199,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 
 	/* copy skb_ubuf_info for callback when skb has no error */
 	if (zerocopy) {
-		skb_shinfo(skb)->destructor_arg = msg_control;
+		skb_destructor_arg_set(skb, msg_control);
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	}
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b8292d8..0998af3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -696,6 +696,25 @@ static inline unsigned int skb_end_offset(const struct sk_buff *skb)
 /* Internal */
 #define skb_shinfo(SKB)	((struct skb_shared_info *)(skb_end_pointer(SKB)))
 
+/**
+ *	skb_destructor_arg_set - set the packet's destructor argument
+ *	@skb: packet
+ *	@ptr: pointer to the destructor argument
+ */
+static inline void skb_destructor_arg_set(struct sk_buff *skb, void *ptr)
+{
+	skb_shinfo(skb)->destructor_arg = ptr;
+}
+
+/**
+ *	skb_destructor_arg_get - return the packet's destructor argument
+ *	@skb: packet
+ */
+static inline void *skb_destructor_arg_get(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->destructor_arg;
+}
+
 static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
 {
 	return &skb_shinfo(skb)->hwtstamps;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 33245ef..e4fa549 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -506,7 +506,7 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 			struct ubuf_info *uarg;
 
-			uarg = skb_shinfo(skb)->destructor_arg;
+			uarg = skb_destructor_arg_get(skb);
 			if (uarg->callback)
 				uarg->callback(uarg, true);
 		}
@@ -635,7 +635,7 @@ void skb_tx_error(struct sk_buff *skb)
 	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 		struct ubuf_info *uarg;
 
-		uarg = skb_shinfo(skb)->destructor_arg;
+		uarg = skb_destructor_arg_get(skb);
 		if (uarg->callback)
 			uarg->callback(uarg, false);
 		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
@@ -782,7 +782,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	int i;
 	int num_frags = skb_shinfo(skb)->nr_frags;
 	struct page *page, *head = NULL;
-	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
+	struct ubuf_info *uarg = skb_destructor_arg_get(skb);
 
 	for (i = 0; i < num_frags; i++) {
 		u8 *vaddr;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1d6793d..32f186b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1833,7 +1833,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 	void *ph;
 
 	if (likely(po->tx_ring.pg_vec)) {
-		ph = skb_shinfo(skb)->destructor_arg;
+		ph = skb_destructor_arg_get(skb);
 		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
 		atomic_dec(&po->tx_ring.pending);
 		__packet_set_status(po, ph, TP_STATUS_AVAILABLE);
@@ -1863,7 +1863,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
-	skb_shinfo(skb)->destructor_arg = ph.raw;
+	skb_destructor_arg_set(skb, ph.raw);
 
 	switch (po->tp_version) {
 	case TPACKET_V2:
