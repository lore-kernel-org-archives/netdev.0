From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Wed, 26 Mar 2008 19:35:38 +0100
Message-ID: <20080326183538.GA14266@ami.dom.local>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:17474 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774AbYCZS1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 14:27:11 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1423234nfb.21
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 11:27:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47E8FCE2.6000308@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2008 at 02:23:46PM +0100, Bernard Pidoux wrote:
...
> I am prepared for the next step you probably want to explore.
...

OK, here is the next try. (Apply after all previous patches to any 2.6.24.x;
there would be more noise, so revert it after catching some data.)

Thanks,
Jarek P.

(debugging patch #3)
---

diff -Nurp 2.6.24.3-with2/include/net/sock.h 2.6.24.3-with3/include/net/sock.h
--- 2.6.24.3-with2/include/net/sock.h	2008-03-24 21:14:43.000000000 +0100
+++ 2.6.24.3-with3/include/net/sock.h	2008-03-26 19:10:33.000000000 +0100
@@ -1414,4 +1414,20 @@ extern int sysctl_optmem_max;
 extern __u32 sysctl_wmem_default;
 extern __u32 sysctl_rmem_default;
 
+static inline int sock_debug_ax25(struct sk_buff *skb, struct sock *ax25_sk)
+{
+	struct sock *sk = skb->sk;
+
+	if (sk && sk->sk_socket && sk->sk_socket->sk != sk) {
+		if (net_ratelimit())
+			printk(KERN_INFO "AX25: %s, %d, %p, %p, %p, %p, %p\n",
+				__FUNCTION__, __LINE__, sk, sk->sk_socket,
+				sk->sk_socket->sk, ax25_sk,
+				ax25_sk == NULL ? NULL : ax25_sk->sk_socket);
+		skb->destructor = NULL;
+		return 1;
+	}
+	return 0;
+}
+
 #endif	/* _SOCK_H */
diff -Nurp 2.6.24.3-with2/net/ax25/af_ax25.c 2.6.24.3-with3/net/ax25/af_ax25.c
--- 2.6.24.3-with2/net/ax25/af_ax25.c	2008-03-23 00:53:51.000000000 +0100
+++ 2.6.24.3-with3/net/ax25/af_ax25.c	2008-03-26 18:52:54.000000000 +0100
@@ -952,6 +952,8 @@ static int ax25_release(struct socket *s
 
 	sock_hold(sk);
 	sock_orphan(sk);
+	if (net_ratelimit())
+		printk(KERN_INFO "AX25- %s, %d, %p, %p\n", __FUNCTION__, __LINE__, sk, sock);
 	lock_sock(sk);
 	ax25 = ax25_sk(sk);
 
@@ -1372,12 +1374,16 @@ static int ax25_accept(struct socket *so
 	newsk		 = skb->sk;
 	newsk->sk_socket = newsock;
 	newsk->sk_sleep	 = &newsock->wait;
+	newsk->sk_ax25_debug = 2;
 
 	/* Now attach up the new socket */
 	kfree_skb(skb);
 	sk->sk_ack_backlog--;
 	newsock->sk    = newsk;
 	newsock->state = SS_CONNECTED;
+	if (net_ratelimit())
+		printk(KERN_INFO "AX25= %s, %d, %p, %p, %p\n",
+			 __FUNCTION__, __LINE__, newsk, sock, newsock);
 
 out:
 	release_sock(sk);
diff -Nurp 2.6.24.3-with2/net/ax25/ax25_out.c 2.6.24.3-with3/net/ax25/ax25_out.c
--- 2.6.24.3-with2/net/ax25/ax25_out.c	2008-03-26 16:38:23.000000000 +0100
+++ 2.6.24.3-with3/net/ax25/ax25_out.c	2008-03-26 18:54:47.000000000 +0100
@@ -98,6 +98,7 @@ ax25_cb *ax25_send_frame(struct sk_buff 
 
 	ax25_start_heartbeat(ax25);
 
+	sock_debug_ax25(skb, ax25->sk);
 	ax25_output(ax25, paclen, skb);
 
 	return ax25;			/* We had to create it */
@@ -176,11 +177,13 @@ void ax25_output(ax25_cb *ax25, int pacl
 			}
 
 			skb_pull(skb, len);
+			sock_debug_ax25(skbn, ax25->sk);
 			skb_queue_tail(&ax25->write_queue, skbn); /* Throw it on the queue */
 		}
 
 		kfree_skb(skb);
 	} else {
+		sock_debug_ax25(skb, ax25->sk);
 		skb_queue_tail(&ax25->write_queue, skb);	  /* Throw it on the queue */
 	}
 
@@ -274,6 +277,8 @@ void ax25_kick(ax25_cb *ax25)
 	ax25->vs = start;
 
 	do {
+		sock_debug_ax25(skb, ax25->sk);
+
 		if ((skbn = skb_clone(skb, GFP_ATOMIC)) == NULL) {
 			skb_queue_head(&ax25->write_queue, skb);
 			break;
@@ -308,6 +313,8 @@ void ax25_kick(ax25_cb *ax25)
 		/*
 		 * Requeue the original data frame.
 		 */
+
+		sock_debug_ax25(skb, ax25->sk);
 		skb_queue_tail(&ax25->ack_queue, skb);
 
 	} while (!last && (skb = skb_dequeue(&ax25->write_queue)) != NULL);
diff -Nurp 2.6.24.3-with2/net/ax25/ax25_subr.c 2.6.24.3-with3/net/ax25/ax25_subr.c
--- 2.6.24.3-with2/net/ax25/ax25_subr.c	2008-01-24 23:58:37.000000000 +0100
+++ 2.6.24.3-with3/net/ax25/ax25_subr.c	2008-03-26 19:23:03.000000000 +0100
@@ -56,6 +56,7 @@ void ax25_frames_acked(ax25_cb *ax25, un
 	if (ax25->va != nr) {
 		while (skb_peek(&ax25->ack_queue) != NULL && ax25->va != nr) {
 			skb = skb_dequeue(&ax25->ack_queue);
+			sock_debug_ax25(skb, ax25->sk);
 			kfree_skb(skb);
 			ax25->va = (ax25->va + 1) % ax25->modulus;
 		}
diff -Nurp 2.6.24.3-with2/net/core/sock.c 2.6.24.3-with3/net/core/sock.c
--- 2.6.24.3-with2/net/core/sock.c	2008-03-24 21:43:46.000000000 +0100
+++ 2.6.24.3-with3/net/core/sock.c	2008-03-26 19:14:37.000000000 +0100
@@ -1520,8 +1520,10 @@ static void sock_def_write_space(struct 
 		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
 			if (!sk->sk_socket || sk->sk_socket->sk != sk) {
 				if (net_ratelimit())
-					printk(KERN_INFO "sk_ax25_debug = %d, %p\n",
-						 sk->sk_ax25_debug, sk->sk_socket);
+					printk(KERN_INFO "sk_ax25_debug = %d, %d, %d, %d, %p, %p, %p\n",
+						 sk->sk_ax25_debug, sk->sk_family,
+						 (int)sk->sk_protocol, sk->sk_type, sk->sk_socket,
+						 sk->sk_socket == NULL ? NULL : sk->sk_socket->sk, sk);
 				WARN_ON_ONCE(1);
 				sk->sk_socket = NULL;
 				sk->sk_sleep = NULL;
