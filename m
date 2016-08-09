From: Florian Westphal <fw@strlen.de>
Subject: Re: 4.8.0-rc1: page allocation failure: order:3,
 mode:0x2084020(GFP_ATOMIC|__GFP_COMP)
Date: Tue, 9 Aug 2016 14:22:41 +0200
Message-ID: <20160809122241.GA13060@breakpoint.cc>
References: <8bdcb66dc3eb2448e4b6f2baef2ad8ea@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org, tgraf@suug.ch
To: linux@eikelenboom.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:44436 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752046AbcHIMWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 08:22:44 -0400
Content-Disposition: inline
In-Reply-To: <8bdcb66dc3eb2448e4b6f2baef2ad8ea@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux@eikelenboom.it <linux@eikelenboom.it> wrote:

[ CC Thomas Graf -- rhashtable related splat ]

> Just tested 4.8.0-rc1, but i get the stack trace below, everything seems to
> continue fine afterwards though
> (haven't tried to bisect it yet, hopefully someone has an insight without
> having to go through that :) )

No need, nat hash was converted to use rhashtable so its normal
that earlier kernels did not have such rhashtable splat here.

> My network config consists of a bridge and NAT.
> 
> [10469.336815] swapper/0: page allocation failure: order:3,
> mode:0x2084020(GFP_ATOMIC|__GFP_COMP)
> [10469.336820] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 4.8.0-rc1-20160808-linus-doflr+ #1
> [10469.336821] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS
> V1.8B1 09/13/2010
> [10469.336825]  0000000000000000 ffff88005f603228 ffffffff81456ca5
> 0000000000000000
> [10469.336828]  0000000000000003 ffff88005f6032b0 ffffffff811633ed
> 020840205fd0f000
> [10469.336830]  0000000000000000 ffff88005f603278 0208402000000008
> 000000035fd0f500
> [10469.336832] Call Trace:
> [10469.336834]  <IRQ>  [<ffffffff81456ca5>] dump_stack+0x87/0xb2
> [10469.336845]  [<ffffffff811633ed>] warn_alloc_failed+0xdd/0x140
> [10469.336847]  [<ffffffff811638b1>] __alloc_pages_nodemask+0x3e1/0xcf0
> [10469.336851]  [<ffffffff810edebf>] ? check_preempt_curr+0x4f/0x90
> [10469.336852]  [<ffffffff810edf12>] ? ttwu_do_wakeup+0x12/0x90
> [10469.336855]  [<ffffffff811a72ed>] alloc_pages_current+0x8d/0x110
> [10469.336857]  [<ffffffff8117cb7f>] kmalloc_order+0x1f/0x70
> [10469.336859]  [<ffffffff811aec19>] __kmalloc+0x129/0x140
> [10469.336861]  [<ffffffff8146d561>] bucket_table_alloc+0xc1/0x1d0
> [10469.336862]  [<ffffffff8146da1d>] rhashtable_insert_rehash+0x5d/0xe0
> [10469.336865]  [<ffffffff819fbe70>] ? __nf_nat_l4proto_find+0x20/0x20
> [10469.336866]  [<ffffffff819fcfff>] nf_nat_setup_info+0x2ef/0x400
> [10469.336869]  [<ffffffff81aa88d5>] nf_nat_masquerade_ipv4+0xd5/0x100

[ snip ]

Hmmm, seems this is coming from an attempt to allocate the bucket lock
array (since actual table has __GFP_NOWARN).

I was about to just send a patch that adds a GPF_NOWARN in
bucket_table_alloc/alloc_bucket_locks call.

However, I wonder if we really need this elaborate sizing logic.
I think it makes more sense to always allocate a fixed size regardless
of number of CPUs, i.e. get rid of locks_mul and all the code that comes
with it.

Doing order-3 allocation for locks seems excessive to me.

The netfilter conntrack hashtable just uses a fixed array of 1024
spinlocks (so on x86_64 we get on page of locks).

What do you think?

Do you have another suggestion on how to tackle this?
