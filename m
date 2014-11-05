From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v4] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Thu, 06 Nov 2014 00:32:06 +0100
Message-ID: <1415230326.3563481.187595441.15F16E51@webmail.messagingengine.com>
References: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lw1a2.jing@gmail.com, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47857 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751261AbaKEXcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 18:32:07 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 2DEE220C16
	for <netdev@vger.kernel.org>; Wed,  5 Nov 2014 18:32:07 -0500 (EST)
In-Reply-To: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014, at 20:27, Daniel Borkmann wrote:
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
> we have changed the limit in order to be less likely to fail.
> 
> However, in MLD/IGMP code, we have some rather ugly AVAILABLE(skb)
> macros, which determine if we may end up doing an skb_put() for
> adding another record. To avoid possible fragmentation, we check
> the skb's tailroom as skb->dev->mtu - skb->len, which is a wrong
> assumption as the actual max allocation size can be much smaller.
> 
> The IGMP case doesn't have this issue as commit 57e1ab6eaddc
> ("igmp: refine skb allocations") stores the allocation size in
> the cb[].
> 
> Set a reserved_tailroom to make it fit into the MTU and use
> skb_availroom() helper instead. This also allows to get rid of
> igmp_skb_size().
> 
> Reported-by: Wei Liu <lw1a2.jing@gmail.com>
> Fixes: 72e09ad107e7 ("ipv6: avoid high order allocations")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: David L Stevens <david.stevens@oracle.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks and sorry for the back and forth, Daniel!
