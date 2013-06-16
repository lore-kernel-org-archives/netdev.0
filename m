From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC/BUG] ipv6: bug in "ipv6: Copy cork options in
 ip6_append_data"
Date: Sun, 16 Jun 2013 13:37:05 -0700
Message-ID: <1371415025.3252.170.camel@edumazet-glaptop>
References: <1368742990.3301.67.camel@edumazet-glaptop>
	 <20130615185131.GA2148@breakpoint.cc>
	 <1371373953.3252.162.camel@edumazet-glaptop>
	 <20130616190721.GA1515@breakpoint.cc> <20130616201019.GB1515@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:60537 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab3FPUhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 16:37:10 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so1356118eek.7
        for <netdev@vger.kernel.org>; Sun, 16 Jun 2013 13:37:09 -0700 (PDT)
In-Reply-To: <20130616201019.GB1515@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-16 at 22:10 +0200, Sebastian Andrzej Siewior wrote:
> On Sun, Jun 16, 2013 at 09:07:21PM +0200, Sebastian Andrzej Siewior wrote:
> > On Sun, Jun 16, 2013 at 02:12:33AM -0700, Eric Dumazet wrote:
> > > So far, I am not sure we solved the problem.
> > > Could you try latest net-next tree ?
> > 
> > Yep. So I run pretty soon into
> > 
> > | BUG: unable to handle kernel paging request at 000000000e180200
> > | IP: [<ffffffff8131ff8c>] ip6_push_pending_frames+0x28a/0x428
> 
> This is
> 
> |        IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
> 
> |31ff80:       48 8b 80 48 01 00 00    mov    0x148(%rax),%rax
> |31ff87:       48 85 c0                test   %rax,%rax
> |31ff8a:       74 14                   je     ffffffff8131ffa0 <ip6_push_pending_frames+0x29e>
> |31ff8c:       48 8b 80 00 02 00 00    mov    0x200(%rax),%rax
> ^^^^^
> |31ff93:       65 48 ff 40 28          incq   %gs:0x28(%rax)
> 
> Stupid me, it looks familiar.
> 
> While writing this email I also captured
> 
> | BUG: unable to handle kernel NULL pointer dereference at 0000000000000031
> | IP: [<ffffffff813339aa>] udpv6_sendmsg+0x793/0x8a0
> | task: ffff88007b7bc0c0 ti: ffff88007a2d4000 task.ti: ffff88007a2d4000
> | RIP: 0010:[<ffffffff813339aa>]  [<ffffffff813339aa>] udpv6_sendmsg+0x793/0x8a0
> | RSP: 0018:ffff88007a2d5b18  EFLAGS: 00010206
> | RAX: 0000000000000005 RBX: ffff88007a1a1200 RCX: ffff88007a1a1560
> | RDX: ffff88007a1a1580 RSI: ffff88007ae39f00 RDI: ffff88007ae39f00
> | RBP: ffff88007a2d5c40 R08: ffff8800fa101be0 R09: ffff88002e8ec010
> | R10: 0000003600000000 R11: 0000000000000001 R12: ffff88007a1a1560
> | R13: 0000000000000000 R14: ffff88007ae39f00 R15: ffff88007a1a1560
> | Call Trace:
> |  [<ffffffff810b75c9>] ? get_page_from_freelist+0x5df/0x69f
> |  [<ffffffff8129cc4e>] ? sock_sendmsg+0x54/0x70
> |  [<ffffffff8136ceb2>] ? page_fault+0x22/0x30
> |  [<ffffffff810f1048>] ? fatal_signal_pending+0x9/0x23
> |  [<ffffffff812a637d>] ? verify_iovec+0x53/0xa0
> |  [<ffffffff8129ce9f>] ? ___sys_sendmsg+0x1fe/0x28e
> |  [<ffffffff810baf58>] ? __lru_cache_add+0x1a/0x39
> |  [<ffffffff810cf82f>] ? handle_pte_fault+0x75a/0x79a
> |  [<ffffffff810d0776>] ? handle_mm_fault+0x1ae/0x20b
> |  [<ffffffff81064b23>] ? timekeeping_get_ns.constprop.10+0xd/0x31
> |  [<ffffffff811b571d>] ? timerqueue_add+0x75/0x8f
> |  [<ffffffff8104bdae>] ? __hrtimer_start_range_ns+0x263/0x297
> |  [<ffffffff8104b6b9>] ? lock_hrtimer_base.isra.14+0x1b/0x3c
> |  [<ffffffff8129db2f>] ? __sys_sendmsg+0x39/0x57
> |  [<ffffffff813719d2>] ? system_call_fastpath+0x16/0x1b
> | Code: df 4c 8b bb 90 02 00 00 e8 ba aa f6 ff 48 8b 54 24 48 48 8b 4c 24 40 49 89 57 48 49 89 4f 50 49 8b 86 a0 00 00 00 48 85  c0 74 05 <8b> 40 2c eb 02 31 c0 41 89 47 74 66 83 83 00 01 00 00 01 eb 08
> 
> This is from __ip6_dst_store() the last piece 
> | np->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
> 
> |3399e:       49 8b 86 a0 00 00 00    mov    0xa0(%r14),%rax
> |339a5:       48 85 c0                test   %rax,%rax
> |339a8:       74 05                   je     ffffffff813339af <udpv6_sendmsg+0x798>
> |339aa:       8b 40 2c                mov    0x2c(%rax),%eax
> ^^^^^
> |339ad:       eb 02                   jmp    ffffffff813339b1 <udpv6_sendmsg+0x79a>
> |339af:       31 c0                   xor    %eax,%eax
> 
> rt->rt6i_node seems to be five.

Yes, that's really the same root cause.
