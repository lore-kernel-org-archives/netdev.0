From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Avoid gettimeofday when not needed
Date: Wed, 31 Mar 2004 14:01:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403311201.i2VC13D19579@zero.aec.at>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch implements an optimization I proposed a long time 
ago. gettimeofday can be quite costly and it currently is 
on the fast path of every packet. Normally the packet time stamp
is not needed (e.g. TCP doesn't use it), except for tcpdump
and a few applications.

This patch adds a global counter that is enabled only when
some socket is interested in time stamps. There is a small race
window after enabling the timestamp when there are already packets
queued without timestamp. In this case just the current time
is filled in. For simplicity the counter is only decremented
after the socket has been destroyed again.

sunrpc was using the timestamp too, but I just changed it to
use xtime (which is accurate enough and true end2end latency
including host latencies is better anyways) 

The patch deletes nearly as much code as it adds because it cleans
up a lot of duplicated code in various socket disciplines.

I didn't benchmark much (mostly because all my machines have
quite fast gettimeofday), some feedback on how much it helps
would be appreciated (especially on machines with slow gettimeofday,
like IBM summit or Altix) 

One warning: bind9 seems to enable the time stamp. If you do benchmarks
kill the name server. This should be probably fixed in user space.

Most of the patch is quite straight forward, except for the change in the
v4/v6 proxy arp code. I assume it was checking the time stamp to distingush
locally originated packets from external packets (?). I changed it
to use skb->sk instead. I'm not 100% sure if I guessed the intention
correctly and don't know why it should check that anyways. 
Someone should review that change.

-Andi

diff -u linux-2.6.5rc3-averell/include/net/sock.h-T linux-2.6.5rc3-averell/include/net/sock.h
--- linux-2.6.5rc3-averell/include/net/sock.h-T	2004-03-21 21:11:55.000000000 +0100
+++ linux-2.6.5rc3-averell/include/net/sock.h	2004-03-31 09:44:02.000000000 +0200
@@ -382,6 +382,7 @@
 	SOCK_LINGER,
 	SOCK_DESTROY,
 	SOCK_BROADCAST,
+	SOCK_TIMESTAMP,
 };
 
 static inline void sock_set_flag(struct sock *sk, enum sock_flags flag)
@@ -1023,11 +1024,33 @@
 static __inline__ void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
-	if (sk->sk_rcvtstamp)
-		put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMP, sizeof(skb->stamp), &skb->stamp);
-	else
-		sk->sk_stamp = skb->stamp;
-}
+	struct timeval *stamp = &skb->stamp;
+	if (sk->sk_rcvtstamp) { 
+		/* Race occurred between timestamp enabling and packet
+		   receiving.  Fill in the current time for now. */
+		if (stamp->tv_sec == 0)
+			do_gettimeofday(stamp);
+		put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMP, sizeof(struct timeval),
+			 stamp);
+	} else
+		sk->sk_stamp = *stamp;
+}
+
+extern atomic_t netstamp_needed;
+extern void sock_enable_timestamp(struct sock *sk);
+extern void sock_disable_timestamp(struct sock *sk);
+
+static inline void net_timestamp(struct timeval *stamp) 
+{ 
+	if (atomic_read(&netstamp_needed)) 
+		do_gettimeofday(stamp);
+	else {
+		stamp->tv_sec = 0;
+		stamp->tv_usec = 0;
+	}		
+} 
+
+extern int sock_get_timestamp(struct sock *, struct timeval *);
 
 /* 
  *	Enable debug/info messages 
diff -u linux-2.6.5rc3-averell/net/core/sock.c-T linux-2.6.5rc3-averell/net/core/sock.c
--- linux-2.6.5rc3-averell/net/core/sock.c-T	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5rc3-averell/net/core/sock.c	2004-03-31 13:45:57.000000000 +0200
@@ -328,6 +328,8 @@
 
 		case SO_TIMESTAMP:
 			sk->sk_rcvtstamp = valbool;
+			if (valbool) 
+				sock_enable_timestamp(sk);
 			break;
 
 		case SO_RCVLOWAT:
@@ -642,6 +644,8 @@
 		sk->sk_filter = NULL;
 	}
 
+	sock_disable_timestamp(sk);
+
 	if (atomic_read(&sk->sk_omem_alloc))
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
 		       __FUNCTION__, atomic_read(&sk->sk_omem_alloc));
@@ -1135,6 +1139,9 @@
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 	sk->sk_owner		=	NULL;
 
+	sk->sk_stamp.tv_sec     = -1L;
+	sk->sk_stamp.tv_usec    = -1L;
+
 	atomic_set(&sk->sk_refcnt, 1);
 }
 
@@ -1160,9 +1167,42 @@
 		wake_up(&(sk->sk_lock.wq));
 	spin_unlock_bh(&(sk->sk_lock.slock));
 }
-
 EXPORT_SYMBOL(release_sock);
 
+/* When > 0 there are consumers of rx skb time stamps */
+atomic_t netstamp_needed = ATOMIC_INIT(0); 
+
+int sock_get_timestamp(struct sock *sk, struct timeval *userstamp)
+{ 
+	if (!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	if (sk->sk_stamp.tv_sec == -1) 
+		return -ENOENT;
+	if (sk->sk_stamp.tv_sec == 0)
+		do_gettimeofday(&sk->sk_stamp);
+	return copy_to_user(userstamp, &sk->sk_stamp, sizeof(struct timeval)) ?
+		-EFAULT : 0; 
+} 
+EXPORT_SYMBOL(sock_get_timestamp);
+
+void sock_enable_timestamp(struct sock *sk)
+{	
+	if (!sock_flag(sk, SOCK_TIMESTAMP)) { 
+		sock_set_flag(sk, SOCK_TIMESTAMP);
+		atomic_inc(&netstamp_needed);
+	}
+}
+EXPORT_SYMBOL(sock_enable_timestamp); 
+
+void sock_disable_timestamp(struct sock *sk)
+{	
+	if (sock_flag(sk, SOCK_TIMESTAMP)) { 
+		sock_reset_flag(sk, SOCK_TIMESTAMP);
+		atomic_dec(&netstamp_needed);
+	}
+}
+EXPORT_SYMBOL(sock_disable_timestamp);
+
 EXPORT_SYMBOL(__lock_sock);
 EXPORT_SYMBOL(__release_sock);
 EXPORT_SYMBOL(sk_alloc);
diff -u linux-2.6.5rc3-averell/net/core/dev.c-T linux-2.6.5rc3-averell/net/core/dev.c
--- linux-2.6.5rc3-averell/net/core/dev.c-T	2004-03-22 01:28:39.000000000 +0100
+++ linux-2.6.5rc3-averell/net/core/dev.c	2004-03-31 09:44:02.000000000 +0200
@@ -1125,7 +1125,7 @@
 void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct packet_type *ptype;
-	do_gettimeofday(&skb->stamp);
+	net_timestamp(&skb->stamp);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
@@ -1546,9 +1546,9 @@
 		return NET_RX_DROP;
 	}
 #endif
-
+	
 	if (!skb->stamp.tv_sec)
-		do_gettimeofday(&skb->stamp);
+		net_timestamp(&skb->stamp);
 
 	/*
 	 * The code is rearranged so that the path is the most
@@ -1710,7 +1710,7 @@
 #endif
 
 	if (!skb->stamp.tv_sec)
-		do_gettimeofday(&skb->stamp);
+		net_timestamp(&skb->stamp);
 
 	skb_bond(skb);
 
diff -u linux-2.6.5rc3-averell/net/ipv4/af_inet.c-T linux-2.6.5rc3-averell/net/ipv4/af_inet.c
--- linux-2.6.5rc3-averell/net/ipv4/af_inet.c-T	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5rc3-averell/net/ipv4/af_inet.c	2004-03-31 09:44:02.000000000 +0200
@@ -843,11 +843,7 @@
 
 	switch (cmd) {
 		case SIOCGSTAMP:
-			if (!sk->sk_stamp.tv_sec)
-				err = -ENOENT;
-			else if (copy_to_user((void *)arg, &sk->sk_stamp,
-					      sizeof(struct timeval)))
-				err = -EFAULT;
+			err = sock_get_timestamp(sk, (struct timeval *)arg);
 			break;
 		case SIOCADDRT:
 		case SIOCDELRT:
diff -u linux-2.6.5rc3-averell/net/ipv4/arp.c-T linux-2.6.5rc3-averell/net/ipv4/arp.c
--- linux-2.6.5rc3-averell/net/ipv4/arp.c-T	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5rc3-averell/net/ipv4/arp.c	2004-03-31 09:44:02.000000000 +0200
@@ -860,7 +860,17 @@
 				if (n)
 					neigh_release(n);
 
-				if (skb->stamp.tv_sec == 0 ||
+				/* Previous code here tested 
+				   skb->stamp.tv_sec != 0. I can only guess
+				   what the author intended with this -
+				   maybe check for packets that have originated
+				   locally. Most likely it was a bug because
+				   there are all kinds of situations where
+				   even a local packet can have a stamp.
+				   It is replaced with an ->sk check
+				   now, which also won't trigger for 
+				   received packets. -AK */
+				if (skb->sk != NULL || 
 				    skb->pkt_type == PACKET_HOST ||
 				    in_dev->arp_parms->proxy_delay == 0) {
 					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
diff -u linux-2.6.5rc3-averell/net/sunrpc/svcsock.c-T linux-2.6.5rc3-averell/net/sunrpc/svcsock.c
--- linux-2.6.5rc3-averell/net/sunrpc/svcsock.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/sunrpc/svcsock.c	2004-03-31 09:44:02.000000000 +0200
@@ -591,6 +591,12 @@
 		/* possibly an icmp error */
 		dprintk("svc: recvfrom returned error %d\n", -err);
 	}
+	if (skb->stamp.tv_sec == 0) {
+		skb->stamp.tv_sec = xtime.tv_sec; 
+		skb->stamp.tv_usec = xtime.tv_nsec * 1000; 
+		/* Don't enable netstamp, sunrpc doesn't 
+		   need that much accuracy */
+	}
 	svsk->sk_sk->sk_stamp = skb->stamp;
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
diff -u linux-2.6.5rc3-averell/net/rose/af_rose.c-T linux-2.6.5rc3-averell/net/rose/af_rose.c
--- linux-2.6.5rc3-averell/net/rose/af_rose.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/rose/af_rose.c	2004-03-31 09:44:02.000000000 +0200
@@ -1269,12 +1269,8 @@
 	}
 
 	case SIOCGSTAMP:
-		if (sk != NULL) {
-			if (!sk->sk_stamp.tv_sec)
-				return -ENOENT;
-			return copy_to_user((void *)arg, &sk->sk_stamp,
-					  sizeof(struct timeval)) ? -EFAULT : 0;
-		}
+		if (sk != NULL) 
+			return sock_get_timestamp(sk, (struct timeval *)arg);
 		return -EINVAL;
 
 	case SIOCGIFADDR:
diff -u linux-2.6.5rc3-averell/net/irda/af_irda.c-T linux-2.6.5rc3-averell/net/irda/af_irda.c
--- linux-2.6.5rc3-averell/net/irda/af_irda.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/irda/af_irda.c	2004-03-31 09:44:02.000000000 +0200
@@ -1796,14 +1796,8 @@
 	}
 
 	case SIOCGSTAMP:
-		if (sk != NULL) {
-			if (!sk->sk_stamp.tv_sec)
-				return -ENOENT;
-			if (copy_to_user((void *)arg, &sk->sk_stamp,
-					 sizeof(struct timeval)))
-				return -EFAULT;
-			return 0;
-		}
+		if (sk != NULL)
+			return sock_get_timestamp(sk, (struct timeval *)arg);
 		return -EINVAL;
 
 	case SIOCGIFADDR:
diff -u linux-2.6.5rc3-averell/net/ipx/af_ipx.c-T linux-2.6.5rc3-averell/net/ipx/af_ipx.c
--- linux-2.6.5rc3-averell/net/ipx/af_ipx.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/ipx/af_ipx.c	2004-03-31 09:44:02.000000000 +0200
@@ -1797,7 +1797,8 @@
 				     copied);
 	if (rc)
 		goto out_free;
-	sk->sk_stamp = skb->stamp;
+	if (skb->stamp.tv_sec)
+		sk->sk_stamp = skb->stamp;
 
 	msg->msg_namelen = sizeof(*sipx);
 
@@ -1870,15 +1871,8 @@
 		break;
 	case SIOCGSTAMP:
 		rc = -EINVAL;
-		if (sk) {
-			rc = -ENOENT;
-			if (!sk->sk_stamp.tv_sec)
-				break;
-			rc = -EFAULT;
-			if (!copy_to_user((void *)arg, &sk->sk_stamp,
-					  sizeof(struct timeval)))
-				rc = 0;
-		}
+		if (sk) 
+			rc = sock_get_timestamp(sk, (struct timeval *)arg);
 		break;
 	case SIOCGIFDSTADDR:
 	case SIOCSIFDSTADDR:
diff -u linux-2.6.5rc3-averell/net/atm/ioctl.c-T linux-2.6.5rc3-averell/net/atm/ioctl.c
--- linux-2.6.5rc3-averell/net/atm/ioctl.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/atm/ioctl.c	2004-03-31 09:44:02.000000000 +0200
@@ -76,12 +76,8 @@
 				goto done;
 			}
 		case SIOCGSTAMP: /* borrowed from IP */
-			if (!vcc->sk->sk_stamp.tv_sec) {
-				error = -ENOENT;
-				goto done;
-			}
-			error = copy_to_user((void *)arg, &vcc->sk->sk_stamp,
-					     sizeof(struct timeval)) ? -EFAULT : 0;
+			error = sock_get_timestamp(vcc->sk, (struct timeval *)
+						   arg);
 			goto done;
 		case ATM_SETSC:
 			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
diff -u linux-2.6.5rc3-averell/net/ax25/af_ax25.c-T linux-2.6.5rc3-averell/net/ax25/af_ax25.c
--- linux-2.6.5rc3-averell/net/ax25/af_ax25.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/ax25/af_ax25.c	2004-03-31 09:44:02.000000000 +0200
@@ -1694,12 +1694,7 @@
 
 	case SIOCGSTAMP:
 		if (sk != NULL) {
-			if (!sk->sk_stamp.tv_sec) {
-				res = -ENOENT;
-				break;
-			}
-			res = copy_to_user((void *)arg, &sk->sk_stamp,
-					  sizeof(struct timeval)) ? -EFAULT : 0;
+			res = sock_get_timestamp(sk, (struct timeval *)arg);
 			break;
 	 	}
 		res = -EINVAL;
diff -u linux-2.6.5rc3-averell/net/ipv6/af_inet6.c-T linux-2.6.5rc3-averell/net/ipv6/af_inet6.c
--- linux-2.6.5rc3-averell/net/ipv6/af_inet6.c-T	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5rc3-averell/net/ipv6/af_inet6.c	2004-03-31 09:44:02.000000000 +0200
@@ -474,13 +474,7 @@
 	switch(cmd) 
 	{
 	case SIOCGSTAMP:
-		if (!sk->sk_stamp.tv_sec)
-			return -ENOENT;
-		err = copy_to_user((void *)arg, &sk->sk_stamp,
-				   sizeof(struct timeval));
-		if (err)
-			return -EFAULT;
-		return 0;
+		return sock_get_timestamp(sk, (struct timeval *)arg);
 
 	case SIOCADDRT:
 	case SIOCDELRT:
diff -u linux-2.6.5rc3-averell/net/ipv6/ndisc.c-T linux-2.6.5rc3-averell/net/ipv6/ndisc.c
--- linux-2.6.5rc3-averell/net/ipv6/ndisc.c-T	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5rc3-averell/net/ipv6/ndisc.c	2004-03-31 09:44:02.000000000 +0200
@@ -761,7 +761,8 @@
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding && 
 		     pneigh_lookup(&nd_tbl, &msg->target, dev, 0))) {
-			if (skb->stamp.tv_sec != 0 &&
+			/* See comment in arp.c about the weird sk check */
+			if (skb->sk == NULL &&
 			    skb->pkt_type != PACKET_HOST &&
 			    inc != 0 &&
 			    idev->nd_parms->proxy_delay != 0) {
diff -u linux-2.6.5rc3-averell/net/rxrpc/transport.c-T linux-2.6.5rc3-averell/net/rxrpc/transport.c
--- linux-2.6.5rc3-averell/net/rxrpc/transport.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/rxrpc/transport.c	2004-03-31 09:44:02.000000000 +0200
@@ -341,6 +341,11 @@
 	msg->trans = trans;
 	msg->state = RXRPC_MSG_RECEIVED;
 	msg->stamp = pkt->stamp;
+	if (msg->stamp.tv_sec == 0) {
+		do_gettimeofday(&msg->stamp); 
+		if (skb->sk) 
+			sock_enable_netstamp(skb->sk);
+	} 
 	msg->seq = ntohl(msg->hdr.seq);
 
 	/* attach the packet */
diff -u linux-2.6.5rc3-averell/net/sctp/input.c-T linux-2.6.5rc3-averell/net/sctp/input.c
--- linux-2.6.5rc3-averell/net/sctp/input.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/sctp/input.c	2004-03-31 09:44:02.000000000 +0200
@@ -175,6 +175,12 @@
 	rcvr = asoc ? &asoc->base : &ep->base;
 	sk = rcvr->sk;
 
+	/* SCTP seems to always need a timestamp right now (FIXME) */
+	if (skb->stamp.tv_sec == 0) {
+		do_gettimeofday(&skb->stamp);
+		sock_enable_timestamp(sk); 
+	}
+
 	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb, family))
 		goto discard_release;
 
diff -u linux-2.6.5rc3-averell/net/x25/af_x25.c-T linux-2.6.5rc3-averell/net/x25/af_x25.c
--- linux-2.6.5rc3-averell/net/x25/af_x25.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/x25/af_x25.c	2004-03-31 09:44:02.000000000 +0200
@@ -1206,14 +1206,10 @@
 		}
 
 		case SIOCGSTAMP:
-			if (sk) {
-				rc = -ENOENT;
-				if (!sk->sk_stamp.tv_sec)
-					break;
-				rc = copy_to_user((void *)arg, &sk->sk_stamp,
-						  sizeof(struct timeval)) ? -EFAULT : 0;
-			}
 			rc = -EINVAL;
+			if (sk)
+				rc = sock_get_timestamp(sk, 
+						(struct timeval *)arg); 
 			break;
 		case SIOCGIFADDR:
 		case SIOCSIFADDR:
diff -u linux-2.6.5rc3-averell/net/wanrouter/af_wanpipe.c-T linux-2.6.5rc3-averell/net/wanrouter/af_wanpipe.c
--- linux-2.6.5rc3-averell/net/wanrouter/af_wanpipe.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/wanrouter/af_wanpipe.c	2004-03-31 09:44:02.000000000 +0200
@@ -1765,13 +1765,7 @@
 	switch(cmd) 
 	{
 		case SIOCGSTAMP:
-			if (!sk->sk_stamp.tv_sec)
-				return -ENOENT;
-			err = -EFAULT;
-			if (!copy_to_user((void *)arg, &sk->sk_stamp,
-			    sizeof(struct timeval)))
-				err = 0;
-			return err;
+			return sock_get_timestamp(sk, (struct timeval *)arg);
 
 		case SIOC_WANPIPE_CHECK_TX:
 
diff -u linux-2.6.5rc3-averell/net/packet/af_packet.c-T linux-2.6.5rc3-averell/net/packet/af_packet.c
--- linux-2.6.5rc3-averell/net/packet/af_packet.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/packet/af_packet.c	2004-03-31 09:44:02.000000000 +0200
@@ -606,6 +606,10 @@
 	h->tp_snaplen = snaplen;
 	h->tp_mac = macoff;
 	h->tp_net = netoff;
+	if (skb->stamp.tv_sec == 0) { 
+		do_gettimeofday(&skb->stamp);
+		sock_enable_timestamp(sk);
+	}
 	h->tp_sec = skb->stamp.tv_sec;
 	h->tp_usec = skb->stamp.tv_usec;
 
@@ -1442,13 +1446,8 @@
 			return put_user(amount, (int *)arg);
 		}
 		case SIOCGSTAMP:
-			if (!sk->sk_stamp.tv_sec)
-				return -ENOENT;
-			if (copy_to_user((void *)arg, &sk->sk_stamp,
-					 sizeof(struct timeval)))
-				return -EFAULT;
-			break;
-
+			return sock_get_timestamp(sk, (struct timeval *)arg);
+			
 #ifdef CONFIG_INET
 		case SIOCADDRT:
 		case SIOCDELRT:
diff -u linux-2.6.5rc3-averell/net/netrom/af_netrom.c-T linux-2.6.5rc3-averell/net/netrom/af_netrom.c
--- linux-2.6.5rc3-averell/net/netrom/af_netrom.c-T	2004-03-21 21:12:00.000000000 +0100
+++ linux-2.6.5rc3-averell/net/netrom/af_netrom.c	2004-03-31 09:44:02.000000000 +0200
@@ -1200,17 +1200,11 @@
 	}
 
 	case SIOCGSTAMP:
-		if (sk != NULL) {
-			if (!sk->sk_stamp.tv_sec) {
-				release_sock(sk);
-				return -ENOENT;
-			}
-			ret = copy_to_user((void *)arg, &sk->sk_stamp, sizeof(struct timeval)) ? -EFAULT : 0;
-			release_sock(sk);
-			return ret;
-		}
+		ret = -EINVAL;
+		if (sk != NULL)
+			ret = sock_get_timestamp(sk, (struct timeval *)arg);
 		release_sock(sk);
-		return -EINVAL;
+		return ret;
 
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
diff -u linux-2.6.5rc3-averell/net/appletalk/ddp.c-T linux-2.6.5rc3-averell/net/appletalk/ddp.c
--- linux-2.6.5rc3-averell/net/appletalk/ddp.c-T	1970-01-01 01:12:51.000000000 +0100
+++ linux-2.6.5rc3-averell/net/appletalk/ddp.c	2004-03-31 09:44:02.000000000 +0200
@@ -1795,13 +1795,7 @@
 			break;
 		}
 		case SIOCGSTAMP:
-			if (!sk)
-				break;
-			rc = -ENOENT;
-			if (!sk->sk_stamp.tv_sec)
-				break;
-			rc = copy_to_user((void *)arg, &sk->sk_stamp,
-					  sizeof(struct timeval)) ? -EFAULT : 0;
+			rc = sock_get_timestamp(sk, (struct timeval *)arg);
 			break;
 		/* Routing */
 		case SIOCADDRT:
diff -u linux-2.6.5rc3-averell/net/econet/af_econet.c-T linux-2.6.5rc3-averell/net/econet/af_econet.c
--- linux-2.6.5rc3-averell/net/econet/af_econet.c-T	2004-03-21 21:12:01.000000000 +0100
+++ linux-2.6.5rc3-averell/net/econet/af_econet.c	2004-03-31 09:44:02.000000000 +0200
@@ -665,10 +665,8 @@
 
 	switch(cmd) {
 		case SIOCGSTAMP:
-			if (!sk->sk_stamp.tv_sec)
-				return -ENOENT;
-			return copy_to_user((void *)arg, &sk->sk_stamp,
-					  sizeof(struct timeval)) ? -EFAULT : 0;
+			return sock_get_timestamp(sk,(struct timeval *)arg);
+
 		case SIOCSIFADDR:
 		case SIOCGIFADDR:
 			return ec_dev_ioctl(sock, cmd, (void *)arg);
