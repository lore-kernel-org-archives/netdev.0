From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache bulk
 free API.
Date: Mon, 7 Sep 2015 14:23:39 -0700
Message-ID: <55EE005B.9080802@gmail.com>
References: <20150824005727.2947.36065.stgit@localhost>
 <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com>
 <20150907101610.44504597@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-mm@kvack.org, aravinda@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	iamjoonsoo.kim@lge.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33652 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbIGVXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 17:23:41 -0400
Received: by pacex6 with SMTP id ex6so104771517pac.0
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 14:23:41 -0700 (PDT)
In-Reply-To: <20150907101610.44504597@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2015 01:16 AM, Jesper Dangaard Brouer wrote:
> On Fri, 4 Sep 2015 11:09:21 -0700
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> This is an interesting start.  However I feel like it might work better
>> if you were to create a per-cpu pool for skbs that could be freed and
>> allocated in NAPI context.  So for example we already have
>> napi_alloc_skb, why not just add a napi_free_skb
> I do like the idea...

If nothing else you want to avoid having to redo this code for every 
driver.  If you can just replace dev_kfree_skb with some other freeing 
call it will make it much easier to convert other drivers.

>> and then make the array
>> of objects to be freed part of a pool that could be used for either
>> allocation or freeing?  If the pool runs empty you just allocate
>> something like 8 or 16 new skb heads, and if you fill it you just free
>> half of the list?
> But I worry that this algorithm will "randomize" the (skb) objects.
> And the SLUB bulk optimization only works if we have many objects
> belonging to the same page.

Agreed to some extent, however at the same time what this does is allow 
for a certain amount of skb recycling.  So instead of freeing the 
buffers received from the socket you would likely be recycling them and 
sending them back as Rx skbs.  In the case of a heavy routing workload 
you would likely just be cycling through the same set of buffers and 
cleaning them off of transmit and placing them back on receive.  The 
general idea is to keep the memory footprint small so recycling Tx 
buffers to use for Rx can have its advantages in terms of keeping things 
confined to limits of the L1/L2 cache.

> It would likely be fastest to implement a simple stack (for these
> per-cpu pools), but I again worry that it would randomize the
> object-pages.  A simple queue might be better, but slightly slower.
> Guess I could just reuse part of qmempool / alf_queue as a quick test.

I would say don't over engineer it.  A stack is the simplest.  The 
qmempool / alf_queue is just going to add extra overhead.

The added advantage to the stack is that you are working with pointers 
and you are guaranteed that the list of pointers are going to be 
linear.  If you use a queue clean-up will require up to 2 blocks of 
freeing in case the ring has wrapped.

> Having a per-cpu pool in networking would solve the problem of the slub
> per-cpu pool isn't large enough for our use-case.  On the other hand,
> maybe we should fix slub to dynamically adjust the size of it's per-cpu
> resources?

The per-cpu pool is just meant to replace the the per-driver pool you 
were using.  By using a per-cpu pool you would get better aggregation 
and can just flush the freed buffers at the end of the Rx softirq or 
when the pool is full instead of having to flush smaller lists per call 
to napi->poll.

> A pre-req knowledge (for people not knowing slub's internal details):
> Slub alloc path will pickup a page, and empty all objects for that page
> before proceeding to the next page.  Thus, slub bulk alloc will give
> many objects belonging to the page.  I'm trying to keep these objects
> grouped together until they can be free'ed in a bulk.

The problem is you aren't going to be able to keep them together very 
easily.  Yes they might be allocated all from one spot on Rx but they 
can very easily end up scattered to multiple locations. The same applies 
to Tx where you will have multiple flows all outgoing on one port.  That 
is why I was thinking adding some skb recycling via a per-cpu stack 
might be useful especially since you have to either fill or empty the 
stack when you allocate or free multiple skbs anyway.  In addition it 
provides an easy way for a bulk alloc and a bulk free to share data 
structures without adding additional overhead by keeping them separate.

If you managed it with some sort of high-water/low-water mark type setup 
you could very well keep the bulk-alloc/free busy without too much 
fragmentation.  For the socket transmit/receive case the thing you have 
to keep in mind is that if you reuse the buffers you are just going to 
be throwing them back at the sockets which are likely not using 
bulk-free anyway.  So in that case reuse could actually improve things 
by simply reducing the number of calls to bulk-alloc you will need to 
make since things like TSO allow you to send 64K using a single sk_buff, 
while you will be likely be receiving one or more acks on the receive 
side which will require allocations.

- Alex
