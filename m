From: Dave Jones <davej@codemonkey.org.uk>
Subject: dccp->bind_conflict jump to null.
Date: Thu, 19 Nov 2015 21:44:48 -0500
Message-ID: <20151120024448.GA15274@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:45414 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161124AbbKTCo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 21:44:56 -0500
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1Zzbh0-0006Lf-Ii
	for netdev@vger.kernel.org; Fri, 20 Nov 2015 02:44:55 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been trying to figure this one out for a while. It smells like a race,
but I can't figure out any more than the clues below, and I've not really
got the time to dig into it.

After running Trinity for a while, I saw the machine just suddenly reboot.
I managed to capture a partial trace over serial console, which pointed
me at dccp.

Oops: 0010 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
CPU: 1 PID: 20093 Comm: trinity-c201 Tainted: G        W       4.4.0-rc1
task: ffff8800d08b8000 ti: ffff8801e1464000 task.ti: ffff8801e1464000
RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
RSP: 0018:ffff8801e1467e68  EFLAGS: 00010246
RAX: ffffffffc02aa1c0 RBX: ffff8804563ee9c0 RCX: ffff8804563ee9c0
RDX: 0000000000000001 RSI: ffff88046af1fb00 RDI: ffff8804563ee9c0
RBP: ffff8801e1467ed8 R08: ffff88046af1fb00 R09: 0000000000000001
R10: ffff8800d08b88d0 R11: 000000000000a42b R12: ffff8804563ee9c0
R13: ffffffffc02a0900 R14: ffff8800ce16be80 R15: ffffffff97ed3040
FS:  00007f5f8e3f8700(0000) GS:ffff880507a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 0000000101aa2000 CR4: 00000000001406e0
Stack:
 ffffffff97740a04 000003e800000005 ffffffff97d0a9d8 ffff8804563ee9c0
 ffff88046af1fb00 0000000000000032 ffffffff0000a42b ffffffff00000000
 ffff8804563eef70 ffff8804563ee9c0 0000000000000008 0000000000000008
Call Trace:
 [<ffffffff97740a04>] ? inet_csk_get_port+0x3e4/0x4f0
 [<ffffffff97740f45>] inet_csk_listen_start+0x65/0xc0
 [<ffffffffc0295117>] inet_dccp_listen+0x87/0xb0 [dccp]
 [<ffffffff976cedce>] SyS_listen+0x4e/0x80
 [<ffffffff97816a57>] entry_SYSCALL_64_fastpath+0x12/0x6b
Code:  Bad RIP value.
RIP  [<          (null)>]           (null)
 RSP <ffff8801e1467e68>
CR2: 0000000000000000


I added some simple null checks before inet_csk_get_port called into
->bind_conflict, with some debug info, and noticed that I managed
to trigger both calls...

[282097.685755] 1st bind_conflict == NULL	ops=ffffffffc05601c0 state=7 err:110 protocol:33 type:6
[350754.355455] 2nd bind_conflict == NULL	ops=ffffffffc05601c0 state=10 err:0 protocol:33 type:6

the ops struct is dccp_ipv6_mapped.

I was wondering if maybe the whole ops struct was getting zero'd.
But that doesn't look like the case..

(from a different run: different addresses)

[87853.676775] 2nd bind_conflict == NULL	ops=ffffffffc054d1c0 state=10 err:0 protocol:33 type:6
[87853.683740] queue_xmit:ffffffffa473a510
[87853.690634] send_check:ffffffffc04c8010
[87853.697574] rebuild_header:ffffffffa47766a0
[87853.704509] sk_rx_dst_set:          (null)
[87853.711467] conn_request:ffffffffc054c590
[87853.718427] syn_recv_sock:ffffffffc054b880
[87853.725296] setsockopt:ffffffffa47d5410
[87853.732055] getsockopt:ffffffffa47d3ea0
[87853.738789] compat_setsockopt:ffffffffa47d54b0
[87853.745554] compat_getsockopt:ffffffffa47d3fb0
[87853.752244] addr2sockaddr:ffffffffa47f29a0
[87853.758936] bind_conflict:          (null)
[87853.765643] mtu_reduced:          (null)


The reason I think this looks like a race, is that even with my NULL checks
before doing the dereference, sometimes I still get that sudden reboot,
with the same partial trace. It happens a lot less with my check, but it's
obviously not perfect, and just a few instructions is wide enough to lose
the race sometimes.

Debug patches I came up with below.

Anyone have any idea what's up here ? I don't use dccp, and neither does
$dayjob, so I'm about ready to just disable it and move on, but in case
anyone is interested in debugging this further...

	Dave


diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 46b9c887bede..071cbe556a97 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -87,6 +87,25 @@ int inet_csk_bind_conflict(const struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
 
+static void printops(const struct inet_connection_sock_af_ops *o)
+{
+	printk("queue_xmit:%p\n", o->queue_xmit);
+	printk("send_check:%p\n", o->send_check);
+	printk("rebuild_header:%p\n", o->rebuild_header);
+	printk("sk_rx_dst_set:%p\n", o->sk_rx_dst_set);
+	printk("conn_request:%p\n", o->conn_request);
+	printk("syn_recv_sock:%p\n", o->syn_recv_sock);
+	printk("setsockopt:%p\n", o->setsockopt);
+	printk("getsockopt:%p\n", o->getsockopt);
+#ifdef CONFIG_COMPAT
+	printk("compat_setsockopt:%p\n", o->compat_setsockopt);
+	printk("compat_getsockopt:%p\n", o->compat_getsockopt);
+#endif
+	printk("addr2sockaddr:%p\n", o->addr2sockaddr);
+	printk("bind_conflict:%p\n", o->bind_conflict);
+	printk("mtu_reduced:%p\n", o->mtu_reduced);
+}
+
 /* Obtain a reference to a local port for the given sock,
  * if snum is zero it means select any available local port.
  */
@@ -137,6 +156,15 @@ again:
 						smallest_size = tb->num_owners;
 						smallest_rover = rover;
 					}
+
+					if (inet_csk(sk)->icsk_af_ops->bind_conflict == NULL) {
+						printk(KERN_INFO "1st bind_conflict == NULL\tops=%p state=%d err:%d protocol:%d type:%d\n",
+								inet_csk(sk)->icsk_af_ops,
+								sk->sk_state, sk->sk_err, sk->sk_protocol, sk->sk_type);
+						printops(inet_csk(sk)->icsk_af_ops);
+						goto fail_unlock;
+					}
+
 					if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false)) {
 						snum = rover;
 						goto tb_found;
@@ -198,6 +226,15 @@ tb_found:
 			goto success;
 		} else {
 			ret = 1;
+
+			if (inet_csk(sk)->icsk_af_ops->bind_conflict == NULL) {
+				printk(KERN_INFO "2nd bind_conflict == NULL\tops=%p state=%d err:%d protocol:%d type:%d\n",
+						inet_csk(sk)->icsk_af_ops,
+						sk->sk_state, sk->sk_err, sk->sk_protocol, sk->sk_type);
+				printops(inet_csk(sk)->icsk_af_ops);
+				goto fail_unlock;
+			}
+
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
 				if (((sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
 				     (tb->fastreuseport > 0 &&
