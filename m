From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] remove dead skb_iter code
Date: Wed, 2 Mar 2005 10:10:35 -0800
Message-ID: <20050302101035.61786113@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The code iterate over skb_frags is defined but not used by any
existing kernel code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2005-03-02 10:13:14 -08:00
+++ b/include/linux/skbuff.h	2005-03-02 10:13:14 -08:00
@@ -1118,22 +1118,6 @@
 extern void skb_init(void);
 extern void skb_add_mtu(int mtu);
 
-struct skb_iter {
-	/* Iteration functions set these */
-	unsigned char *data;
-	unsigned int len;
-
-	/* Private to iteration */
-	unsigned int nextfrag;
-	struct sk_buff *fraglist;
-};
-
-/* Keep iterating until skb_iter_next returns false. */
-extern void skb_iter_first(const struct sk_buff *skb, struct skb_iter *i);
-extern int skb_iter_next(const struct sk_buff *skb, struct skb_iter *i);
-/* Call this if aborting loop before !skb_iter_next */
-extern void skb_iter_abort(const struct sk_buff *skb, struct skb_iter *i);
-
 #ifdef CONFIG_NETFILTER
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
 {
diff -Nru a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c	2005-03-02 10:13:14 -08:00
+++ b/net/core/skbuff.c	2005-03-02 10:13:14 -08:00
@@ -982,70 +982,6 @@
 	return -EFAULT;
 }
 
-/* Keep iterating until skb_iter_next returns false. */
-void skb_iter_first(const struct sk_buff *skb, struct skb_iter *i)
-{
-	i->len = skb_headlen(skb);
-	i->data = (unsigned char *)skb->data;
-	i->nextfrag = 0;
-	i->fraglist = NULL;
-}
-
-int skb_iter_next(const struct sk_buff *skb, struct skb_iter *i)
-{
-	/* Unmap previous, if not head fragment. */
-	if (i->nextfrag)
-		kunmap_skb_frag(i->data);
-
-	if (i->fraglist) {
-	fraglist:
-		/* We're iterating through fraglist. */
-		if (i->nextfrag < skb_shinfo(i->fraglist)->nr_frags) {
-			i->data = kmap_skb_frag(&skb_shinfo(i->fraglist)
-						->frags[i->nextfrag]);
-			i->len = skb_shinfo(i->fraglist)->frags[i->nextfrag]
-				.size;
-			i->nextfrag++;
-			return 1;
-		}
-		/* Fragments with fragments?  Too hard! */
-		BUG_ON(skb_shinfo(i->fraglist)->frag_list);
-		i->fraglist = i->fraglist->next;
-		if (!i->fraglist)
-			goto end;
-
-		i->len = skb_headlen(i->fraglist);
-		i->data = i->fraglist->data;
-		i->nextfrag = 0;
-		return 1;
-	}
-
-	if (i->nextfrag < skb_shinfo(skb)->nr_frags) {
-		i->data = kmap_skb_frag(&skb_shinfo(skb)->frags[i->nextfrag]);
-		i->len = skb_shinfo(skb)->frags[i->nextfrag].size;
-		i->nextfrag++;
-		return 1;
-	}
-
-	i->fraglist = skb_shinfo(skb)->frag_list;
-	if (i->fraglist)
-		goto fraglist;
-
-end:
-	/* Bug trap for callers */
-	i->data = NULL;
-	return 0;
-}
-
-void skb_iter_abort(const struct sk_buff *skb, struct skb_iter *i)
-{
-	/* Unmap previous, if not head fragment. */
-	if (i->data && i->nextfrag)
-		kunmap_skb_frag(i->data);
-	/* Bug trap for callers */
-	i->data = NULL;
-}
-
 /* Checksum skb data. */
 
 unsigned int skb_checksum(const struct sk_buff *skb, int offset,
@@ -1516,6 +1452,3 @@
 EXPORT_SYMBOL(skb_unlink);
 EXPORT_SYMBOL(skb_append);
 EXPORT_SYMBOL(skb_split);
-EXPORT_SYMBOL(skb_iter_first);
-EXPORT_SYMBOL(skb_iter_next);
-EXPORT_SYMBOL(skb_iter_abort);
