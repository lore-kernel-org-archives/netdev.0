From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
Date: Mon, 7 Sep 2015 10:16:10 +0200
Message-ID: <20150907101610.44504597@redhat.com>
References: <20150824005727.2947.36065.stgit@localhost>
	<20150904165944.4312.32435.stgit@devil>
	<55E9DE51.7090109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org,
        aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>,
        "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>,
        iamjoonsoo.kim@lge.com, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <55E9DE51.7090109@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Sep 2015 11:09:21 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> This is an interesting start.  However I feel like it might work better 
> if you were to create a per-cpu pool for skbs that could be freed and 
> allocated in NAPI context.  So for example we already have 
> napi_alloc_skb, why not just add a napi_free_skb

I do like the idea...

> and then make the array 
> of objects to be freed part of a pool that could be used for either 
> allocation or freeing?  If the pool runs empty you just allocate 
> something like 8 or 16 new skb heads, and if you fill it you just free 
> half of the list?

But I worry that this algorithm will "randomize" the (skb) objects.
And the SLUB bulk optimization only works if we have many objects
belonging to the same page.

It would likely be fastest to implement a simple stack (for these
per-cpu pools), but I again worry that it would randomize the
object-pages.  A simple queue might be better, but slightly slower.
Guess I could just reuse part of qmempool / alf_queue as a quick test.

Having a per-cpu pool in networking would solve the problem of the slub
per-cpu pool isn't large enough for our use-case.  On the other hand,
maybe we should fix slub to dynamically adjust the size of it's per-cpu
resources?


A pre-req knowledge (for people not knowing slub's internal details):
Slub alloc path will pickup a page, and empty all objects for that page
before proceeding to the next page.  Thus, slub bulk alloc will give
many objects belonging to the page.  I'm trying to keep these objects
grouped together until they can be free'ed in a bulk.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
