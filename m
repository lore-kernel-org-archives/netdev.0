From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
Date: Mon, 04 May 2015 19:49:53 -0700
Message-ID: <55482FD1.5060707@redhat.com>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>	 <20150504231448.1538.84164.stgit@ahduyck-vm-fedora22> <1430785003.27254.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
        davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1430785003.27254.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org



On 05/04/2015 05:16 PM, Eric Dumazet wrote:
> On Mon, 2015-05-04 at 16:14 -0700, Alexander Duyck wrote:
>> This change adds a function called skb_free_frag which is meant to
>> compliment the function __alloc_page_frag.  The general idea is to enable a
>> more lightweight version of page freeing since we don't actually need all
>> the overhead of a put_page, and we don't quite fit the model of __free_pages.
>
> Could you describe what are the things that put_page() handle that we
> don't need for skb frags ?

A large part of it is just all the extra code flow with each level 
having to retest flags.  So if you follow the calls for put_page w/ a 
page frag you end up with something like:
skb_free_head - virt_to_head_page
   put_page() - (Head | Tail)
     put_compound_page() - Tail, Head, _count
       __put_compound_page() - compound_dtor
         __page_cache_release() - LRU, mem_cgroup
           free_compound_page() - Head, compound_order
             __free_pages_ok()

If I free the same page frag in skb_frag_free the path ends up looking like:
skb_free_head - inlined by compiler
   skb_free_frag - virt_to_head_page, count, head, order
     __free_pages_ok()

> It looks the change could benefit to other users (outside of networking)

It could, but there are also other mechanisms already in place for 
freeing pages.  For example in the Intel drivers I had gotten into the 
habit of using __free_pages for Rx pages since it does exactly the same 
thing but you need to know the order of the pages you are freeing before 
you can use it.  In the case of head frags we don't really know that 
since it can be a page fragment given to us by any of the drivers using 
alloc_pages.

The motivation behind creating a centralized function was to take care 
of the virt_to_head_page and compound_order portions of this in one 
centralized spot.  It avoids bloating things as I'm able to get away 
with little tricks like combining the compound_order Head flag check 
with the one to determine if I call the compound freeing function or the 
order 0 one.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
