From: Archie Cobbs <archie@precisionio.com>
Subject: [PATCH] sk_buff's allocated from private pools
Date: Wed, 19 Mar 2003 14:08:34 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303192208.h2JM8Yx1037110@bubba.precisionio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Archie Cobbs <archie@precisionio.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I'm submitting this patch for inclusion in the Linux kernel if deemed
generally useful.

The purpose of this patch is to add a new function called alloc_skb_custom()
(or whatever) that allows the data portion of an sk_buff to reside in any
memory region, not just a region returned by kmalloc(). For example, if a
networking device has a restriction on where receive buffers may reside,
then the device driver can avoid copying every incoming packet if it is
able to create an sk_buff that points to the receive buffer memory.

Basically this amounts to adding a 'free_data' function pointer to the
sk_buff structure. By default this points to kfree() but in general could
point to anywhere.

FYI FreeBSD has had equivalent functionality in its 'struct mbuf' for
many years (I'm also a FreeBSD developer).

Thanks for your review.

Cheers,
-Archie

__________________________________________________________________________
Archie Cobbs     *     Precision I/O      *     http://www.precisionio.com

Index: include/linux/skbuff.h
===================================================================
RCS file: /home/cvs/linux-2.4.20/include/linux/skbuff.h,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -u -r1.1.1.1 -r1.2
--- include/linux/skbuff.h	3 Jan 2003 22:31:40 -0000	1.1.1.1
+++ include/linux/skbuff.h	15 Mar 2003 01:13:35 -0000	1.2
@@ -193,6 +193,7 @@
 	unsigned char	*tail;			/* Tail pointer					*/
 	unsigned char 	*end;			/* End pointer					*/
 
+	void 		(*free_data)(const void *);		/* Free data buffer function	*/
 	void 		(*destructor)(struct sk_buff *);	/* Destruct function		*/
 #ifdef CONFIG_NETFILTER
 	/* Can be used for communication between hooks. */
@@ -230,6 +231,8 @@
 
 extern void			__kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *		alloc_skb(unsigned int size, int priority);
+extern struct sk_buff *		alloc_skb_custom(unsigned int size, int priority,
+					void (*free_data)(const void *), u8 *data);
 extern void			kfree_skbmem(struct sk_buff *skb);
 extern struct sk_buff *		skb_clone(struct sk_buff *skb, int priority);
 extern struct sk_buff *		skb_copy(const struct sk_buff *skb, int priority);
Index: net/netsyms.c
===================================================================
RCS file: /home/cvs/linux-2.4.20/net/netsyms.c,v
retrieving revision 1.1.1.1
retrieving revision 1.2
diff -u -r1.1.1.1 -r1.2
--- net/netsyms.c	3 Jan 2003 22:31:42 -0000	1.1.1.1
+++ net/netsyms.c	15 Mar 2003 01:13:35 -0000	1.2
@@ -489,6 +489,7 @@
 EXPORT_SYMBOL(eth_copy_and_sum);
 #endif
 EXPORT_SYMBOL(alloc_skb);
+EXPORT_SYMBOL(alloc_skb_custom);
 EXPORT_SYMBOL(__kfree_skb);
 EXPORT_SYMBOL(skb_clone);
 EXPORT_SYMBOL(skb_copy);
Index: net/core/skbuff.c
===================================================================
RCS file: /home/cvs/linux-2.4.20/net/core/skbuff.c,v
retrieving revision 1.1
retrieving revision 1.3
diff -u -r1.1 -r1.3
--- net/core/skbuff.c	7 Jan 2003 00:35:25 -0000	1.1
+++ net/core/skbuff.c	18 Mar 2003 23:14:54 -0000	1.3
@@ -149,7 +149,7 @@
  */
 
 /**
- *	alloc_skb	-	allocate a network buffer
+ *	alloc_skb	-	allocate a network buffer using kmalloc
  *	@size: size to allocate
  *	@gfp_mask: allocation mask
  *
@@ -169,8 +169,46 @@
 	if (in_interrupt() && (gfp_mask & __GFP_WAIT)) {
 		static int count = 0;
 		if (++count < 5) {
-			printk(KERN_ERR "alloc_skb called nonatomically "
-			       "from interrupt %p\n", NET_CALLER(size));
+			printk(KERN_ERR "%s called nonatomically from "
+			       "interrupt %p\n", "alloc_skb", NET_CALLER(size));
+ 			BUG();
+		}
+		gfp_mask &= ~__GFP_WAIT;
+	}
+
+	/* Get the DATA. Size must match skb_add_mtu(). */
+	size = SKB_DATA_ALIGN(size);
+	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	if (data == NULL)
+		return NULL;
+
+	/* Allocate the rest of the skb */
+	if ((skb = alloc_skb_custom(size, gfp_mask, kfree, data)) == NULL)
+		kfree(data);
+
+	/* Done */
+	return skb;
+}
+
+/**
+ *	alloc_skb_custom	-	allocate a network buffer
+ *					using the supplied data area
+ *
+ *	This assumes that size is aligned via SKB_DATA_ALIGN(), and
+ *	that 'data' points to size + sizeof(struct skb_shared_info)
+ *	bytes.
+ */
+ 
+struct sk_buff *alloc_skb_custom(unsigned int size, int gfp_mask,
+	void (*free_data)(const void *), u8 *data)
+{
+	struct sk_buff *skb;
+
+	if (in_interrupt() && (gfp_mask & __GFP_WAIT)) {
+		static int count = 0;
+		if (++count < 5) {
+			printk(KERN_ERR "%s called nonatomically from "
+			       "interrupt %p\n", "alloc_skb_custom", NET_CALLER(size));
  			BUG();
 		}
 		gfp_mask &= ~__GFP_WAIT;
@@ -184,11 +222,9 @@
 			goto nohead;
 	}
 
-	/* Get the DATA. Size must match skb_add_mtu(). */
-	size = SKB_DATA_ALIGN(size);
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
-	if (data == NULL)
-		goto nodata;
+	/* Size must match skb_add_mtu(). */
+	if (size != SKB_DATA_ALIGN(size))
+		BUG();
 
 	/* XXX: does not include slab overhead */ 
 	skb->truesize = size + sizeof(struct sk_buff);
@@ -198,6 +234,7 @@
 	skb->data = data;
 	skb->tail = data;
 	skb->end = data + size;
+	skb->free_data = free_data;
 
 	/* Set up other state */
 	skb->len = 0;
@@ -210,8 +247,6 @@
 	skb_shinfo(skb)->frag_list = NULL;
 	return skb;
 
-nodata:
-	skb_head_to_pool(skb);
 nohead:
 	return NULL;
 }
@@ -285,7 +320,10 @@
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
-		kfree(skb->head);
+		if (skb->free_data == NULL)
+			BUG();
+		(*skb->free_data)(skb->head);
+		skb->free_data = NULL;
 	}
 }
 
@@ -384,6 +422,7 @@
 	C(tail);
 	C(end);
 	n->destructor = NULL;
+	C(free_data);
 #ifdef CONFIG_NETFILTER
 	C(nfmark);
 	C(nfcache);
@@ -520,6 +559,7 @@
 
 	skb->head = data;
 	skb->end  = data + size;
+	skb->free_data = kfree;
 
 	/* Set up new pointers */
 	skb->h.raw += offset;
@@ -647,6 +687,7 @@
 
 	skb->head = data;
 	skb->end  = data+size;
+	skb->free_data = kfree;
 
 	skb->data += off;
 	skb->tail += off;
