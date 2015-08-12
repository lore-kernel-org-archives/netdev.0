From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: dccp related oops in inet_csk_get_port
Date: Wed, 12 Aug 2015 09:27:56 -0400
Message-ID: <20150812132756.GA8030@codemonkey.org.uk>
References: <20150715220710.GB30757@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:39950 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657AbbHLN2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 09:28:04 -0400
Received: from [209.6.119.210] (helo=backup.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1ZPW4M-0006Wz-7y
	for netdev@vger.kernel.org; Wed, 12 Aug 2015 14:27:50 +0100
Content-Disposition: inline
In-Reply-To: <20150715220710.GB30757@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 06:07:10PM -0400, Dave Jones wrote:
 > While experimenting with some dccp fuzzing, I hit this..
 > 
 > Oops: 0010 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
 > CPU: 3 PID: 19269 Comm: trinity-c22 Not tainted 4.2.0-rc2-think+ #2
 > task: ffff88006f3954c0 ti: ffff8802b89b0000 task.ti: ffff8802b89b0000
 > RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
 > RSP: 0018:ffff8802b89b3e30  EFLAGS: 00010246
 > RAX: ffffffffc063b200 RBX: 000000000000908c RCX: 000000000000908c
 > RDX: 0000000000000001 RSI: ffff8800cb94ef00 RDI: ffff880501ad8c40
 > RBP: ffff8802b89b3eb8 R08: ffff8800cb94ef00 R09: 0000000000000000
 > R10: 0000000000000001 R11: 0000000000000005 R12: 000000000000908c
 > R13: ffffffffc0631940 R14: ffffffffafeefd40 R15: ffff8800cc97e850
 > FS:  00007fc948b0b740(0000) GS:ffff880507e00000(0000) knlGS:0000000000000000
 > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 > CR2: 0000000000000000 CR3: 000000024f2d2000 CR4: 00000000001407e0
 > DR0: 00007fe46baf0000 DR1: 0000000000000000 DR2: 0000000000000000
 > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
 > Stack:
 >  ffffffffaf725ae5 ffff8802b89b3e48 000003e800000005 ffff8802b89b3e68
 >  ffff880501ad8c40 ffff8800cb94ef00 ffff880033cc8000 ffffffffb89b3e88
 >  ffffffff00000000 ffff880501ad9200 ffff880501ad9200 ffff8802b89b3eb8
 > Call Trace:
 >  [<ffffffffaf725ae5>] ? inet_csk_get_port+0x3a5/0x4f0
 >  [<ffffffffaf7260a9>] inet_csk_listen_start+0x79/0xe0
 >  [<ffffffffc06260bb>] inet_dccp_listen+0x8b/0xc0 [dccp]
 >  [<ffffffffaf6b509e>] SyS_listen+0x4e/0x80
 >  [<ffffffffaf80063c>] tracesys_phase2+0x84/0x89

I managed to reproduce this a lot faster. I can now hit it several times a day.

I threw in this debug patch:

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 60021d0d9326..89b9cba73b3d 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -198,6 +198,14 @@ tb_found:
 			goto success;
 		} else {
 			ret = 1;
+
+			if (inet_csk(sk)->icsk_af_ops->bind_conflict == NULL) {
+				printk(KERN_INFO "bind_conflict == NULL\tops=%p state=%d err:%d\n",
+						inet_csk(sk)->icsk_af_ops,
+						sk->sk_state, sk->sk_err);
+				goto fail_unlock;
+			}
+
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
 				if (((sk->sk_reuse && sk->sk_state != TCP_LISTEN) ||
 				     (tb->fastreuseport > 0 &&



And now I regularly get 

[ 7544.518516] bind_conflict == NULL	ops=ffffffffc04a1200 state=10 err:0

$ grep ffffffffc04a1200  /proc/kallsyms 
ffffffffc04a1200 r dccp_ipv6_mapped	[dccp_ipv6]

It's always the v6 struct this happens with (at least so far).

What I'm missing, is how that pointer can be zero.
It's in rodata. Any write to it should cause a page fault.

Also, I don't see anywhere where we actually write to that table directly.
Do we do an indirect clearing of icsk_af_ops anywhere ?
I'm not seeing anything obvious.

	Dave
