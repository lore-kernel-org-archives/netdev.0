From: Johannes Berg <johannes@sipsolutions.net>
Subject: [ARCHIVE] store skb allocation stacktrace in skb
Date: Sun, 04 May 2008 21:07:10 +0200
Message-ID: <1209928030.3655.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37601 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbYEDTHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 15:07:19 -0400
Received: from [91.5.67.65] (helo=[10.0.0.4])
	by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <johannes@sipsolutions.net>)
	id 1JsjXi-0005gt-JY
	for netdev@vger.kernel.org; Sun, 04 May 2008 21:06:38 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I needed this patch, so here it is for the archive just in case somebody
else needs some similar debugging feature in the future.

---
 include/linux/skbuff.h |   12 ++++++++++++
 kernel/stacktrace.c    |    3 +++
 net/Kconfig            |   12 ++++++++++++
 net/core/skbuff.c      |   30 ++++++++++++++++++++++++++++++
 4 files changed, 57 insertions(+)

--- everything.orig/include/linux/skbuff.h	2008-05-04 13:21:14.000000000 +0200
+++ everything/include/linux/skbuff.h	2008-05-04 13:22:41.000000000 +0200
@@ -28,6 +28,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/stacktrace.h>
 
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
@@ -188,6 +189,8 @@ enum {
 #define NET_SKBUFF_DATA_USES_OFFSET 1
 #endif
 
+#define NET_SKBUFF_STACKTRACE_ENTRIES	20
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 typedef unsigned int sk_buff_data_t;
 #else
@@ -245,6 +248,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
+ *	@stacktrace: allocation stack trace
+ *	@stacktracedata: allocation stack trace entries
  */
 
 struct sk_buff {
@@ -321,6 +326,11 @@ struct sk_buff {
 
 	__u32			mark;
 
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+	struct stack_trace	stacktrace;
+	unsigned long		stacktracedata[NET_SKBUFF_STACKTRACE_ENTRIES];
+#endif
+
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
@@ -341,6 +351,8 @@ struct sk_buff {
 
 #include <asm/system.h>
 
+extern void print_skb_alloc_trace(struct sk_buff *skb);
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
--- everything.orig/net/Kconfig	2008-05-04 13:21:14.000000000 +0200
+++ everything/net/Kconfig	2008-05-04 13:22:41.000000000 +0200
@@ -35,6 +35,18 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config SKBUFF_ALLOC_TRACE
+	bool "SKB allocation stack tracking"
+	depends on EXPERIMENTAL && STACKTRACE_SUPPORT
+	select STACKTRACE
+	help
+	  This option makes the skb allocation functions store a stack trace
+	  into an SKB when allocated so that later one can dump it if
+	  something is wrong with the SKB to find out where it came from.
+
+	  Say N unless you're debugging SKB problems and need this
+	  information, you can print the trace using print_skb_alloc_trace().
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
--- everything.orig/net/core/skbuff.c	2008-05-04 13:21:14.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-04 14:04:07.000000000 +0200
@@ -227,6 +227,13 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
 
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+	skb->stacktrace.max_entries = NET_SKBUFF_STACKTRACE_ENTRIES;
+	skb->stacktrace.entries = skb->stacktracedata;
+	skb->stacktrace.skip = 1;
+	save_stack_trace(&skb->stacktrace);
+#endif
+
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
@@ -244,6 +251,24 @@ nodata:
 	goto out;
 }
 
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+/**
+ * print_skb_alloc_trace - print skbuff allocation trace
+ * @skb: skb to print trace for
+ *
+ * This function prints the stacktrace from the location where
+ * the skb was allocated.
+ */
+void print_skb_alloc_trace(struct sk_buff *skb)
+{
+	if (WARN_ON(!skb))
+		return;
+
+	print_stack_trace(&skb->stacktrace, 0);
+}
+EXPORT_SYMBOL(print_skb_alloc_trace);
+#endif
+
 /**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
@@ -446,6 +471,11 @@ static void __copy_skb_header(struct sk_
 #endif
 #endif
 	skb_copy_secmark(new, old);
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+	memcpy(&new->stacktrace, &old->stacktrace, sizeof(old->stacktrace));
+	memcpy(&new->stacktracedata, &old->stacktracedata, sizeof(old->stacktracedata));
+	new->stacktrace.entries = new->stacktracedata;
+#endif
 }
 
 static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)


