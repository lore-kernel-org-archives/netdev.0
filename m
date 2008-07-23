From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 01:01:02 +0300
Message-ID: <1216850464-30000-2-git-send-email-opurdila@ixiacom.com>
References: <1216850464-30000-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1937 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750799AbYGWWDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:03:30 -0400
In-Reply-To: <1216850464-30000-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces per skb control messages that can be used to
directly exchange information between the application and the
hardware, at a per packet level. Examples of usecases are: RX/TX
hardware timestamps, TX scheduling (request hardware to send packets
at a future time).

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/linux/skbuff.h |   62 +++++++++++++++++++++++++
 include/linux/socket.h |    1 +
 include/net/sock.h     |    2 +
 net/core/skbuff.c      |  118 +++++++++++++++++++++++++++++++++++++++++++++++-
 net/core/sock.c        |   46 +++++++++++++++++++
 5 files changed, 227 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f24d261..f2988d1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -135,6 +135,17 @@ struct skb_frag_struct {
 	__u32 size;
 };
 
+/*
+ * Control message queue; used to exchange additional information between the
+ * application and hardware (e.g. RX/TX hardware timestamps, TX scheduling,
+ * etc.)
+ */
+struct skb_cmsg {
+	struct skb_cmsg *next;
+	int type, len;
+	char data[0];
+};
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -148,6 +159,7 @@ struct skb_shared_info {
 	__be32          ip6_frag_id;
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
+	struct skb_cmsg *cmsg;
 };
 
 /* We divide dataref into two halves.  The higher 16 bits hold references
@@ -1719,5 +1731,55 @@ static inline void skb_forward_csum(struct sk_buff *skb)
 }
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
+
+
+#define skb_cmsg_queue(skb) (skb_shinfo(skb)->cmsg)
+
+/**
+ * skb_cmsg_for_each - iterate over a control message list
+ * @i: the loop cursor (a struct skb_cmsg *)
+ * @head: the head (a struct skb_cmsg **)
+ */
+#define skb_cmsg_for_each(i, head) for (i = *head; i != NULL; \
+				       i = i->next)
+
+void skb_cmsg_free(struct skb_cmsg *head);
+
+struct skb_cmsg *skb_cmsg_alloc(int type, int len, int gfp);
+
+/**
+ * skb_add_cmsg - add a new control message to a list
+ * @head - head of the list
+ * @sc - the control message
+ *
+ * This function should only be called from:
+ * - the device driver, before sending the skb up the network stack
+ * - the higher levels of the network stack, before sending the skb down the
+ * network stack
+ *
+ * Because of these conventions, no synchonization is needed on the cmsg queue
+ * of the skb.
+ */
+static inline void skb_cmsg_add(struct skb_cmsg **head, struct skb_cmsg *sc)
+{
+	sc->next = (*head)->next;
+	*head = sc;
+}
+
+int __skb_cmsg_send(struct skb_cmsg **head, struct msghdr *msg);
+
+/**
+ * skb_cmsg_send - appends the skb control messages sent by the
+ * application to an skb
+ * @msg: the message header passed by the application
+ * @skb: the skb to append the control messages to
+ */
+static inline int skb_cmsg_send(struct sk_buff *skb, struct msghdr *msg)
+{
+	return __skb_cmsg_send(&skb_cmsg_queue(skb), msg);
+}
+
+void skb_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index bd2b30a..21687a7 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -293,6 +293,7 @@ struct ucred {
 #define SOL_RXRPC	272
 #define SOL_PPPOL2TP	273
 #define SOL_BLUETOOTH	274
+#define SOL_SKB         275
 
 /* IPX options */
 #define IPX_TYPE	1
diff --git a/include/net/sock.h b/include/net/sock.h
index dc42b44..8cc7598 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1365,4 +1365,6 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+int sock_queue_skb_cmsg(struct sk_buff *skb, struct skb_cmsg *sc, int clone);
+
 #endif	/* _SOCK_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 61f3d1f..6426ee9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -220,6 +220,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
+	shinfo->cmsg = NULL;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -313,6 +314,48 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 		skb_get(list);
 }
 
+/*
+ * FIXME: Do we need a full copy, or is it ok to just prune the control message
+ * list for copied skb?
+ */
+static struct sk_buff *skb_cmsg_copy(struct sk_buff *skb, int gfp)
+{
+#if 0
+	struct skb_cmsg *i, *head = NULL;
+
+	skb_cmsg_for_each(i, skb_cmsg_queue(skb)) {
+		struct skb_cmsg *sc = skb_cmsg_alloc(i->type, i->len, gfp);
+
+		if (!sc)
+			goto abort;
+
+		memcpy(sc->data, i->data, i->len);
+		skb_cmsg_add(&head, sc);
+	}
+
+	skb_cmsg_queue(skb) = head;
+
+	return skb;
+
+abort:
+	skb_cmsg_free(head);
+	dev_kfree_skb_any(skb);
+	return NULL;
+#else
+	skb_cmsg_queue(skb) = NULL;
+	return skb;
+#endif
+}
+
+void skb_cmsg_free(struct skb_cmsg *i)
+{
+	while (i) {
+		struct skb_cmsg *sc = i;
+		i = i->next;
+		kfree(sc);
+	}
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
@@ -328,6 +371,8 @@ static void skb_release_data(struct sk_buff *skb)
 			skb_drop_fraglist(skb);
 
 		kfree(skb->head);
+
+		skb_cmsg_free(skb_cmsg_queue(skb));
 	}
 }
 
@@ -567,6 +612,8 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
 	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
+
+	skb_shinfo(new)->cmsg = skb_shinfo(old)->cmsg;
 }
 
 /**
@@ -610,7 +657,8 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 		BUG();
 
 	copy_skb_header(n, skb);
-	return n;
+
+	return skb_cmsg_copy(n, gfp_mask);
 }
 
 
@@ -835,7 +883,7 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	n->mac_header	    += off;
 #endif
 
-	return n;
+	return skb_cmsg_copy(n, gfp_mask);
 }
 
 /**
@@ -2594,6 +2642,72 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
 	return true;
 }
 
+/**
+ * skb_cmsg_recv - copies the control messages from an skb to the
+ * application
+ * @msg: the message header passed by the application
+ * @skb: the skb
+ *
+ * Control messages are freed when we free the skb.
+ */
+void skb_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
+{
+	struct skb_cmsg *sc = skb_shinfo(skb)->cmsg;
+
+	while (sc) {
+		put_cmsg(msg, SOL_SKB, sc->type, sc->len, sc->data);
+		sc = sc->next;
+	}
+}
+EXPORT_SYMBOL(skb_cmsg_recv);
+
+/**
+ * __skb_cmsg_recv - appends the skb control messages sent by the
+ * application to a control message list
+ * @msg: the message header passed by the application
+ * @head: the head of the list to append the control messages to
+ *
+ */
+int __skb_cmsg_send(struct skb_cmsg **head, struct msghdr *msg)
+{
+	struct cmsghdr *cmsg;
+
+	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+		int len;
+		struct skb_cmsg *sc;
+
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+		if (cmsg->cmsg_level != SOL_SKB)
+			continue;
+		len = cmsg->cmsg_len - sizeof(struct cmsghdr);
+
+		sc = skb_cmsg_alloc(cmsg->cmsg_type, len, GFP_KERNEL);
+		if (!sc)
+			return -ENOMEM;
+		memcpy(sc->data, CMSG_DATA(cmsg), len);
+
+		skb_cmsg_add(head, sc);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(__skb_cmsg_send);
+
+struct skb_cmsg *skb_cmsg_alloc(int type, int len, int gfp)
+{
+	struct skb_cmsg *sc = kmalloc(sizeof(*sc) + len, gfp);
+
+	if (!sc)
+		return NULL;
+
+	sc->type = type;
+	sc->len = len;
+
+	return sc;
+}
+EXPORT_SYMBOL(skb_cmsg_alloc);
+
 EXPORT_SYMBOL(___pskb_trim);
 EXPORT_SYMBOL(__kfree_skb);
 EXPORT_SYMBOL(kfree_skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 88094cb..8a63898 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -307,6 +307,52 @@ out:
 }
 EXPORT_SYMBOL(sock_queue_rcv_skb);
 
+/**
+ * sock_queue_skb_cmsg - queue a cloned or empty skb together with a list of
+ * control messages to the error socket of a given skb
+ * @skb: the skb for which the control messages are being send
+ * @sc: a control message list to be sent
+ * @clone: whether the control messages will be transported with an empty skb
+ * or with a clone of the original skb
+ *
+ * This function can be used to get post-send skb control messages to the
+ * application (e.g. TX timestamps).
+ *
+ * Control messages of the original skb will be deleted, the driver and stack
+ * should read them before calling this function.
+ */
+int sock_queue_skb_cmsg(struct sk_buff *skb, struct skb_cmsg *sc, int clone)
+{
+	struct sock *sk = skb->sk;
+	struct sk_buff *n;
+	int err = -ENOMEM;
+
+	if (!sk)
+		return -ENOTSOCK;
+
+	if (clone) {
+		n = skb_clone(skb, GFP_ATOMIC);
+		skb_cmsg_free(skb_cmsg_queue(skb));
+	} else {
+		n = dev_alloc_skb(0);
+		skb_reset_network_header(n);
+		skb_reset_transport_header(n);
+	}
+
+	if (!n)
+		return err;
+
+	n->dev = NULL;
+	skb_cmsg_add(&skb_cmsg_queue(n), sc);
+
+	err = sock_queue_err_skb(sk, n);
+	if (err)
+		kfree_skb(n);
+
+	return err;
+}
+EXPORT_SYMBOL(sock_queue_skb_cmsg);
+
 int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
 {
 	int rc = NET_RX_SUCCESS;
-- 
1.5.6.2

