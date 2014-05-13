From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: filter: x86: fix JIT address randomization
Date: Tue, 13 May 2014 13:23:49 -0700
Message-ID: <1400012629.7973.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400007214-3236-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47182 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaEMUXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 16:23:51 -0400
Received: by mail-pb0-f47.google.com with SMTP id un15so689742pbc.6
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 13:23:51 -0700 (PDT)
In-Reply-To: <1400007214-3236-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 11:53 -0700, Alexei Starovoitov wrote:
> bpf_alloc_binary() adds 128 bytes of room to JITed program image
> and rounds it up to the nearest page size. If image size is close
> to page size (like 4000), it is rounded to two pages:
> round_up(4000 + 4 + 128) == 8192
> then 'hole' is computed as 8192 - (4000 + 4) = 4188
> If prandom_u32() % hole selects a number >= 4096, then kernel will crash
> during bpf_jit_free():
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
> Fix it by picking image offset always out of the first page.

You mean, offset should be in first page ?

> 
> While at it make the offset to be within first half of the page,
> so there is some room for CPU to run before it hits page miss.
> 
> Fixes: 314beb9bcabfd ("x86: bpf_jit_comp: secure bpf jit against spraying attacks")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> 
> s390 commit aa2d2c73c21f ("s390/bpf,jit: address randomize and write protect jit code")
> seems to have the same problem
> 
>  arch/x86/net/bpf_jit_comp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
> index dc01773..c6ab7a0 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -171,7 +171,7 @@ static struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
>  	memset(header, 0xcc, sz); /* fill whole space with int3 instructions */
>  
>  	header->pages = sz / PAGE_SIZE;
> -	hole = sz - (proglen + sizeof(*header));
> +	hole = min(sz - (proglen + sizeof(*header)), PAGE_SIZE / 2);
>  
>  	/* insert a random number of int3 instructions before BPF code */
>  	*image_ptr = &header->image[prandom_u32() % hole];

Good catch, but I am not sure about the PAGE_SIZE / 2

The argument of not having code ending on (or being very close of) page
boundary seems orthogonal to this bug fix.

Thanks
