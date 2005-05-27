From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5] [NET] Add skb_find_text() to search for a text pattern in skbs
Date: Sat, 28 May 2005 00:48:58 +0200
Message-ID: <20050527224858.GK15391@postel.suug.ch>
References: <20050527224725.GG15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050527224725.GG15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Adds the function skb_find_text() to search for text patterns
in both, linear and non-linear skbs.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 4fdcfba0bf99efed709bc8ebaeda0d5ed7e9cc67
tree 13ce1cd98014267f2a353b96e813c1e70bbe9c3b
parent 81553cdea2a7ff762cb44aeced743d3a77efd2d7
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:44:50 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 23:44:50 +0200

 include/linux/skbuff.h |    4 ++
 net/core/skbuff.c      |   83 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 87 insertions(+)

Index: include/linux/skbuff.h
===================================================================
--- 266c4ad512e5ae71bd7cd88c94bfb18fb2f761d6/include/linux/skbuff.h  (mode:100644)
+++ 13ce1cd98014267f2a353b96e813c1e70bbe9c3b/include/linux/skbuff.h  (mode:100644)
@@ -28,6 +28,7 @@
 #include <linux/poll.h>
 #include <linux/net.h>
 #include <net/checksum.h>
+#include <linux/textsearch.h>
 
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
@@ -1187,6 +1188,9 @@
 extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
 
+extern int skb_find_text(struct sk_buff *skb, int from, int to,
+			 struct ts_config *config, struct ts_state *state);
+
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
 {
Index: net/core/skbuff.c
===================================================================
--- 266c4ad512e5ae71bd7cd88c94bfb18fb2f761d6/net/core/skbuff.c  (mode:100644)
+++ 13ce1cd98014267f2a353b96e813c1e70bbe9c3b/net/core/skbuff.c  (mode:100644)
@@ -1506,6 +1506,88 @@
 		skb_split_no_header(skb, skb1, len, pos);
 }
 
+static int get_skb_text(int offset, unsigned char **text,
+			struct ts_config *conf, struct ts_state *state)
+{
+	/* args[0]: lower limit
+	 * args[1]: upper limit
+	 * args[2]: skb
+	 * args[3]: fragment index
+	 * args[4]: current fragment data buffer
+	 * args[5]: octets consumed up to previous fragment */
+	int from = state->args[0], to = state->args[1];
+	struct sk_buff *skb = (struct sk_buff *) state->args[2];
+	int limit = min_t(int, skb_headlen(skb), to);
+	int real_offset = offset + from;
+	skb_frag_t *f;
+
+	if (!skb_is_nonlinear(skb)) {
+		if (real_offset < limit) {
+linear:
+			*text = skb->data + real_offset;
+			return limit - real_offset;
+		}
+
+		return 0;
+	}
+
+	if (real_offset < limit)
+		goto linear;
+
+next_fragment:
+	f = &skb_shinfo(skb)->frags[state->args[3]];
+	limit = min_t(int, f->size + state->args[5], to);
+
+	if (!state->args[4])
+		state->args[4] = (long) kmap_skb_frag(f);
+
+	if (real_offset < limit) {
+		*text = (unsigned char *) state->args[4] + f->page_offset +
+			(real_offset - (int) state->args[5]);
+		return limit - real_offset;
+	}
+
+	kunmap_skb_frag((void *) state->args[4]);
+	state->args[3]++;
+	state->args[4] = (long) NULL;
+	state->args[5] += f->size;
+
+	if (state->args[3] >= skb_shinfo(skb)->nr_frags)
+		return 0;
+
+	goto next_fragment;
+}
+
+static void get_skb_text_finish(struct ts_config *conf, struct ts_state *state)
+{
+	if (state->args[4])
+		kunmap_skb_frag((void *) state->args[4]);
+}
+
+/**
+ * skb_find_text - Find a text pattern in skb data
+ * @skb: the buffer to look in
+ * @from: search offset
+ * @to: search limit
+ * @config: textsearch configuration
+ * @state: empty textsearch state variable
+ */
+int skb_find_text(struct sk_buff *skb, int from, int to,
+		  struct ts_config *config, struct ts_state *state)
+{
+	config->get_text = get_skb_text;
+	config->finish = get_skb_text_finish;
+	state->args[0] = from;
+	state->args[1] = to;
+	state->args[2] = (long) skb;
+	state->args[3] = 0;
+	state->args[4] = 0;
+	state->args[5] = skb_headlen(skb);
+
+	return textsearch_find(config, state);
+}
+
+
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
@@ -1544,3 +1626,4 @@
 EXPORT_SYMBOL(skb_unlink);
 EXPORT_SYMBOL(skb_append);
 EXPORT_SYMBOL(skb_split);
+EXPORT_SYMBOL(skb_find_text);
