From: Eric Franchoze <franchoze@yandex.ru>
Subject: [PATCH] change sk->sk_forward_alloc to atomic
Date: Fri, 03 Sep 2010 00:47:06 +0400
Message-ID: <20100902204706.29795.6982.stgit@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward5.mail.yandex.net ([77.88.46.21]:46785 "EHLO
	forward5.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490Ab0IBUrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:47:09 -0400
Received: from smtp2.mail.yandex.net (smtp2.mail.yandex.net [77.88.46.102])
	by forward5.mail.yandex.net (Yandex) with ESMTP id 45D4314D07A0
	for <netdev@vger.kernel.org>; Fri,  3 Sep 2010 00:47:08 +0400 (MSD)
Received: from [127.0.1.1] (unknown [79.164.51.235])
	by smtp2.mail.yandex.net (Yandex) with ESMTPSA id 1193052806B
	for <netdev@vger.kernel.org>; Fri,  3 Sep 2010 00:47:08 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch fixes issue bellow.
kernel: ------------[ cut here ]------------
 kernel: WARNING: at net/ipv4/af_inet.c:153 inet_sock_destruct+0xfb/0x114()
 kernel: Hardware name: PowerEdge SC1435
 kernel: Modules linked in: ipt_REJECT xt_connlimit xt_limit iptable_filter ipt_REDIRECT xt_tcpudp xt_state xt_multiport iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables tun 8021q dm_mirror dm_multipath scsi_dh sbs sbshc power_meter hwmon battery ac sg dcdbas tpm_tis tpm serio_raw tpm_bios button rtc_cmos rtc_core rtc_lib tg3 firmware_class libphy amd64_edac_mod edac_core i2c_piix4 i2c_core dm_region_hash dm_log dm_mod sata_svw libata sd_mod scsi_mod ext3 jbd
 kernel: Pid: 15163, comm: openvpn Tainted: G        W  2.6.32.17 #3
 kernel: Call Trace:
 kernel:  [<ffffffff812a1d21>] ? inet_sock_destruct+0xfb/0x114
 kernel:  [<ffffffff81047e4a>] warn_slowpath_common+0x77/0x8f
 kernel:  [<ffffffff81047e71>] warn_slowpath_null+0xf/0x11
 kernel:  [<ffffffff812a1d21>] inet_sock_destruct+0xfb/0x114
 kernel:  [<ffffffff8124c52c>] __sk_free+0x1e/0xdb
 kernel:  [<ffffffff8124c65a>] sk_free+0x17/0x19
 kernel:  [<ffffffff8124c670>] sock_put+0x14/0x16
 kernel:  [<ffffffff8124c71e>] sk_common_release+0xac/0xb1
 kernel:  [<ffffffff812995c8>] udp_lib_close+0x9/0xb
 kernel:  [<ffffffff812a1300>] inet_release+0x58/0x5f
 kernel:  [<ffffffff81249ce7>] sock_release+0x1a/0x6c
 kernel:  [<ffffffff8124a1ad>] sock_close+0x22/0x26
 kernel:  [<ffffffff810dc8f5>] __fput+0xf6/0x193
 kernel:  [<ffffffff810dcc36>] fput+0x15/0x17
 kernel:  [<ffffffff810d9bc9>] filp_close+0x67/0x72
 kernel:  [<ffffffff81049d7b>] put_files_struct+0x77/0xcb
 kernel:  [<ffffffff81049e05>] exit_files+0x36/0x3b
 kernel:  [<ffffffff8104af44>] do_exit+0x23f/0x65e
 kernel:  [<ffffffff81055e91>] ? set_tsk_thread_flag+0xd/0xf
 kernel:  [<ffffffff81055ec9>] ? recalc_sigpending_tsk+0x36/0x3d
 kernel:  [<ffffffff8104b3f7>] sys_exit_group+0x0/0x16
 kernel:  [<ffffffff8105829f>] get_signal_to_deliver+0x33a/0x38d
 kernel:  [<ffffffff8100b11e>] do_notify_resume+0x8c/0x6bb
 kernel:  [<ffffffff812db68f>] ? _spin_lock_irqsave+0x18/0x34
 kernel:  [<ffffffff81060737>] ? remove_wait_queue+0x4c/0x51
 kernel:  [<ffffffff8104ac2d>] ? do_wait+0x216/0x222
 kernel:  [<ffffffff8104ace6>] ? sys_wait4+0xad/0xbf
 kernel:  [<ffffffff8100be06>] int_signal+0x12/0x17
 kernel: ---[ end trace 9ae8be71cf9ee7de ]---
Signed-off-by: Eric Franchoze <franchoze@yandex.ru>
---

 include/net/sctp/sctp.h |    2 +-
 include/net/sock.h      |   14 +++++++-------
 net/core/sock.c         |   12 ++++++------
 net/core/stream.c       |    2 +-
 net/ipv4/af_inet.c      |    2 +-
 net/ipv4/inet_diag.c    |    2 +-
 net/ipv4/tcp_input.c    |    2 +-
 net/sched/em_meta.c     |    2 +-
 8 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 65946bc..4428fcd 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -455,7 +455,7 @@ static inline void sctp_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	/*
 	 * This mimics the behavior of skb_set_owner_r
 	 */
-	sk->sk_forward_alloc -= event->rmem_len;
+	atomic_sub(rmem_len, &sk->sk_forward_alloc);
 }
 
 /* Tests if the list has one and only one entry. */
diff --git a/include/net/sock.h b/include/net/sock.h
index ac53bfb..6703268 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -276,7 +276,7 @@ struct sock {
 	struct sk_buff_head	sk_async_wait_queue;
 #endif
 	int			sk_wmem_queued;
-	int			sk_forward_alloc;
+	atomic_t		sk_forward_alloc;
 	gfp_t			sk_allocation;
 	int			sk_route_caps;
 	int			sk_route_nocaps;
@@ -930,7 +930,7 @@ static inline int sk_wmem_schedule(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
 		return 1;
-	return size <= sk->sk_forward_alloc ||
+	return size <= atomic_read(&sk->sk_forward_alloc) ||
 		__sk_mem_schedule(sk, size, SK_MEM_SEND);
 }
 
@@ -938,7 +938,7 @@ static inline int sk_rmem_schedule(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
 		return 1;
-	return size <= sk->sk_forward_alloc ||
+	return size <= atomic_read(&sk->sk_forward_alloc) ||
 		__sk_mem_schedule(sk, size, SK_MEM_RECV);
 }
 
@@ -946,7 +946,7 @@ static inline void sk_mem_reclaim(struct sock *sk)
 {
 	if (!sk_has_account(sk))
 		return;
-	if (sk->sk_forward_alloc >= SK_MEM_QUANTUM)
+	if (atomic_read(&sk->sk_forward_alloc) >= SK_MEM_QUANTUM)
 		__sk_mem_reclaim(sk);
 }
 
@@ -954,7 +954,7 @@ static inline void sk_mem_reclaim_partial(struct sock *sk)
 {
 	if (!sk_has_account(sk))
 		return;
-	if (sk->sk_forward_alloc > SK_MEM_QUANTUM)
+	if (atomic_read(&sk->sk_forward_alloc) > SK_MEM_QUANTUM)
 		__sk_mem_reclaim(sk);
 }
 
@@ -962,14 +962,14 @@ static inline void sk_mem_charge(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
 		return;
-	sk->sk_forward_alloc -= size;
+	atomic_sub(size, &sk->sk_forward_alloc);
 }
 
 static inline void sk_mem_uncharge(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
 		return;
-	sk->sk_forward_alloc += size;
+	atomic_add(size, &sk->sk_forward_alloc);
 }
 
 static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
diff --git a/net/core/sock.c b/net/core/sock.c
index b05b9b6..c8d4eb4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1215,7 +1215,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 
 		newsk->sk_dst_cache	= NULL;
 		newsk->sk_wmem_queued	= 0;
-		newsk->sk_forward_alloc = 0;
+		atomic_set(&newsk->sk_forward_alloc, 0); 
 		newsk->sk_send_head	= NULL;
 		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
 
@@ -1648,7 +1648,7 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 	int amt = sk_mem_pages(size);
 	int allocated;
 
-	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
+	atomic_add(amt * SK_MEM_QUANTUM, &sk->sk_forward_alloc); 
 	allocated = atomic_add_return(amt, prot->memory_allocated);
 
 	/* Under limit. */
@@ -1689,7 +1689,7 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 		if (prot->sysctl_mem[2] > alloc *
 		    sk_mem_pages(sk->sk_wmem_queued +
 				 atomic_read(&sk->sk_rmem_alloc) +
-				 sk->sk_forward_alloc))
+				 atomic_read(&sk->sk_forward_alloc)))
 			return 1;
 	}
 
@@ -1706,7 +1706,7 @@ suppress_allocation:
 	}
 
 	/* Alas. Undo changes. */
-	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
+	atomic_sub(amt * SK_MEM_QUANTUM, &sk->sk_forward_alloc);
 	atomic_sub(amt, prot->memory_allocated);
 	return 0;
 }
@@ -1720,9 +1720,9 @@ void __sk_mem_reclaim(struct sock *sk)
 {
 	struct proto *prot = sk->sk_prot;
 
-	atomic_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
+	atomic_sub(atomic_read(&sk->sk_forward_alloc) >> SK_MEM_QUANTUM_SHIFT,
 		   prot->memory_allocated);
-	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
+	atomic_set(&sk->sk_forward_alloc, atomic_read(&sk->sk_forward_alloc) & SK_MEM_QUANTUM - 1); 
 
 	if (prot->memory_pressure && *prot->memory_pressure &&
 	    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]))
diff --git a/net/core/stream.c b/net/core/stream.c
index d959e0f..3b6262e 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -198,7 +198,7 @@ void sk_stream_kill_queues(struct sock *sk)
 	sk_mem_reclaim(sk);
 
 	WARN_ON(sk->sk_wmem_queued);
-	WARN_ON(sk->sk_forward_alloc);
+	WARN_ON(atomic_read(&sk->sk_forward_alloc));
 
 	/* It is _impossible_ for the backlog to contain anything
 	 * when we get here.  All user references to this socket
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6a1100c..8837644 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -151,7 +151,7 @@ void inet_sock_destruct(struct sock *sk)
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
 	WARN_ON(sk->sk_wmem_queued);
-	WARN_ON(sk->sk_forward_alloc);
+	WARN_ON(atomic_read(&sk->sk_forward_alloc));
 
 	kfree(inet->opt);
 	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e5fa2dd..b4585af 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -159,7 +159,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 	if (minfo) {
 		minfo->idiag_rmem = sk_rmem_alloc_get(sk);
 		minfo->idiag_wmem = sk->sk_wmem_queued;
-		minfo->idiag_fmem = sk->sk_forward_alloc;
+		minfo->idiag_fmem = atomic_read(&sk->sk_forward_alloc);
 		minfo->idiag_tmem = sk_wmem_alloc_get(sk);
 	}
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e663b78..8a95746 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5366,7 +5366,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 
 				tcp_rcv_rtt_measure_ts(sk, skb);
 
-				if ((int)skb->truesize > sk->sk_forward_alloc)
+				if ((int)skb->truesize > atomic_read(&sk->sk_forward_alloc))
 					goto step5;
 
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITS);
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 3bcac8a..d9abe9c 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -387,7 +387,7 @@ META_COLLECTOR(int_sk_wmem_queued)
 META_COLLECTOR(int_sk_fwd_alloc)
 {
 	SKIP_NONLOCAL(skb);
-	dst->value = skb->sk->sk_forward_alloc;
+	dst->value = atomic_read(&skb->sk->sk_forward_alloc);
 }
 
 META_COLLECTOR(int_sk_sndbuf)


Best regards,
Eric Franchoze.

