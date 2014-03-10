From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH resend] tcp: tcp_release_cb() should release socket ownership
Date: Mon, 10 Mar 2014 09:50:11 -0700
Message-ID: <1394470211.3607.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <771471B8871B5044A6CA7CCD9C26EEE10117E265C59B@xmail2.se.axis.com>
	 <1393942583.26794.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140304.134811.86791174090638790.davem@davemloft.net>
	 <1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:56837 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbaCJQuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 12:50:13 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so7331800pdb.28
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 09:50:12 -0700 (PDT)
In-Reply-To: <1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lars Persson reported following deadlock :

-000 |M:0x0:0x802B6AF8(asm) <-- arch_spin_lock 
-001 |tcp_v4_rcv(skb = 0x8BD527A0) <-- sk = 0x8BE6B2A0
-002 |ip_local_deliver_finish(skb = 0x8BD527A0)
-003 |__netif_receive_skb_core(skb = 0x8BD527A0, ?)
-004 |netif_receive_skb(skb = 0x8BD527A0)
-005 |elk_poll(napi = 0x8C770500, budget = 64)
-006 |net_rx_action(?)
-007 |__do_softirq()
-008 |do_softirq()
-009 |local_bh_enable()
-010 |tcp_rcv_established(sk = 0x8BE6B2A0, skb = 0x87D3A9E0, th = 0x814EBE14, ?)
-011 |tcp_v4_do_rcv(sk = 0x8BE6B2A0, skb = 0x87D3A9E0)
-012 |tcp_delack_timer_handler(sk = 0x8BE6B2A0)
-013 |tcp_release_cb(sk = 0x8BE6B2A0)
-014 |release_sock(sk = 0x8BE6B2A0)
-015 |tcp_sendmsg(?, sk = 0x8BE6B2A0, ?, ?)
-016 |sock_sendmsg(sock = 0x8518C4C0, msg = 0x87D8DAA8, size = 4096)
-017 |kernel_sendmsg(?, ?, ?, ?, size = 4096)
-018 |smb_send_kvec()
-019 |smb_send_rqst(server = 0x87C4D400, rqst = 0x87D8DBA0)
-020 |cifs_call_async()
-021 |cifs_async_writev(wdata = 0x87FD6580)
-022 |cifs_writepages(mapping = 0x852096E4, wbc = 0x87D8DC88)
-023 |__writeback_single_inode(inode = 0x852095D0, wbc = 0x87D8DC88)
-024 |writeback_sb_inodes(sb = 0x87D6D800, wb = 0x87E4A9C0, work = 0x87D8DD88)
-025 |__writeback_inodes_wb(wb = 0x87E4A9C0, work = 0x87D8DD88)
-026 |wb_writeback(wb = 0x87E4A9C0, work = 0x87D8DD88)
-027 |wb_do_writeback(wb = 0x87E4A9C0, force_wait = 0)
-028 |bdi_writeback_workfn(work = 0x87E4A9CC)
-029 |process_one_work(worker = 0x8B045880, work = 0x87E4A9CC)
-030 |worker_thread(__worker = 0x8B045880)
-031 |kthread(_create = 0x87CADD90)
-032 |ret_from_kernel_thread(asm)

Bug occurs because __tcp_checksum_complete_user() enables BH, assuming
it is running from softirq context.

Lars trace involved a NIC without RX checksum support but other points
are problematic as well, like the prequeue stuff.

Problem is triggered by a timer, that found socket being owned by user.

tcp_release_cb() should call tcp_write_timer_handler() or
tcp_delack_timer_handler() in the appropriate context :

BH disabled and socket lock held, but 'owned' field cleared,
as if they were running from timer handlers.

Fixes: 6f458dfb4092 ("tcp: improve latencies of timer triggered events")
Reported-by: Lars Persson <lars.persson@axis.com>
Tested-by: Lars Persson <lars.persson@axis.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h    |    5 +++++
 net/core/sock.c       |    5 ++++-
 net/ipv4/tcp_output.c |   11 +++++++++++
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5c3f7c3624aa..2100d5e8809a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1488,6 +1488,11 @@ static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
  */
 #define sock_owned_by_user(sk)	((sk)->sk_lock.owned)
 
+static inline void sock_release_ownership(struct sock *sk)
+{
+	sk->sk_lock.owned = 0;
+}
+
 /*
  * Macro so as to not evaluate some arguments when
  * lockdep is not enabled.
diff --git a/net/core/sock.c b/net/core/sock.c
index 5b6a9431b017..c0fc6bdad1e3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2357,10 +2357,13 @@ void release_sock(struct sock *sk)
 	if (sk->sk_backlog.tail)
 		__release_sock(sk);
 
+	/* Warning : release_cb() might need to release sk ownership,
+	 * ie call sock_release_ownership(sk) before us.
+	 */
 	if (sk->sk_prot->release_cb)
 		sk->sk_prot->release_cb(sk);
 
-	sk->sk_lock.owned = 0;
+	sock_release_ownership(sk);
 	if (waitqueue_active(&sk->sk_lock.wq))
 		wake_up(&sk->sk_lock.wq);
 	spin_unlock_bh(&sk->sk_lock.slock);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f0eb4e337ec8..17a11e65e57f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -767,6 +767,17 @@ void tcp_release_cb(struct sock *sk)
 	if (flags & (1UL << TCP_TSQ_DEFERRED))
 		tcp_tsq_handler(sk);
 
+	/* Here begins the tricky part :
+	 * We are called from release_sock() with :
+	 * 1) BH disabled
+	 * 2) sk_lock.slock spinlock held
+	 * 3) socket owned by us (sk->sk_lock.owned == 1)
+	 *
+	 * But following code is meant to be called from BH handlers,
+	 * so we should keep BH disabled, but early release socket ownership
+	 */
+	sock_release_ownership(sk);
+
 	if (flags & (1UL << TCP_WRITE_TIMER_DEFERRED)) {
 		tcp_write_timer_handler(sk);
 		__sock_put(sk);
