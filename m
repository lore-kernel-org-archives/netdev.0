From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next 1/2] packet: clean up error variable assignments
Date: Tue, 23 Oct 2012 13:56:30 +0200
Message-ID: <20121023115629.GA8664@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f194.google.com ([209.85.212.194]:57915 "EHLO
	mail-wi0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990Ab2JWMNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 08:13:06 -0400
Received: by mail-wi0-f194.google.com with SMTP id hr7so2521426wib.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 05:13:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch performs clean-ups of packet's err variables where appropriate.
In particular, errnos are *only* assigned in error cases, which saves
useless instructions in non-error cases and makes the code more readable
in terms of which error type belongs to which evaluated error condition.
Also, in some cases an errno was set, but not used until the next assignment.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 net/packet/af_packet.c |  162 ++++++++++++++++++++++++++---------------------
 1 files changed, 90 insertions(+), 72 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 94060ed..1f2f465 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1176,7 +1176,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	struct packet_fanout *f, *match;
 	u8 type = type_flags & 0xff;
 	u8 defrag = (type_flags & PACKET_FANOUT_FLAG_DEFRAG) ? 1 : 0;
-	int err;
+	int err = 0;
 
 	switch (type) {
 	case PACKET_FANOUT_HASH:
@@ -1202,14 +1202,18 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 			break;
 		}
 	}
-	err = -EINVAL;
-	if (match && match->defrag != defrag)
+
+	if (match && match->defrag != defrag) {
+		err = -EINVAL;
 		goto out;
+	}
+
 	if (!match) {
-		err = -ENOMEM;
 		match = kzalloc(sizeof(*match), GFP_KERNEL);
-		if (!match)
+		if (!match) {
+			err = -ENOMEM;
 			goto out;
+		}
 		write_pnet(&match->net, sock_net(sk));
 		match->id = id;
 		match->type = type;
@@ -1226,6 +1230,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		dev_add_pack(&match->prot_hook);
 		list_add(&match->list, &fanout_list);
 	}
+
 	err = -EINVAL;
 	if (match->type == type &&
 	    match->prot_hook.type == po->prot_hook.type &&
@@ -1348,7 +1353,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb = NULL;
 	struct net_device *dev;
 	__be16 proto = 0;
-	int err;
+	int err = 0;
 	int extra_len = 0;
 
 	/*
@@ -1371,13 +1376,15 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 retry:
 	rcu_read_lock();
 	dev = dev_get_by_name_rcu(sock_net(sk), saddr->spkt_device);
-	err = -ENODEV;
-	if (dev == NULL)
+	if (dev == NULL) {
+		err = -ENODEV;
 		goto out_unlock;
+	}
 
-	err = -ENETDOWN;
-	if (!(dev->flags & IFF_UP))
+	if (!(dev->flags & IFF_UP)) {
+		err = -ENETDOWN;
 		goto out_unlock;
+	}
 
 	/*
 	 * You may not queue a frame bigger than the mtu. This is the lowest level
@@ -1392,9 +1399,10 @@ retry:
 		extra_len = 4; /* We're doing our own CRC */
 	}
 
-	err = -EMSGSIZE;
-	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN + extra_len)
+	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN + extra_len) {
+		err = -EMSGSIZE;
 		goto out_unlock;
+	}
 
 	if (!skb) {
 		size_t reserved = LL_RESERVED_SPACE(dev);
@@ -1907,7 +1915,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		to_write -= dev->hard_header_len;
 	}
 
-	err = -EFAULT;
 	offset = offset_in_page(data);
 	len_max = PAGE_SIZE - offset;
 	len = ((to_write > len_max) ? len_max : to_write);
@@ -1946,7 +1953,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct net_device *dev;
 	__be16 proto;
 	bool need_rls_dev = false;
-	int err, reserve = 0;
+	int err = 0, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	int tp_len, size_max;
@@ -1957,7 +1964,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 	mutex_lock(&po->pg_vec_lock);
 
-	err = -EBUSY;
 	if (saddr == NULL) {
 		dev = po->prot_hook.dev;
 		proto	= po->num;
@@ -1976,15 +1982,17 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		need_rls_dev = true;
 	}
 
-	err = -ENXIO;
-	if (unlikely(dev == NULL))
+	if (unlikely(dev == NULL)) {
+		err = -ENXIO;
 		goto out;
+	}
 
 	reserve = dev->hard_header_len;
 
-	err = -ENETDOWN;
-	if (unlikely(!(dev->flags & IFF_UP)))
+	if (unlikely(!(dev->flags & IFF_UP))) {
+		err = -ENETDOWN;
 		goto out_put;
+	}
 
 	size_max = po->tx_ring.frame_size
 		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));
@@ -2008,8 +2016,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 				hlen + tlen + sizeof(struct sockaddr_ll),
 				0, &err);
 
-		if (unlikely(skb == NULL))
+		if (unlikely(skb == NULL)) {
+			err = -ENOMEM;
 			goto out_status;
+		}
 
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 				addr, hlen);
@@ -2103,7 +2113,7 @@ static int packet_snd(struct socket *sock,
 	__be16 proto;
 	bool need_rls_dev = false;
 	unsigned char *addr;
-	int err, reserve = 0;
+	int err = 0, reserve = 0;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
 	int vnet_hdr_len;
@@ -2132,22 +2142,25 @@ static int packet_snd(struct socket *sock,
 		need_rls_dev = true;
 	}
 
-	err = -ENXIO;
-	if (dev == NULL)
+	if (dev == NULL) {
+		err = -ENXIO;
 		goto out_unlock;
+	}
 	if (sock->type == SOCK_RAW)
 		reserve = dev->hard_header_len;
 
-	err = -ENETDOWN;
-	if (!(dev->flags & IFF_UP))
+	if (!(dev->flags & IFF_UP)) {
+		err = -ENETDOWN;
 		goto out_unlock;
+	}
 
 	if (po->has_vnet_hdr) {
 		vnet_hdr_len = sizeof(vnet_hdr);
 
-		err = -EINVAL;
-		if (len < vnet_hdr_len)
+		if (len < vnet_hdr_len) {
+			err = -EINVAL;
 			goto out_unlock;
+		}
 
 		len -= vnet_hdr_len;
 
@@ -2198,11 +2211,11 @@ static int packet_snd(struct socket *sock,
 		extra_len = 4; /* We're doing our own CRC */
 	}
 
-	err = -EMSGSIZE;
-	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN + extra_len))
+	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN + extra_len)) {
+		err = -EMSGSIZE;
 		goto out_unlock;
+	}
 
-	err = -ENOBUFS;
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
 	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, vnet_hdr.hdr_len,
@@ -2212,10 +2225,11 @@ static int packet_snd(struct socket *sock,
 
 	skb_set_network_header(skb, reserve);
 
-	err = -EINVAL;
 	if (sock->type == SOCK_DGRAM &&
-	    (offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len)) < 0)
+	    (offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len)) < 0) {
+		err = -EINVAL;
 		goto out_free;
+	}
 
 	/* Returns -EFAULT on error */
 	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
@@ -2436,8 +2450,7 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 	struct sockaddr_ll *sll = (struct sockaddr_ll *)uaddr;
 	struct sock *sk = sock->sk;
 	struct net_device *dev = NULL;
-	int err;
-
+	int err = 0;
 
 	/*
 	 *	Check legality
@@ -2449,13 +2462,13 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 		return -EINVAL;
 
 	if (sll->sll_ifindex) {
-		err = -ENODEV;
 		dev = dev_get_by_index(sock_net(sk), sll->sll_ifindex);
-		if (dev == NULL)
+		if (dev == NULL) {
+			err = -ENODEV;
 			goto out;
+		}
 	}
 	err = packet_do_bind(sk, dev, sll->sll_protocol ? : pkt_sk(sk)->num);
-
 out:
 	return err;
 }
@@ -2476,7 +2489,6 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	struct sock *sk;
 	struct packet_sock *po;
 	__be16 proto = (__force __be16)protocol; /* weird, but documented */
-	int err;
 
 	if (!capable(CAP_NET_RAW))
 		return -EPERM;
@@ -2486,10 +2498,9 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 
 	sock->state = SS_UNCONNECTED;
 
-	err = -ENOBUFS;
 	sk = sk_alloc(net, PF_PACKET, GFP_KERNEL, &packet_proto);
 	if (sk == NULL)
-		goto out;
+		return -ENOBUFS;
 
 	sock->ops = &packet_ops;
 	if (sock->type == SOCK_PACKET)
@@ -2531,20 +2542,17 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	preempt_enable();
 
 	return 0;
-out:
-	return err;
 }
 
 static int packet_recv_error(struct sock *sk, struct msghdr *msg, int len)
 {
 	struct sock_exterr_skb *serr;
 	struct sk_buff *skb, *skb2;
-	int copied, err;
+	int copied, err = 0;
 
-	err = -EAGAIN;
 	skb = skb_dequeue(&sk->sk_error_queue);
 	if (skb == NULL)
-		goto out;
+		return -EAGAIN;
 
 	copied = skb->len;
 	if (copied > len) {
@@ -2576,7 +2584,6 @@ static int packet_recv_error(struct sock *sk, struct msghdr *msg, int len)
 
 out_free_skb:
 	kfree_skb(skb);
-out:
 	return err;
 }
 
@@ -2590,13 +2597,14 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
-	int copied, err;
+	int copied, err = 0;
 	struct sockaddr_ll *sll;
 	int vnet_hdr_len = 0;
 
-	err = -EINVAL;
-	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT|MSG_ERRQUEUE))
+	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT|MSG_ERRQUEUE)) {
+		err = -EINVAL;
 		goto out;
+	}
 
 #if 0
 	/* What error should we return now? EUNATTACH? */
@@ -2632,10 +2640,11 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (pkt_sk(sk)->has_vnet_hdr) {
 		struct virtio_net_hdr vnet_hdr = { 0 };
 
-		err = -EINVAL;
 		vnet_hdr_len = sizeof(vnet_hdr);
-		if (len < vnet_hdr_len)
+		if (len < vnet_hdr_len) {
+			err = -EINVAL;
 			goto out_free;
+		}
 
 		len -= vnet_hdr_len;
 
@@ -2836,25 +2845,27 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 	struct packet_sock *po = pkt_sk(sk);
 	struct packet_mclist *ml, *i;
 	struct net_device *dev;
-	int err;
+	int err = 0;
 
 	rtnl_lock();
 
-	err = -ENODEV;
 	dev = __dev_get_by_index(sock_net(sk), mreq->mr_ifindex);
-	if (!dev)
+	if (!dev) {
+		err = -ENODEV;
 		goto done;
+	}
 
-	err = -EINVAL;
-	if (mreq->mr_alen > dev->addr_len)
+	if (mreq->mr_alen > dev->addr_len) {
+		err = -EINVAL;
 		goto done;
+	}
 
-	err = -ENOBUFS;
 	i = kmalloc(sizeof(*i), GFP_KERNEL);
-	if (i == NULL)
+	if (i == NULL) {
+		err = -ENOBUFS;
 		goto done;
+	}
 
-	err = 0;
 	for (ml = po->mclist; ml; ml = ml->next) {
 		if (ml->ifindex == mreq->mr_ifindex &&
 		    ml->type == mreq->mr_type &&
@@ -3457,21 +3468,22 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 	struct packet_ring_buffer *rb;
 	struct sk_buff_head *rb_queue;
 	__be16 num;
-	int err = -EINVAL;
+	int err = 0;
 	/* Added to avoid minimal code churn */
 	struct tpacket_req *req = &req_u->req;
 
 	/* Opening a Tx-ring is NOT supported in TPACKET_V3 */
 	if (!closing && tx_ring && (po->tp_version > TPACKET_V2)) {
 		WARN(1, "Tx-ring is not supported.\n");
+		err = -EINVAL;
 		goto out;
 	}
 
 	rb = tx_ring ? &po->tx_ring : &po->rx_ring;
 	rb_queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
 
-	err = -EBUSY;
 	if (!closing) {
+		err = -EBUSY;
 		if (atomic_read(&po->mapped))
 			goto out;
 		if (atomic_read(&rb->pending))
@@ -3480,9 +3492,10 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 
 	if (req->tp_block_nr) {
 		/* Sanity tests and some calculations */
-		err = -EBUSY;
-		if (unlikely(rb->pg_vec))
+		if (unlikely(rb->pg_vec)) {
+			err = -EBUSY;
 			goto out;
+		}
 
 		switch (po->tp_version) {
 		case TPACKET_V1:
@@ -3514,11 +3527,13 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 					req->tp_frame_nr))
 			goto out;
 
-		err = -ENOMEM;
 		order = get_order(req->tp_block_size);
 		pg_vec = alloc_pg_vec(req, order);
-		if (unlikely(!pg_vec))
+		if (unlikely(!pg_vec)) {
+			err = -ENOMEM;
 			goto out;
+		}
+
 		switch (po->tp_version) {
 		case TPACKET_V3:
 		/* Transmit path is not supported. We checked
@@ -3533,9 +3548,10 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 	}
 	/* Done */
 	else {
-		err = -EINVAL;
-		if (unlikely(req->tp_frame_nr))
+		if (unlikely(req->tp_frame_nr)) {
+			err = -EINVAL;
 			goto out;
+		}
 	}
 
 	lock_sock(sk);
@@ -3603,7 +3619,7 @@ static int packet_mmap(struct file *file, struct socket *sock,
 	unsigned long size, expected_size;
 	struct packet_ring_buffer *rb;
 	unsigned long start;
-	int err = -EINVAL;
+	int err = 0;
 	int i;
 
 	if (vma->vm_pgoff)
@@ -3620,12 +3636,16 @@ static int packet_mmap(struct file *file, struct socket *sock,
 		}
 	}
 
-	if (expected_size == 0)
+	if (expected_size == 0) {
+		err = -EINVAL;
 		goto out;
+	}
 
 	size = vma->vm_end - vma->vm_start;
-	if (size != expected_size)
+	if (size != expected_size) {
+		err = -EINVAL;
 		goto out;
+	}
 
 	start = vma->vm_start;
 	for (rb = &po->rx_ring; rb <= &po->tx_ring; rb++) {
@@ -3650,8 +3670,6 @@ static int packet_mmap(struct file *file, struct socket *sock,
 
 	atomic_inc(&po->mapped);
 	vma->vm_ops = &packet_mmap_ops;
-	err = 0;
-
 out:
 	mutex_unlock(&po->pg_vec_lock);
 	return err;
