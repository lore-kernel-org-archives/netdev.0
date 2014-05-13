From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: filter: x86: fix JIT address randomization
Date: Tue, 13 May 2014 18:31:45 -0400 (EDT)
Message-ID: <20140513.183145.1568789082256942703.davem@davemloft.net>
References: <1400018755-3049-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, hpa@zytor.com, dborkman@redhat.com,
	heiko.carstens@de.ibm.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaEMWbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:31:50 -0400
In-Reply-To: <1400018755-3049-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 13 May 2014 15:05:55 -0700

> bpf_alloc_binary() adds 128 bytes of room to JITed program image
> and rounds it up to the nearest page size. If image size is close
> to page size (like 4000), it is rounded to two pages:
> round_up(4000 + 4 + 128) == 8192
> then 'hole' is computed as 8192 - (4000 + 4) = 4188
> If prandom_u32() % hole selects a number >= PAGE_SIZE - sizeof(*header)
> then kernel will crash during bpf_jit_free():
> 
> kernel BUG at arch/x86/mm/pageattr.c:887!
> Call Trace:
>  [<ffffffff81037285>] change_page_attr_set_clr+0x135/0x460
>  [<ffffffff81694cc0>] ? _raw_spin_unlock_irq+0x30/0x50
>  [<ffffffff810378ff>] set_memory_rw+0x2f/0x40
>  [<ffffffffa01a0d8d>] bpf_jit_free_deferred+0x2d/0x60
>  [<ffffffff8106bf98>] process_one_work+0x1d8/0x6a0
>  [<ffffffff8106bf38>] ? process_one_work+0x178/0x6a0
>  [<ffffffff8106c90c>] worker_thread+0x11c/0x370
> 
> since bpf_jit_free() does:
>   unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
>   struct bpf_binary_header *header = (void *)addr;
> to compute start address of 'bpf_binary_header'
> and header->pages will pass junk to:
>   set_memory_rw(addr, header->pages);
> 
> Fix it by making sure that &header->image[prandom_u32() % hole] and &header
> are in the same page
> 
> Fixes: 314beb9bcabfd ("x86: bpf_jit_comp: secure bpf jit against spraying attacks")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied and queued up for -stable, thank you.
