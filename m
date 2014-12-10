From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 1/6] net: Split netdev_alloc_frag into __alloc_page_frag
 and add __napi_alloc_frag
Date: Wed, 10 Dec 2014 07:21:49 -0800
Message-ID: <5488650D.8060708@gmail.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>	<20141210034042.2114.29360.stgit@ahduyck-vm-fedora20> <CAMEtUuwNjq4PnYnou7a+PhbXdYBKwmQajHADMyqyEkhT7WeEnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43759 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757814AbaLJPVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 10:21:51 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so2990984pad.15
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 07:21:51 -0800 (PST)
In-Reply-To: <CAMEtUuwNjq4PnYnou7a+PhbXdYBKwmQajHADMyqyEkhT7WeEnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2014 08:16 PM, Alexei Starovoitov wrote:
> On Tue, Dec 9, 2014 at 7:40 PM, Alexander Duyck
> <alexander.h.duyck@redhat.com> wrote:
>> This patch splits the netdev_alloc_frag function up so that it can be used
>> on one of two page frag pools instead of being fixed on the
>> netdev_alloc_cache.  By doing this we can add a NAPI specific function
>> __napi_alloc_frag that accesses a pool that is only used from softirq
>> context.  The advantage to this is that we do not need to call
>> local_irq_save/restore which can be a significant savings.
>>
>> I also took the opportunity to refactor the core bits that were placed in
>> __alloc_page_frag.  First I updated the allocation to do either a 32K
>> allocation or an order 0 page.  This is based on the changes in commmit
>> d9b2938aa where it was found that latencies could be reduced in case of
> thanks for explaining that piece of it.
>
>> +       struct page *page = NULL;
>> +       gfp_t gfp = gfp_mask;
>> +
>> +       if (order) {
>> +               gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
>> +               page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
>> +               nc->frag.size = PAGE_SIZE << (page ? order : 0);
>> +       }
>>
>> -       local_irq_save(flags);
>> -       nc = this_cpu_ptr(&netdev_alloc_cache);
>> -       if (unlikely(!nc->frag.page)) {
>> +       if (unlikely(!page))
>> +               page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
> I'm guessing you're not combining this 'if' with above one to
> keep gfp untouched, so there is a 'warn' when it actually fails 2nd time.
> Tricky :)
> Anyway looks good to me and I think I understand it enough to say:
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Thanks.  Yes the compiler is smart enough to combine the frag.size and
the second check into one if order is non-zero.  The other trick here is
if order is 0 then that whole block disappears and I don't have to touch
frag.size or gfp at all and the code gets much simpler as the *page =
NULL falls though and cancels out the 'if' as a compile time check.

- Alex
