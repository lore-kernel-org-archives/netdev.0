From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space
 data
Date: Wed, 10 Dec 2008 22:04:36 +0300
Message-ID: <494012C4.7090304@vlnb.net>
References: <494009D7.4020602@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org
To: linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:52156 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431AbYLJTEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 14:04:52 -0500
In-Reply-To: <494009D7.4020602@vlnb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for zero-copy TCP transmit of user space 
data. It is necessary in iSCSI-SCST target driver for transmitting data 
from user space buffers, supplied by user space backend handlers. In 
this case SCST core needs to know when TCP finished transmitting the 
data, so the corresponding buffers can be reused or freed. Without this 
patch it isn't possible, so iSCSI-SCST has to use data copying to TCP 
send buffers function sock_sendpage(). ISCSI-SCST also works without 
this patch, but that this patch gives a nice performance improvement.

In the chosen approach new optional field void *net_priv was added to 
struct page. It is enclosed by

#if defined(CONFIG_TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION),

so if one doesn't need this functionality, net_priv won't consume space 
in struct page.

Then, 2 new global callbacks net_get_page_callback and 
net_put_page_callback together with 2 new inline functions 
net_get_page() and net_put_page() were added. If 
CONFIG_TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION not defined 
net_get_page() and net_put_page() effectively become get_page() and 
put_page() correspondingly.

Those functions, if the corresponding net_get_page_callback or 
net_put_page_callback assigned, call it, then do get_page() or put_page().

Then in net/ subdirectory all get_page() calls were replaced by 
net_get_page() and put_page() - by net_put_page().

How it works. ISCSI-SCST assigns net_get_page_callback and 
net_put_page_callback to its internal functions. Each page before being 
sent to TCP's sendpage has net_priv field set to pointer to the 
corresponding iSCSI command. Then in each net_get_page_callback handler 
reference counter for that command increased and in each 
net_put_page_callback - decreased. When it reaches zero, then all the 
data for this command were transferred, so the command and its buffer 
can be freed.

You can find how it used in the iSCSI-SCST patch (number 21 in this series).

Global callbacks were chosen, because this is the simplest and most
performance effective approach, fully following section 2 subsection 4 
of SubmittingPatches file: "Don't over-design". If accepted, iSCSI-SCST 
will be the only user of this functionality. Requirements to call 
net_set_get_put_page_callbacks() (see comment in the patch) allows to 
not protect those callbacks anyhow. Then, if in the future there is 
another user of that functionality, it will be possible to convert those 
callbacks to RCU-protected list of callbacks. But for now there's no 
need to overcomplicate the code.

During development the following approaches were also examined and rejected:

1. Add net_priv analog in struct sk_buff, not in struct page. But then 
it would be required that all the pages in each skb must be from the 
same originator, i.e. with the same net_priv. It is unpractical to 
change all the operations with skb's to forbid merging them, if they 
have different net_priv. I tried, but quickly gave up. There are too 
many such places in very not obvious code pieces.

2. Have in iSCSI-SCST a hashed list to translate page to iSCSI cmd by a 
simple search function. This approach was rejected, because to copy a 
page a modern CPU needs using MMX about 1500 ticks. It was observed, 
that each page can be referenced by TCP during transmit about 20 times 
or even more. So, if each search needs, say, 20 ticks, the overall 
search time will be 20*20*2 (to get() and put()) = 800 ticks. So, this 
approach would considerably worse performance-wise to the chosen 
approach and provide not too much benefit.

Please, if you reject this approach, advice any other way to implement 
the required functionality.

Signed-off-by: Vladislav Bolkhovitin <vst@vlnb.net>
---
  include/linux/mm_types.h |   12 +++++++++++
  include/linux/net.h      |   40 ++++++++++++++++++++++++++++++++++++++
  net/Kconfig              |   12 +++++++++++
  net/core/skbuff.c        |   14 ++++++-------
  net/ipv4/Makefile        |    1
  net/ipv4/ip_output.c     |    4 +--
  net/ipv4/tcp.c           |    8 +++----
  net/ipv4/tcp_output.c    |    2 -
  net/ipv4/tcp_zero_copy.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++
  net/ipv6/ip6_output.c    |    2 -
  10 files changed, 129 insertions(+), 15 deletions(-)

diff -upr linux-2.6.26/include/linux/mm_types.h linux-2.6.26/include/linux/mm_types.h
--- linux-2.6.26/include/linux/mm_types.h	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/include/linux/mm_types.h	2008-07-22 20:30:21.000000000 +0400
@@ -92,6 +92,18 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
+
+#if defined(CONFIG_TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION)
+	/*
+	 * Used to implement support for notification on zero-copy TCP transfer
+	 * completion. It might look as not good to have this field here and
+	 * it's better to have it in struct sk_buff, but it would make the code
+	 * much more complicated and fragile, since all skb then would have to
+	 * contain only pages with the same value in this field.
+	 */
+	 void *net_priv;
+#endif
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	unsigned long page_cgroup;
 #endif
diff -upr linux-2.6.26/include/linux/net.h linux-2.6.26/include/linux/net.h
--- linux-2.6.26/include/linux/net.h	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/include/linux/net.h	2008-07-29 20:48:07.000000000 +0400
@@ -57,6 +57,7 @@ typedef enum {
 #include <linux/random.h>
 #include <linux/wait.h>
 #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
+#include <linux/mm.h>

 struct poll_table_struct;
 struct pipe_inode_info;
@@ -354,5 +354,44 @@ extern int net_msg_cost;
 extern struct ratelimit_state net_ratelimit_state;
 #endif

+#if defined(CONFIG_TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION)
+/* Support for notification on zero-copy TCP transfer completion */
+typedef void (*net_get_page_callback_t)(struct page *page);
+typedef void (*net_put_page_callback_t)(struct page *page);
+
+extern net_get_page_callback_t net_get_page_callback;
+extern net_put_page_callback_t net_put_page_callback;
+
+extern int net_set_get_put_page_callbacks(
+	net_get_page_callback_t get_callback,
+	net_put_page_callback_t put_callback);
+
+/*
+ * See comment for net_set_get_put_page_callbacks() why those functions
+ * don't need any protection.
+ */
+static inline void net_get_page(struct page *page)
+{
+	if (page->net_priv != 0)
+		net_get_page_callback(page);
+	get_page(page);
+}
+static inline void net_put_page(struct page *page)
+{
+	if (page->net_priv != 0)
+		net_put_page_callback(page);
+	put_page(page);
+}
+#else
+static inline void net_get_page(struct page *page)
+{
+	get_page(page);
+}
+static inline void net_put_page(struct page *page)
+{
+	put_page(page);
+}
+#endif /* CONFIG_TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION */
+
 #endif /* __KERNEL__ */
 #endif	/* _LINUX_NET_H */
diff -upr linux-2.6.26/net/core/skbuff.c linux-2.6.26/net/core/skbuff.c
--- linux-2.6.26/net/core/skbuff.c	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/net/core/skbuff.c	2008-07-22 20:28:41.000000000 +0400
@@ -319,7 +319,7 @@ static void skb_release_data(struct sk_b
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+				net_put_page(skb_shinfo(skb)->frags[i].page);
 		}
 
 		if (skb_shinfo(skb)->frag_list)
@@ -658,7 +658,7 @@ struct sk_buff *pskb_copy(struct sk_buff
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
-			get_page(skb_shinfo(n)->frags[i].page);
+			net_get_page(skb_shinfo(n)->frags[i].page);
 		}
 		skb_shinfo(n)->nr_frags = i;
 	}
@@ -721,7 +721,7 @@ int pskb_expand_head(struct sk_buff *skb
 	       sizeof(struct skb_shared_info));
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		get_page(skb_shinfo(skb)->frags[i].page);
+		net_get_page(skb_shinfo(skb)->frags[i].page);
 
 	if (skb_shinfo(skb)->frag_list)
 		skb_clone_fraglist(skb);
@@ -990,7 +990,7 @@ drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
 		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+			net_put_page(skb_shinfo(skb)->frags[i].page);
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
@@ -1159,7 +1159,7 @@ pull_pages:
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			net_put_page(skb_shinfo(skb)->frags[i].page);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -1916,7 +1916,7 @@ static inline void skb_split_no_header(s
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				net_get_page(skb_shinfo(skb)->frags[i].page);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
 				skb_shinfo(skb1)->frags[0].size -= len - pos;
 				skb_shinfo(skb)->frags[i].size	= len - pos;
@@ -2284,7 +2284,7 @@ struct sk_buff *skb_segment(struct sk_bu
 			BUG_ON(i >= nfrags);
 
 			*frag = skb_shinfo(skb)->frags[i];
-			get_page(frag->page);
+			net_get_page(frag->page);
 			size = frag->size;
 
 			if (pos < offset) {
diff -upr linux-2.6.26/net/ipv4/ip_output.c linux-2.6.26/net/ipv4/ip_output.c
--- linux-2.6.26/net/ipv4/ip_output.c	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/net/ipv4/ip_output.c	2008-07-22 20:28:41.000000000 +0400
@@ -1007,7 +1007,7 @@ alloc_new_skb:
 						err = -EMSGSIZE;
 						goto error;
 					}
-					get_page(page);
+					net_get_page(page);
 					skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
 					frag = &skb_shinfo(skb)->frags[i];
 				}
@@ -1165,7 +1165,7 @@ ssize_t	ip_append_page(struct sock *sk, 
 		if (skb_can_coalesce(skb, i, page, offset)) {
 			skb_shinfo(skb)->frags[i-1].size += len;
 		} else if (i < MAX_SKB_FRAGS) {
-			get_page(page);
+			net_get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, len);
 		} else {
 			err = -EMSGSIZE;
diff -upr linux-2.6.26/net/ipv4/Makefile linux-2.6.26/net/ipv4/Makefile
--- linux-2.6.26/net/ipv4/Makefile	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/net/ipv4/Makefile	2008-07-22 20:35:05.000000000 +0400
@@ -50,6 +50,7 @@ obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
+obj-$(CONFIG_TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION) += tcp_zero_copy.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff -upr linux-2.6.26/net/ipv4/tcp.c linux-2.6.26/net/ipv4/tcp.c
--- linux-2.6.26/net/ipv4/tcp.c	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/net/ipv4/tcp.c	2008-07-22 20:28:41.000000000 +0400
@@ -712,7 +712,7 @@ new_segment:
 		if (can_coalesce) {
 			skb_shinfo(skb)->frags[i - 1].size += copy;
 		} else {
-			get_page(page);
+			net_get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
 		}
 
@@ -917,7 +917,7 @@ new_segment:
 					goto new_segment;
 				} else if (page) {
 					if (off == PAGE_SIZE) {
-						put_page(page);
+						net_put_page(page);
 						TCP_PAGE(sk) = page = NULL;
 						off = 0;
 					}
@@ -958,9 +958,9 @@ new_segment:
 				} else {
 					skb_fill_page_desc(skb, i, page, off, copy);
 					if (TCP_PAGE(sk)) {
-						get_page(page);
+						net_get_page(page);
 					} else if (off + copy < PAGE_SIZE) {
-						get_page(page);
+						net_get_page(page);
 						TCP_PAGE(sk) = page;
 					}
 				}
diff -upr linux-2.6.26/net/ipv4/tcp_output.c linux-2.6.26/net/ipv4/tcp_output.c
--- linux-2.6.26/net/ipv4/tcp_output.c	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/net/ipv4/tcp_output.c	2008-07-22 20:28:41.000000000 +0400
@@ -854,7 +854,7 @@ static void __pskb_trim_head(struct sk_b
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			net_put_page(skb_shinfo(skb)->frags[i].page);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
diff -upr linux-2.6.26/net/ipv4/tcp_zero_copy.c linux-2.6.26/net/ipv4/tcp_zero_copy.c
--- linux-2.6.26/net/ipv4/tcp_zero_copy.c	2008-07-22 20:12:35.000000000 +0400
+++ linux-2.6.26/net/ipv4/tcp_zero_copy.c	2008-07-31 21:21:13.000000000 +0400
@@ -0,0 +1,49 @@
+/*
+ *	Support routines for TCP zero copy transmit
+ *
+ *	Created by Vladislav Bolkhovitin
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/skbuff.h>
+
+net_get_page_callback_t net_get_page_callback __read_mostly;
+EXPORT_SYMBOL(net_get_page_callback);
+
+net_put_page_callback_t net_put_page_callback __read_mostly;
+EXPORT_SYMBOL(net_put_page_callback);
+
+/*
+ * Caller of this function must ensure that at the moment when it's called
+ * there are no pages in the system with net_priv field set to non-zero
+ * value. Hence, this function, as well as net_get_page() and net_put_page(),
+ * don't need any protection.
+ */
+int net_set_get_put_page_callbacks(
+	net_get_page_callback_t get_callback,
+	net_put_page_callback_t put_callback)
+{
+	int res = 0;
+
+	if ((net_get_page_callback != NULL) && (get_callback != NULL) &&
+	    (net_get_page_callback != get_callback)) {
+		res = -EBUSY;
+		goto out;
+	}
+
+	if ((net_put_page_callback != NULL) && (put_callback != NULL) &&
+	    (net_put_page_callback != put_callback)) {
+		res = -EBUSY;
+		goto out;
+	}
+
+	net_get_page_callback = get_callback;
+	net_put_page_callback = put_callback;
+
+out:
+	return res;
+}
+EXPORT_SYMBOL(net_set_get_put_page_callbacks);
diff -upr linux-2.6.26/net/ipv6/ip6_output.c linux-2.6.26/net/ipv6/ip6_output.c
--- linux-2.6.26/net/ipv6/ip6_output.c	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/net/ipv6/ip6_output.c	2008-07-22 20:28:41.000000000 +0400
@@ -1349,7 +1349,7 @@ alloc_new_skb:
 						err = -EMSGSIZE;
 						goto error;
 					}
-					get_page(page);
+					net_get_page(page);
 					skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
 					frag = &skb_shinfo(skb)->frags[i];
 				}
diff -upr linux-2.6.26/net/Kconfig linux-2.6.26/net/Kconfig
--- linux-2.6.26/net/Kconfig	2008-07-14 01:51:29.000000000 +0400
+++ linux-2.6.26/net/Kconfig	2008-07-29 21:15:39.000000000 +0400
@@ -59,6 +59,18 @@ config INET
 
 	  Short answer: say Y.
 
+config TCP_ZERO_COPY_TRANSFER_COMPLETION_NOTIFICATION
+	bool "TCP/IP zero-copy transfer completion notification"
+        depends on INET
+        default SCST_ISCSI
+	---help---
+	  Adds support for sending a notification upon completion of a
+          zero-copy TCP/IP transfer. This can speed up certain TCP/IP
+          software. Currently this is only used by the iSCSI target driver
+          iSCSI-SCST.
+
+          If unsure, say N.
+
 if INET
 source "net/ipv4/Kconfig"
 source "net/ipv6/Kconfig"


