From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [RFC/BUG] ipv6: bug in "ipv6: Copy cork options in
 ip6_append_data"
Date: Sat, 15 Jun 2013 20:51:31 +0200
Message-ID: <20130615185131.GA2148@breakpoint.cc>
References: <1368742990.3301.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47906 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754213Ab3FOSvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 14:51:39 -0400
Content-Disposition: inline
In-Reply-To: <1368742990.3301.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 03:23:10PM -0700, Eric Dumazet wrote:
> Hi Herbert
Hi Eric,

> Looking at the code added in commit 0178b695fd6b40a62a215cb
> ("ipv6: Copy cork options in ip6_append_data") it looks like we can have
> either a memleak or corruption (later in ip6_cork_release()) in case one
> of the sub-allocation (ip6_opt_dup()/ip6_rthdr_dup()) fails.

Would this explain the following on 3.9.5?

| BUG: unable to handle kernel paging request at 00000000ffffc52c
| IP: [<ffffffff81342d2b>] ip6_append_data+0xb93/0xbea
| RIP: 0010:[<ffffffff81342d2b>]  [<ffffffff81342d2b>] ip6_append_data+0xb93/0xbea
| RSP: 0018:ffff880072cf7a28  EFLAGS: 00010202
| RAX: 00000000ffffc334 RBX: ffff88007c14cd80 RCX: 0000000000000008
| RDX: 00000000ffffffe0 RSI: 0000000000000048 RDI: ffff88007c14cd80
| RBP: 0000000000000000 R08: ffff880072cf7a98 R09: 0000000000000040
| R10: 0000000000000000 R11: ffff88007c14cd80 R12: ffff88007c6208c0
| R13: 0000000000000008 R14: 0000000000000000 R15: 000000000000fff0
| FS:  00007f2342014700(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
| CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
| CR2: 00000000ffffc52c CR3: 0000000020799000 CR4: 00000000000006f0
| DR0: 00000000327ff15b DR1: 0000000000000000 DR2: 0000000000000000
| DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
| Process trinity-child0 (pid: 31667, threadinfo ffff880072cf6000, task ffff880037509830)
| Stack:
|  0000000000000001 0000000000000400 0000000800000028 0000ffe800000000
|  0000000000000000 0000000000000008 0000000000000008 ffff88007c14ce90
|  ffffffff812f9545 ffff880072cf7db8 0000000000000000 0000002000000010
| Call Trace:
|  [<ffffffff812f9545>] ? ip_skb_dst_mtu+0x32/0x32
|  [<ffffffff81390462>] ? _raw_spin_lock_bh+0xe/0x1c
|  [<ffffffff8106161c>] ? should_resched+0x5/0x23
|  [<ffffffff81356606>] ? udpv6_sendmsg+0x668/0x84d
|  [<ffffffff812be1ef>] ? sock_sendmsg+0x4f/0x6c
|  [<ffffffff812be3fe>] ? __sys_sendmsg+0x1f2/0x284
|  [<ffffffff813904bb>] ? _raw_spin_lock_irqsave+0x14/0x35
|  [<ffffffff81058710>] ? remove_wait_queue+0xe/0x48
|  [<ffffffff8139047c>] ? _raw_spin_unlock_irqrestore+0xc/0xd
|  [<ffffffff81257004>] ? n_tty_write+0x309/0x348
|  [<ffffffff8102f296>] ? kvm_clock_read+0x1c/0x1e
|  [<ffffffff811cf695>] ? timerqueue_add+0x79/0x98
|  [<ffffffff8105a352>] ? enqueue_hrtimer+0x36/0x6d
|  [<ffffffff8139047c>] ? _raw_spin_unlock_irqrestore+0xc/0xd
|  [<ffffffff811219bc>] ? fget_light+0x2e/0x7c
|  [<ffffffff812bf425>] ? sys_sendmsg+0x39/0x57
|  [<ffffffff81395869>] ? system_call_fastpath+0x16/0x1b
| Code: 00 0f 8f 12 fa ff ff e9 d9 f4 ff ff c7 44 24 70 f2 ff ff ff 8b 4c 24 14 29 8b e4 02 00 00 49 8b 84 24 48 01 00 00 48 85 c0 74 0c <48>  8b 80 f8 01 00 00 65 48 ff 40 70 48 8b 43 30 48 8b 80 70 01 
| RIP  [<ffffffff81342d2b>] ip6_append_data+0xb93/0xbea

unfortunately I have no idea how this happend. trinity was running a while and
I managed not to get any logs due to a pebkac. The RIP is at

|IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);

|81342d1e:       49 8b 84 24 48 01 00    mov    0x148(%r12),%rax
|81342d25:       00 
|81342d26:       48 85 c0                test   %rax,%rax
|81342d29:       74 0c                   je     ffffffff81342d37 <ip6_append_data+0xb9f>
|81342d2b:       48 8b 80 f8 01 00 00    mov    0x1f8(%rax),%rax
^^^
|81342d32:       65 48 ff 40 70          incq   %gs:0x70(%rax)

This looks like rt6i_idev is not NULL but it is also not a valid pointer since the
upper 32bit are NULL.

Sebastian
