From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink, mmap: transform mmap skb into full skb on
 taps
Date: Fri, 11 Sep 2015 12:42:05 -0700 (PDT)
Message-ID: <20150911.124205.1992250802389107845.davem@davemloft.net>
References: <d8546f5fdd1e84659e0f184275b36fcd565fe59c.1441887916.git.daniel@iogearbox.net>
	<20150910.221132.1962916984876023271.davem@davemloft.net>
	<55F2AC29.3030209@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, fw@strlen.de, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbIKTmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 15:42:08 -0400
In-Reply-To: <55F2AC29.3030209@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 11 Sep 2015 12:25:45 +0200

> Already calling into skb_clone() is an issue itself, as the data
> area is user space buffer, and skb_clone() as well as skb_copy()
> access skb_shinfo() area. :/ So in that regard netlink mmap skbs are
> even further restrictive on what we can do than netlink large skbs.

Indeed, this is fatal.

So we'd still need something special like your
netlink_to_full_skb_clone to elide trying to touch the skb_shinfo
area.

I thought briefly about somehow cobbling up extra space in the ring
entries so we could have a real skb_shinfo() there, but that's illegal
too as the user could scribble all over it randomly while we interpret
the contents.  We don't own that memory.  So this doesn't work.

We could rename the clone_preserves_destructor and have it also mean
that the SKB lacks frags and skb_shinfo() should not be inspected.

Something like this:

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 639e9b8..47d5875 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -97,22 +97,6 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 
-static inline struct sk_buff *
-netlink_skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
-{
-	struct sk_buff *nskb;
-
-	nskb = skb_clone(skb, gfp_mask);
-	if (!nskb)
-		return NULL;
-
-	/* This is a large skb, set destructor callback to release head */
-	if (is_vmalloc_addr(skb->head))
-		nskb->destructor = skb->destructor;
-
-	return nskb;
-}
-
 /*
  *	skb should fit one page. This choice is good for headerless malloc.
  *	But we should limit to 8K so that userspace does not have to
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2738d35..898c53d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -584,8 +584,9 @@ struct sk_buff {
 				fclone:2,
 				peeked:1,
 				head_frag:1,
-				xmit_more:1;
-	/* one bit hole */
+				xmit_more:1,
+				private_buffers:1;
+
 	kmemcheck_bitfield_end(flags1);
 
 	/* fields enclosed in headers_start/headers_end are copied
@@ -2220,7 +2221,8 @@ static inline void skb_orphan(struct sk_buff *skb)
  */
 static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)))
+	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) ||
+		   skb->private_buffers))
 		return 0;
 	return skb_copy_ubufs(skb, gfp_mask);
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index dad4dd3..54f9d6e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -825,7 +825,10 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
 	n->cloned = 1;
 	n->nohdr = 0;
-	n->destructor = NULL;
+	if (!skb->private_buffers)
+		n->destructor = NULL;
+	else
+		C(destructor);
 	C(tail);
 	C(end);
 	C(head);
@@ -1675,6 +1678,9 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 		to     += copy;
 	}
 
+	if (skb->private_buffers)
+		goto out;
+
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		int end;
 		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
@@ -1720,7 +1726,7 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 		}
 		start = end;
 	}
-
+out:
 	if (!len)
 		return 0;
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6fcbd21..2ec5425 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1075,7 +1075,7 @@ static void nl_fib_input(struct sk_buff *skb)
 	    nlmsg_len(nlh) < sizeof(*frn))
 		return;
 
-	skb = netlink_skb_clone(skb, GFP_KERNEL);
+	skb = skb_clone(skb, GFP_KERNEL);
 	if (!skb)
 		return;
 	nlh = nlmsg_hdr(skb);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 70277b1..4c612481 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -291,7 +291,7 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 replay:
 	status = 0;
 
-	skb = netlink_skb_clone(oskb, GFP_KERNEL);
+	skb = skb_clone(oskb, GFP_KERNEL);
 	if (!skb)
 		return netlink_ack(oskb, nlh, -ENOMEM);
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7f86d3b..523adac 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -719,6 +719,7 @@ static void netlink_ring_setup_skb(struct sk_buff *skb, struct sock *sk,
 	skb->end	= skb->tail + size;
 	skb->len	= 0;
 
+	skb->private_buffers = 1;
 	skb->destructor	= netlink_skb_destructor;
 	NETLINK_CB(skb).flags |= NETLINK_SKB_MMAPED;
 	NETLINK_CB(skb).sk = sk;
@@ -854,6 +855,14 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
 #define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, scm)	0
 #endif /* CONFIG_NETLINK_MMAP */
 
+static bool skb_can_release_head(struct sk_buff *skb)
+{
+	if (!skb->cloned ||
+	    !atomic_dec_return(&(skb_shinfo(skb)->dataref)))
+		return true;
+	return false;
+}
+
 static void netlink_skb_destructor(struct sk_buff *skb)
 {
 #ifdef CONFIG_NETLINK_MMAP
@@ -866,31 +875,35 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 	 * the status. In the direction userspace to kernel, the status is
 	 * always reset here after the packet was processed and freed.
 	 */
-	if (netlink_skb_is_mmaped(skb)) {
-		hdr = netlink_mmap_hdr(skb);
-		sk = NETLINK_CB(skb).sk;
+	if (!netlink_skb_is_mmaped(skb))
+		goto not_mmaped;
 
-		if (NETLINK_CB(skb).flags & NETLINK_SKB_TX) {
-			netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
-			ring = &nlk_sk(sk)->tx_ring;
-		} else {
-			if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
-				hdr->nm_len = 0;
-				netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
-			}
-			ring = &nlk_sk(sk)->rx_ring;
-		}
+	if (!skb_can_release_head(skb))
+		goto clone_refs_remain;
 
-		WARN_ON(atomic_read(&ring->pending) == 0);
-		atomic_dec(&ring->pending);
-		sock_put(sk);
+	hdr = netlink_mmap_hdr(skb);
+	sk = NETLINK_CB(skb).sk;
 
-		skb->head = NULL;
+	if (NETLINK_CB(skb).flags & NETLINK_SKB_TX) {
+		netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
+		ring = &nlk_sk(sk)->tx_ring;
+	} else {
+		if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
+			hdr->nm_len = 0;
+			netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
+		}
+		ring = &nlk_sk(sk)->rx_ring;
 	}
+
+	WARN_ON(atomic_read(&ring->pending) == 0);
+	atomic_dec(&ring->pending);
+	sock_put(sk);
+clone_refs_remain:
+	skb->head = NULL;
+not_mmaped:
 #endif
 	if (is_vmalloc_addr(skb->head)) {
-		if (!skb->cloned ||
-		    !atomic_dec_return(&(skb_shinfo(skb)->dataref)))
+		if (skb_can_release_head(skb))
 			vfree(skb->head);
 
 		skb->head = NULL;
@@ -1669,6 +1682,7 @@ static struct sk_buff *netlink_alloc_large_skb(unsigned int size,
 	if (data == NULL)
 		return NULL;
 
+	skb->private_buffers = 1;
 	skb = __build_skb(data, size);
 	if (skb == NULL)
 		vfree(data);
