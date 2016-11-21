From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [mm PATCH v3 21/23] mm: Add support for releasing multiple
 instances of a page
Date: Mon, 21 Nov 2016 08:21:39 -0800
Message-ID: <CAKgT0UfoS-JC66hHV14E-hgmrhGdz4oYpmHve=01A1X8o8O=rw@mail.gmail.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
 <20161110113606.76501.70752.stgit@ahduyck-blue-test.jf.intel.com> <20161118152716.3f7acf6e25f142846909b2f6@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm <linux-mm@kvack.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161118152716.3f7acf6e25f142846909b2f6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2016 at 3:27 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 10 Nov 2016 06:36:06 -0500 Alexander Duyck <alexander.h.duyck@intel.com> wrote:
>
>> This patch adds a function that allows us to batch free a page that has
>> multiple references outstanding.  Specifically this function can be used to
>> drop a page being used in the page frag alloc cache.  With this drivers can
>> make use of functionality similar to the page frag alloc cache without
>> having to do any workarounds for the fact that there is no function that
>> frees multiple references.
>>
>> ...
>>
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -506,6 +506,8 @@ extern void free_hot_cold_page(struct page *page, bool cold);
>>  extern void free_hot_cold_page_list(struct list_head *list, bool cold);
>>
>>  struct page_frag_cache;
>> +extern void __page_frag_drain(struct page *page, unsigned int order,
>> +                           unsigned int count);
>>  extern void *__alloc_page_frag(struct page_frag_cache *nc,
>>                              unsigned int fragsz, gfp_t gfp_mask);
>>  extern void __free_page_frag(void *addr);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 0fbfead..54fea40 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3912,6 +3912,20 @@ static struct page *__page_frag_refill(struct page_frag_cache *nc,
>>       return page;
>>  }
>>
>> +void __page_frag_drain(struct page *page, unsigned int order,
>> +                    unsigned int count)
>> +{
>> +     VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
>> +
>> +     if (page_ref_sub_and_test(page, count)) {
>> +             if (order == 0)
>> +                     free_hot_cold_page(page, false);
>> +             else
>> +                     __free_pages_ok(page, order);
>> +     }
>> +}
>> +EXPORT_SYMBOL(__page_frag_drain);
>
> It's an exported-to-modules library function.  It should be documented,
> please?  The page-frag API is only partially documented, but that's no
> excuse.

Okay.  I assume you want the documentation as a follow-up patch since
I received a notice that the patch was added to -mm?

> And perhaps documentation will help explain the naming choice.  Why
> "drain"?  I'd have expected "put"?

The idea was that this is supposed to be a counterpart to
__page_frag_refill.  Basically it is a function we can use if we need
to tear down the page frag cache and free the backing page.  If you
want I could update the names for these functions to make that
clarification that this is meant to drain a frag cache versus just
freeing a page frag.  I had originally thought about coming up with an
mput or something like that since we are dropping multiple references,
but then I figured since we already had __page_frag_refill I would go
for __page_frag_drain.

> And why the leading underscores.  The page-frag API is pretty weird :(
>
> And inconsistent.  __alloc_page_frag -> page_frag_alloc,
> __free_page_frag -> page_frag_free(), etc.  I must have been asleep
> when I let that lot through.

The leading underscores are inherited.  Most of it has to do with the
fact that this is a backing API for the netdev sk_buff allocator.
When this stuff existed in net it was already named this way and I
just moved it over.  I'm not sure if you approved it or not as I don't
see an Ack-by or Signed-off-by from you on the patch.  The timing of
it was such that I think Linus approved it and it was then pulled in
through Dave's tree.

If you would like I could look at doing a couple of renaming patches
so that we make the API a bit more consistent.  I could move the
__alloc and __free to what you have suggested, and then take a look at
trying to rename the refill/drain to be a bit more consistent in terms
of what they are supposed to work on and how they are supposed to be
used.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
