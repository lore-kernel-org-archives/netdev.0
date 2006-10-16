From: Eric Barton <eeb@bartonsoftware.com>
Subject: PATCH zero-copy send completion callback
Date: Mon, 16 Oct 2006 18:25:22 +0100
Message-ID: <200610161725.k9GHPMMT022244@robert.bartonsoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out2.blueyonder.co.uk ([195.188.213.5]:52947 "EHLO
	smtp-out2.blueyonder.co.uk") by vger.kernel.org with ESMTP
	id S1750775AbWJPRZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 13:25:26 -0400
Received: from [172.23.170.142] (helo=anti-virus02-09)
	by smtp-out2.blueyonder.co.uk with smtp (Exim 4.52)
	id 1GZWDN-0004n5-Iw
	for netdev@vger.kernel.org; Mon, 16 Oct 2006 18:25:25 +0100
Received: from [82.32.9.64] (helo=robert.bartonsoftware.com)
	by asmtp-out3.blueyonder.co.uk with esmtpa (Exim 4.52)
	id 1GZWDL-0008C6-87
	for netdev@vger.kernel.org; Mon, 16 Oct 2006 18:25:23 +0100
Received: from robert.bartonsoftware.com (localhost.localdomain [127.0.0.1])
	by robert.bartonsoftware.com (8.13.1/8.13.1) with ESMTP id k9GHPMg7022247
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 18:25:22 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch has been used with the lustre cluster file system (www.lustre.org)
to give notification when page buffers used to send bulk data via TCP/IP may be
overwritten.  It implements...

  a) A general-purpose callback to inform higher-level protocols when a
     zero-copy send of a set of pages has completed.

  b) tcp_sendpage_zccd(), a variation on tcp_sendpage() that includes a
     completion callback parameter.

How to use it ("you" are a higher-level protocol driver)...

  a) Initialise a zero-copy descriptor with your callback procedure.

  b) Pass this descriptor in all zero-copy sends for an arbitrary set of pages.
     Skbuffs that reference your pages also take a reference on your zero-copy
     callback descriptor.  They release this reference when they release their
     page references.

  c) Release your own reference when you've posted all your pages and you're
     ready for the callback.

  d) The callback occurs when the last reference is dropped.


This patch applies on branch 'master' of
git://kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6

================================================================================
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85577a4..4afaef1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -129,6 +129,36 @@ struct skb_frag_struct {
 	__u16 size;
 };
 
+/* Zero Copy Callback Descriptor
+ * This struct supports receiving notification when zero-copy network I/O has
+ * completed.  The ZCCD can be embedded in a struct containing the state of a
+ * zero-copy network send.  Every skbuff that references that send's pages also
+ * keeps a reference on the ZCCD.  When they have all been disposed of, the
+ * reference count on the ZCCD drops to zero and the callback is made, telling
+ * the original caller that the pages may now be overwritten. */
+struct zccd 
+{
+	atomic_t	 zccd_refcount;
+	void           (*zccd_callback)(struct zccd *); 
+};
+
+static inline void zccd_init (struct zccd *d, void (*callback)(struct zccd *))
+{
+	atomic_set (&d->zccd_refcount, 1);
+	d->zccd_callback = callback;
+}
+
+static inline void zccd_incref (struct zccd *d)	/* take a reference */
+{
+	atomic_inc (&d->zccd_refcount);
+}
+
+static inline void zccd_decref (struct zccd *d)	/* release a reference */
+{
+	if (atomic_dec_and_test (&d->zccd_refcount))
+		(d->zccd_callback)(d);
+}
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -141,6 +171,11 @@ struct skb_shared_info {
 	unsigned short  gso_type;
 	unsigned int    ip6_frag_id;
 	struct sk_buff	*frag_list;
+	struct zccd     *zccd1;
+	struct zccd     *zccd2;
+	/* NB zero-copy data is normally whole pages.  We have 2 zccds in an
+	 * skbuff so we don't unneccessarily split the packet where pages fall
+	 * into the same packet. */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
 
@@ -1311,6 +1346,23 @@ #ifdef CONFIG_HIGHMEM
 #endif
 }
 
+/* This skbuf has dropped its pages: drop refs on any zero-copy callback
+ * descriptors it has. */
+static inline void skb_complete_zccd (struct sk_buff *skb)
+{
+	struct skb_shared_info *info = skb_shinfo(skb);
+	
+	if (info->zccd1 != NULL) {
+		zccd_decref(info->zccd1);
+		info->zccd1 = NULL;
+	}
+
+	if (info->zccd2 != NULL) {
+		zccd_decref(info->zccd2);
+		info->zccd2 = NULL;
+	}
+}
+
 #define skb_queue_walk(queue, skb) \
 		for (skb = (queue)->next;					\
 		     prefetch(skb->next), (skb != (struct sk_buff *)(queue));	\
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7a093d0..e02b55f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -278,6 +278,8 @@ extern int		    	tcp_v4_tw_remember_stam
 extern int			tcp_sendmsg(struct kiocb *iocb, struct sock *sk,
 					    struct msghdr *msg, size_t size);
 extern ssize_t			tcp_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags);
+extern ssize_t			tcp_sendpage_zccd(struct socket *sock, struct page *page, int offset, size_t size,
+						  int flags, struct zccd *zccd);
 
 extern int			tcp_ioctl(struct sock *sk, 
 					  int cmd, 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3c23760..a1d2ed0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -177,6 +177,8 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
+	shinfo->zccd1 = NULL;
+	shinfo->zccd2 = NULL;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -242,6 +244,8 @@ struct sk_buff *alloc_skb_from_cache(kme
 	skb_shinfo(skb)->gso_segs = 0;
 	skb_shinfo(skb)->gso_type = 0;
 	skb_shinfo(skb)->frag_list = NULL;
+	skb_shinfo(skb)->zccd1 = NULL;
+	skb_shinfo(skb)->zccd2 = NULL;
 out:
 	return skb;
 nodata:
@@ -307,6 +311,9 @@ static void skb_release_data(struct sk_b
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
+		/* complete zero-copy callbacks (if any) */
+		skb_complete_zccd(skb);
+
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
@@ -650,6 +657,18 @@ struct sk_buff *pskb_copy(struct sk_buff
 			get_page(skb_shinfo(n)->frags[i].page);
 		}
 		skb_shinfo(n)->nr_frags = i;
+
+		if (skb_shinfo(skb)->zccd1 != NULL) {
+			BUG_TRAP(skb_shinfo(n)->zccd1 == NULL);
+			skb_shinfo(n)->zccd1 = skb_shinfo(skb)->zccd1;
+			zccd_incref(skb_shinfo(n)->zccd1);
+		}
+
+		if (skb_shinfo(skb)->zccd2 != NULL) {
+			BUG_TRAP(skb_shinfo(n)->zccd2 == NULL);
+			skb_shinfo(n)->zccd2 = skb_shinfo(skb)->zccd2;
+			zccd_incref(skb_shinfo(n)->zccd2);
+		}
 	}
 
 	if (skb_shinfo(skb)->frag_list) {
@@ -700,6 +719,13 @@ int pskb_expand_head(struct sk_buff *skb
 	memcpy(data + nhead, skb->head, skb->tail - skb->head);
 	memcpy(data + size, skb->end, sizeof(struct skb_shared_info));
 
+	/* zero-copy descriptors have been copied into the new shinfo - 
+	 * account the new references */
+	if (skb_shinfo(skb)->zccd1 != NULL)
+	   zccd_incref(skb_shinfo(skb)->zccd1);
+	if (skb_shinfo(skb)->zccd2 != NULL)
+	   zccd_incref(skb_shinfo(skb)->zccd2);
+	
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		get_page(skb_shinfo(skb)->frags[i].page);
 
@@ -881,6 +907,8 @@ int ___pskb_trim(struct sk_buff *skb, un
 
 drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
+		if (i == 0)
+			skb_complete_zccd(skb);
 
 		for (; i < nfrags; i++)
 			put_page(skb_shinfo(skb)->frags[i].page);
@@ -1066,6 +1094,9 @@ pull_pages:
 	}
 	skb_shinfo(skb)->nr_frags = k;
 
+	if (k == 0)				/* dropped all the pages */
+		skb_complete_zccd(skb);		/* drop zccd refs */
+		
 	skb->tail     += delta;
 	skb->data_len -= delta;
 
@@ -1598,6 +1629,15 @@ static inline void skb_split_inside_head
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		skb_shinfo(skb1)->frags[i] = skb_shinfo(skb)->frags[i];
 
+	/* Transfer zero-copy callback descriptors */
+	BUG_TRAP(skb_shinfo(skb1)->zccd1 == NULL);
+	skb_shinfo(skb1)->zccd1    = skb_shinfo(skb)->zccd1;
+	skb_shinfo(skb)->zccd1     = NULL;
+
+	BUG_TRAP(skb_shinfo(skb1)->zccd2 == NULL);
+	skb_shinfo(skb1)->zccd2    = skb_shinfo(skb)->zccd2;
+	skb_shinfo(skb)->zccd2     = NULL;
+
 	skb_shinfo(skb1)->nr_frags = skb_shinfo(skb)->nr_frags;
 	skb_shinfo(skb)->nr_frags  = 0;
 	skb1->data_len		   = skb->data_len;
@@ -1646,6 +1686,30 @@ static inline void skb_split_no_header(s
 		pos += size;
 	}
 	skb_shinfo(skb1)->nr_frags = k;
+
+	if (k != 0) {				
+		/* skb1 has pages. Transfer or clone the zccds */
+
+		if (skb_shinfo(skb)->zccd1 != NULL) {
+			BUG_TRAP(skb_shinfo(skb1)->zccd1 == NULL);
+			skb_shinfo(skb1)->zccd1 = skb_shinfo(skb)->zccd1;
+
+			if (skb_shinfo(skb)->nr_frags == 0)
+				skb_shinfo(skb)->zccd1 = NULL;
+			else
+				zccd_incref(skb_shinfo(skb)->zccd1);
+		}
+		
+		if (skb_shinfo(skb)->zccd2 != NULL) {
+			BUG_TRAP(skb_shinfo(skb1)->zccd2 == NULL);
+			skb_shinfo(skb1)->zccd2 = skb_shinfo(skb)->zccd2;
+
+			if (skb_shinfo(skb)->nr_frags == 0)
+				skb_shinfo(skb)->zccd2 = NULL;
+			else
+				zccd_incref(skb_shinfo(skb)->zccd2);
+		}
+	}
 }
 
 /**
@@ -2024,6 +2088,21 @@ struct sk_buff *skb_segment(struct sk_bu
 			frag++;
 		}
 
+		if (k != 0) {
+			/* nskb has pages.  Clone the zccds */
+			if (skb_shinfo(skb)->zccd1 != NULL) {
+				BUG_TRAP(skb_shinfo(nskb)->zccd1 == NULL);
+				skb_shinfo(nskb)->zccd1 = skb_shinfo(skb)->zccd1;
+				zccd_incref(skb_shinfo(skb)->zccd1);
+			}
+		
+			if (skb_shinfo(skb)->zccd2 != NULL) {
+				BUG_TRAP(skb_shinfo(nskb)->zccd2 == NULL);
+				skb_shinfo(nskb)->zccd2 = skb_shinfo(skb)->zccd2;
+				zccd_incref(skb_shinfo(skb)->zccd2);
+			}
+		}
+		
 		skb_shinfo(nskb)->nr_frags = k;
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 66e9a72..515c8b4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -499,8 +499,9 @@ static inline void tcp_push(struct sock 
 	}
 }
 
+/* Extra parameter: user zero copy descriptor (or NULL if not doing that) */
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
-			 size_t psize, int flags)
+				size_t psize, int flags, struct zccd *zccd)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now, size_goal;
@@ -548,6 +549,16 @@ new_segment:
 			copy = size;
 
 		i = skb_shinfo(skb)->nr_frags;
+
+		if (zccd != NULL &&                   /* completion callback wanted */
+		    skb_shinfo(skb)->zccd1 != NULL && /* no room for zccd */
+		    skb_shinfo(skb)->zccd2 != NULL && 
+		    skb_shinfo(skb)->zccd1 != zccd && /* room needed */
+		    skb_shinfo(skb)->zccd2 != zccd) {
+			tcp_mark_push (tp, skb);
+			goto new_segment;
+		}
+
 		can_coalesce = skb_can_coalesce(skb, i, page, offset);
 		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
 			tcp_mark_push(tp, skb);
@@ -563,6 +574,18 @@ new_segment:
 			skb_fill_page_desc(skb, i, page, offset, copy);
 		}
 
+		if (zccd != NULL &&		      /* completion callback wanted */
+		    skb_shinfo(skb)->zccd1 != zccd && /* new to this skbuf */
+		    skb_shinfo(skb)->zccd2 != zccd) {
+			if (skb_shinfo(skb)->zccd1 == NULL) {
+				skb_shinfo(skb)->zccd1 = zccd;
+			} else {
+				BUG_TRAP (skb_shinfo(skb)->zccd2 == NULL);
+				skb_shinfo(skb)->zccd2 = zccd;
+			}
+			zccd_incref(zccd);	      /* new reference */
+		}
+
 		skb->len += copy;
 		skb->data_len += copy;
 		skb->truesize += copy;
@@ -616,8 +639,8 @@ out_err:
 	return sk_stream_error(sk, flags, err);
 }
 
-ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
-		     size_t size, int flags)
+ssize_t tcp_sendpage_zccd(struct socket *sock, struct page *page, int offset,
+			  size_t size, int flags, struct zccd *zccd)
 {
 	ssize_t res;
 	struct sock *sk = sock->sk;
@@ -628,12 +651,18 @@ ssize_t tcp_sendpage(struct socket *sock
 
 	lock_sock(sk);
 	TCP_CHECK_TIMER(sk);
-	res = do_tcp_sendpages(sk, &page, offset, size, flags);
+	res = do_tcp_sendpages(sk, &page, offset, size, flags, zccd);
 	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return res;
 }
 
+ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
+		     size_t size, int flags)
+{
+	return tcp_sendpage_zccd(sock, page, offset, size, flags, NULL);
+}
+
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
 
@@ -2347,6 +2376,7 @@ EXPORT_SYMBOL(tcp_read_sock);
 EXPORT_SYMBOL(tcp_recvmsg);
 EXPORT_SYMBOL(tcp_sendmsg);
 EXPORT_SYMBOL(tcp_sendpage);
+EXPORT_SYMBOL(tcp_sendpage_zccd);
 EXPORT_SYMBOL(tcp_setsockopt);
 EXPORT_SYMBOL(tcp_shutdown);
 EXPORT_SYMBOL(tcp_statistics);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f22536e..943bc7b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -680,6 +680,9 @@ static void __pskb_trim_head(struct sk_b
 	}
 	skb_shinfo(skb)->nr_frags = k;
 
+	if (k == 0)				/* dropped all pages */
+		skb_complete_zccd(skb);
+	
 	skb->tail = skb->data;
 	skb->data_len -= len;
 	skb->len = skb->data_len;

