From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/T] [NET] give truesize warning when truesize differs
Date: Mon, 05 May 2008 00:09:04 +0200
Message-ID: <1209938944.3981.4.camel@johannes.berg>
References: <1209924728.3655.7.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40473 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758285AbYEDWJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 18:09:20 -0400
In-Reply-To: <1209924728.3655.7.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-05-04 at 20:12 +0200, Johannes Berg wrote:
> This patch makes the truesize warning be printed when the truesize
> actually changed, not just when the header was increased and the
> additional size actually used.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> It'll trigger with mac80211, should hold it until I fixed that.

With all the patches I posted it now no longer triggers with mac80211
but within netlink, e.g.:

[  152.607800] SKB BUG: Invalid truesize (556) size=560, sizeof(sk_buff)=272
[  152.607805] last reallocate at:
[  152.607807]  [<00000000>] 0x0
[  152.607822]  [<c02735ec>] pskb_expand_head+0xa4/0x1f8
[  152.607828]  [<c0296a9c>] netlink_broadcast+0xb0/0x42c
[  152.607834]  [<c0297680>] nlmsg_notify+0x4c/0xc8
[  152.607838]  [<c0287518>] rtnl_notify+0x30/0x40
[  152.607843]  [<c0320e68>] wireless_nlevent_process+0x28/0x60
[  152.607851]  [<c0035058>] tasklet_action+0x74/0xec
[  152.607858]  [<c0035964>] __do_softirq+0x8c/0xfc
[  152.607863]  [<c0006e40>] do_softirq+0x58/0x5c
[  152.607869]  [<c0035738>] ksoftirqd+0x7c/0x178
[  152.607874]  [<c0047944>] kthread+0x50/0x88
[  152.607879]  [<c0012310>] kernel_thread+0x44/0x60


below patch helps debug it, but I can't fix it all right now.

It most likely is a consequence of pskb_expand_head() not updating
truesize and some, but not all, callers doing it. IMHO pskb_expand_head
should do it and those callers that do it be changed to not (afaik it's
afpacket or something and mac80211 now)

johannes

---
 include/linux/skbuff.h |   12 ++++++++++++
 kernel/stacktrace.c    |    3 +++
 net/Kconfig            |   12 ++++++++++++
 net/core/skbuff.c      |   37 +++++++++++++++++++++++++++++++++++++
 4 files changed, 64 insertions(+)

--- everything.orig/include/linux/skbuff.h	2008-05-04 23:31:31.000000000 +0200
+++ everything/include/linux/skbuff.h	2008-05-04 23:35:21.000000000 +0200
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
--- everything.orig/net/Kconfig	2008-05-04 23:31:31.000000000 +0200
+++ everything/net/Kconfig	2008-05-04 23:35:21.000000000 +0200
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
--- everything.orig/net/core/skbuff.c	2008-05-04 23:31:32.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-04 23:37:08.000000000 +0200
@@ -160,6 +160,8 @@ void skb_truesize_bug(struct sk_buff *sk
 	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
 	       "size=%u, sizeof(sk_buff)=%Zd\n",
 	       skb->truesize, len, sizeof(struct sk_buff));
+	printk(KERN_DEBUG "last reallocate at:\n");
+	print_skb_alloc_trace(skb);
 }
 EXPORT_SYMBOL(skb_truesize_bug);
 
@@ -227,6 +229,13 @@ struct sk_buff *__alloc_skb(unsigned int
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
@@ -244,6 +253,24 @@ nodata:
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
@@ -446,6 +473,11 @@ static void __copy_skb_header(struct sk_
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
@@ -693,6 +725,11 @@ int pskb_expand_head(struct sk_buff *skb
 
 	WARN_ON((nhead || ntail) && skb->sk);
 
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+	skb->stacktrace.max_entries = NET_SKBUFF_STACKTRACE_ENTRIES;
+	skb->stacktrace.nr_entries = 0;
+	save_stack_trace(&skb->stacktrace);
+#endif
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void. */
 #ifdef NET_SKBUFF_DATA_USES_OFFSET


