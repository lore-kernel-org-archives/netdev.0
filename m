From: cagri coltekin <cagri@ripe.net>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Fri, 1 Sep 2006 18:22:48 +0200
Message-ID: <20060901162248.GI19284@ripe.net>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from x10.ripe.net ([193.0.1.10]:34463 "EHLO x10.ripe.net")
	by vger.kernel.org with ESMTP id S932441AbWIAQWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 12:22:49 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060901070557.GA15731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 05:05:57PM +1000, Herbert Xu wrote:
> On Thu, Aug 31, 2006 at 05:12:43PM +0200, cagri coltekin wrote:
> > 
> > It took a while to find equipment for test environment, but now I
> > have a test environment that I can test.
> > 
> > Here is the result:
> > 
> > ---------------------------------------------------------------------------
> > [17180051.768000] ip6_fragment: hlen = 0x818, len = 0x7ce, nexthdr=4
> 
> Thanks for the result.  It looks like something is screwed up with the
> extension headers.  What version of bind are you using?

It's bind 9.3.2, the version we were using had a specific patch.
However, I've just tested with non-patched bind 9.3.2, it does it
too. The system has large number of zones, with most of them
DNSSEC enabled. That may be the reason for the peculiarity. I can
send configuration/zone files etc. if it would be helpful.

> Please try the following patch instead to see if we can further isolate
> the problem.

The second causes the system to give the bug a couple of seconds
after bind starts, and loads the zones, without any traffic going
on. BTW, patch applied with some offset difference (3 for the
first -48 for the other two changes), on a pristine 2.6.17.11
source tree.

Here is the new result:

---------------------------------------------------------------------------------------------
[17199663.616000] ip6_push: hlen = 0x388, len = 0x8f, nexthdr1 = 0, nexthdr2 = 162, proto = 0
[17199663.712000] ip6_push: opt = 0x0, flen = 0, nflen = 0
[17199663.776000] ------------[ cut here ]------------
[17199663.836000] kernel BUG at net/ipv6/ip6_output.c:1215!
[17199663.896000] invalid opcode: 0000 [#1]
[17199663.944000] SMP 
[17199663.972000] Modules linked in: ipmi_si ipmi_msghandler ide_cd cdrom
[17199664.048000] CPU:    1
[17199664.048000] EIP:    0060:[<c02bd7b9>]    Not tainted VLI
[17199664.048000] EFLAGS: 00010282   (2.6.17.11-ns-pri-debug-p2 #1) 
[17199664.220000] EIP is at ip6_push_pending_frames+0x39d/0x42e
[17199664.288000] eax: 0000003e   ebx: f60fae80   ecx: c038f5bc   edx: 00000286
[17199664.372000] esi: f7258d80   edi: f782ea40   ebp: f6171d00   esp: f60f7c0c
[17199664.456000] ds: 007b   es: 007b   ss: 0068
[17199664.508000] Process named (pid: 15561, threadinfo=f60f6000 task=f7ae9030)
[17199664.592000] Stack: c03246e0 00000000 00000000 00000000 000000a2 00000000 f6171e88 f7258d80 
[17199664.696000]        00000000 f6171edc f782ea48 f60f7c40 00000000 00000000 00000000 00000000 
[17199664.800000]        00000000 f6171e90 f6171ea0 f6171e88 f782ea40 c02ce42e f6171d00 00000008 
[17199664.904000] Call Trace:
[17199664.936000]  <c02ce42e> udp_v6_push_pending_frames+0x13d/0x1a4  <c02cea1f> udpv6_sendmsg+0x58a/0x953
[17199665.048000]  <c02a6032> inet_sendmsg+0x4a/0x56  <c0260b82> sock_sendmsg+0xeb/0x105
[17199665.144000]  <c01c18cc> __next_cpu+0x22/0x31  <c01167c7> find_busiest_group+0xd6/0x305
[17199665.244000]  <c0173c22> file_update_time+0x48/0xcb  <c01177e6> dependent_sleeper+0x1ec/0x32d
[17199665.348000]  <c012f91e> autoremove_wake_function+0x0/0x57  <c01c662e> copy_from_user+0x46/0x7c
[17199665.456000]  <c0267b9c> verify_iovec+0x3c/0x94  <c02626c9> sys_sendmsg+0x191/0x1f8
[17199665.548000]  <c02e4ff7> schedule_timeout+0xa8/0xaa  <c0133356> unqueue_me+0x56/0x9d
[17199665.644000]  <c012f726> add_wait_queue+0x1a/0x46  <c013356a> futex_wait+0x1cd/0x238
[17199665.740000]  <c014b75c> find_extend_vma+0x29/0x7e  <c01c18cc> __next_cpu+0x22/0x31
[17199665.832000]  <c01177e6> dependent_sleeper+0x1ec/0x32d  <c01c662e> copy_from_user+0x46/0x7c
[17199665.936000]  <c0262b6f> sys_socketcall+0x236/0x254  <c0102be3> syscall_call+0x7/0xb
[17199666.032000] Code: 20 89 44 24 0c 31 c0 85 d2 74 08 8b 54 24 20 0f b7 42 04 89 44 24 08 c7 04 24 e0 46 32 c0 8b 44 24 20 89 44 24 04 e8 54 f6 e5 ff <0f> 0b bf 04 41 13 32 c0 e9 b8 fe ff ff 66 c7 41 04 00 00 e9 21 
[17199666.268000] EIP: [<c02bd7b9>] ip6_push_pending_frames+0x39d/0x42e SS:ESP 0068:f60f7c0c
---------------------------------------------------------------------------------------------

Cheers,
-- 
cagri
