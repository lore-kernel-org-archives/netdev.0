From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: RTF_PCPU should not be settable from
 userspace
Date: Fri, 21 Apr 2017 13:56:14 -0400 (EDT)
Message-ID: <20170421.135614.1102528675212359364.davem@davemloft.net>
References: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com, andreyknvl@google.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423198AbdDUSCc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:02:32 -0400
In-Reply-To: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 19 Apr 2017 14:19:43 -0700

> Andrey reported a fault in the IPv6 route code:
> 
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 4035 Comm: a.out Not tainted 4.11.0-rc7+ #250
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880069809600 task.stack: ffff880062dc8000
> RIP: 0010:ip6_rt_cache_alloc+0xa6/0x560 net/ipv6/route.c:975
> RSP: 0018:ffff880062dced30 EFLAGS: 00010206
> RAX: dffffc0000000000 RBX: ffff8800670561c0 RCX: 0000000000000006
> RDX: 0000000000000003 RSI: ffff880062dcfb28 RDI: 0000000000000018
> RBP: ffff880062dced68 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> R13: ffff880062dcfb28 R14: dffffc0000000000 R15: 0000000000000000
> FS:  00007feebe37e7c0(0000) GS:ffff88006cb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000205a0fe4 CR3: 000000006b5c9000 CR4: 00000000000006e0
> Call Trace:
>  ip6_pol_route+0x1512/0x1f20 net/ipv6/route.c:1128
>  ip6_pol_route_output+0x4c/0x60 net/ipv6/route.c:1212
> ...
> 
> Andrey's syzkaller program passes rtmsg.rtmsg_flags with the RTF_PCPU bit
> set. Flags passed to the kernel are blindly copied to the allocated
> rt6_info by ip6_route_info_create making a newly inserted route appear
> as though it is a per-cpu route. ip6_rt_cache_alloc sees the flag set
> and expects rt->dst.from to be set - which it is not since it is not
> really a per-cpu copy. The subsequent call to __ip6_dst_alloc then
> generates the fault.
> 
> Fix by checking for the flag and failing with EINVAL.
> 
> Fixes: d52d3997f843f ("ipv6: Create percpu rt6_info")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable.
