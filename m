From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 2/9] irda: stack should call irda_get_skb_cb()
Date: Mon, 15 Dec 2008 02:57:31 +0100
Message-ID: <20081215015857.180881820@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:49968 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751436AbYLOCDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:07 -0500
Content-Disposition: inline; filename=0002-irda-stack-should-call-irda_get_skb_cb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of accessing the irda_skb_cb directly, the stack callers should
use the irda_get_skb_cb() routine.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/net/irda/irda_device.h |    8 ++++----
 net/irda/ircomm/ircomm_lmp.c   |    4 ++--
 net/irda/irlap_frame.c         |    4 +++-
 net/irda/wrapper.c             |    4 +++-
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 305eb05..3bbf695 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -244,7 +244,7 @@ static inline struct irda_skb_cb *irda_get_skb_cb(struct sk_buff *skb)
  */
 static inline __u16 irda_get_mtt(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->head;
 	return (cb->magic == LAP_MAGIC) ? cb->mtt : 10000;
 }
 
@@ -257,7 +257,7 @@ static inline __u16 irda_get_mtt(const struct sk_buff *skb)
  */
 static inline __u32 irda_get_next_speed(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->head;
 	return (cb->magic == LAP_MAGIC) ? cb->next_speed : -1;
 }
 
@@ -270,7 +270,7 @@ static inline __u32 irda_get_next_speed(const struct sk_buff *skb)
  */
 static inline __u16 irda_get_xbofs(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->head;
 	return (cb->magic == LAP_MAGIC) ? cb->xbofs : 10;
 }
 
@@ -283,7 +283,7 @@ static inline __u16 irda_get_xbofs(const struct sk_buff *skb)
  */
 static inline __u16 irda_get_next_xbofs(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->head;
 	return (cb->magic == LAP_MAGIC) ? cb->next_xbofs : -1;
 }
 #endif /* IRDA_DEVICE_H */
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 407bad3..c463bec 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -146,7 +146,7 @@ static void ircomm_lmp_flow_control(struct sk_buff *skb)
 
 	IRDA_ASSERT(skb != NULL, return;);
 
-	cb = (struct irda_skb_cb *) skb->cb;
+	cb = irda_get_skb_cb(skb);
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
@@ -187,7 +187,7 @@ static int ircomm_lmp_data_request(struct ircomm_cb *self,
 
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	cb = (struct irda_skb_cb *) skb->cb;
+	cb = irda_get_skb_cb(skb);
 
 	cb->line = self->line;
 
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index bf41ebf..8760af6 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -56,7 +56,9 @@ static void irlap_send_i_frame(struct irlap_cb *self, struct sk_buff *skb,
 static inline void irlap_insert_info(struct irlap_cb *self,
 				     struct sk_buff *skb)
 {
-	struct irda_skb_cb *cb = (struct irda_skb_cb *) skb->cb;
+	struct irda_skb_cb *cb;
+
+	cb = irda_get_skb_cb(skb);
 
 	/*
 	 * Insert MTT (min. turn time) and speed into skb, so that the
diff --git a/net/irda/wrapper.c b/net/irda/wrapper.c
index fd0995b..b13cb3b 100644
--- a/net/irda/wrapper.c
+++ b/net/irda/wrapper.c
@@ -82,7 +82,7 @@ static inline int stuff_byte(__u8 byte, __u8 *buf)
  */
 int async_wrap_skb(struct sk_buff *skb, __u8 *tx_buff, int buffsize)
 {
-	struct irda_skb_cb *cb = (struct irda_skb_cb *) skb->cb;
+	struct irda_skb_cb *cb;
 	int xbofs;
 	int i;
 	int n;
@@ -91,6 +91,8 @@ int async_wrap_skb(struct sk_buff *skb, __u8 *tx_buff, int buffsize)
 		__u8 bytes[2];
 	} fcs;
 
+	cb = irda_get_skb_cb(skb);
+
 	/* Initialize variables */
 	fcs.value = INIT_FCS;
 	n = 0;
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
