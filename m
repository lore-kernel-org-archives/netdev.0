From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Tue, 14 Oct 2014 16:00:56 -0400 (EDT)
Message-ID: <20141014.160056.2113064815910782529.davem@davemloft.net>
References: <CALCETrWfQe5H2Ht7cjCQLfUw+XUcRvga_H93esaWpAp37=noZg@mail.gmail.com>
	<20141014.151949.1967601568480255495.davem@davemloft.net>
	<CALCETrUYBed_TBacxoDPMphM5y=iqxho2isrDruOQi=pmK2yoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755658AbaJNUBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:01:01 -0400
In-Reply-To: <CALCETrUYBed_TBacxoDPMphM5y=iqxho2isrDruOQi=pmK2yoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 14 Oct 2014 12:33:43 -0700

> For full honesty, there is now the machinery developed for memfd
> sealing, but I can't imagine that this is ever faster than just
> copying the buffer.

I don't have much motivation to even check if it's a worthwhile
pursuit at this point.  

Someone who wants to can :-)

> I think that the NETLINK_SKB_TX declaration in include/linux/netlink.h
> should probably go, too.  And there's the last parameter to
> netlink_set_ring, too, and possibly even the nlk->tx_ring struct
> itself.

Agreed on all counts, here is the new patch:

====================
[PATCH] netlink: Remove TX mmap support.

There is no reasonable manner in which to absolutely make sure that another
thread of control cannot write to the pages in the mmap()'d area and thus
make sure that netlink messages do not change underneath us after we've
performed verifications.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netlink.h  |   5 +-
 net/netlink/af_netlink.c | 161 +++++------------------------------------------
 net/netlink/af_netlink.h |   1 -
 3 files changed, 16 insertions(+), 151 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 9e572da..57080a9 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -17,9 +17,8 @@ static inline struct nlmsghdr *nlmsg_hdr(const struct sk_buff *skb)
 
 enum netlink_skb_flags {
 	NETLINK_SKB_MMAPED	= 0x1,	/* Packet data is mmaped */
-	NETLINK_SKB_TX		= 0x2,	/* Packet was sent by userspace */
-	NETLINK_SKB_DELIVERED	= 0x4,	/* Packet was delivered */
-	NETLINK_SKB_DST		= 0x8,	/* Dst set in sendto or sendmsg */
+	NETLINK_SKB_DELIVERED	= 0x2,	/* Packet was delivered */
+	NETLINK_SKB_DST		= 0x4,	/* Dst set in sendto or sendmsg */
 };
 
 struct netlink_skb_parms {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c416725..07ef0c9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -289,11 +289,6 @@ static bool netlink_rx_is_mmaped(struct sock *sk)
 	return nlk_sk(sk)->rx_ring.pg_vec != NULL;
 }
 
-static bool netlink_tx_is_mmaped(struct sock *sk)
-{
-	return nlk_sk(sk)->tx_ring.pg_vec != NULL;
-}
-
 static __pure struct page *pgvec_to_page(const void *addr)
 {
 	if (is_vmalloc_addr(addr))
@@ -359,7 +354,7 @@ err1:
 }
 
 static int netlink_set_ring(struct sock *sk, struct nl_mmap_req *req,
-			    bool closing, bool tx_ring)
+			    bool closing)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct netlink_ring *ring;
@@ -368,8 +363,8 @@ static int netlink_set_ring(struct sock *sk, struct nl_mmap_req *req,
 	unsigned int order = 0;
 	int err;
 
-	ring  = tx_ring ? &nlk->tx_ring : &nlk->rx_ring;
-	queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
+	ring  = &nlk->rx_ring;
+	queue = &sk->sk_receive_queue;
 
 	if (!closing) {
 		if (atomic_read(&nlk->mapped))
@@ -476,11 +471,9 @@ static int netlink_mmap(struct file *file, struct socket *sock,
 	mutex_lock(&nlk->pg_vec_lock);
 
 	expected = 0;
-	for (ring = &nlk->rx_ring; ring <= &nlk->tx_ring; ring++) {
-		if (ring->pg_vec == NULL)
-			continue;
+	ring = &nlk->rx_ring;
+	if (ring->pg_vec)
 		expected += ring->pg_vec_len * ring->pg_vec_pages * PAGE_SIZE;
-	}
 
 	if (expected == 0)
 		goto out;
@@ -490,10 +483,8 @@ static int netlink_mmap(struct file *file, struct socket *sock,
 		goto out;
 
 	start = vma->vm_start;
-	for (ring = &nlk->rx_ring; ring <= &nlk->tx_ring; ring++) {
-		if (ring->pg_vec == NULL)
-			continue;
-
+	ring = &nlk->rx_ring;
+	if (ring->pg_vec) {
 		for (i = 0; i < ring->pg_vec_len; i++) {
 			struct page *page;
 			void *kaddr = ring->pg_vec[i];
@@ -662,13 +653,6 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 	}
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
-	spin_lock_bh(&sk->sk_write_queue.lock);
-	if (nlk->tx_ring.pg_vec) {
-		if (netlink_current_frame(&nlk->tx_ring, NL_MMAP_STATUS_UNUSED))
-			mask |= POLLOUT | POLLWRNORM;
-	}
-	spin_unlock_bh(&sk->sk_write_queue.lock);
-
 	return mask;
 }
 
@@ -698,104 +682,6 @@ static void netlink_ring_setup_skb(struct sk_buff *skb, struct sock *sk,
 	NETLINK_CB(skb).sk = sk;
 }
 
-static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
-				u32 dst_portid, u32 dst_group,
-				struct sock_iocb *siocb)
-{
-	struct netlink_sock *nlk = nlk_sk(sk);
-	struct netlink_ring *ring;
-	struct nl_mmap_hdr *hdr;
-	struct sk_buff *skb;
-	unsigned int maxlen;
-	bool excl = true;
-	int err = 0, len = 0;
-
-	/* Netlink messages are validated by the receiver before processing.
-	 * In order to avoid userspace changing the contents of the message
-	 * after validation, the socket and the ring may only be used by a
-	 * single process, otherwise we fall back to copying.
-	 */
-	if (atomic_long_read(&sk->sk_socket->file->f_count) > 2 ||
-	    atomic_read(&nlk->mapped) > 1)
-		excl = false;
-
-	mutex_lock(&nlk->pg_vec_lock);
-
-	ring   = &nlk->tx_ring;
-	maxlen = ring->frame_size - NL_MMAP_HDRLEN;
-
-	do {
-		hdr = netlink_current_frame(ring, NL_MMAP_STATUS_VALID);
-		if (hdr == NULL) {
-			if (!(msg->msg_flags & MSG_DONTWAIT) &&
-			    atomic_read(&nlk->tx_ring.pending))
-				schedule();
-			continue;
-		}
-		if (hdr->nm_len > maxlen) {
-			err = -EINVAL;
-			goto out;
-		}
-
-		netlink_frame_flush_dcache(hdr);
-
-		if (likely(dst_portid == 0 && dst_group == 0 && excl)) {
-			skb = alloc_skb_head(GFP_KERNEL);
-			if (skb == NULL) {
-				err = -ENOBUFS;
-				goto out;
-			}
-			sock_hold(sk);
-			netlink_ring_setup_skb(skb, sk, ring, hdr);
-			NETLINK_CB(skb).flags |= NETLINK_SKB_TX;
-			__skb_put(skb, hdr->nm_len);
-			netlink_set_status(hdr, NL_MMAP_STATUS_RESERVED);
-			atomic_inc(&ring->pending);
-		} else {
-			skb = alloc_skb(hdr->nm_len, GFP_KERNEL);
-			if (skb == NULL) {
-				err = -ENOBUFS;
-				goto out;
-			}
-			__skb_put(skb, hdr->nm_len);
-			memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, hdr->nm_len);
-			netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
-		}
-
-		netlink_increment_head(ring);
-
-		NETLINK_CB(skb).portid	  = nlk->portid;
-		NETLINK_CB(skb).dst_group = dst_group;
-		NETLINK_CB(skb).creds	  = siocb->scm->creds;
-
-		err = security_netlink_send(sk, skb);
-		if (err) {
-			kfree_skb(skb);
-			goto out;
-		}
-
-		if (unlikely(dst_group)) {
-			atomic_inc(&skb->users);
-			netlink_broadcast(sk, skb, dst_portid, dst_group,
-					  GFP_KERNEL);
-		}
-		err = netlink_unicast(sk, skb, dst_portid,
-				      msg->msg_flags & MSG_DONTWAIT);
-		if (err < 0)
-			goto out;
-		len += err;
-
-	} while (hdr != NULL ||
-		 (!(msg->msg_flags & MSG_DONTWAIT) &&
-		  atomic_read(&nlk->tx_ring.pending)));
-
-	if (len > 0)
-		err = len;
-out:
-	mutex_unlock(&nlk->pg_vec_lock);
-	return err;
-}
-
 static void netlink_queue_mmaped_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct nl_mmap_hdr *hdr;
@@ -842,10 +728,8 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
 #else /* CONFIG_NETLINK_MMAP */
 #define netlink_skb_is_mmaped(skb)	false
 #define netlink_rx_is_mmaped(sk)	false
-#define netlink_tx_is_mmaped(sk)	false
 #define netlink_mmap			sock_no_mmap
 #define netlink_poll			datagram_poll
-#define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, siocb)	0
 #endif /* CONFIG_NETLINK_MMAP */
 
 static void netlink_skb_destructor(struct sk_buff *skb)
@@ -864,16 +748,11 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 		hdr = netlink_mmap_hdr(skb);
 		sk = NETLINK_CB(skb).sk;
 
-		if (NETLINK_CB(skb).flags & NETLINK_SKB_TX) {
-			netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
-			ring = &nlk_sk(sk)->tx_ring;
-		} else {
-			if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
-				hdr->nm_len = 0;
-				netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
-			}
-			ring = &nlk_sk(sk)->rx_ring;
+		if (!(NETLINK_CB(skb).flags & NETLINK_SKB_DELIVERED)) {
+			hdr->nm_len = 0;
+			netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
 		}
+		ring = &nlk_sk(sk)->rx_ring;
 
 		WARN_ON(atomic_read(&ring->pending) == 0);
 		atomic_dec(&ring->pending);
@@ -921,10 +800,7 @@ static void netlink_sock_destruct(struct sock *sk)
 
 		memset(&req, 0, sizeof(req));
 		if (nlk->rx_ring.pg_vec)
-			netlink_set_ring(sk, &req, true, false);
-		memset(&req, 0, sizeof(req));
-		if (nlk->tx_ring.pg_vec)
-			netlink_set_ring(sk, &req, true, true);
+			netlink_set_ring(sk, &req, true);
 	}
 #endif /* CONFIG_NETLINK_MMAP */
 
@@ -2165,8 +2041,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		err = 0;
 		break;
 #ifdef CONFIG_NETLINK_MMAP
-	case NETLINK_RX_RING:
-	case NETLINK_TX_RING: {
+	case NETLINK_RX_RING: {
 		struct nl_mmap_req req;
 
 		/* Rings might consume more memory than queue limits, require
@@ -2178,8 +2053,7 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			return -EINVAL;
 		if (copy_from_user(&req, optval, sizeof(req)))
 			return -EFAULT;
-		err = netlink_set_ring(sk, &req, false,
-				       optname == NETLINK_TX_RING);
+		err = netlink_set_ring(sk, &req, false);
 		break;
 	}
 #endif /* CONFIG_NETLINK_MMAP */
@@ -2295,13 +2169,6 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out;
 	}
 
-	if (netlink_tx_is_mmaped(sk) &&
-	    msg->msg_iov->iov_base == NULL) {
-		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
-					   siocb);
-		goto out;
-	}
-
 	err = -EMSGSIZE;
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index b20a173..4741b88 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -45,7 +45,6 @@ struct netlink_sock {
 #ifdef CONFIG_NETLINK_MMAP
 	struct mutex		pg_vec_lock;
 	struct netlink_ring	rx_ring;
-	struct netlink_ring	tx_ring;
 	atomic_t		mapped;
 #endif /* CONFIG_NETLINK_MMAP */
 
-- 
1.7.11.7
