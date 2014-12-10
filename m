From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [net-next PATCH 1/6] net: Split netdev_alloc_frag into
 __alloc_page_frag and add __napi_alloc_frag
Date: Tue, 9 Dec 2014 20:16:14 -0800
Message-ID: <CAMEtUuwNjq4PnYnou7a+PhbXdYBKwmQajHADMyqyEkhT7WeEnQ@mail.gmail.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
	<20141210034042.2114.29360.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:42241 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755310AbaLJEQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:16:15 -0500
Received: by mail-qa0-f54.google.com with SMTP id i13so1503634qae.27
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 20:16:14 -0800 (PST)
In-Reply-To: <20141210034042.2114.29360.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 7:40 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> This patch splits the netdev_alloc_frag function up so that it can be used
> on one of two page frag pools instead of being fixed on the
> netdev_alloc_cache.  By doing this we can add a NAPI specific function
> __napi_alloc_frag that accesses a pool that is only used from softirq
> context.  The advantage to this is that we do not need to call
> local_irq_save/restore which can be a significant savings.
>
> I also took the opportunity to refactor the core bits that were placed in
> __alloc_page_frag.  First I updated the allocation to do either a 32K
> allocation or an order 0 page.  This is based on the changes in commmit
> d9b2938aa where it was found that latencies could be reduced in case of

thanks for explaining that piece of it.

> +       struct page *page = NULL;
> +       gfp_t gfp = gfp_mask;
> +
> +       if (order) {
> +               gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
> +               page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
> +               nc->frag.size = PAGE_SIZE << (page ? order : 0);
> +       }
>
> -       local_irq_save(flags);
> -       nc = this_cpu_ptr(&netdev_alloc_cache);
> -       if (unlikely(!nc->frag.page)) {
> +       if (unlikely(!page))
> +               page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);

I'm guessing you're not combining this 'if' with above one to
keep gfp untouched, so there is a 'warn' when it actually fails 2nd time.
Tricky :)
Anyway looks good to me and I think I understand it enough to say:
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
