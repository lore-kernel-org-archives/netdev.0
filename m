From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/3] net: introduce kfree_skb_bulk() user of
 kmem_cache_free_bulk()
Date: Mon, 7 Sep 2015 10:41:01 +0200
Message-ID: <20150907104101.3e392a6d@redhat.com>
References: <20150904165944.4312.32435.stgit@devil>
	<20150904170046.4312.38018.stgit@devil>
	<CALx6S36R2zGwj5XF0GZWPOC1Ng5HviPWxBM-cn=DDMXU9Auoxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	iamjoonsoo.kim@lge.com, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543AbbIGIlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 04:41:09 -0400
In-Reply-To: <CALx6S36R2zGwj5XF0GZWPOC1Ng5HviPWxBM-cn=DDMXU9Auoxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Sep 2015 11:47:17 -0700 Tom Herbert <tom@herbertland.com> wrote:

> On Fri, Sep 4, 2015 at 10:00 AM, Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > Introduce the first user of SLAB bulk free API kmem_cache_free_bulk(),
> > in the network stack in form of function kfree_skb_bulk() which bulk
> > free SKBs (not skb clones or skb->head, yet).
> >
[...]
> > +/**
> > + *     kfree_skb_bulk - bulk free SKBs when refcnt allows to
> > + *     @skbs: array of SKBs to free
> > + *     @size: number of SKBs in array
> > + *
> > + *     If SKB refcnt allows for free, then release any auxiliary data
> > + *     and then bulk free SKBs to the SLAB allocator.
> > + *
> > + *     Note that interrupts must be enabled when calling this function.
> > + */
> > +void kfree_skb_bulk(struct sk_buff **skbs, unsigned int size)
> > +{
>
> What not pass a list of skbs (e.g. using skb->next)?

Because the next layer, the slab API needs an array:
  kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)

Look at the patch:
 [PATCH V2 3/3] slub: build detached freelist with look-ahead
 http://thread.gmane.org/gmane.linux.kernel.mm/137469/focus=137472

Where I use this array to progressively scan for objects belonging to
the same page.  (A subtle detail is I manage to zero out the array,
which is good from a security/error-handling point of view, as pointers
to the objects are not left dangling on the stack).


I cannot argue that, writing skb->next comes as an additional cost,
because the slUb free also writes into this cacheline.  Perhaps the
slAb allocator does not?

[...]
> > +       if (likely(cnt)) {
> > +               kmem_cache_free_bulk(skbuff_head_cache, cnt, (void **) skbs);
> > +       }
> > +}
> > +EXPORT_SYMBOL(kfree_skb_bulk);

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
