From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/11) netrom - lock sockets during usage
Date: Wed, 13 Aug 2003 16:03:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813160300.64d3fb54.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeroen Vreeken <pe1rxq@amsat.org>

Lock sockets while doing protocol processing.

diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 12:22:36 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 12:22:36 2003
@@ -147,8 +147,10 @@
 	spin_lock_bh(&nr_list_lock);
 	sk_for_each(s, node, &nr_list)
 		if (!ax25cmp(&nr_sk(s)->source_addr, addr) &&
-		    s->sk_state == TCP_LISTEN)
+		    s->sk_state == TCP_LISTEN) {
+		    	bh_lock_sock(s);
 			goto found;
+		}
 	s = NULL;
 found:
 	spin_unlock_bh(&nr_list_lock);
@@ -167,8 +169,10 @@
 	sk_for_each(s, node, &nr_list) {
 		nr_cb *nr = nr_sk(s);
 		
-		if (nr->my_index == index && nr->my_id == id)
+		if (nr->my_index == index && nr->my_id == id) {
+			bh_lock_sock(s);
 			goto found;
+		}
 	}
 	s = NULL;
 found:
@@ -190,8 +194,10 @@
 		nr_cb *nr = nr_sk(s);
 		
 		if (nr->your_index == index && nr->your_id == id &&
-		    !ax25cmp(&nr->dest_addr, dest))
+		    !ax25cmp(&nr->dest_addr, dest)) {
+		    	bh_lock_sock(s);
 			goto found;
+		}
 	}
 	s = NULL;
 found:
@@ -206,14 +212,17 @@
 {
 	unsigned short id = circuit;
 	unsigned char i, j;
+	struct sock *sk;
 
 	for (;;) {
 		i = id / 256;
 		j = id % 256;
 
-		if (i != 0 && j != 0)
-			if (nr_find_socket(i, j) == NULL)
+		if (i != 0 && j != 0) {
+			if ((sk=nr_find_socket(i, j)) == NULL)
 				break;
+			bh_unlock_sock(sk);
+		}
 
 		id++;
 	}
@@ -231,7 +240,12 @@
  */
 static void nr_destroy_timer(unsigned long data)
 {
-	nr_destroy_socket((struct sock *)data);
+	struct sock *sk=(struct sock *)data;
+	bh_lock_sock(sk);
+	sock_hold(sk);
+	nr_destroy_socket(sk);
+	bh_unlock_sock(sk);
+	sock_put(sk);
 }
 
 /*
@@ -277,7 +291,7 @@
 		sk->sk_timer.data     = (unsigned long)sk;
 		add_timer(&sk->sk_timer);
 	} else
-		sk_free(sk);
+		sock_put(sk);
 }
 
 /*
@@ -391,12 +405,15 @@
 {
 	struct sock *sk = sock->sk;
 
+	lock_sock(sk);
 	if (sk->sk_state != TCP_LISTEN) {
 		memset(&nr_sk(sk)->user_addr, 0, AX25_ADDR_LEN);
 		sk->sk_max_ack_backlog = backlog;
 		sk->sk_state           = TCP_LISTEN;
+		release_sock(sk);
 		return 0;
 	}
+	release_sock(sk);
 
 	return -EOPNOTSUPP;
 }
@@ -498,6 +515,7 @@
 
 	if (sk == NULL) return 0;
 
+	lock_sock(sk);
 	nr = nr_sk(sk);
 
 	switch (nr->state) {
@@ -531,6 +549,7 @@
 	}
 
 	sock->sk   = NULL;	
+	release_sock(sk);
 
 	return 0;
 }
@@ -543,21 +562,26 @@
 	struct net_device *dev;
 	ax25_address *user, *source;
 
-	if (!sk->sk_zapped)
+	lock_sock(sk);
+	if (!sk->sk_zapped) {
+		release_sock(sk);
 		return -EINVAL;
-
-	if (addr_len < sizeof(struct sockaddr_ax25) || addr_len > sizeof(struct
-full_sockaddr_ax25))
+	}
+	if (addr_len < sizeof(struct sockaddr_ax25) || addr_len > sizeof(struct full_sockaddr_ax25)) {
+		release_sock(sk);
 		return -EINVAL;
-
-	if (addr_len < (addr->fsa_ax25.sax25_ndigis * sizeof(ax25_address) + sizeof(struct sockaddr_ax25)))
+	}
+	if (addr_len < (addr->fsa_ax25.sax25_ndigis * sizeof(ax25_address) + sizeof(struct sockaddr_ax25))) {
+		release_sock(sk);
 		return -EINVAL;
-
-	if (addr->fsa_ax25.sax25_family != AF_NETROM)
+	}
+	if (addr->fsa_ax25.sax25_family != AF_NETROM) {
+		release_sock(sk);
 		return -EINVAL;
-
+	}
 	if ((dev = nr_dev_get(&addr->fsa_ax25.sax25_call)) == NULL) {
 		SOCK_DEBUG(sk, "NET/ROM: bind failed: invalid node callsign\n");
+		release_sock(sk);
 		return -EADDRNOTAVAIL;
 	}
 
@@ -565,16 +589,22 @@
 	 * Only the super user can set an arbitrary user callsign.
 	 */
 	if (addr->fsa_ax25.sax25_ndigis == 1) {
-		if (!capable(CAP_NET_BIND_SERVICE))
+		if (!capable(CAP_NET_BIND_SERVICE)) {
+			dev_put(dev);
+			release_sock(sk);
 			return -EACCES;
+		}
 		nr->user_addr   = addr->fsa_digipeater[0];
 		nr->source_addr = addr->fsa_ax25.sax25_call;
 	} else {
 		source = &addr->fsa_ax25.sax25_call;
 
 		if ((user = ax25_findbyuid(current->euid)) == NULL) {
-			if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE))
+			if (ax25_uid_policy && !capable(CAP_NET_BIND_SERVICE)) {
+				release_sock(sk);
+				dev_put(dev);
 				return -EPERM;
+			}
 			user = source;
 		}
 
@@ -586,6 +616,8 @@
 	nr_insert_socket(sk);
 
 	sk->sk_zapped = 0;
+	dev_put(dev);
+	release_sock(sk);
 	SOCK_DEBUG(sk, "NET/ROM: socket is bound\n");
 	return 0;
 }
@@ -599,39 +631,50 @@
 	ax25_address *user, *source = NULL;
 	struct net_device *dev;
 
+	lock_sock(sk);
 	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
 		sock->state = SS_CONNECTED;
+		release_sock(sk);
 		return 0;	/* Connect completed during a ERESTARTSYS event */
 	}
 
 	if (sk->sk_state == TCP_CLOSE && sock->state == SS_CONNECTING) {
 		sock->state = SS_UNCONNECTED;
+		release_sock(sk);
 		return -ECONNREFUSED;
 	}
 
-	if (sk->sk_state == TCP_ESTABLISHED)
+	if (sk->sk_state == TCP_ESTABLISHED) {
+		release_sock(sk);
 		return -EISCONN;	/* No reconnect on a seqpacket socket */
+	}
 
 	sk->sk_state   = TCP_CLOSE;	
 	sock->state = SS_UNCONNECTED;
 
-	if (addr_len != sizeof(struct sockaddr_ax25) && addr_len != sizeof(struct full_sockaddr_ax25))
+	if (addr_len != sizeof(struct sockaddr_ax25) && addr_len != sizeof(struct full_sockaddr_ax25)) {
+		release_sock(sk);
 		return -EINVAL;
-
-	if (addr->sax25_family != AF_NETROM)
+	}
+	if (addr->sax25_family != AF_NETROM) {
+		release_sock(sk);
 		return -EINVAL;
-
+	}
 	if (sk->sk_zapped) {	/* Must bind first - autobinding in this may or may not work */
 		sk->sk_zapped = 0;
 
-		if ((dev = nr_dev_first()) == NULL)
+		if ((dev = nr_dev_first()) == NULL) {
+			release_sock(sk);
 			return -ENETUNREACH;
-
+		}
 		source = (ax25_address *)dev->dev_addr;
 
 		if ((user = ax25_findbyuid(current->euid)) == NULL) {
-			if (ax25_uid_policy && !capable(CAP_NET_ADMIN))
+			if (ax25_uid_policy && !capable(CAP_NET_ADMIN)) {
+				dev_put(dev);
+				release_sock(sk);
 				return -EPERM;
+			}
 			user = source;
 		}
 
@@ -639,12 +682,15 @@
 		nr->source_addr = *source;
 		nr->device      = dev;
 
+		dev_put(dev);
 		nr_insert_socket(sk);		/* Finish the bind */
 	}
 
 	nr->dest_addr = addr->sax25_call;
 
+	release_sock(sk);
 	circuit = nr_find_next_circuit();
+	lock_sock(sk);
 
 	nr->my_index = circuit / 256;
 	nr->my_id    = circuit % 256;
@@ -662,8 +708,10 @@
 	nr_start_heartbeat(sk);
 
 	/* Now the loop */
-	if (sk->sk_state != TCP_ESTABLISHED && (flags & O_NONBLOCK))
+	if (sk->sk_state != TCP_ESTABLISHED && (flags & O_NONBLOCK)) {
+		release_sock(sk);
 		return -EINPROGRESS;
+	}
 		
 	/*
 	 * A Connect Ack with Choke or timeout or failed routing will go to
@@ -678,8 +726,10 @@
 			set_current_state(TASK_INTERRUPTIBLE);
 			if (sk->sk_state != TCP_SYN_SENT)
 				break;
+			release_sock(sk);
 			if (!signal_pending(tsk)) {
 				schedule();
+				lock_sock(sk);
 				continue;
 			}
 			return -ERESTARTSYS;
@@ -690,10 +740,12 @@
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		sock->state = SS_UNCONNECTED;
+		release_sock(sk);
 		return sock_error(sk);	/* Always set at this point */
 	}
 
 	sock->state = SS_CONNECTED;
+	release_sock(sk);
 
 	return 0;
 }
@@ -756,6 +808,7 @@
 	newsock->sk = newsk;
 
 out:
+	release_sock(sk);
 	return err;
 }
 
@@ -766,9 +819,12 @@
 	struct sock *sk = sock->sk;
 	nr_cb *nr = nr_sk(sk);
 
+	lock_sock(sk);
 	if (peer != 0) {
-		if (sk->sk_state != TCP_ESTABLISHED)
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			release_sock(sk);
 			return -ENOTCONN;
+		}
 		sax->fsa_ax25.sax25_family = AF_NETROM;
 		sax->fsa_ax25.sax25_ndigis = 1;
 		sax->fsa_ax25.sax25_call   = nr->user_addr;
@@ -780,6 +836,7 @@
 		sax->fsa_ax25.sax25_call   = nr->source_addr;
 		*uaddr_len = sizeof(struct sockaddr_ax25);
 	}
+	release_sock(sk);
 
 	return 0;
 }
@@ -793,6 +850,7 @@
 	unsigned short circuit_index, circuit_id;
 	unsigned short peer_circuit_index, peer_circuit_id;
 	unsigned short frametype, flags, window, timeout;
+	int ret;
 
 	skb->sk = NULL;		/* Initially we don't know who it's for */
 
@@ -850,7 +908,9 @@
 		else
 			nr_sk(sk)->bpqext = 0;
 
-		return nr_process_rx_frame(sk, skb);
+		ret = nr_process_rx_frame(sk, skb);
+		bh_unlock_sock(sk);
+		return ret;
 	}
 
 	/*
@@ -880,6 +940,8 @@
 	if (!sk || sk->sk_ack_backlog == sk->sk_max_ack_backlog ||
 	    (make = nr_make_new(sk)) == NULL) {
 		nr_transmit_refusal(skb, 0);
+		if (sk)
+			bh_unlock_sock(sk);
 		return 0;
 	}
 
@@ -897,7 +959,9 @@
 	nr_make->your_index  = circuit_index;
 	nr_make->your_id     = circuit_id;
 
+	bh_unlock_sock(sk);
 	circuit = nr_find_next_circuit();
+	bh_lock_sock(sk);
 
 	nr_make->my_index    = circuit / 256;
 	nr_make->my_id       = circuit % 256;
@@ -939,6 +1003,7 @@
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, skb->len);
 
+	bh_unlock_sock(sk);
 	return 1;
 }
 
@@ -957,28 +1022,42 @@
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR))
 		return -EINVAL;
 
-	if (sk->sk_zapped)
-		return -EADDRNOTAVAIL;
+	lock_sock(sk);
+	if (sk->sk_zapped) {
+		err = -EADDRNOTAVAIL;
+		goto out;
+	}
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
 		send_sig(SIGPIPE, current, 0);
-		return -EPIPE;
+		err = -EPIPE;
+		goto out;
 	}
 
-	if (nr->device == NULL)
-		return -ENETUNREACH;
+	if (nr->device == NULL) {
+		err = -ENETUNREACH;
+		goto out;
+	}
 
 	if (usax) {
-		if (msg->msg_namelen < sizeof(sax))
-			return -EINVAL;
+		if (msg->msg_namelen < sizeof(sax)) {
+			err = -EINVAL;
+			goto out;
+		}
 		sax = *usax;
-		if (ax25cmp(&nr->dest_addr, &sax.sax25_call) != 0)
-			return -EISCONN;
-		if (sax.sax25_family != AF_NETROM)
-			return -EINVAL;
+		if (ax25cmp(&nr->dest_addr, &sax.sax25_call) != 0) {
+			err = -EISCONN;
+			goto out;
+		}
+		if (sax.sax25_family != AF_NETROM) {
+			err = -EINVAL;
+			goto out;
+		}
 	} else {
-		if (sk->sk_state != TCP_ESTABLISHED)
-			return -ENOTCONN;
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			err = -ENOTCONN;
+			goto out;
+		}
 		sax.sax25_family = AF_NETROM;
 		sax.sax25_call   = nr->dest_addr;
 	}
@@ -987,10 +1066,10 @@
 
 	/* Build a packet */
 	SOCK_DEBUG(sk, "NET/ROM: sendto: building packet.\n");
-	size = len + AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + NR_TRANSPORT_LEN;
+	size = len + NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 
 	if ((skb = sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT, &err)) == NULL)
-		return err;
+		goto out;
 
 	skb_reserve(skb, size - len);
 
@@ -1025,12 +1104,16 @@
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		kfree_skb(skb);
-		return -ENOTCONN;
+		err = -ENOTCONN;
+		goto out;
 	}
 
 	nr_output(sk, skb);	/* Shove it onto the queue */
 
-	return len;
+	err = len;
+out:
+	release_sock(sk);
+	return err;
 }
 
 static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
@@ -1047,12 +1130,17 @@
 	 * us! We do one quick check first though
 	 */
 
-	if (sk->sk_state != TCP_ESTABLISHED)
+	lock_sock(sk);
+	if (sk->sk_state != TCP_ESTABLISHED) {
+		release_sock(sk);
 		return -ENOTCONN;
+	}
 
 	/* Now we can treat all alike */
-	if ((skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er)) == NULL)
+	if ((skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er)) == NULL) {
+		release_sock(sk);
 		return er;
+	}
 
 	skb->h.raw = skb->data;
 	copied     = skb->len;
@@ -1073,6 +1161,7 @@
 
 	skb_free_datagram(sk, skb);
 
+	release_sock(sk);
 	return copied;
 }
 
@@ -1080,13 +1169,16 @@
 static int nr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
+	int ret;
 
+	lock_sock(sk);
 	switch (cmd) {
 	case TIOCOUTQ: {
 		long amount;
 		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
 		if (amount < 0)
 			amount = 0;
+		release_sock(sk);
 		return put_user(amount, (int *)arg);
 	}
 
@@ -1096,15 +1188,21 @@
 		/* These two are safe on a single CPU system as only user tasks fiddle here */
 		if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
 			amount = skb->len;
+		release_sock(sk);
 		return put_user(amount, (int *)arg);
 	}
 
 	case SIOCGSTAMP:
 		if (sk != NULL) {
-			if (!sk->sk_stamp.tv_sec)
+			if (!sk->sk_stamp.tv_sec) {
+				release_sock(sk);
 				return -ENOENT;
-			return copy_to_user((void *)arg, &sk->sk_stamp, sizeof(struct timeval)) ? -EFAULT : 0;
+			}
+			ret = copy_to_user((void *)arg, &sk->sk_stamp, sizeof(struct timeval)) ? -EFAULT : 0;
+			release_sock(sk);
+			return ret;
 		}
+		release_sock(sk);
 		return -EINVAL;
 
 	case SIOCGIFADDR:
@@ -1117,17 +1215,21 @@
 	case SIOCSIFNETMASK:
 	case SIOCGIFMETRIC:
 	case SIOCSIFMETRIC:
+		release_sock(sk);
 		return -EINVAL;
 
 	case SIOCADDRT:
 	case SIOCDELRT:
 	case SIOCNRDECOBS:
+		release_sock(sk);
 		if (!capable(CAP_NET_ADMIN)) return -EPERM;
 		return nr_rt_ioctl(cmd, (void *)arg);
 
 	default:
+		release_sock(sk);
 		return dev_ioctl(cmd, (void *)arg);
 	}
+	release_sock(sk);
 
 	return 0;
 }
@@ -1147,7 +1249,9 @@
 	len += sprintf(buffer, "user_addr dest_node src_node  dev    my  your  st  vs  vr  va    t1     t2     t4      idle   n2  wnd Snd-Q Rcv-Q inode\n");
 
 	sk_for_each(s, node, &nr_list) {
-		nr_cb *nr = nr_sk(s);
+		nr_cb *nr;
+		bh_lock_sock(s);
+		nr = nr_sk(s);
 
 		if ((dev = nr->device) == NULL)
 			devname = "???";
@@ -1190,7 +1294,7 @@
 			len   = 0;
 			begin = pos;
 		}
-
+		bh_unlock_sock(s);
 		if (pos > offset + length)
 			break;
 	}
diff -Nru a/net/netrom/nr_in.c b/net/netrom/nr_in.c
--- a/net/netrom/nr_in.c	Wed Aug 13 12:22:36 2003
+++ b/net/netrom/nr_in.c	Wed Aug 13 12:22:36 2003
@@ -74,6 +74,7 @@
 static int nr_state1_machine(struct sock *sk, struct sk_buff *skb,
 	int frametype)
 {
+	bh_lock_sock(sk);
 	switch (frametype) {
 	case NR_CONNACK: {
 		nr_cb *nr = nr_sk(sk);
@@ -102,6 +103,7 @@
 	default:
 		break;
 	}
+	bh_unlock_sock(sk);
 
 	return 0;
 }
@@ -114,6 +116,7 @@
 static int nr_state2_machine(struct sock *sk, struct sk_buff *skb,
 	int frametype)
 {
+	bh_lock_sock(sk);
 	switch (frametype) {
 	case NR_CONNACK | NR_CHOKE_FLAG:
 		nr_disconnect(sk, ECONNRESET);
@@ -129,6 +132,7 @@
 	default:
 		break;
 	}
+	bh_unlock_sock(sk);
 
 	return 0;
 }
@@ -150,6 +154,7 @@
 	nr = skb->data[18];
 	ns = skb->data[17];
 
+	bh_lock_sock(sk);
 	switch (frametype) {
 	case NR_CONNREQ:
 		nr_write_internal(sk, NR_CONNACK);
@@ -260,6 +265,7 @@
 	default:
 		break;
 	}
+	bh_unlock_sock(sk);
 
 	return queued;
 }
diff -Nru a/net/netrom/nr_timer.c b/net/netrom/nr_timer.c
--- a/net/netrom/nr_timer.c	Wed Aug 13 12:22:36 2003
+++ b/net/netrom/nr_timer.c	Wed Aug 13 12:22:36 2003
@@ -143,7 +143,10 @@
 		   is accepted() it isn't 'dead' so doesn't get removed. */
 		if (sock_flag(sk, SOCK_DESTROY) ||
 		    (sk->sk_state == TCP_LISTEN && sock_flag(sk, SOCK_DEAD))) {
+			sock_hold(sk);
 			nr_destroy_socket(sk);
+			bh_unlock_sock(sk);
+			sock_put(sk);
 			return;
 		}
 		break;
@@ -227,6 +230,7 @@
 	case NR_STATE_1:
 		if (nr->n2count == nr->n2) {
 			nr_disconnect(sk, ETIMEDOUT);
+			bh_unlock_sock(sk);
 			return;
 		} else {
 			nr->n2count++;
@@ -237,6 +241,7 @@
 	case NR_STATE_2:
 		if (nr->n2count == nr->n2) {
 			nr_disconnect(sk, ETIMEDOUT);
+			bh_unlock_sock(sk);
 			return;
 		} else {
 			nr->n2count++;
@@ -247,6 +252,7 @@
 	case NR_STATE_3:
 		if (nr->n2count == nr->n2) {
 			nr_disconnect(sk, ETIMEDOUT);
+			bh_unlock_sock(sk);
 			return;
 		} else {
 			nr->n2count++;
