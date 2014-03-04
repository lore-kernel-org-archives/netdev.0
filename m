From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Deadlock on sk->sk_lock.slock
Date: Tue, 04 Mar 2014 06:16:23 -0800
Message-ID: <1393942583.26794.107.camel@edumazet-glaptop2.roam.corp.google.com>
References: <771471B8871B5044A6CA7CCD9C26EEE10117E265C59B@xmail2.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:57718 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbaCDOQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 09:16:25 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so3155129pde.1
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 06:16:25 -0800 (PST)
In-Reply-To: <771471B8871B5044A6CA7CCD9C26EEE10117E265C59B@xmail2.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-04 at 09:59 +0100, Lars Persson wrote:
> Hi
> 
> We can trigger an rcu stall by stressing the error handling in the CIFS file system. The test case induces network outages of varying length while data is written to the file system. Judging by the stack dump it might be a deadlock in the tcpv4 code. So far seen on stable 3.10.32.
> 
> My initial interpretation of the stack trace:
> At frame 9 bh is enabled while holding the socket spinlock. This happens from __tcp_checksum_complete_user, which is inlined in tcp_rcv_established.
> 


Thanks a lot for this report.


> At frame 1 we try to grab the same lock from bh context with resulting deadlock.
> 
> -000 |M:0x0:0x802B6AF8(asm) <-- arch_spin_lock 
> -001 |tcp_v4_rcv(skb = 0x8BD527A0) <-- sk = 0x8BE6B2A0
> -002 |ip_local_deliver_finish(skb = 0x8BD527A0)
> -003 |__netif_receive_skb_core(skb = 0x8BD527A0, ?)
> -004 |netif_receive_skb(skb = 0x8BD527A0)
> -005 |elk_poll(napi = 0x8C770500, budget = 64)
> -006 |net_rx_action(?)
> -007 |__do_softirq()
> -008 |do_softirq()
> -009 |local_bh_enable()
> -010 |tcp_rcv_established(sk = 0x8BE6B2A0, skb = 0x87D3A9E0, th = 0x814EBE14, ?)
> -011 |tcp_v4_do_rcv(sk = 0x8BE6B2A0, skb = 0x87D3A9E0)
> -012 |tcp_delack_timer_handler(sk = 0x8BE6B2A0)
> -013 |tcp_release_cb(sk = 0x8BE6B2A0)
> -014 |release_sock(sk = 0x8BE6B2A0)
> -015 |tcp_sendmsg(?, sk = 0x8BE6B2A0, ?, ?)
> -016 |sock_sendmsg(sock = 0x8518C4C0, msg = 0x87D8DAA8, size = 4096)
> -017 |kernel_sendmsg(?, ?, ?, ?, size = 4096)
> -018 |smb_send_kvec(server = 0x87C4D400, iov = 0x87D8DB10, n_vec = 1, sent = 0x87D8DB1C)
> -019 |smb_send_rqst(server = 0x87C4D400, rqst = 0x87D8DBA0)
> -020 |cifs_call_async(server = 0x87C4D400, rqst = 0x87D8DBA0, receive = 0x0, callback = 0x80219514,
> -021 |cifs_async_writev(wdata = 0x87FD6580)
> -022 |cifs_writepages(mapping = 0x852096E4, wbc = 0x87D8DC88)
> -023 |__writeback_single_inode(inode = 0x852095D0, wbc = 0x87D8DC88)
> -024 |writeback_sb_inodes(sb = 0x87D6D800, wb = 0x87E4A9C0, work = 0x87D8DD88)
> -025 |__writeback_inodes_wb(wb = 0x87E4A9C0, work = 0x87D8DD88)
> -026 |wb_writeback(wb = 0x87E4A9C0, work = 0x87D8DD88)
> -027 |wb_do_writeback(wb = 0x87E4A9C0, force_wait = 0)
> -028 |bdi_writeback_workfn(work = 0x87E4A9CC)
> -029 |process_one_work(worker = 0x8B045880, work = 0x87E4A9CC)
> -030 |worker_thread(__worker = 0x8B045880)
> -031 |kthread(_create = 0x87CADD90)
> -032 |ret_from_kernel_thread(asm)

So the callchain is 

release_sock()
{
 spin_lock_bh(&sk->sk_lock.slock);

 sk->sk_prot->release_cb(sk); //

 sk->sk_lock.owned = 0;
}

Meaning we have the socket spinlock locked by us, and we disabled BH.

Problem is tcp_delack_timer_handler() assumes it was called from timer
handler and sock was not owned by user.

Bug was added in commit 6f458dfb409272082c9bfa412f77ff2fc21c626f
("tcp: improve latencies of timer triggered events")

and triggers if NIC lacks RX checksum support.


Could you try following hack/patch ?

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6e4809389cbf..ed17e1cacae2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4945,7 +4945,10 @@ static __sum16 __tcp_checksum_complete_user(struct sock *sk,
 {
 	__sum16 result;
 
-	if (sock_owned_by_user(sk)) {
+	/* If we are called from tcp_release_cb(),
+	 * we do not want to enable BH
+	 */
+	if (sk->sk_lock.owned == 1) {
 		local_bh_enable();
 		result = __tcp_checksum_complete(skb);
 		local_bh_disable();
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index aaa68f5b1055..588837d06c60 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -785,6 +785,8 @@ void tcp_release_cb(struct sock *sk)
 		__sock_put(sk);
 	}
 	if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED)) {
+		/* Make sure __tcp_checksum_complete_user() wont enable BH */
+		sk->sk_lock.owned = 2;
 		tcp_delack_timer_handler(sk);
 		__sock_put(sk);
 	}
