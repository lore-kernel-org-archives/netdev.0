From: Kelly Daly <kelly@au1.ibm.com>
Subject: [PATCH 3/3] Rough VJ Channel Implementation - vj_udp.patch
Date: Wed, 26 Apr 2006 11:47:46 +0000
Message-ID: <200604261147.46969.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:19128 "EHLO
	ausmtp04.au.ibm.com") by vger.kernel.org with ESMTP id S932331AbWDZBrX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 21:47:23 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k3Q1v9lR295020
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:57:12 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3Q1oKfd199512
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:50:25 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11/8.13.3) with ESMTP id k3Q1l0SC013250
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 11:47:00 +1000
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Kelly Daly <kelly@au.ibm.com>

Hacked udp.c to receive directly to VJ Channel socket.
Breaks normal UDP - sockets don't speak non-VJ anymore!

----


diff -r 47031a1f466c linux-2.6.16/include/linux/udp.h
--- linux-2.6.16/include/linux/udp.h	Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/include/linux/udp.h	Mon Apr 24 19:50:46 2006
@@ -51,6 +51,8 @@
 	 * when the socket is uncorked.
 	 */
 	__u16		 len;		/* total length of pending frames */
+	struct vj_channel *chan;        /* VJ net channel */
+	int		vj_reg_flag; 	/* is the vj channel registered */
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
diff -r 47031a1f466c linux-2.6.16/net/ipv4/udp.c
--- linux-2.6.16/net/ipv4/udp.c	Thu Mar 23 06:32:12 2006
+++ linux-2.6.16/net/ipv4/udp.c	Mon Apr 24 19:50:46 2006
@@ -1,3 +1,4 @@
+
 /*
  * INET		An implementation of the TCP/IP protocol suite for the LINUX
  *		operating system.  INET is implemented using the  BSD Socket
@@ -89,6 +90,7 @@
 #include <linux/igmp.h>
 #include <linux/in.h>
 #include <linux/errno.h>
+#include <linux/err.h>
 #include <linux/timer.h>
 #include <linux/mm.h>
 #include <linux/config.h>
@@ -109,6 +111,7 @@
 #include <net/inet_common.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <linux/vjchan.h>
 
 /*
  *	Snmp MIB for the UDP layer
@@ -127,6 +130,7 @@
 	struct hlist_node *node;
 	struct sock *sk2;
 	struct inet_sock *inet = inet_sk(sk);
+	struct vj_flowid flowid;
 
 	write_lock_bh(&udp_hash_lock);
 	if (snum == 0) {
@@ -195,6 +199,17 @@
 		sk_add_node(sk, h);
 		sock_prot_inc_use(sk->sk_prot);
 	}
+
+	/* copied from udp_v4_lookup_longway */
+	flowid.saddr = inet->daddr;
+	flowid.daddr = inet->rcv_saddr;
+	flowid.sport = inet->dport;
+	flowid.dport = htons(inet->num);
+	flowid.ifindex = sk->sk_bound_dev_if;
+	flowid.proto = IPPROTO_UDP;
+	vj_register_chan(udp_sk(sk)->chan, &flowid);
+	udp_sk(sk)->vj_reg_flag = 1;
+
 	write_unlock_bh(&udp_hash_lock);
 	return 0;
 
@@ -771,18 +786,158 @@
 		__udp_checksum_complete(skb);
 }
 
+static inline unsigned short int vj_udp_csum(struct vj_buffer *buffer)
+{
+	struct iphdr *ip = (struct iphdr *)(buffer->data + buffer->header_len);
+	int udpoff = buffer->header_len + (ip->ihl * 4);
+	struct udphdr *up = (struct udphdr *)(buffer->data + udpoff);
+
+	if (up->check == 0)
+		return 0;
+
+	return csum_tcpudp_magic(ip->saddr,
+			  ip->daddr,
+			  (buffer->data_len - (ip->ihl * 4)), 
+			  IPPROTO_UDP,
+			  csum_partial((buffer->data + udpoff),
+				       (buffer->data_len - (ip->ihl * 4)),
+				       0));
+}
+
+/*
+ *	Is a socket 'connection oriented' ?
+ */
+static inline int connection_based(struct sock *sk)
+{
+	return sk->sk_type == SOCK_SEQPACKET || sk->sk_type == SOCK_STREAM;
+}
+
+/* returns 1 if if we need to keep waiting, <= 0 indicates stop waiting */
+static int wait_for_vj_buffer(struct sock *sk, long *timeo_p)
+{
+	int error;
+	wait_queue_head_t *wq = &udp_sk(sk)->chan->wq;
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(wq, &wait, TASK_INTERRUPTIBLE);
+	vj_inc_wakecnt(udp_sk(sk)->chan);
+
+	error = sock_error(sk);
+	if (error)
+		goto out;
+	if (vj_peek_next_buffer(udp_sk(sk)->chan)) {
+		error = 1;
+		goto out;
+	}
+	if (sk->sk_shutdown & RCV_SHUTDOWN) {
+		error = 0;
+		goto out;
+	}
+	if (connection_based(sk) && !(sk->sk_state == TCP_ESTABLISHED ||
+				      sk->sk_state == TCP_LISTEN)) {
+		error = -ENOTCONN;
+		goto out;
+	}
+	if (signal_pending(current)) {
+		error = sock_intr_errno(*timeo_p);
+		goto out;
+	}
+
+	error = 1;
+
+	*timeo_p = schedule_timeout(*timeo_p);
+out:
+	finish_wait(wq, &wait);
+	return error;
+}
+
+/* almost a direct copy of skb_recv_datagram to get all req'd information while using a vj buffer instead of skb */
+struct vj_buffer *vj_recv_datagram(struct sock *sk, unsigned flags, 
+				   int noblock, int *err)
+{
+	struct vj_buffer *buffer;
+	long timeo;
+	*err = sock_error(sk);
+
+	if (*err)
+		return NULL;
+
+	timeo = sock_rcvtimeo(sk, noblock);
+	do {
+//we can just grab the buffer and return it seeing as either way will be a "peek".  Then after we consume we can figure out if (flags & MSG_PEEK) and move to the next buffer at that time...  we need to consume the buffer, write barrier before we move on to avoid a race condition.
+
+		buffer = vj_peek_next_buffer(udp_sk(sk)->chan);
+		if (buffer)
+			return buffer;
+
+		/* User doesn't want to wait */
+		*err = -EAGAIN;
+		if (!timeo) {
+			return NULL;
+		}
+	} while ((*err = wait_for_vj_buffer(sk, &timeo)) > 0);
+
+	return NULL;
+}
+
+static int vj_copy_datagram_iovec(struct vj_buffer *buffer, int offset, 
+		       struct iovec *to, int len)
+{
+// offset to be taken from buffer->header_len (which contains eth hdr + ip hdr)
+	if(memcpy_toiovec(to, buffer->data + offset, len))
+		return -EFAULT;
+	return 0;
+}
+
+/* FIXME: original code did timestamp in netif_rx */
+static __inline__ void vj_sock_recv_timestamp(struct msghdr *msg, 
+					   struct sock *sk)
+{
+	do_gettimeofday(&sk->sk_stamp);
+	put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMP, sizeof(struct timeval), &sk->sk_stamp);
+}
+
+/* Returns offset in buffer past ip hdr, or 0 if something wrong.  */
+static unsigned check_ip_packet(struct vj_buffer *buffer)
+{
+	struct iphdr *iph;
+
+	iph = (struct iphdr *)(buffer->data + buffer->header_len);
+
+	if (buffer->data_len < sizeof(*iph))
+		return 0;
+
+	if (iph->ihl < 5 || iph->version != 4)
+		return 0;
+
+	if (iph->ihl * 4 > ntohs(iph->tot_len))  //less than 0 data?
+		return 0;
+
+	if (ntohs(iph->tot_len) > buffer->data_len) { //truncated
+		return 0;
+	} else if (ntohs(iph->tot_len) < buffer->data_len) { //padded - trim it
+		buffer->data_len = ntohs(iph->tot_len);
+	}
+
+	if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
+		return 0;
+
+	return buffer->header_len + iph->ihl*4;
+}
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
  */
-
 static int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
   	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
-  	struct sk_buff *skb;
-  	int copied, err;
+  	struct vj_buffer *buffer;
+	struct iphdr *ip;
+	struct udphdr *udph;
+  	int copied, err, udpoff;
 
 	/*
 	 *	Check any passed addresses
@@ -794,63 +949,71 @@
 		return ip_recv_error(sk, msg, len);
 
 try_again:
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
-	if (!skb)
+	buffer = vj_recv_datagram(sk, flags, noblock, &err);
+	if (!buffer)
 		goto out;
-  
-  	copied = skb->len - sizeof(struct udphdr);
+
+	ip = (struct iphdr *)(buffer->data + buffer->header_len);
+	udpoff = check_ip_packet(buffer);
+	if (udpoff == 0)
+		goto bad_packet;
+
+	udph = (struct udphdr *)(buffer->data + udpoff);
+
+	buffer->data_len = ntohs(ip->tot_len);
+
+	if (((ip->ihl * 4) + ntohs(udph->len)) > buffer->data_len)
+		goto bad_packet;
+	buffer->data_len = (ip->ihl * 4) + ntohs(udph->len);
+
+	copied = buffer->data_len - ((ip->ihl * 4) + sizeof(struct udphdr));
+
 	if (copied > len) {
 		copied = len;
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov,
-					      copied);
-	} else if (msg->msg_flags&MSG_TRUNC) {
-		if (__udp_checksum_complete(skb))
-			goto csum_copy_err;
-		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov,
-					      copied);
-	} else {
-		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
-
-		if (err == -EINVAL)
-			goto csum_copy_err;
-	}
-
-	if (err)
-		goto out_free;
-
-	sock_recv_timestamp(msg, sk, skb);
+/* FIXME: if card is calculating csum, should be using that rather
+ * than calculating here */
+	if (vj_udp_csum(buffer) != 0) //bad checksum
+		goto bad_packet;
+
+	err = vj_copy_datagram_iovec(buffer, udpoff + sizeof(struct udphdr), msg->msg_iov, copied);
+
+	if (err) {
+		vj_done_with_buffer(udp_sk(sk)->chan);
+		return err;
+	}
+
+	vj_sock_recv_timestamp(msg, sk);
 
 	/* Copy the address. */
 	if (sin)
 	{
 		sin->sin_family = AF_INET;
-		sin->sin_port = skb->h.uh->source;
-		sin->sin_addr.s_addr = skb->nh.iph->saddr;
+		sin->sin_port = udph->source;
+		sin->sin_addr.s_addr = ip->saddr;
 		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
   	}
+
+#if 0 				/* FIXME: implement this! */
 	if (inet->cmsg_flags)
 		ip_cmsg_recv(msg, skb);
+#endif
 
 	err = copied;
 	if (flags & MSG_TRUNC)
-		err = skb->len - sizeof(struct udphdr);
+		err = buffer->data_len - (ip->ihl * 4) - sizeof(struct udphdr);
+	if (!(flags & MSG_PEEK))
+		vj_done_with_buffer(udp_sk(sk)->chan);
   
-out_free:
-  	skb_free_datagram(sk, skb);
 out:
   	return err;
 
-csum_copy_err:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
-
-	skb_kill_datagram(sk, skb, flags);
-
-	if (noblock)
-		return -EAGAIN;	
+bad_packet:
+	vj_done_with_buffer(udp_sk(sk)->chan);
+	if(noblock)
+		return -EAGAIN;
 	goto try_again;
 }
 
@@ -858,10 +1021,15 @@
 int udp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	/*
 	 *	1003.1g - break association.
 	 */
-	 
+	if (up->vj_reg_flag) {
+		vj_unregister_chan(up->chan);
+		up->vj_reg_flag = 0;
+	}	
+ 
 	sk->sk_state = TCP_CLOSE;
 	inet->daddr = 0;
 	inet->dport = 0;
@@ -879,6 +1047,14 @@
 
 static void udp_close(struct sock *sk, long timeout)
 {
+	struct udp_sock *up = udp_sk(sk);
+
+	if (up->vj_reg_flag) {
+		vj_unregister_chan(up->chan);
+		up->vj_reg_flag = 0;
+	}
+	vj_free_chan(up->chan);
+
 	sk_common_release(sk);
 }
 
@@ -1293,6 +1469,46 @@
   	return 0;
 }
 
+unsigned int vj_datagram_poll(struct file *file, struct socket *sock, poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	unsigned int mask;
+
+	poll_wait(file, &udp_sk(sk)->chan->wq, wait);
+	vj_inc_wakecnt(udp_sk(sk)->chan);
+
+	mask = 0;
+
+	/* exceptional events? */
+	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+		mask |= POLLERR;
+	if (sk->sk_shutdown == SHUTDOWN_MASK)
+		mask |= POLLHUP;
+
+
+	/* readable? */
+	if (vj_peek_next_buffer(udp_sk(sk)->chan) ||
+	    (sk->sk_shutdown & RCV_SHUTDOWN))
+		mask |= POLLIN | POLLRDNORM;
+
+	/* Connection-based need to check for termination and startup */
+	if (connection_based(sk)) {
+		if (sk->sk_state == TCP_CLOSE)
+			mask |= POLLHUP;
+		/* connection hasn't started yet? */
+		if (sk->sk_state == TCP_SYN_SENT)
+			return mask;
+	}
+
+	/* writable? */
+	if (sock_writeable(sk))
+		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+	else
+		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+
+	return mask;
+}
+
 /**
  * 	udp_poll - wait for a UDP event.
  *	@file - file struct
@@ -1308,41 +1524,47 @@
  */
 unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
-	unsigned int mask = datagram_poll(file, sock, wait);
+	unsigned int mask = vj_datagram_poll(file, sock, wait);
 	struct sock *sk = sock->sk;
 	
 	/* Check for false positives due to checksum errors */
 	if ( (mask & POLLRDNORM) &&
 	     !(file->f_flags & O_NONBLOCK) &&
 	     !(sk->sk_shutdown & RCV_SHUTDOWN)){
-		struct sk_buff_head *rcvq = &sk->sk_receive_queue;
-		struct sk_buff *skb;
-
-		spin_lock_bh(&rcvq->lock);
-		while ((skb = skb_peek(rcvq)) != NULL) {
-			if (udp_checksum_complete(skb)) {
-				UDP_INC_STATS_BH(UDP_MIB_INERRORS);
-				__skb_unlink(skb, rcvq);
-				kfree_skb(skb);
-			} else {
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
+		struct vj_buffer *buffer;
+
+		while ((buffer = vj_peek_next_buffer(udp_sk(sk)->chan)) != NULL) {
+//test that this fixes the csum
+	check_ip_packet(buffer);
+			if (vj_udp_csum(buffer) == 0)
 				break;
-			}
-		}
-		spin_unlock_bh(&rcvq->lock);
+			UDP_INC_STATS_BH(UDP_MIB_INERRORS);
+			vj_done_with_buffer(udp_sk(sk)->chan);
+		}
 
 		/* nothing to see, move along */
-		if (skb == NULL)
+		if (buffer == NULL)
 			mask &= ~(POLLIN | POLLRDNORM);
 	}
 
 	return mask;
 	
 }
+
+static int udp_init(struct sock *sk)
+{
+	udp_sk(sk)->chan = vj_alloc_chan(0);
+	udp_sk(sk)->vj_reg_flag = 0;
+	if (!udp_sk(sk)->chan)
+		return -ENOMEM;
+	return 0;
+}
+
 
 struct proto udp_prot = {
  	.name =		"UDP",
 	.owner =	THIS_MODULE,
+	.init = 	udp_init,
 	.close =	udp_close,
 	.connect =	ip4_datagram_connect,
 	.disconnect =	udp_disconnect,
