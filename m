From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 18 Feb 2008 22:09:24 +0000
Message-ID: <47BA0214.40703@katalix.com>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:47476 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761475AbYBRWJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 17:09:36 -0500
In-Reply-To: <20080214130016.GA2583@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Hi,
> 
> It seems, this nice report is still uncomplete: could you check if
> there could have been something more yet?

Unfortunately the ISP's syslog stops. But I've been able to borrow two Quad Xeon boxes and have reproduced the problem.

Here's a new version of the patch. The patch avoids disabling irqs and fixes the sk_dst_get() usage that DaveM mentioned. But even with this patch, lockdep still complains if hundreds of ppp sessions are inserted into a tunnel as rapidly as possible (lockdep trace is below). I can stop these errors by wrapping the call to ppp_input() in pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is a better fix?

btw, I'm not sending this from my usual mail client so the patch will probably be mangled; I'm sending it only for feedback / discussion at this stage.

Index: linux-2.6.24.2/drivers/net/pppol2tp.c
===================================================================
--- linux-2.6.24.2.orig/drivers/net/pppol2tp.c
+++ linux-2.6.24.2/drivers/net/pppol2tp.c
@@ -302,14 +302,14 @@ pppol2tp_session_find(struct pppol2tp_tu
 	struct pppol2tp_session *session;
 	struct hlist_node *walk;
 
-	read_lock(&tunnel->hlist_lock);
+	read_lock_bh(&tunnel->hlist_lock);
 	hlist_for_each_entry(session, walk, session_list, hlist) {
 		if (session->tunnel_addr.s_session == session_id) {
-			read_unlock(&tunnel->hlist_lock);
+			read_unlock_bh(&tunnel->hlist_lock);
 			return session;
 		}
 	}
-	read_unlock(&tunnel->hlist_lock);
+	read_unlock_bh(&tunnel->hlist_lock);
 
 	return NULL;
 }
@@ -320,14 +320,14 @@ static struct pppol2tp_tunnel *pppol2tp_
 {
 	struct pppol2tp_tunnel *tunnel = NULL;
 
-	read_lock(&pppol2tp_tunnel_list_lock);
+	read_lock_bh(&pppol2tp_tunnel_list_lock);
 	list_for_each_entry(tunnel, &pppol2tp_tunnel_list, list) {
 		if (tunnel->stats.tunnel_id == tunnel_id) {
-			read_unlock(&pppol2tp_tunnel_list_lock);
+			read_unlock_bh(&pppol2tp_tunnel_list_lock);
 			return tunnel;
 		}
 	}
-	read_unlock(&pppol2tp_tunnel_list_lock);
+	read_unlock_bh(&pppol2tp_tunnel_list_lock);
 
 	return NULL;
 }
@@ -344,7 +344,7 @@ static void pppol2tp_recv_queue_skb(stru
 	struct sk_buff *skbp;
 	u16 ns = PPPOL2TP_SKB_CB(skb)->ns;
 
-	spin_lock(&session->reorder_q.lock);
+	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk(&session->reorder_q, skbp) {
 		if (PPPOL2TP_SKB_CB(skbp)->ns > ns) {
 			__skb_insert(skb, skbp->prev, skbp, &session->reorder_q);
@@ -360,7 +360,7 @@ static void pppol2tp_recv_queue_skb(stru
 	__skb_queue_tail(&session->reorder_q, skb);
 
 out:
-	spin_unlock(&session->reorder_q.lock);
+	spin_unlock_bh(&session->reorder_q.lock);
 }
 
 /* Dequeue a single skb.
@@ -442,7 +442,7 @@ static void pppol2tp_recv_dequeue(struct
 	 * expect to send up next, dequeue it and any other
 	 * in-sequence packets behind it.
 	 */
-	spin_lock(&session->reorder_q.lock);
+	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
 		if (time_after(jiffies, PPPOL2TP_SKB_CB(skb)->expires)) {
 			session->stats.rx_seq_discards++;
@@ -469,13 +469,13 @@ static void pppol2tp_recv_dequeue(struct
 				goto out;
 			}
 		}
-		spin_unlock(&session->reorder_q.lock);
+		spin_unlock_bh(&session->reorder_q.lock);
 		pppol2tp_recv_dequeue_skb(session, skb);
-		spin_lock(&session->reorder_q.lock);
+		spin_lock_bh(&session->reorder_q.lock);
 	}
 
 out:
-	spin_unlock(&session->reorder_q.lock);
+	spin_unlock_bh(&session->reorder_q.lock);
 }
 
 /* Internal receive frame. Do the real work of receiving an L2TP data frame
@@ -964,6 +964,7 @@ static int pppol2tp_xmit(struct ppp_chan
 	static const u8 ppph[2] = { 0xff, 0x03 };
 	struct sock *sk = (struct sock *) chan->private;
 	struct sock *sk_tun;
+	struct rtable *rt;
 	int hdr_len;
 	struct pppol2tp_session *session;
 	struct pppol2tp_tunnel *tunnel;
@@ -1057,8 +1058,32 @@ static int pppol2tp_xmit(struct ppp_chan
 	nf_reset(skb);
 
 	/* Get routing info from the tunnel socket */
-	dst_release(skb->dst);
-	skb->dst = sk_dst_get(sk_tun);
+	rt = (struct rtable *)__sk_dst_check(sk_tun, 0);
+	if (rt == NULL) {
+		struct flowi fl = { .oif = sk_tun->sk_bound_dev_if,
+				    .nl_u = { .ip4_u =
+					      { .daddr = inet->daddr,
+						.saddr = inet->saddr,
+						.tos = inet->tos } },
+				    .proto = sk_tun->sk_protocol,
+				    .uli_u = { .ports =
+					       { .sport = inet->sport,
+						 .dport = inet->dport } } };
+		security_sk_classify_flow(sk_tun, &fl);
+		rc = ip_route_output_flow(&rt, &fl, sk_tun, 1);
+		if (rc) {
+			if (rc == -ENETUNREACH)
+				IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+			goto abort;
+		}
+
+		sk_dst_set(sk_tun, dst_clone(&rt->u.dst));
+	}
+
+	write_lock_bh(&sk_tun->sk_dst_lock);
+	skb->dst = __sk_dst_get(sk_tun);
+	dst_hold(skb->dst);
+	write_unlock_bh(&sk_tun->sk_dst_lock);
 	skb_orphan(skb);
 	skb->sk = sk_tun;
 
@@ -1106,7 +1131,7 @@ static void pppol2tp_tunnel_closeall(str
 	PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
 	       "%s: closing all sessions...\n", tunnel->name);
 
-	write_lock(&tunnel->hlist_lock);
+	write_lock_bh(&tunnel->hlist_lock);
 	for (hash = 0; hash < PPPOL2TP_HASH_SIZE; hash++) {
 again:
 		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
@@ -1126,7 +1151,7 @@ again:
 			 * disappear as we're jumping between locks.
 			 */
 			sock_hold(sk);
-			write_unlock(&tunnel->hlist_lock);
+			write_unlock_bh(&tunnel->hlist_lock);
 			lock_sock(sk);
 
 			if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
@@ -1148,11 +1173,11 @@ again:
 			 * list so we are guaranteed to make forward
 			 * progress.
 			 */
-			write_lock(&tunnel->hlist_lock);
+			write_lock_bh(&tunnel->hlist_lock);
 			goto again;
 		}
 	}
-	write_unlock(&tunnel->hlist_lock);
+	write_unlock_bh(&tunnel->hlist_lock);
 }
 
 /* Really kill the tunnel.
@@ -1161,9 +1186,9 @@ again:
 static void pppol2tp_tunnel_free(struct pppol2tp_tunnel *tunnel)
 {
 	/* Remove from socket list */
-	write_lock(&pppol2tp_tunnel_list_lock);
+	write_lock_bh(&pppol2tp_tunnel_list_lock);
 	list_del_init(&tunnel->list);
-	write_unlock(&pppol2tp_tunnel_list_lock);
+	write_unlock_bh(&pppol2tp_tunnel_list_lock);
 
 	atomic_dec(&pppol2tp_tunnel_count);
 	kfree(tunnel);
@@ -1239,9 +1264,9 @@ static void pppol2tp_session_destruct(st
 				/* Delete the session socket from the
 				 * hash
 				 */
-				write_lock(&tunnel->hlist_lock);
+				write_lock_bh(&tunnel->hlist_lock);
 				hlist_del_init(&session->hlist);
-				write_unlock(&tunnel->hlist_lock);
+				write_unlock_bh(&tunnel->hlist_lock);
 
 				atomic_dec(&pppol2tp_session_count);
 			}
@@ -1386,9 +1411,9 @@ static struct sock *pppol2tp_prepare_tun
 
 	/* Add tunnel to our list */
 	INIT_LIST_HEAD(&tunnel->list);
-	write_lock(&pppol2tp_tunnel_list_lock);
+	write_lock_bh(&pppol2tp_tunnel_list_lock);
 	list_add(&tunnel->list, &pppol2tp_tunnel_list);
-	write_unlock(&pppol2tp_tunnel_list_lock);
+	write_unlock_bh(&pppol2tp_tunnel_list_lock);
 	atomic_inc(&pppol2tp_tunnel_count);
 
 	/* Bump the reference count. The tunnel context is deleted
@@ -1546,14 +1571,15 @@ static int pppol2tp_connect(struct socke
 	session->mtu = session->mru = 1500 - PPPOL2TP_HEADER_OVERHEAD;
 
 	/* If PMTU discovery was enabled, use the MTU that was discovered */
-	dst = sk_dst_get(sk);
+	read_lock_bh(&tunnel_sock->sk_dst_lock);
+	dst = __sk_dst_get(sk);
 	if (dst != NULL) {
-		u32 pmtu = dst_mtu(__sk_dst_get(sk));
+		u32 pmtu = dst_mtu(dst);
 		if (pmtu != 0)
 			session->mtu = session->mru = pmtu -
 				PPPOL2TP_HEADER_OVERHEAD;
-		dst_release(dst);
 	}
+	read_unlock_bh(&tunnel_sock->sk_dst_lock);
 
 	/* Special case: if source & dest session_id == 0x0000, this socket is
 	 * being created to manage the tunnel. Don't add the session to the
@@ -1593,11 +1619,11 @@ static int pppol2tp_connect(struct socke
 	sk->sk_user_data = session;
 
 	/* Add session to the tunnel's hash list */
-	write_lock(&tunnel->hlist_lock);
+	write_lock_bh(&tunnel->hlist_lock);
 	hlist_add_head(&session->hlist,
 		       pppol2tp_session_id_hash(tunnel,
 						session->tunnel_addr.s_session));
-	write_unlock(&tunnel->hlist_lock);
+	write_unlock_bh(&tunnel->hlist_lock);
 
 	atomic_inc(&pppol2tp_session_count);
 
@@ -2199,7 +2225,7 @@ static struct pppol2tp_session *next_ses
 	int next = 0;
 	int i;
 
-	read_lock(&tunnel->hlist_lock);
+	read_lock_bh(&tunnel->hlist_lock);
 	for (i = 0; i < PPPOL2TP_HASH_SIZE; i++) {
 		hlist_for_each_entry(session, walk, &tunnel->session_hlist[i], hlist) {
 			if (curr == NULL) {
@@ -2217,7 +2243,7 @@ static struct pppol2tp_session *next_ses
 		}
 	}
 out:
-	read_unlock(&tunnel->hlist_lock);
+	read_unlock_bh(&tunnel->hlist_lock);
 	if (!found)
 		session = NULL;
 
@@ -2228,13 +2254,13 @@ static struct pppol2tp_tunnel *next_tunn
 {
 	struct pppol2tp_tunnel *tunnel = NULL;
 
-	read_lock(&pppol2tp_tunnel_list_lock);
+	read_lock_bh(&pppol2tp_tunnel_list_lock);
 	if (list_is_last(&curr->list, &pppol2tp_tunnel_list)) {
 		goto out;
 	}
 	tunnel = list_entry(curr->list.next, struct pppol2tp_tunnel, list);
 out:
-	read_unlock(&pppol2tp_tunnel_list_lock);
+	read_unlock_bh(&pppol2tp_tunnel_list_lock);
 
 	return tunnel;
 }

......................................................
Here's the lockdep trace (long).

Feb 18 20:56:18 localhost kernel: 
Feb 18 20:56:18 localhost kernel: ======================================================
Feb 18 20:56:18 localhost kernel: [ INFO: soft-safe -> soft-unsafe lock order detected ]
Feb 18 20:56:18 localhost kernel: 2.6.24.2 #1
Feb 18 20:56:18 localhost kernel: ------------------------------------------------------
Feb 18 20:56:18 localhost kernel: pppd/3241 [HC0[0]:SC0[2]:HE1:SE0] is trying to acquire:
Feb 18 20:56:18 localhost kernel:  (&pch->downl){-...}, at: [<f8c566db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 20:56:18 localhost kernel: 
Feb 18 20:56:18 localhost kernel: and this task is already holding:
Feb 18 20:56:18 localhost kernel:  (&ppp->wlock){-...}, at: [<f8c56f10>] ppp_xmit_process+0x15/0x5a1 [ppp_generic]
Feb 18 20:56:18 localhost kernel: which would create a new lock dependency:
Feb 18 20:56:18 localhost kernel:  (&ppp->wlock){-...} -> (&pch->downl){-...}
Feb 18 20:56:18 localhost kernel: 
Feb 18 20:56:18 localhost kernel: but this new dependency connects a soft-irq-safe lock:
Feb 18 20:56:18 localhost kernel:  (&pch->upl){-.-+}
Feb 18 20:56:18 localhost kernel: ... which became soft-irq-safe at:
Feb 18 20:56:18 localhost kernel:   [<c0448013>] check_usage_backwards+0x19/0x41
Feb 18 20:56:18 localhost kernel:   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:18 localhost kernel:   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:18 localhost kernel:   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:18 localhost kernel:   [<f8c5940d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 20:56:18 localhost kernel:   [<c061b373>] _read_lock_bh+0x2e/0x39
Feb 18 20:56:18 localhost kernel:   [<f8c5940d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 20:56:18 localhost kernel:   [<f8c5940d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 20:56:18 localhost kernel:   [<f8c60263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 20:56:18 localhost kernel:   [<f8c6037a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 20:56:18 localhost kernel:   [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 20:56:18 localhost kernel:   [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 20:56:18 localhost kernel:   [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 20:56:18 localhost kernel:   [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 20:56:18 localhost kernel:   [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 20:56:18 localhost kernel:   [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 20:56:18 localhost kernel:   [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:18 localhost kernel:   [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 20:56:18 localhost kernel:   [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 20:56:18 localhost kernel:   [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:18 localhost kernel:   [<f89877c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 20:56:18 localhost kernel:   [<f8987453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 20:56:18 localhost kernel:   [<f8984f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 20:56:19 localhost kernel:   [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 20:56:19 localhost kernel:   [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 20:56:19 localhost kernel:   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:19 localhost kernel:   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:19 localhost kernel:   [<ffffffff>] 0xffffffff
Feb 18 20:56:19 localhost kernel: 
Feb 18 20:56:19 localhost kernel: to a soft-irq-unsafe lock:
Feb 18 20:56:19 localhost kernel:  (&sk->sk_dst_lock){----}
Feb 18 20:56:19 localhost kernel: ... which became soft-irq-unsafe at:
Feb 18 20:56:19 localhost kernel: ...  [<c0449046>] __lock_acquire+0x48b/0xbf1
Feb 18 20:56:19 localhost kernel:   [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 20:56:19 localhost kernel:   [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 20:56:19 localhost kernel:   [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 20:56:19 localhost kernel:   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:19 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:56:19 localhost kernel:   [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 20:56:19 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:56:19 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:56:19 localhost kernel:   [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 20:56:19 localhost kernel:   [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 20:56:19 localhost kernel:   [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 20:56:19 localhost kernel:   [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 20:56:19 localhost kernel:   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:19 localhost kernel:   [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 20:56:19 localhost kernel:   [<ffffffff>] 0xffffffff
Feb 18 20:56:19 localhost kernel: 
Feb 18 20:56:19 localhost kernel: other info that might help us debug this:
Feb 18 20:56:19 localhost kernel: 
Feb 18 20:56:19 localhost kernel: 1 lock held by pppd/3241:
Feb 18 20:56:19 localhost kernel:  #0:  (&ppp->wlock){-...}, at: [<f8c56f10>] ppp_xmit_process+0x15/0x5a1 [ppp_generic]
Feb 18 20:56:19 localhost kernel: 
Feb 18 20:56:19 localhost kernel: the soft-irq-safe lock's dependencies:
Feb 18 20:56:19 localhost kernel: -> (&pch->upl){-.-+} ops: 13 {
Feb 18 20:56:19 localhost kernel:    initial-use  at:
Feb 18 20:56:19 localhost kernel:                         [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:19 localhost kernel:                         [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:19 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:19 localhost kernel:                         [<f8c57b7c>] ppp_ioctl+0x4df/0xc06 [ppp_generic]
Feb 18 20:56:19 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:19 localhost kernel:                         [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:19 localhost kernel:                         [<c061b300>] _write_lock_bh+0x2e/0x39
Feb 18 20:56:20 localhost kernel:                         [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:20 localhost kernel:                         [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:20 localhost kernel:                         [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:20 localhost kernel:                         [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:20 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:20 localhost kernel:                         [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:20 localhost kernel:                         [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:56:20 localhost kernel:                         [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:56:20 localhost kernel:                         [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:56:20 localhost kernel:                         [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:56:20 localhost kernel:                         [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:56:20 localhost kernel:                         [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:20 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:56:20 localhost kernel:    hardirq-on-W at:
Feb 18 20:56:20 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:20 localhost kernel:                         [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:20 localhost kernel:                         [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 20:56:20 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:20 localhost kernel:                         [<f8c57b7c>] ppp_ioctl+0x4df/0xc06 [ppp_generic]
Feb 18 20:56:20 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:20 localhost kernel:                         [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:20 localhost kernel:                         [<c061b300>] _write_lock_bh+0x2e/0x39
Feb 18 20:56:20 localhost kernel:                         [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:20 localhost kernel:                         [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:20 localhost kernel:                         [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:20 localhost kernel:                         [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:20 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:20 localhost kernel:                         [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:20 localhost kernel:                         [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:56:20 localhost kernel:                         [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:56:20 localhost kernel:                         [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:56:20 localhost kernel:                         [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:56:20 localhost kernel:                         [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:56:20 localhost kernel:                         [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:20 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:56:20 localhost kernel:    in-softirq-R at:
Feb 18 20:56:20 localhost kernel:                         [<c0448013>] check_usage_backwards+0x19/0x41
Feb 18 20:56:20 localhost kernel:                         [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:20 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:20 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:20 localhost kernel:                         [<f8c5940d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<c061b373>] _read_lock_bh+0x2e/0x39
Feb 18 20:56:21 localhost kernel:                         [<f8c5940d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<f8c5940d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<f8c60263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 20:56:21 localhost kernel:                         [<f8c6037a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 20:56:21 localhost kernel:                         [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 20:56:21 localhost kernel:                         [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 20:56:21 localhost kernel:                         [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 20:56:21 localhost kernel:                         [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 20:56:21 localhost kernel:                         [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 20:56:21 localhost kernel:                         [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 20:56:21 localhost kernel:                         [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:21 localhost kernel:                         [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 20:56:21 localhost kernel:                         [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 20:56:21 localhost kernel:                         [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:21 localhost kernel:                         [<f89877c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 20:56:21 localhost kernel:                         [<f8987453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 20:56:21 localhost kernel:                         [<f8984f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 20:56:21 localhost kernel:                         [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 20:56:21 localhost kernel:                         [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 20:56:21 localhost kernel:                         [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:21 localhost kernel:                         [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:21 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:56:21 localhost kernel:    hardirq-on-R at:
Feb 18 20:56:21 localhost kernel:                         [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 20:56:21 localhost kernel:                         [<c0449001>] __lock_acquire+0x446/0xbf1
Feb 18 20:56:21 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:21 localhost kernel:                         [<f8c5834b>] ppp_channel_push+0x71/0x90 [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<c061b373>] _read_lock_bh+0x2e/0x39
Feb 18 20:56:21 localhost kernel:                         [<f8c5834b>] ppp_channel_push+0x71/0x90 [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<f8c5834b>] ppp_channel_push+0x71/0x90 [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<f8c593bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<f8c592ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 20:56:21 localhost kernel:                         [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 20:56:21 localhost kernel:                         [<c047ecfd>] sys_write+0x41/0x67
Feb 18 20:56:21 localhost kernel:                         [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:21 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:56:21 localhost kernel:  }
Feb 18 20:56:21 localhost kernel:  ... key      at: [<f8c5dd20>] __key.29741+0x0/0xffffb822 [ppp_generic]
Feb 18 20:56:21 localhost kernel:  -> (&ppp->wlock){-...} ops: 11 {
Feb 18 20:56:22 localhost kernel:     initial-use  at:
Feb 18 20:56:22 localhost kernel:                           [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:22 localhost kernel:                           [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:22 localhost kernel:                           [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:56:22 localhost kernel:                           [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:22 localhost kernel:                           [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:22 localhost kernel:                           [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:22 localhost kernel:                           [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:22 localhost kernel:                           [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:56:22 localhost kernel:                           [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:56:22 localhost kernel:                           [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:56:22 localhost kernel:                           [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:56:22 localhost kernel:                           [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:56:22 localhost kernel:                           [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:22 localhost kernel:                           [<ffffffff>] 0xffffffff
Feb 18 20:56:22 localhost kernel:     hardirq-on-W at:
Feb 18 20:56:22 localhost kernel:                           [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 20:56:22 localhost kernel:                           [<f8c57ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:22 localhost kernel:                           [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:56:22 localhost kernel:                           [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:22 localhost kernel:                           [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:22 localhost kernel:                           [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:22 localhost kernel:                           [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:22 localhost kernel:                           [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:22 localhost kernel:                           [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:56:22 localhost kernel:                           [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:56:22 localhost kernel:                           [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:56:22 localhost kernel:                           [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:56:22 localhost kernel:                           [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:56:22 localhost kernel:                           [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:22 localhost kernel:                           [<ffffffff>] 0xffffffff
Feb 18 20:56:22 localhost kernel:   }
Feb 18 20:56:22 localhost kernel:   ... key      at: [<f8c5dd08>] __key.29980+0x0/0xffffb83a [ppp_generic]
Feb 18 20:56:22 localhost kernel:   -> (&ppp->rlock){-+..} ops: 5 {
Feb 18 20:56:22 localhost kernel:      initial-use  at:
Feb 18 20:56:22 localhost kernel:                             [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:23 localhost kernel:                             [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:23 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:23 localhost kernel:                             [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:56:23 localhost kernel:                             [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:56:23 localhost kernel:                             [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:56:23 localhost kernel:                             [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:56:23 localhost kernel:                             [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:23 localhost kernel:                             [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:23 localhost kernel:                             [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:23 localhost kernel:                             [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:23 localhost kernel:                             [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:56:23 localhost kernel:                             [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:56:23 localhost kernel:                             [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:56:23 localhost kernel:                             [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:56:23 localhost kernel:                             [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:56:23 localhost kernel:                             [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:23 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 20:56:23 localhost kernel:      in-softirq-W at:
Feb 18 20:56:23 localhost kernel:                             [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:23 localhost kernel:                             [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:23 localhost kernel:                             [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:23 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:23 localhost kernel:                             [<f8c59473>] ppp_input+0xab/0xef [ppp_generic]
Feb 18 20:56:23 localhost kernel:                             [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:56:23 localhost kernel:                             [<f8c59473>] ppp_input+0xab/0xef [ppp_generic]
Feb 18 20:56:23 localhost kernel:                             [<f8c59473>] ppp_input+0xab/0xef [ppp_generic]
Feb 18 20:56:23 localhost kernel:                             [<f8c60263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 20:56:23 localhost kernel:                             [<f8c6037a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 20:56:23 localhost kernel:                             [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 20:56:23 localhost kernel:                             [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 20:56:23 localhost kernel:                             [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 20:56:23 localhost kernel:                             [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 20:56:23 localhost kernel:                             [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 20:56:23 localhost kernel:                             [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 20:56:23 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:23 localhost kernel:                             [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 20:56:23 localhost kernel:                             [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 20:56:23 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:23 localhost kernel:                             [<f89877c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 20:56:23 localhost kernel:                             [<f8987453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 20:56:23 localhost kernel:                             [<f8984f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 20:56:24 localhost kernel:                             [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 20:56:24 localhost kernel:                             [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 20:56:24 localhost kernel:                             [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:24 localhost kernel:                             [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:24 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 20:56:24 localhost kernel:      hardirq-on-W at:
Feb 18 20:56:24 localhost kernel:                             [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 20:56:24 localhost kernel:                             [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:56:24 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:24 localhost kernel:                             [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:56:24 localhost kernel:                             [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:56:24 localhost kernel:                             [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:56:24 localhost kernel:                             [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:56:24 localhost kernel:                             [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:24 localhost kernel:                             [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:24 localhost kernel:                             [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:24 localhost kernel:                             [<c061b008>] __down+0x82/0xb8
Feb 18 20:56:24 localhost kernel:                             [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:56:24 localhost kernel:                             [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:56:24 localhost kernel:                             [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:56:24 localhost kernel:                             [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:56:24 localhost kernel:                             [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:56:24 localhost kernel:                             [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:24 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 20:56:24 localhost kernel:    }
Feb 18 20:56:24 localhost kernel:    ... key      at: [<f8c5dd10>] __key.29979+0x0/0xffffb832 [ppp_generic]
Feb 18 20:56:24 localhost kernel:    -> (&list->lock#7){.+..} ops: 31 {
Feb 18 20:56:24 localhost kernel:       initial-use  at:
Feb 18 20:56:24 localhost kernel:                               [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:24 localhost kernel:                               [<c046b874>] __do_fault+0x31b/0x35d
Feb 18 20:56:24 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:24 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:24 localhost kernel:                               [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:24 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:24 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:24 localhost kernel:                               [<f8c5939f>] ppp_write+0xb2/0xdb [ppp_generic]
Feb 18 20:56:24 localhost kernel:                               [<f8c592ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 20:56:24 localhost kernel:                               [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 20:56:24 localhost kernel:                               [<c047ecfd>] sys_write+0x41/0x67
Feb 18 20:56:24 localhost kernel:                               [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:56:24 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 20:56:24 localhost kernel:       in-softirq-W at:
Feb 18 20:56:24 localhost kernel:                               [<c0446ab0>] save_trace+0x37/0x8b
Feb 18 20:56:25 localhost kernel:                               [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:25 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:25 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:25 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:25 localhost kernel:                               [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:25 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:25 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:25 localhost kernel:                               [<f8c59433>] ppp_input+0x6b/0xef [ppp_generic]
Feb 18 20:56:25 localhost kernel:                               [<f8c60263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 20:56:25 localhost kernel:                               [<f8c6037a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 20:56:25 localhost kernel:                               [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 20:56:25 localhost kernel:                               [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 20:56:25 localhost kernel:                               [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 20:56:25 localhost kernel:                               [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 20:56:25 localhost kernel:                               [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 20:56:25 localhost kernel:                               [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 20:56:25 localhost kernel:                               [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:25 localhost kernel:                               [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 20:56:25 localhost kernel:                               [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 20:56:25 localhost kernel:                               [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:25 localhost kernel:                               [<f89877c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 20:56:25 localhost kernel:                               [<f8987453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 20:56:25 localhost kernel:                               [<f8984f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 20:56:25 localhost kernel:                               [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 20:56:25 localhost kernel:                               [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 20:56:25 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:25 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:25 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 20:56:25 localhost kernel:     }
Feb 18 20:56:25 localhost kernel:     ... key      at: [<f8c5dd18>] __key.21159+0x0/0xffffb82a [ppp_generic]
Feb 18 20:56:25 localhost kernel:    ... acquired at:
Feb 18 20:56:25 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:56:25 localhost kernel:    [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:25 localhost kernel:    [<c0446ab0>] save_trace+0x37/0x8b
Feb 18 20:56:25 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:25 localhost kernel:    [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:25 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:25 localhost kernel:    [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:25 localhost kernel:    [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:56:25 localhost kernel:    [<f8c589f2>] ppp_receive_nonmp_frame+0x4e6/0x70a [ppp_generic]
Feb 18 20:56:25 localhost kernel:    [<f8c59473>] ppp_input+0xab/0xef [ppp_generic]
Feb 18 20:56:26 localhost kernel:    [<f8c59487>] ppp_input+0xbf/0xef [ppp_generic]
Feb 18 20:56:26 localhost kernel:    [<f8c60263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 20:56:26 localhost kernel:    [<f8c6037a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 20:56:26 localhost kernel:    [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 20:56:26 localhost kernel:    [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 20:56:26 localhost kernel:    [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 20:56:26 localhost kernel:    [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 20:56:26 localhost kernel:    [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 20:56:26 localhost kernel:    [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 20:56:26 localhost kernel:    [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:26 localhost kernel:    [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 20:56:26 localhost kernel:    [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 20:56:26 localhost kernel:    [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:56:26 localhost kernel:    [<f89877c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 20:56:26 localhost kernel:    [<f8987453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 20:56:26 localhost kernel:    [<f8984f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 20:56:26 localhost kernel:    [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 20:56:26 localhost kernel:    [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 20:56:26 localhost kernel:    [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:26 localhost kernel:    [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:26 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:56:26 localhost kernel: 
Feb 18 20:56:26 localhost kernel:    -> (&q->lock){++..} ops: 468037 {
Feb 18 20:56:26 localhost kernel:       initial-use  at:
Feb 18 20:56:26 localhost kernel:                               [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:26 localhost kernel:                               [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:26 localhost kernel:                               [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:26 localhost kernel:                               [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 20:56:26 localhost kernel:                               [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:26 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:26 localhost kernel:                               [<c0619856>] wait_for_common+0x2a/0xe0
Feb 18 20:56:26 localhost kernel:                               [<c061b4a0>] _spin_lock_irq+0x2f/0x3a
Feb 18 20:56:26 localhost kernel:                               [<c0619856>] wait_for_common+0x2a/0xe0
Feb 18 20:56:26 localhost kernel:                               [<c0619856>] wait_for_common+0x2a/0xe0
Feb 18 20:56:26 localhost kernel:                               [<c043d4b2>] kthread_create+0x70/0xa4
Feb 18 20:56:26 localhost kernel:                               [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:26 localhost kernel:                               [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:26 localhost kernel:                               [<c04265bc>] migration_call+0x49/0x364
Feb 18 20:56:26 localhost kernel:                               [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:26 localhost kernel:                               [<c075e01b>] migration_init+0x19/0x40
Feb 18 20:56:26 localhost kernel:                               [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:27 localhost kernel:                               [<c074e39e>] kernel_init+0x55/0x2af
Feb 18 20:56:27 localhost kernel:                               [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:56:27 localhost kernel:                               [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:27 localhost kernel:                               [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:27 localhost kernel:                               [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:27 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 20:56:27 localhost kernel:       in-hardirq-W at:
Feb 18 20:56:27 localhost kernel:                               [<c04480df>] check_usage_forwards+0x19/0x41
Feb 18 20:56:27 localhost kernel:                               [<c0446ab0>] save_trace+0x37/0x8b
Feb 18 20:56:27 localhost kernel:                               [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:27 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:27 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:27 localhost kernel:                               [<c04235da>] complete+0x12/0x44
Feb 18 20:56:27 localhost kernel:                               [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:27 localhost kernel:                               [<c04235da>] complete+0x12/0x44
Feb 18 20:56:27 localhost kernel:                               [<c04235da>] complete+0x12/0x44
Feb 18 20:56:27 localhost kernel:                               [<c058446e>] i8042_aux_test_irq+0x44/0x5c
Feb 18 20:56:27 localhost kernel:                               [<c045bcde>] handle_IRQ_event+0x13/0x3d
Feb 18 20:56:27 localhost kernel:                               [<c045cd38>] handle_edge_irq+0xc2/0xff
Feb 18 20:56:27 localhost kernel:                               [<c045cc76>] handle_edge_irq+0x0/0xff
Feb 18 20:56:27 localhost kernel:                               [<c04071b4>] do_IRQ+0xac/0xd4
Feb 18 20:56:27 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 20:56:27 localhost kernel:       in-softirq-W at:
Feb 18 20:56:27 localhost kernel:                               [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:27 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:27 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:27 localhost kernel:                               [<c04235da>] complete+0x12/0x44
Feb 18 20:56:27 localhost kernel:                               [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:27 localhost kernel:                               [<c04235da>] complete+0x12/0x44
Feb 18 20:56:27 localhost kernel:                               [<c04235da>] complete+0x12/0x44
Feb 18 20:56:27 localhost kernel:                               [<c0430b61>] tasklet_action+0x23/0xa4
Feb 18 20:56:27 localhost kernel:                               [<c043b647>] __rcu_process_callbacks+0xfc/0x16e
Feb 18 20:56:27 localhost kernel:                               [<c043b6d1>] rcu_process_callbacks+0x18/0x30
Feb 18 20:56:27 localhost kernel:                               [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:56:27 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:27 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:27 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 20:56:27 localhost kernel:     }
Feb 18 20:56:27 localhost kernel:     ... key      at: [<c0804610>] __key.17392+0x0/0x8
Feb 18 20:56:27 localhost kernel:     -> (&rq->rq_lock_key){++..} ops: 138094 {
Feb 18 20:56:28 localhost kernel:        initial-use  at:
Feb 18 20:56:28 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:28 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:28 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:28 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:28 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:28 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:28 localhost kernel:                                 [<c075e3c9>] sched_init+0x27d/0x292
Feb 18 20:56:28 localhost kernel:                                 [<c074e756>] start_kernel+0x15e/0x327
Feb 18 20:56:28 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:56:28 localhost kernel:        in-hardirq-W at:
Feb 18 20:56:28 localhost kernel:                                 [<c04480a2>] find_usage_forwards+0x67/0x8b
Feb 18 20:56:28 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:28 localhost kernel:                                 [<c0442f77>] clocksource_get_next+0xa/0x3f
Feb 18 20:56:28 localhost kernel:                                 [<c0442fa6>] clocksource_get_next+0x39/0x3f
Feb 18 20:56:28 localhost kernel:                                 [<c044204f>] update_wall_time+0x58d/0x71c
Feb 18 20:56:28 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:28 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:28 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:28 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:28 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:28 localhost kernel:                                 [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:56:28 localhost kernel:                                 [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:56:28 localhost kernel:                                 [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:56:28 localhost kernel:                                 [<c0407b80>] timer_interrupt+0x44/0x4a
Feb 18 20:56:28 localhost kernel:                                 [<c045bcde>] handle_IRQ_event+0x13/0x3d
Feb 18 20:56:28 localhost kernel:                                 [<c045d17e>] handle_level_irq+0x78/0xbe
Feb 18 20:56:28 localhost kernel:                                 [<c045d106>] handle_level_irq+0x0/0xbe
Feb 18 20:56:28 localhost kernel:                                 [<c04071b4>] do_IRQ+0xac/0xd4
Feb 18 20:56:28 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:56:28 localhost kernel:        in-softirq-W at:
Feb 18 20:56:28 localhost kernel:                                 [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 20:56:28 localhost kernel:                                 [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 20:56:28 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:28 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:28 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:28 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:56:28 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:28 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:56:28 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:56:28 localhost kernel:                                 [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 20:56:29 localhost kernel:                                 [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 20:56:29 localhost kernel:                                 [<c0430afa>] __do_softirq+0xc9/0xde
Feb 18 20:56:29 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:29 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:56:29 localhost kernel:      }
Feb 18 20:56:29 localhost kernel:      ... key      at: [<c2a22488>] 0xc2a22488
Feb 18 20:56:29 localhost kernel:      -> (&rq->rq_lock_key#2){++..} ops: 382046 {
Feb 18 20:56:29 localhost kernel:         initial-use  at:
Feb 18 20:56:29 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:29 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:29 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:29 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:29 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:29 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:29 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:56:29 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:56:29 localhost kernel:                                   [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:56:29 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:56:29 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:56:29 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:56:29 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:29 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:29 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:29 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:29 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:29 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:29 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:29 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:29 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:56:29 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:56:29 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:29 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:29 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:29 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:29 localhost kernel:         in-hardirq-W at:
Feb 18 20:56:29 localhost kernel:                                   [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:29 localhost kernel:                                   [<c040a9d6>] save_stack_trace+0x20/0x3a
Feb 18 20:56:29 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:29 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:29 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:29 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:30 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:30 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:30 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:30 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:30 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:56:30 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:56:30 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:56:30 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:56:30 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:56:30 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:56:30 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:30 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:56:30 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:30 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:56:30 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:56:30 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:56:30 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:30 localhost kernel:         in-softirq-W at:
Feb 18 20:56:30 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:30 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 20:56:30 localhost kernel:                                   [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 20:56:30 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:30 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:30 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:56:30 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:30 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:56:30 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:56:30 localhost kernel:                                   [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:56:30 localhost kernel:                                   [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 20:56:30 localhost kernel:                                   [<c0433d59>] run_timer_softirq+0x113/0x188
Feb 18 20:56:30 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:30 localhost kernel:                                   [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:56:30 localhost kernel:                                   [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 20:56:30 localhost kernel:                                   [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:56:30 localhost kernel:                                   [<c0433d67>] run_timer_softirq+0x121/0x188
Feb 18 20:56:30 localhost kernel:                                   [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:56:30 localhost kernel:                                   [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 20:56:30 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:30 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:30 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:30 localhost kernel:       }
Feb 18 20:56:31 localhost kernel:       ... key      at: [<c2a2b488>] 0xc2a2b488
Feb 18 20:56:31 localhost kernel:       -> (&rq->rq_lock_key#3){++..} ops: 250064 {
Feb 18 20:56:31 localhost kernel:          initial-use  at:
Feb 18 20:56:31 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:31 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:31 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:31 localhost kernel:                                     [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:31 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:31 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:31 localhost kernel:                                     [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:56:31 localhost kernel:                                     [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:56:31 localhost kernel:                                     [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:56:31 localhost kernel:                                     [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:56:31 localhost kernel:                                     [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:56:31 localhost kernel:                                     [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:56:31 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:31 localhost kernel:                                     [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:31 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:31 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:31 localhost kernel:                                     [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:31 localhost kernel:                                     [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:31 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:31 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:31 localhost kernel:                                     [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:56:31 localhost kernel:                                     [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:56:31 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:31 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:31 localhost kernel:                                     [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:31 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:56:31 localhost kernel:          in-hardirq-W at:
Feb 18 20:56:31 localhost kernel:                                     [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:31 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:31 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:31 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:31 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:31 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:31 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:31 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:31 localhost kernel:                                     [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:56:31 localhost kernel:                                     [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:56:31 localhost kernel:                                     [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:56:32 localhost kernel:                                     [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:56:32 localhost kernel:                                     [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:56:32 localhost kernel:                                     [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:56:32 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:32 localhost kernel:                                     [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:56:32 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:32 localhost kernel:                                     [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:56:32 localhost kernel:                                     [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:56:32 localhost kernel:                                     [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:56:32 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:56:32 localhost kernel:          in-softirq-W at:
Feb 18 20:56:32 localhost kernel:                                     [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:32 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:32 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:32 localhost kernel:                                     [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:56:32 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:32 localhost kernel:                                     [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:56:32 localhost kernel:                                     [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:56:32 localhost kernel:                                     [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:56:32 localhost kernel:                                     [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:56:32 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:56:32 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:32 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:32 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:56:32 localhost kernel:        }
Feb 18 20:56:32 localhost kernel:        ... key      at: [<c2a34488>] 0xc2a34488
Feb 18 20:56:32 localhost kernel:        -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:56:32 localhost kernel:           initial-use  at:
Feb 18 20:56:32 localhost kernel:                                       [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:32 localhost kernel:                                       [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:32 localhost kernel:                                       [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:32 localhost kernel:                                       [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:32 localhost kernel:                                       [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:32 localhost kernel:                                       [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:32 localhost kernel:                                       [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:56:32 localhost kernel:                                       [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:56:32 localhost kernel:                                       [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:56:32 localhost kernel:                                       [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:56:32 localhost kernel:                                       [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:56:32 localhost kernel:                                       [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:56:32 localhost kernel:                                       [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:32 localhost kernel:                                       [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:33 localhost kernel:                                       [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:33 localhost kernel:                                       [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:33 localhost kernel:                                       [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:33 localhost kernel:                                       [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:33 localhost kernel:                                       [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:33 localhost kernel:                                       [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:33 localhost kernel:                                       [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:56:33 localhost kernel:                                       [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:56:33 localhost kernel:                                       [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:33 localhost kernel:                                       [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:33 localhost kernel:                                       [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:33 localhost kernel:                                       [<ffffffff>] 0xffffffff
Feb 18 20:56:33 localhost kernel:           in-hardirq-W at:
Feb 18 20:56:33 localhost kernel:                                       [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:33 localhost kernel:                                       [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:33 localhost kernel:                                       [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:33 localhost kernel:                                       [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:33 localhost kernel:                                       [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:33 localhost kernel:                                       [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:33 localhost kernel:                                       [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:33 localhost kernel:                                       [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:33 localhost kernel:                                       [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:56:33 localhost kernel:                                       [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:56:33 localhost kernel:                                       [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:56:33 localhost kernel:                                       [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:56:33 localhost kernel:                                       [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:56:33 localhost kernel:                                       [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:56:33 localhost kernel:                                       [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:33 localhost kernel:                                       [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:56:33 localhost kernel:                                       [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:33 localhost kernel:                                       [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:56:33 localhost kernel:                                       [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:56:33 localhost kernel:                                       [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:56:33 localhost kernel:                                       [<ffffffff>] 0xffffffff
Feb 18 20:56:33 localhost kernel:           in-softirq-W at:
Feb 18 20:56:33 localhost kernel:                                       [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:33 localhost kernel:                                       [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:33 localhost kernel:                                       [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:33 localhost kernel:                                       [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:33 localhost kernel:                                       [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:33 localhost kernel:                                       [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:33 localhost kernel:                                       [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:56:34 localhost kernel:                                       [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:56:34 localhost kernel:                                       [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:56:34 localhost kernel:                                       [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:34 localhost kernel:                                       [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:34 localhost kernel:                                       [<ffffffff>] 0xffffffff
Feb 18 20:56:34 localhost kernel:         }
Feb 18 20:56:34 localhost kernel:         ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:56:34 localhost kernel:        ... acquired at:
Feb 18 20:56:34 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:56:34 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:34 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:56:34 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:34 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:56:34 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:56:34 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:34 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:56:34 localhost kernel: 
Feb 18 20:56:34 localhost kernel:       ... acquired at:
Feb 18 20:56:34 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:34 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:56:34 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:34 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:56:34 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:34 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:56:34 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:56:34 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:34 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:56:35 localhost kernel: 
Feb 18 20:56:35 localhost kernel:       -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:56:35 localhost kernel:          initial-use  at:
Feb 18 20:56:35 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:35 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:35 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:35 localhost kernel:                                     [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:35 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:35 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:35 localhost kernel:                                     [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:56:35 localhost kernel:                                     [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:56:35 localhost kernel:                                     [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:56:35 localhost kernel:                                     [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:56:35 localhost kernel:                                     [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:56:35 localhost kernel:                                     [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:56:35 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:35 localhost kernel:                                     [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:35 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:35 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:35 localhost kernel:                                     [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:35 localhost kernel:                                     [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:35 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:35 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:35 localhost kernel:                                     [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:56:35 localhost kernel:                                     [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:56:35 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:35 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:35 localhost kernel:                                     [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:35 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:56:35 localhost kernel:          in-hardirq-W at:
Feb 18 20:56:35 localhost kernel:                                     [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:35 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:35 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:35 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:35 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:35 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:35 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:35 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:35 localhost kernel:                                     [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:56:35 localhost kernel:                                     [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:56:35 localhost kernel:                                     [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:56:36 localhost kernel:                                     [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:56:36 localhost kernel:                                     [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:56:36 localhost kernel:                                     [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:56:36 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:36 localhost kernel:                                     [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:56:36 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:36 localhost kernel:                                     [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:56:36 localhost kernel:                                     [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:56:36 localhost kernel:                                     [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:56:36 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:56:36 localhost kernel:          in-softirq-W at:
Feb 18 20:56:36 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:36 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:36 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:36 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:36 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:36 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:36 localhost kernel:                                     [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:56:36 localhost kernel:                                     [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:56:36 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:56:36 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:36 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:36 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:56:36 localhost kernel:        }
Feb 18 20:56:36 localhost kernel:        ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:56:36 localhost kernel:       ... acquired at:
Feb 18 20:56:36 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:56:36 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:36 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:36 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:36 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:36 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:36 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:36 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:56:36 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:36 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:56:36 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:36 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:56:36 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:56:36 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:36 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:56:37 localhost kernel: 
Feb 18 20:56:37 localhost kernel:      ... acquired at:
Feb 18 20:56:37 localhost kernel:    [<c0446b6a>] add_lock_to_list+0x66/0x89
Feb 18 20:56:37 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:56:37 localhost kernel:    [<c0619307>] schedule+0x22e/0x6ec
Feb 18 20:56:37 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:37 localhost kernel:    [<c0619307>] schedule+0x22e/0x6ec
Feb 18 20:56:37 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:37 localhost kernel:    [<c0619307>] schedule+0x22e/0x6ec
Feb 18 20:56:37 localhost kernel:    [<c0619307>] schedule+0x22e/0x6ec
Feb 18 20:56:37 localhost kernel:    [<c0619a92>] schedule_timeout+0x13/0x8d
Feb 18 20:56:37 localhost kernel:    [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 20:56:37 localhost kernel:    [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:37 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:37 localhost kernel:    [<c06198d2>] wait_for_common+0xa6/0xe0
Feb 18 20:56:37 localhost kernel:    [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:56:37 localhost kernel:    [<c0439c5c>] call_usermodehelper_exec+0x7a/0xbe
Feb 18 20:56:37 localhost kernel:    [<c04ecbd6>] kobject_uevent_env+0x348/0x37c
Feb 18 20:56:37 localhost kernel:    [<c055f4c0>] device_add+0x318/0x54c
Feb 18 20:56:37 localhost kernel:    [<c055fa67>] device_create+0x7a/0x9a
Feb 18 20:56:37 localhost kernel:    [<c053c13e>] tty_register_device+0xb5/0xbd
Feb 18 20:56:37 localhost kernel:    [<c04efab1>] vsnprintf+0x440/0x47c
Feb 18 20:56:37 localhost kernel:    [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 20:56:37 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:37 localhost kernel:    [<c042c9c6>] register_console+0x4b/0x1fe
Feb 18 20:56:37 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:37 localhost kernel:    [<c055aff0>] serial8250_pm+0x0/0xb2
Feb 18 20:56:37 localhost kernel:    [<c0558795>] uart_change_pm+0x23/0x2b
Feb 18 20:56:37 localhost kernel:    [<c055998a>] uart_add_one_port+0x29d/0x2f6
Feb 18 20:56:37 localhost kernel:    [<c05623c9>] platform_device_add+0xee/0x11c
Feb 18 20:56:37 localhost kernel:    [<c055ed94>] device_initialize+0x7b/0x93
Feb 18 20:56:37 localhost kernel:    [<c05624ee>] platform_device_alloc+0x40/0x51
Feb 18 20:56:37 localhost kernel:    [<c076a545>] serial8250_init+0xca/0x110
Feb 18 20:56:37 localhost kernel:    [<c074e491>] kernel_init+0x148/0x2af
Feb 18 20:56:37 localhost kernel:    [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:37 localhost kernel:    [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:37 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:37 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:56:37 localhost kernel: 
Feb 18 20:56:37 localhost kernel:      -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:56:37 localhost kernel:         initial-use  at:
Feb 18 20:56:38 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:38 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:38 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:38 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:38 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:38 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:38 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:56:38 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:56:38 localhost kernel:                                   [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:56:38 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:56:38 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:56:38 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:56:38 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:38 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:38 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:38 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:38 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:38 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:38 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:38 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:38 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:56:38 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:56:38 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:38 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:38 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:38 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:38 localhost kernel:         in-hardirq-W at:
Feb 18 20:56:38 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:38 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:38 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:38 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:38 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:38 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:38 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:38 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:38 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:56:38 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:56:38 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:56:38 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:56:38 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:56:38 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:56:39 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:39 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:56:39 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:39 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:56:39 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:56:39 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:56:39 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:39 localhost kernel:         in-softirq-W at:
Feb 18 20:56:39 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:39 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:39 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:39 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:39 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:39 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:39 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:56:39 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:56:39 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:56:39 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:39 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:39 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:39 localhost kernel:       }
Feb 18 20:56:39 localhost kernel:       ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:56:39 localhost kernel:      ... acquired at:
Feb 18 20:56:39 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:56:39 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:39 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:39 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:39 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:39 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:39 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:56:39 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:56:39 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:39 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:56:39 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:56:39 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:56:39 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:56:39 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:39 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:56:39 localhost kernel: 
Feb 18 20:56:39 localhost kernel:      -> (&rq->rq_lock_key#3){++..} ops: 250064 {
Feb 18 20:56:39 localhost kernel:         initial-use  at:
Feb 18 20:56:40 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:40 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:40 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:40 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:40 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:40 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:40 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:56:40 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:56:40 localhost kernel:                                   [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:56:40 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:56:40 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:56:40 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:56:40 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:40 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:40 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:40 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:40 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:40 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:56:40 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:40 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:40 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:56:40 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:56:40 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:40 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:56:40 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:56:40 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:40 localhost kernel:         in-hardirq-W at:
Feb 18 20:56:40 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:56:40 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:40 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:56:40 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:40 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:40 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:40 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:40 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:56:40 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:56:40 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:56:40 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:56:40 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:56:40 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:56:40 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:56:41 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:41 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:56:41 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:56:41 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:56:41 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:56:41 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:56:41 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:41 localhost kernel:         in-softirq-W at:
Feb 18 20:56:41 localhost kernel:                                   [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:56:41 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:56:41 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:41 localhost kernel:                                   [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:56:41 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:56:41 localhost kernel:                                   [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:56:41 localhost kernel:                                   [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:56:41 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:56:41 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:56:41 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:56:41 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:56:41 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:56:41 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:56:41 localhost kernel:       }
Feb 18 20:56:41 localhost kernel:       ... key      at: [<c2a34488>] 0xc2a34488
Feb 18 20:56:41 localhost kernel:       -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:56:41 localhost kernel:          initial-use  at:
Feb 18 20:56:41 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:56:41 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:56:41 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:41 localhost kernel:                                     [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:56:41 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:41 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:56:41 localhost kernel:                                     [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:56:41 localhost kernel:                                     [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:56:41 localhost kernel:                                     [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:56:41 localhost kernel:                                     [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:56:41 localhost kernel:                                     [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:56:41 localhost kernel:                                     [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:56:41 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:42 localhost kernel:                                     [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:56:43 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:56:48 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:56:53 localhost kernel:                                     [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:56:58 localhost kernel:                                     [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:03 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:09 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:13 localhost kernel:                                     [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:18 localhost kernel:                                     [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:21 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:25 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:26 localhost kernel:                                     [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:27 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:57:27 localhost kernel:          in-hardirq-W at:
Feb 18 20:57:27 localhost kernel:                                     [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:27 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:27 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:27 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:27 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:27 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:27 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:27 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:27 localhost kernel:                                     [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:27 localhost kernel:                                     [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:27 localhost kernel:                                     [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:27 localhost kernel:                                     [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:27 localhost kernel:                                     [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:27 localhost kernel:                                     [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:27 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:27 localhost kernel:                                     [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:27 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:27 localhost kernel:                                     [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:27 localhost kernel:                                     [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:27 localhost kernel:                                     [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:27 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:57:27 localhost kernel:          in-softirq-W at:
Feb 18 20:57:27 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:27 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:27 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:27 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:27 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:                                     [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:57:28 localhost kernel:                                     [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:57:28 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:57:28 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:28 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:28 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:57:28 localhost kernel:        }
Feb 18 20:57:28 localhost kernel:        ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:57:28 localhost kernel:       ... acquired at:
Feb 18 20:57:28 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:57:28 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:28 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:57:28 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:28 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:28 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:28 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:28 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:28 localhost kernel: 
Feb 18 20:57:28 localhost kernel:      ... acquired at:
Feb 18 20:57:28 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:28 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:57:28 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:28 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:57:28 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:28 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:28 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:28 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:29 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:29 localhost kernel: 
Feb 18 20:57:29 localhost kernel:     ... acquired at:
Feb 18 20:57:29 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:29 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:29 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:29 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:29 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:29 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:29 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:29 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:29 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 20:57:29 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 20:57:29 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 20:57:29 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:29 localhost kernel:    [<c043d502>] kthread+0x1c/0x5e
Feb 18 20:57:29 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:29 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:29 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:29 localhost kernel: 
Feb 18 20:57:29 localhost kernel:     -> (&rq->rq_lock_key#2){++..} ops: 382046 {
Feb 18 20:57:29 localhost kernel:        initial-use  at:
Feb 18 20:57:29 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:29 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:29 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:29 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:29 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:29 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:29 localhost kernel:                                 [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:57:29 localhost kernel:                                 [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:57:29 localhost kernel:                                 [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:57:29 localhost kernel:                                 [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:57:29 localhost kernel:                                 [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:57:29 localhost kernel:                                 [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:57:29 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:29 localhost kernel:                                 [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:29 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:29 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:29 localhost kernel:                                 [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:57:29 localhost kernel:                                 [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:29 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:29 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:30 localhost kernel:                                 [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:30 localhost kernel:                                 [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:30 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:30 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:30 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:30 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:30 localhost kernel:        in-hardirq-W at:
Feb 18 20:57:30 localhost kernel:                                 [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:57:30 localhost kernel:                                 [<c040a9d6>] save_stack_trace+0x20/0x3a
Feb 18 20:57:30 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:30 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:30 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:30 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:30 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:30 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:30 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:30 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:30 localhost kernel:                                 [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:30 localhost kernel:                                 [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:30 localhost kernel:                                 [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:30 localhost kernel:                                 [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:30 localhost kernel:                                 [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:30 localhost kernel:                                 [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:30 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:30 localhost kernel:                                 [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:30 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:30 localhost kernel:                                 [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:30 localhost kernel:                                 [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:30 localhost kernel:                                 [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:30 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:30 localhost kernel:        in-softirq-W at:
Feb 18 20:57:30 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:30 localhost kernel:                                 [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 20:57:30 localhost kernel:                                 [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 20:57:30 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:30 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:30 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:30 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:30 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:30 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:30 localhost kernel:                                 [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:57:31 localhost kernel:                                 [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 20:57:31 localhost kernel:                                 [<c0433d59>] run_timer_softirq+0x113/0x188
Feb 18 20:57:31 localhost kernel:                                 [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:31 localhost kernel:                                 [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:57:31 localhost kernel:                                 [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 20:57:31 localhost kernel:                                 [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:57:31 localhost kernel:                                 [<c0433d67>] run_timer_softirq+0x121/0x188
Feb 18 20:57:31 localhost kernel:                                 [<c0433efb>] process_timeout+0x0/0x5
Feb 18 20:57:31 localhost kernel:                                 [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 20:57:31 localhost kernel:                                 [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:31 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:31 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:31 localhost kernel:      }
Feb 18 20:57:31 localhost kernel:      ... key      at: [<c2a2b488>] 0xc2a2b488
Feb 18 20:57:31 localhost kernel:      -> (&rq->rq_lock_key#3){++..} ops: 250064 {
Feb 18 20:57:31 localhost kernel:         initial-use  at:
Feb 18 20:57:31 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:31 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:31 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:31 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:31 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:31 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:31 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:57:31 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:57:31 localhost kernel:                                   [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:57:31 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:57:31 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:57:31 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:57:31 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:31 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:31 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:31 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:31 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:57:31 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:31 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:31 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:31 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:31 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:31 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:31 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:31 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:32 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:32 localhost kernel:         in-hardirq-W at:
Feb 18 20:57:32 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:32 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:32 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:32 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:32 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:32 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:32 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:32 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:32 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:32 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:32 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:32 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:32 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:32 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:32 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:32 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:32 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:32 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:32 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:32 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:32 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:32 localhost kernel:         in-softirq-W at:
Feb 18 20:57:32 localhost kernel:                                   [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:57:32 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:32 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:32 localhost kernel:                                   [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:57:32 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:32 localhost kernel:                                   [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:57:32 localhost kernel:                                   [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:57:32 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:57:32 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:57:32 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:57:32 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:32 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:32 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:32 localhost kernel:       }
Feb 18 20:57:32 localhost kernel:       ... key      at: [<c2a34488>] 0xc2a34488
Feb 18 20:57:32 localhost kernel:       -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:57:32 localhost kernel:          initial-use  at:
Feb 18 20:57:33 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:33 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:33 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:33 localhost kernel:                                     [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:33 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:33 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:33 localhost kernel:                                     [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:57:33 localhost kernel:                                     [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:57:33 localhost kernel:                                     [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:57:33 localhost kernel:                                     [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:57:33 localhost kernel:                                     [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:57:33 localhost kernel:                                     [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:57:33 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:33 localhost kernel:                                     [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:33 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:33 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:33 localhost kernel:                                     [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:57:33 localhost kernel:                                     [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:33 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:33 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:33 localhost kernel:                                     [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:33 localhost kernel:                                     [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:33 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:33 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:33 localhost kernel:                                     [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:33 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:57:33 localhost kernel:          in-hardirq-W at:
Feb 18 20:57:33 localhost kernel:                                     [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:33 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:33 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:33 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:33 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:33 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:33 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:33 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:33 localhost kernel:                                     [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:33 localhost kernel:                                     [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:33 localhost kernel:                                     [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:33 localhost kernel:                                     [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:33 localhost kernel:                                     [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:33 localhost kernel:                                     [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:33 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:33 localhost kernel:                                     [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:34 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:34 localhost kernel:                                     [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:34 localhost kernel:                                     [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:34 localhost kernel:                                     [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:34 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:57:34 localhost kernel:          in-softirq-W at:
Feb 18 20:57:34 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:34 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:34 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:34 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:                                     [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:57:34 localhost kernel:                                     [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:57:34 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:57:34 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:34 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:34 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 20:57:34 localhost kernel:        }
Feb 18 20:57:34 localhost kernel:        ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:57:34 localhost kernel:       ... acquired at:
Feb 18 20:57:34 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:57:34 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:34 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:57:34 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:34 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:34 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:34 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:34 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:34 localhost kernel: 
Feb 18 20:57:34 localhost kernel:      ... acquired at:
Feb 18 20:57:34 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:34 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:34 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:35 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:35 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:35 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:35 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:57:35 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:35 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:57:35 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:35 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:35 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:35 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:35 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:35 localhost kernel: 
Feb 18 20:57:35 localhost kernel:      -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:57:35 localhost kernel:         initial-use  at:
Feb 18 20:57:35 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:35 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:35 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:35 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:35 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:35 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:35 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:57:35 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:57:35 localhost kernel:                                   [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:57:35 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:57:35 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:57:35 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:57:35 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:35 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:35 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:35 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:35 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:57:35 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:35 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:35 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:35 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:35 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:35 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:35 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:35 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:35 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:35 localhost kernel:         in-hardirq-W at:
Feb 18 20:57:35 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:36 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:36 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:36 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:36 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:36 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:36 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:36 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:36 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:36 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:36 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:36 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:36 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:36 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:36 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:36 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:36 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:36 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:36 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:36 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:36 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:36 localhost kernel:         in-softirq-W at:
Feb 18 20:57:36 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:36 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:36 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:36 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:36 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:36 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:36 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:57:36 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:57:36 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:57:36 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:36 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:36 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:36 localhost kernel:       }
Feb 18 20:57:36 localhost kernel:       ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:57:36 localhost kernel:      ... acquired at:
Feb 18 20:57:36 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:36 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:36 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:36 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:37 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:37 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:37 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:37 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:57:37 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:37 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:57:37 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:37 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:37 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:37 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:37 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:37 localhost kernel: 
Feb 18 20:57:37 localhost kernel:     ... acquired at:
Feb 18 20:57:37 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:37 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:37 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:37 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:37 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:37 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:37 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:37 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 20:57:37 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 20:57:37 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 20:57:37 localhost kernel:    [<c043aad8>] worker_thread+0x0/0xc4
Feb 18 20:57:37 localhost kernel:    [<c043d502>] kthread+0x1c/0x5e
Feb 18 20:57:37 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:37 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:37 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:37 localhost kernel: 
Feb 18 20:57:37 localhost kernel:     -> (&rq->rq_lock_key#3){++..} ops: 250064 {
Feb 18 20:57:37 localhost kernel:        initial-use  at:
Feb 18 20:57:37 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:37 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:37 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:37 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:37 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:37 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:37 localhost kernel:                                 [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:57:37 localhost kernel:                                 [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:57:37 localhost kernel:                                 [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:57:38 localhost kernel:                                 [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:57:38 localhost kernel:                                 [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:57:38 localhost kernel:                                 [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:57:38 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:38 localhost kernel:                                 [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:38 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:38 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:38 localhost kernel:                                 [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:57:38 localhost kernel:                                 [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:38 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:38 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:38 localhost kernel:                                 [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:38 localhost kernel:                                 [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:38 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:38 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:38 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:38 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:38 localhost kernel:        in-hardirq-W at:
Feb 18 20:57:38 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:38 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:38 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:38 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:38 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:38 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:38 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:38 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:38 localhost kernel:                                 [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:38 localhost kernel:                                 [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:38 localhost kernel:                                 [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:38 localhost kernel:                                 [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:38 localhost kernel:                                 [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:38 localhost kernel:                                 [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:38 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:38 localhost kernel:                                 [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:38 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:38 localhost kernel:                                 [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:38 localhost kernel:                                 [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:38 localhost kernel:                                 [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:38 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:38 localhost kernel:        in-softirq-W at:
Feb 18 20:57:38 localhost kernel:                                 [<c044816c>] mark_lock+0x65/0x454
Feb 18 20:57:38 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:39 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:39 localhost kernel:                                 [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:57:39 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:39 localhost kernel:                                 [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:57:39 localhost kernel:                                 [<c042313a>] double_rq_lock+0x29/0x40
Feb 18 20:57:39 localhost kernel:                                 [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:57:39 localhost kernel:                                 [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:57:39 localhost kernel:                                 [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:57:39 localhost kernel:                                 [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:39 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:39 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:39 localhost kernel:      }
Feb 18 20:57:39 localhost kernel:      ... key      at: [<c2a34488>] 0xc2a34488
Feb 18 20:57:39 localhost kernel:      -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:57:39 localhost kernel:         initial-use  at:
Feb 18 20:57:39 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:39 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:39 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:39 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:39 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:39 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:39 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:57:39 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:57:39 localhost kernel:                                   [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:57:39 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:57:39 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:57:39 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:57:39 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:39 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:39 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:39 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:39 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:57:39 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:39 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:39 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:39 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:39 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:39 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:39 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:39 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:39 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:40 localhost kernel:         in-hardirq-W at:
Feb 18 20:57:40 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:40 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:40 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:40 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:40 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:40 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:40 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:40 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:40 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:40 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:40 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:40 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:40 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:40 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:40 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:40 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:40 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:40 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:40 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:40 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:40 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:40 localhost kernel:         in-softirq-W at:
Feb 18 20:57:40 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:40 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:40 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:40 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:40 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:40 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:40 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:57:40 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:57:40 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:57:40 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:40 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:40 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 20:57:40 localhost kernel:       }
Feb 18 20:57:40 localhost kernel:       ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:57:40 localhost kernel:      ... acquired at:
Feb 18 20:57:40 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:40 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:40 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:40 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:41 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:41 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:41 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:41 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 20:57:41 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:41 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 20:57:41 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:41 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:41 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:41 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:41 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:41 localhost kernel: 
Feb 18 20:57:41 localhost kernel:     ... acquired at:
Feb 18 20:57:41 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:41 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:41 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:41 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:41 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:41 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:41 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:41 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 20:57:41 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 20:57:41 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 20:57:41 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:41 localhost kernel:    [<c0428996>] migration_thread+0x186/0x1d2
Feb 18 20:57:41 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:41 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:41 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:41 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:41 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:41 localhost kernel: 
Feb 18 20:57:41 localhost kernel:     -> (&rq->rq_lock_key#4){++..} ops: 233519 {
Feb 18 20:57:41 localhost kernel:        initial-use  at:
Feb 18 20:57:41 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:41 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:41 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:41 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:41 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:41 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 20:57:41 localhost kernel:                                 [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 20:57:41 localhost kernel:                                 [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 20:57:42 localhost kernel:                                 [<c041a8a3>] setup_local_APIC+0x9e/0x28f
Feb 18 20:57:42 localhost kernel:                                 [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 20:57:42 localhost kernel:                                 [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 20:57:42 localhost kernel:                                 [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 20:57:42 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:42 localhost kernel:                                 [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:42 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:42 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 20:57:42 localhost kernel:                                 [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 20:57:42 localhost kernel:                                 [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 20:57:42 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:42 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:42 localhost kernel:                                 [<c074e399>] kernel_init+0x50/0x2af
Feb 18 20:57:42 localhost kernel:                                 [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 20:57:42 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:42 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 20:57:42 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:42 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:42 localhost kernel:        in-hardirq-W at:
Feb 18 20:57:42 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 20:57:42 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:42 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:42 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:42 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:42 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:42 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:42 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 20:57:42 localhost kernel:                                 [<c0434365>] update_process_times+0x3a/0x44
Feb 18 20:57:42 localhost kernel:                                 [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 20:57:42 localhost kernel:                                 [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 20:57:42 localhost kernel:                                 [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 20:57:42 localhost kernel:                                 [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 20:57:42 localhost kernel:                                 [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 20:57:42 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:42 localhost kernel:                                 [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 20:57:42 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 20:57:42 localhost kernel:                                 [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 20:57:42 localhost kernel:                                 [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 20:57:42 localhost kernel:                                 [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 20:57:42 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:42 localhost kernel:        in-softirq-W at:
Feb 18 20:57:43 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:43 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:43 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:43 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:43 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:43 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 20:57:43 localhost kernel:                                 [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 20:57:43 localhost kernel:                                 [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 20:57:43 localhost kernel:                                 [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 20:57:43 localhost kernel:                                 [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:43 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:43 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 20:57:43 localhost kernel:      }
Feb 18 20:57:43 localhost kernel:      ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 20:57:43 localhost kernel:     ... acquired at:
Feb 18 20:57:43 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:43 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:43 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:43 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:43 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 20:57:43 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:43 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 20:57:43 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 20:57:43 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 20:57:43 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 20:57:43 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:43 localhost kernel:    [<c0428996>] migration_thread+0x186/0x1d2
Feb 18 20:57:43 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 20:57:43 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 20:57:43 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 20:57:43 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 20:57:43 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:43 localhost kernel: 
Feb 18 20:57:43 localhost kernel:    ... acquired at:
Feb 18 20:57:43 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:43 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 20:57:43 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:43 localhost kernel:    [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:57:43 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:43 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 20:57:43 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:44 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 20:57:44 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 20:57:44 localhost kernel:    [<f8c58a2b>] ppp_receive_nonmp_frame+0x51f/0x70a [ppp_generic]
Feb 18 20:57:44 localhost kernel:    [<f8c59487>] ppp_input+0xbf/0xef [ppp_generic]
Feb 18 20:57:44 localhost kernel:    [<f8c60263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 20:57:44 localhost kernel:    [<f8c6037a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 20:57:44 localhost kernel:    [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 20:57:44 localhost kernel:    [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 20:57:44 localhost kernel:    [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 20:57:44 localhost kernel:    [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 20:57:44 localhost kernel:    [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 20:57:44 localhost kernel:    [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 20:57:44 localhost kernel:    [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:57:44 localhost kernel:    [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 20:57:44 localhost kernel:    [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 20:57:44 localhost kernel:    [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:57:44 localhost kernel:    [<f89877c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 20:57:44 localhost kernel:    [<f8987453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 20:57:44 localhost kernel:    [<f8984f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 20:57:44 localhost kernel:    [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 20:57:44 localhost kernel:    [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 20:57:44 localhost kernel:    [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:44 localhost kernel:    [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:44 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:44 localhost kernel: 
Feb 18 20:57:44 localhost kernel:   ... acquired at:
Feb 18 20:57:44 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:44 localhost kernel:    [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:57:44 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:44 localhost kernel:    [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:57:44 localhost kernel:    [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:57:44 localhost kernel:    [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:57:44 localhost kernel:    [<f8c57bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 20:57:44 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 20:57:44 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:44 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:44 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 20:57:44 localhost kernel:    [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:57:44 localhost kernel:    [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:57:44 localhost kernel:    [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:57:44 localhost kernel:    [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:57:45 localhost kernel:    [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:57:45 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:57:45 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:45 localhost kernel: 
Feb 18 20:57:45 localhost kernel:   -> (&list->lock#7){.+..} ops: 31 {
Feb 18 20:57:45 localhost kernel:      initial-use  at:
Feb 18 20:57:45 localhost kernel:                             [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:45 localhost kernel:                             [<c046b874>] __do_fault+0x31b/0x35d
Feb 18 20:57:45 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:45 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:57:45 localhost kernel:                             [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:45 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:57:45 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:57:45 localhost kernel:                             [<f8c5939f>] ppp_write+0xb2/0xdb [ppp_generic]
Feb 18 20:57:45 localhost kernel:                             [<f8c592ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 20:57:45 localhost kernel:                             [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 20:57:45 localhost kernel:                             [<c047ecfd>] sys_write+0x41/0x67
Feb 18 20:57:45 localhost kernel:                             [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:57:45 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 20:57:45 localhost kernel:      in-softirq-W at:
Feb 18 20:57:45 localhost kernel:                             [<c0446ab0>] save_trace+0x37/0x8b
Feb 18 20:57:45 localhost kernel:                             [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 20:57:45 localhost kernel:                             [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:45 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:45 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:57:45 localhost kernel:                             [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:45 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:57:45 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 20:57:45 localhost kernel:                             [<f8c59433>] ppp_input+0x6b/0xef [ppp_generic]
Feb 18 20:57:45 localhost kernel:                             [<f8c60263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 20:57:45 localhost kernel:                             [<f8c6037a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 20:57:45 localhost kernel:                             [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 20:57:45 localhost kernel:                             [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 20:57:45 localhost kernel:                             [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 20:57:45 localhost kernel:                             [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 20:57:45 localhost kernel:                             [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 20:57:45 localhost kernel:                             [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 20:57:45 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:57:45 localhost kernel:                             [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 20:57:45 localhost kernel:                             [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 20:57:45 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 20:57:45 localhost kernel:                             [<f89877c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 20:57:45 localhost kernel:                             [<f8987453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 20:57:46 localhost kernel:                             [<f8984f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 20:57:46 localhost kernel:                             [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 20:57:46 localhost kernel:                             [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 20:57:46 localhost kernel:                             [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 20:57:46 localhost kernel:                             [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 20:57:46 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 20:57:46 localhost kernel:    }
Feb 18 20:57:46 localhost kernel:    ... key      at: [<f8c5dd18>] __key.21159+0x0/0xffffb82a [ppp_generic]
Feb 18 20:57:46 localhost kernel:   ... acquired at:
Feb 18 20:57:46 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:46 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 20:57:46 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:46 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:46 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 20:57:46 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 20:57:46 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 20:57:46 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 20:57:46 localhost kernel:    [<f8c57424>] ppp_xmit_process+0x529/0x5a1 [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<f8c5834b>] ppp_channel_push+0x71/0x90 [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<c061b373>] _read_lock_bh+0x2e/0x39
Feb 18 20:57:46 localhost kernel:    [<f8c5835a>] ppp_channel_push+0x80/0x90 [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<f8c593bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<f8c592ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 20:57:46 localhost kernel:    [<c047ecfd>] sys_write+0x41/0x67
Feb 18 20:57:46 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:57:46 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:46 localhost kernel: 
Feb 18 20:57:46 localhost kernel:  ... acquired at:
Feb 18 20:57:46 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 20:57:46 localhost kernel:    [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:46 localhost kernel:    [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:57:46 localhost kernel:    [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<f8c57bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 20:57:46 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 20:57:46 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:46 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:46 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 20:57:46 localhost kernel:    [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:57:47 localhost kernel:    [<c061ae17>] __down_failed+0x7/0xc
Feb 18 20:57:47 localhost kernel:    [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 20:57:47 localhost kernel:    [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 20:57:47 localhost kernel:    [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 20:57:47 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:57:47 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 20:57:47 localhost kernel: 
Feb 18 20:57:47 localhost kernel: 
Feb 18 20:57:47 localhost kernel: the soft-irq-unsafe lock's dependencies:
Feb 18 20:57:47 localhost kernel: -> (&sk->sk_dst_lock){----} ops: 284 {
Feb 18 20:57:47 localhost kernel:    initial-use  at:
Feb 18 20:57:47 localhost kernel:                         [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 20:57:47 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 20:57:47 localhost kernel:                         [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 20:57:47 localhost kernel:                         [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 20:57:47 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:47 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:47 localhost kernel:                         [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 20:57:47 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:47 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:47 localhost kernel:                         [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 20:57:47 localhost kernel:                         [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 20:57:47 localhost kernel:                         [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 20:57:47 localhost kernel:                         [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 20:57:47 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:47 localhost kernel:                         [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 20:57:47 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:57:47 localhost kernel:    softirq-on-W at:
Feb 18 20:57:47 localhost kernel:                         [<c0449046>] __lock_acquire+0x48b/0xbf1
Feb 18 20:57:47 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 20:57:47 localhost kernel:                         [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 20:57:47 localhost kernel:                         [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 20:57:47 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:47 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:47 localhost kernel:                         [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 20:57:47 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:47 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:47 localhost kernel:                         [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 20:57:47 localhost kernel:                         [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 20:57:47 localhost kernel:                         [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 20:57:47 localhost kernel:                         [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 20:57:47 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:48 localhost kernel:                         [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 20:57:48 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:57:48 localhost kernel:    hardirq-on-W at:
Feb 18 20:57:48 localhost kernel:                         [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 20:57:48 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 20:57:48 localhost kernel:                         [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 20:57:48 localhost kernel:                         [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 20:57:48 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:48 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:48 localhost kernel:                         [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 20:57:48 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:48 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 20:57:48 localhost kernel:                         [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 20:57:48 localhost kernel:                         [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 20:57:48 localhost kernel:                         [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 20:57:48 localhost kernel:                         [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 20:57:48 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:48 localhost kernel:                         [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 20:57:48 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:57:48 localhost kernel:    softirq-on-R at:
Feb 18 20:57:48 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:48 localhost kernel:                         [<c0449046>] __lock_acquire+0x48b/0xbf1
Feb 18 20:57:48 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:48 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:48 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 20:57:48 localhost kernel:                         [<c061b3a7>] _read_lock+0x29/0x34
Feb 18 20:57:48 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 20:57:48 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 20:57:48 localhost kernel:                         [<f8a6a9b1>] ipv6_chk_addr+0x8a/0x96 [ipv6]
Feb 18 20:57:48 localhost kernel:                         [<f8a649b0>] ip6_sk_dst_lookup+0x2d/0x17a [ipv6]
Feb 18 20:57:48 localhost kernel:                         [<c0489d61>] __pollwait+0x0/0xac
Feb 18 20:57:48 localhost kernel:                         [<f8a75e6d>] udpv6_sendmsg+0x4c1/0x8a1 [ipv6]
Feb 18 20:57:48 localhost kernel:                         [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:57:48 localhost last message repeated 2 times
Feb 18 20:57:48 localhost kernel:                         [<c05f5fc7>] inet_sendmsg+0x3b/0x45
Feb 18 20:57:48 localhost kernel:                         [<c05ab8cd>] sock_sendmsg+0xc9/0xe4
Feb 18 20:57:48 localhost kernel:                         [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 20:57:48 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:48 localhost kernel:                         [<c04f05f4>] copy_from_user+0x32/0x5e
Feb 18 20:57:49 localhost kernel:                         [<c04f05f4>] copy_from_user+0x32/0x5e
Feb 18 20:57:49 localhost kernel:                         [<c05aba7a>] sys_sendmsg+0x192/0x1f7
Feb 18 20:57:49 localhost kernel:                         [<c048f764>] file_update_time+0x22/0x6a
Feb 18 20:57:49 localhost kernel:                         [<c0483d90>] pipe_write+0x392/0x3ef
Feb 18 20:57:49 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:49 localhost kernel:                         [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 20:57:49 localhost kernel:                         [<c05acd2b>] sys_socketcall+0x240/0x261
Feb 18 20:57:49 localhost kernel:                         [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:57:49 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:57:49 localhost kernel:    hardirq-on-R at:
Feb 18 20:57:49 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:49 localhost kernel:                         [<c0449001>] __lock_acquire+0x446/0xbf1
Feb 18 20:57:49 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:49 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:49 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 20:57:49 localhost kernel:                         [<c061b3a7>] _read_lock+0x29/0x34
Feb 18 20:57:49 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 20:57:49 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 20:57:49 localhost kernel:                         [<f8a6a9b1>] ipv6_chk_addr+0x8a/0x96 [ipv6]
Feb 18 20:57:49 localhost kernel:                         [<f8a649b0>] ip6_sk_dst_lookup+0x2d/0x17a [ipv6]
Feb 18 20:57:49 localhost kernel:                         [<c0489d61>] __pollwait+0x0/0xac
Feb 18 20:57:49 localhost kernel:                         [<f8a75e6d>] udpv6_sendmsg+0x4c1/0x8a1 [ipv6]
Feb 18 20:57:49 localhost kernel:                         [<c0425474>] default_wake_function+0x0/0x8
Feb 18 20:57:49 localhost last message repeated 2 times
Feb 18 20:57:49 localhost kernel:                         [<c05f5fc7>] inet_sendmsg+0x3b/0x45
Feb 18 20:57:49 localhost kernel:                         [<c05ab8cd>] sock_sendmsg+0xc9/0xe4
Feb 18 20:57:49 localhost kernel:                         [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 20:57:49 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:49 localhost kernel:                         [<c04f05f4>] copy_from_user+0x32/0x5e
Feb 18 20:57:49 localhost kernel:                         [<c04f05f4>] copy_from_user+0x32/0x5e
Feb 18 20:57:49 localhost kernel:                         [<c05aba7a>] sys_sendmsg+0x192/0x1f7
Feb 18 20:57:49 localhost kernel:                         [<c048f764>] file_update_time+0x22/0x6a
Feb 18 20:57:49 localhost kernel:                         [<c0483d90>] pipe_write+0x392/0x3ef
Feb 18 20:57:49 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 20:57:49 localhost kernel:                         [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 20:57:49 localhost kernel:                         [<c05acd2b>] sys_socketcall+0x240/0x261
Feb 18 20:57:49 localhost kernel:                         [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:57:49 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 20:57:49 localhost kernel:  }
Feb 18 20:57:49 localhost kernel:  ... key      at: [<c0a3dc28>] __key.35996+0x0/0x8
Feb 18 20:57:49 localhost kernel: 
Feb 18 20:57:49 localhost kernel: stack backtrace:
Feb 18 20:57:50 localhost kernel: Pid: 3241, comm: pppd Not tainted 2.6.24.2 #1
Feb 18 20:57:50 localhost kernel:  [<c0448b1e>] check_usage+0x24e/0x258
Feb 18 20:57:50 localhost kernel:  [<c0449555>] __lock_acquire+0x99a/0xbf1
Feb 18 20:57:50 localhost kernel:  [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 20:57:50 localhost kernel:  [<f8c566db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 20:57:50 localhost kernel:  [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 20:57:50 localhost kernel:  [<f8c566db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 20:57:50 localhost kernel:  [<f8c566db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 20:57:50 localhost kernel:  [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 20:57:50 localhost kernel:  [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 20:57:50 localhost kernel:  [<f8c573f1>] ppp_xmit_process+0x4f6/0x5a1 [ppp_generic]
Feb 18 20:57:50 localhost kernel:  [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 20:57:50 localhost kernel:  [<f8c593b4>] ppp_write+0xc7/0xdb [ppp_generic]
Feb 18 20:57:50 localhost kernel:  [<f8c592ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 20:57:50 localhost kernel:  [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 20:57:50 localhost kernel:  [<c047ecfd>] sys_write+0x41/0x67
Feb 18 20:57:50 localhost kernel:  [<c0404efa>] syscall_call+0x7/0xb
Feb 18 20:57:50 localhost kernel:  =======================

> 
> Thanks,
> Jarek P.
> 
> On Tue, Feb 12, 2008 at 10:58:21AM +0000, James Chapman wrote:
> ...
>> Here is a trace from when we had _bh locks.
>>
>> Feb  5 16:26:32  ======================================================
>> Feb  5 16:26:32  [ INFO: soft-safe -> soft-unsafe lock order detected ]
>> Feb  5 16:26:32  2.6.24-core2 #1
>> Feb  5 16:26:32  ------------------------------------------------------
>> Feb  5 16:26:32  pppd/3224 [HC0[0]:SC0[2]:HE1:SE0] is trying to acquire:
> ...
>> Feb  5 16:26:32  [<f8d7b84d>] e1000_clean+0x5d/0x290 [e1000]
>> Feb  5 16:26:32  [<c039d580>] net_rx_action+0x1a0/0x2a0
>> Feb  5 16:26:32  [<c039d43f>] net_rx_action+0x5f/0x2a0
>> Feb  5 16:26:32  [<c0131e72>] __do_softirq+0x92/0x120
>> Feb  5 16:26:32  [<c0131f78>] do_softirq+0x78/0x80
>> Feb  5 16:26:32  [<c010b15a>] do_IRQ+0x4a/0xa0
>> Feb  5 16:26:32  [<c0127af0>] finish_task_switch+0x0/0xc0
>> Feb  5 16:26:32  [<c0108dcc>] common_interrupt+0x24/0x34
>> Feb  5 16:26:32  [<c0108dd6>] common_interrupt+0x2e/0x34
>> Feb  5 16:26:32  [<c01062d6>] mwait_idle_with_hints+0x46/0x60
>> Feb  5 16:26:32  [<c0106550>] mwait_idle+0x0/0x20
>> Feb  5 16:26:32  [<c0106694>] cpu_idle+0x74/0xe0
>> Feb  5 16:26:32  [<c0536a9a>] start_kernel+0x30a/0x3a0

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

