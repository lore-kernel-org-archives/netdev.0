From: Lars Persson <lars.persson@axis.com>
Subject: [BUG] Deadlock on sk->sk_lock.slock
Date: Tue, 4 Mar 2014 09:59:13 +0100
Message-ID: <771471B8871B5044A6CA7CCD9C26EEE10117E265C59B@xmail2.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:54957 "EHLO
	bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756717AbaCDJEf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 04:04:35 -0500
Received: from localhost (localhost [127.0.0.1])
	by bastet.se.axis.com (Postfix) with ESMTP id 8BFC31809E
	for <netdev@vger.kernel.org>; Tue,  4 Mar 2014 09:59:15 +0100 (CET)
Received: from bastet.se.axis.com ([IPv6:::ffff:127.0.0.1])
	by localhost (bastet.se.axis.com [::ffff:127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id Mg3g6VVgwvip for <netdev@vger.kernel.org>;
	Tue,  4 Mar 2014 09:59:15 +0100 (CET)
Received: from boulder.se.axis.com (boulder.se.axis.com [10.0.2.104])
	by bastet.se.axis.com (Postfix) with ESMTP id 097CC180E1
	for <netdev@vger.kernel.org>; Tue,  4 Mar 2014 09:59:14 +0100 (CET)
Received: from boulder.se.axis.com (localhost [127.0.0.1])
	by postfix.imss71 (Postfix) with ESMTP id BEC60D3F
	for <netdev@vger.kernel.org>; Tue,  4 Mar 2014 09:59:14 +0100 (CET)
Received: from thoth.se.axis.com (thoth.se.axis.com [10.0.2.173])
	by boulder.se.axis.com (Postfix) with ESMTP id B3D30CE1
	for <netdev@vger.kernel.org>; Tue,  4 Mar 2014 09:59:14 +0100 (CET)
Received: from xmail2.se.axis.com (xmail2.se.axis.com [10.0.5.74])
	by thoth.se.axis.com (Postfix) with ESMTP id B1DCA34005
	for <netdev@vger.kernel.org>; Tue,  4 Mar 2014 09:59:14 +0100 (CET)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

We can trigger an rcu stall by stressing the error handling in the CIFS file system. The test case induces network outages of varying length while data is written to the file system. Judging by the stack dump it might be a deadlock in the tcpv4 code. So far seen on stable 3.10.32.

My initial interpretation of the stack trace:
At frame 9 bh is enabled while holding the socket spinlock. This happens from __tcp_checksum_complete_user, which is inlined in tcp_rcv_established.

At frame 1 we try to grab the same lock from bh context with resulting deadlock.

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
-018 |smb_send_kvec(server = 0x87C4D400, iov = 0x87D8DB10, n_vec = 1, sent = 0x87D8DB1C)
-019 |smb_send_rqst(server = 0x87C4D400, rqst = 0x87D8DBA0)
-020 |cifs_call_async(server = 0x87C4D400, rqst = 0x87D8DBA0, receive = 0x0, callback = 0x80219514,
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
