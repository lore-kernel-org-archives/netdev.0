From: Johannes Berg <johannes@sipsolutions.net>
Subject: [DEBUG] truesize debugging
Date: Tue, 06 May 2008 17:03:15 +0200
Message-ID: <1210086195.13316.37.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46590 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbYEFPD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 11:03:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I was digging into the truesize stuff and discussed with Herbert he
mentioned that we should really check the actual allocation size...

I have a number of questions and sort of todo items, but not really all
that much interest right now in pursuing them, so here they are:

     1. why is sizeof(skb_shared_info) not accounted?
     2. why do you think it's bad when somebody increases the skb size a
        bit and uses the space (as indicated by the truesize bug print)
        but not when the space is not used? The networking stack
        *explicitly* allocates more space than would be necessary in
        some places to avoid future expansions, but doesn't account for
        that either. No truesize bugs are currently logged for that if
        the space never ends up getting used (so since we don't see
        truesize bugs I guess that optimisation to expand by at least
        128 bytes sometimes is useless?)
     3. why does pskb_expand_head not change truesize? right now, unless
        the extra space isn't really used, I can't see how to use it at
        all even on an skb that isn't accounted to a socket if that skb
        can later ever be accounted to a socket.
     4. the truesize debugging printout is pretty useless. maybe a patch
        like the one below should be shipped in mainline that one can
        optionally turn on when running into the problem frequently.

The patch below changes the truesize check to be more accurate and makes
the code print out a stacktrace from the last place the skb was
allocated, cloned or head-expanded.

johannes

---
 include/linux/skbuff.h |   20 ++++++++++++++++++--
 net/Kconfig            |    9 +++++++++
 net/core/skbuff.c      |   34 ++++++++++++++++++++++++++++++++--
 3 files changed, 59 insertions(+), 4 deletions(-)

--- everything.orig/include/linux/skbuff.h	2008-05-06 16:40:40.000000000 +0200
+++ everything/include/linux/skbuff.h	2008-05-06 16:43:08.000000000 +0200
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
 
+#define NET_SKBUFF_STACKTRACE_ENTRIES	10
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
@@ -387,9 +397,15 @@ extern void	      skb_truesize_bug(struc
 
 static inline void skb_truesize_check(struct sk_buff *skb)
 {
-	int len = sizeof(struct sk_buff) + skb->len;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	int len = skb->end;
+#else
+	int len = (skb->end - skb->head);
+#endif
+
+	len += sizeof(struct sk_buff) + skb->data_len;
 
-	if (unlikely((int)skb->truesize < len))
+	if (unlikely((int)skb->truesize != len))
 		skb_truesize_bug(skb);
 }
 
--- everything.orig/net/core/skbuff.c	2008-05-06 16:40:40.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-06 17:02:07.000000000 +0200
@@ -151,9 +151,21 @@ void skb_under_panic(struct sk_buff *skb
 
 void skb_truesize_bug(struct sk_buff *skb)
 {
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	int len = skb->end;
+#else
+	int len = (skb->end - skb->head);
+#endif
+
+	len += sizeof(struct sk_buff) + skb->data_len;
+
 	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
-	       "len=%u, sizeof(sk_buff)=%Zd\n",
-	       skb->truesize, skb->len, sizeof(struct sk_buff));
+	       "size=%u, sizeof(sk_buff)=%Zd\n",
+	       skb->truesize, len, sizeof(struct sk_buff));
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+	printk(KERN_DEBUG "last reallocate at:\n");
+	print_stack_trace(&skb->stacktrace, 0);
+#endif
 }
 EXPORT_SYMBOL(skb_truesize_bug);
 
@@ -219,6 +231,13 @@ struct sk_buff *__alloc_skb(unsigned int
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
@@ -438,6 +457,12 @@ static void __copy_skb_header(struct sk_
 #endif
 #endif
 	skb_copy_secmark(new, old);
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+	new->stacktrace.max_entries = NET_SKBUFF_STACKTRACE_ENTRIES;
+	new->stacktrace.entries = new->stacktracedata;
+	new->stacktrace.skip = 1;
+	save_stack_trace(&new->stacktrace);
+#endif
 }
 
 static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
@@ -683,6 +708,11 @@ int pskb_expand_head(struct sk_buff *skb
 	if (!data)
 		goto nodata;
 
+#ifdef CONFIG_SKBUFF_ALLOC_TRACE
+	skb->stacktrace.max_entries = NET_SKBUFF_STACKTRACE_ENTRIES;
+	skb->stacktrace.nr_entries = 0;
+	save_stack_trace(&skb->stacktrace);
+#endif
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void. */
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
--- everything.orig/net/Kconfig	2008-05-06 16:40:40.000000000 +0200
+++ everything/net/Kconfig	2008-05-06 16:46:23.000000000 +0200
@@ -35,6 +35,15 @@ config NET_NS
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
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"


