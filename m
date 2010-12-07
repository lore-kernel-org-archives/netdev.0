From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: constify sk_run_filter()
Date: Tue, 07 Dec 2010 07:50:09 +0100
Message-ID: <1291704609.2769.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61224 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab0LGGuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 01:50:15 -0500
Received: by wwa36 with SMTP id 36so13777011wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Dec 2010 22:50:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_run_filter() doesnt write on skb, change its prototype to reflect
this.

Fix two af_packet comments.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/filter.h  |    2 +-
 net/core/filter.c       |    7 ++++---
 net/core/timestamping.c |    2 +-
 net/packet/af_packet.c  |   31 ++++++++++++++++---------------
 4 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 5334ada..45266b7 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -148,7 +148,7 @@ struct sk_buff;
 struct sock;
 
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
-extern unsigned int sk_run_filter(struct sk_buff *skb,
+extern unsigned int sk_run_filter(const struct sk_buff *skb,
 				  const struct sock_filter *filter);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
diff --git a/net/core/filter.c b/net/core/filter.c
index ac4920a..25500f1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -88,7 +88,7 @@ enum {
 };
 
 /* No hurry in this branch */
-static void *__load_pointer(struct sk_buff *skb, int k)
+static void *__load_pointer(const struct sk_buff *skb, int k)
 {
 	u8 *ptr = NULL;
 
@@ -102,7 +102,7 @@ static void *__load_pointer(struct sk_buff *skb, int k)
 	return NULL;
 }
 
-static inline void *load_pointer(struct sk_buff *skb, int k,
+static inline void *load_pointer(const struct sk_buff *skb, int k,
 				 unsigned int size, void *buffer)
 {
 	if (k >= 0)
@@ -160,7 +160,8 @@ EXPORT_SYMBOL(sk_filter);
  * and last instruction guaranteed to be a RET, we dont need to check
  * flen. (We used to pass to this function the length of filter)
  */
-unsigned int sk_run_filter(struct sk_buff *skb, const struct sock_filter *fentry)
+unsigned int sk_run_filter(const struct sk_buff *skb,
+			   const struct sock_filter *fentry)
 {
 	void *ptr;
 	u32 A = 0;			/* Accumulator */
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index dac7ed6..b124d28 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -26,7 +26,7 @@ static struct sock_filter ptp_filter[] = {
 	PTP_FILTER
 };
 
-static unsigned int classify(struct sk_buff *skb)
+static unsigned int classify(const struct sk_buff *skb)
 {
 	if (likely(skb->dev &&
 		   skb->dev->phydev &&
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a11c731..17eafe5 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -517,7 +517,8 @@ out_free:
 	return err;
 }
 
-static inline unsigned int run_filter(struct sk_buff *skb, struct sock *sk,
+static inline unsigned int run_filter(const struct sk_buff *skb,
+				      const struct sock *sk,
 				      unsigned int res)
 {
 	struct sk_filter *filter;
@@ -532,15 +533,15 @@ static inline unsigned int run_filter(struct sk_buff *skb, struct sock *sk,
 }
 
 /*
-   This function makes lazy skb cloning in hope that most of packets
-   are discarded by BPF.
-
-   Note tricky part: we DO mangle shared skb! skb->data, skb->len
-   and skb->cb are mangled. It works because (and until) packets
-   falling here are owned by current CPU. Output packets are cloned
-   by dev_queue_xmit_nit(), input packets are processed by net_bh
-   sequencially, so that if we return skb to original state on exit,
-   we will not harm anyone.
+ * This function makes lazy skb cloning in hope that most of packets
+ * are discarded by BPF.
+ *
+ * Note tricky part: we DO mangle shared skb! skb->data, skb->len
+ * and skb->cb are mangled. It works because (and until) packets
+ * falling here are owned by current CPU. Output packets are cloned
+ * by dev_queue_xmit_nit(), input packets are processed by net_bh
+ * sequencially, so that if we return skb to original state on exit,
+ * we will not harm anyone.
  */
 
 static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
@@ -566,11 +567,11 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	if (dev->header_ops) {
 		/* The device has an explicit notion of ll header,
-		   exported to higher levels.
-
-		   Otherwise, the device hides datails of it frame
-		   structure, so that corresponding packet head
-		   never delivered to user.
+		 * exported to higher levels.
+		 *
+		 * Otherwise, the device hides details of its frame
+		 * structure, so that corresponding packet head is
+		 * never delivered to user.
 		 */
 		if (sk->sk_type != SOCK_DGRAM)
 			skb_push(skb, skb->data - skb_mac_header(skb));


