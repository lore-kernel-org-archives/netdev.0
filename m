From: Simon Kirby <sim@hostway.ca>
Subject: Re: ipv6 hitting route max_size
Date: Wed, 8 Jun 2011 21:40:42 -0700
Message-ID: <20110609044042.GA32537@hostway.ca>
References: <20110606213727.GB11757@hostway.ca> <20110606.150142.2071869702137894615.davem@davemloft.net> <20110606231521.GB22559@hostway.ca> <20110607.005645.1883989402770213985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:57420 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab1FIEkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 00:40:43 -0400
Content-Disposition: inline
In-Reply-To: <20110607.005645.1883989402770213985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2011 at 12:56:45AM -0700, David Miller wrote:

> From: Simon Kirby <sim@hostway.ca>
> Date: Mon, 6 Jun 2011 16:15:21 -0700
> 
> > Ok, makes sense, but the result is now that ipv4 loads a full Internet
> > table with no adjustments, while ipv6 does not. Would it make sense to
> > change 4096 to 1048576, or would it be better to count only clones of
> > the actual route or something along those lines?
> 
> Simon can you give this patch a try?

Didn't apply to 2.6.39, so I tried 3.0-rc2, but I get an Oops when
running the example reproduction case I gave before (

for ((i = 0;i < 4200;i++)); do ip route add unreachable 2000::$i; done

) both with and without your patch applied:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000a0
IP: [<ffffffff8143e2b7>] ip6_route_add+0xe7/0x6b0
PGD 3ed7c8067 PUD 3ed5a1067 PMD 0
Oops: 0002 [#1] SMP
CPU 0
Modules linked in: nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack tg3 e100 libphy

Pid: 8932, comm: ip Not tainted 3.0.0-rc2-amd64-net #1 To Be Filled By O.E.M. To Be Filled By O.E.M./TYAN High-End Dual AMD Opteron, S2882
RIP: 0010:[<ffffffff8143e2b7>]  [<ffffffff8143e2b7>] ip6_route_add+0xe7/0x6b0
RSP: 0018:ffff8803e59939f8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8803e5993a58 RCX: 0000000000000038
RDX: 00000000000000a0 RSI: 0000000000000008 RDI: 00000000000000a0
RBP: ffffffff817b3300 R08: ffffffff816c8980 R09: 0000000000000000
R10: 0000000000000001 R11: dead000000200200 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 00000000fffffff4
FS:  00007f5f11908700(0000) GS:ffff8803ffc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000000a0 CR3: 00000003edfdd000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ip (pid: 8932, threadinfo ffff8803e5992000, task ffff8803ed70dfa0)
Stack:
 0000000000000000 0000000000000000 ffff8803eecd2a80 0000000000000000
 0000000000000000 ffff8803eedabe00 ffff8803ee671600 ffffffff813b8a30
 ffff8803fe00ac00 ffff8803e5993b50 0000000000000000 ffffffff8143e89c
Call Trace:
 [<ffffffff813b8a30>] ? rtnetlink_rcv+0x30/0x30
 [<ffffffff8143e89c>] ? inet6_rtm_newroute+0x1c/0x30
 [<ffffffff813cb3b9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff813b8a1f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff813cb013>] ? netlink_unicast+0x283/0x2d0
 [<ffffffff813cb930>] ? netlink_sendmsg+0x230/0x390
 [<ffffffff8139639b>] ? sock_sendmsg+0xab/0xe0
 [<ffffffff810925eb>] ? __alloc_pages_nodemask+0x10b/0x700
 [<ffffffff810a3fc2>] ? __do_fault+0x3e2/0x4c0
 [<ffffffff81395b9e>] ? move_addr_to_kernel+0x2e/0x40
 [<ffffffff813a1fd9>] ? verify_iovec+0x69/0xd0
 [<ffffffff813972e2>] ? __sys_sendmsg+0x172/0x300
 [<ffffffff81027465>] ? do_page_fault+0x1a5/0x430
 [<ffffffff813cb6be>] ? netlink_autobind+0x8e/0xd0
 [<ffffffff81395bfc>] ? move_addr_to_user+0x4c/0x60
 [<ffffffff81396f55>] ? sys_getsockname+0xd5/0xe0
 [<ffffffff81397634>] ? sys_sendmsg+0x44/0x80
 [<ffffffff814a35bb>] ? system_call_fastpath+0x16/0x1b
Code: 31 c9 31 d2 45 31 c0 31 f6 41 bf f4 ff ff ff e8 b0 2d f7 ff 48 8d 90 a0 00 00 00 49 89 c4 b9 38 00 00 00 31 c0 4d 85 e4 48 89 d7 <f3> ab 0f 84 06 03 00 00 66 41 c7 44 24 6a ff ff 31 c0 f6 43 16
RIP  [<ffffffff8143e2b7>] ip6_route_add+0xe7/0x6b0
 RSP <ffff8803e59939f8>
CR2: 00000000000000a0
---[ end trace 370907621d87fefc ]---

I don't see many changes to ip6_route_add other than c3968a857a6b6c3.
Checking shortly once I get a git tree on this box, but no ipmi and I'm
remote at the moment.

Btw, maybe rt6_alloc_clone or rt6_alloc_cow needs to clear the DST_NOCOUNT
flag from rt->dst.flags for it to count any of them? Didn't verify.

Simon-
