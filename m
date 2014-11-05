From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Tue, 04 Nov 2014 17:06:56 -0800
Message-ID: <1415149616.30247.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415149113-32668-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lw1a2.jing@gmail.com, fw@strlen.de,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:60502 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbaKEBG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 20:06:58 -0500
Received: by mail-ig0-f169.google.com with SMTP id hn18so7473138igb.0
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:06:58 -0800 (PST)
In-Reply-To: <1415149113-32668-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 01:58 +0100, Daniel Borkmann wrote:
> It has been reported that generating an MLD listener report on
> devices with large MTUs (e.g. 9000) and a high number of IPv6
> addresses can trigger a skb_over_panic():
> 
> skbuff: skb_over_panic: text:ffffffff80612a5d len:3776 put:20
> head:ffff88046d751000 data:ffff88046d751010 tail:0xed0 end:0xec0
> dev:port1
>  ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:100!
> invalid opcode: 0000 [#1] SMP
> Modules linked in: ixgbe(O)
> CPU: 3 PID: 0 Comm: swapper/3 Tainted: G O 3.14.23+ #4
> [...]
> Call Trace:
>  <IRQ>
>  [<ffffffff80578226>] ? skb_put+0x3a/0x3b
>  [<ffffffff80612a5d>] ? add_grhead+0x45/0x8e
>  [<ffffffff80612e3a>] ? add_grec+0x394/0x3d4
>  [<ffffffff80613222>] ? mld_ifc_timer_expire+0x195/0x20d
>  [<ffffffff8061308d>] ? mld_dad_timer_expire+0x45/0x45
>  [<ffffffff80255b5d>] ? call_timer_fn.isra.29+0x12/0x68
>  [<ffffffff80255d16>] ? run_timer_softirq+0x163/0x182
>  [<ffffffff80250e6f>] ? __do_softirq+0xe0/0x21d
>  [<ffffffff8025112b>] ? irq_exit+0x4e/0xd3
>  [<ffffffff802214bb>] ? smp_apic_timer_interrupt+0x3b/0x46
>  [<ffffffff8063f10a>] ? apic_timer_interrupt+0x6a/0x70
> 
> mld_newpack() skb allocations are usually requested with dev->mtu
> in size, since commit 72e09ad107e7 ("ipv6: avoid high order allocations")
> we have changed the limit in order to be less unreliable to fail.
> 
> However, in MLD/IGMP code, we have some rather ugly AVAILABLE(skb)
> macros, which determine if we may end up doing an skb_put() for
> adding another record. To avoid possible fragmentation, we check
> the skb's tailroom as skb->dev->mtu - skb->len, which is a wrong
> assumption as the actual max allocation size will be much smaller.
> 
> The IGMP case doesn't have this issue as commit 57e1ab6eaddc
> ("igmp: refine skb allocations") stores the allocation size in the
> cb[], but therefore takes the MTU check not into account anymore.
> Add and use skb_nofrag_tailroom() for both cases.
> 
> Reported-by: lw1a2.jing@gmail.com
> Fixes: 72e09ad107e7 ("ipv6: avoid high order allocations")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David L Stevens <david.stevens@oracle.com>
> ---
>  In skb_nofrag_tailroom(), we could actually omit the !skb->dev check,
>  but I leave that rather as a possible cleanup item for net-next.


Hmm... we have a proliferation of such things.

Could you take a look at sk_stream_alloc_skb(), skb->reserved_tailroom,
and skb_availroom() ?

Thanks !
