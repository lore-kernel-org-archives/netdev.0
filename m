From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4 5/6] slub: support for bulk free with SLUB
 freelists
Date: Tue, 29 Sep 2015 19:00:29 +0200
Message-ID: <20150929190029.01ca01f2@redhat.com>
References: <20150929154605.14465.98995.stgit@canyon>
	<20150929154807.14465.76422.stgit@canyon>
	<560ABE86.9050508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        Christoph
 Lameter <cl@linux.com>, netdev@vger.kernel.org,
        Pekka Enberg
 <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <560ABE86.9050508@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Sep 2015 09:38:30 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On 09/29/2015 08:48 AM, Jesper Dangaard Brouer wrote:
> > Make it possible to free a freelist with several objects by adjusting
> > API of slab_free() and __slab_free() to have head, tail and an objects
> > counter (cnt).
> >
> > Tail being NULL indicate single object free of head object.  This
> > allow compiler inline constant propagation in slab_free() and
> > slab_free_freelist_hook() to avoid adding any overhead in case of
> > single object free.
> >
> > This allows a freelist with several objects (all within the same
> > slab-page) to be free'ed using a single locked cmpxchg_double in
> > __slab_free() and with an unlocked cmpxchg_double in slab_free().
> >
> > Object debugging on the free path is also extended to handle these
> > freelists.  When CONFIG_SLUB_DEBUG is enabled it will also detect if
> > objects don't belong to the same slab-page.
> >
> > These changes are needed for the next patch to bulk free the detached
> > freelists it introduces and constructs.
> >
> > Micro benchmarking showed no performance reduction due to this change,
> > when debugging is turned off (compiled with CONFIG_SLUB_DEBUG).
> >
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> >
> > ---
> > V4:
> >   - Change API per req of Christoph Lameter
> >   - Remove comments in init_object.
> >
[...]
> >
> > +/* Compiler cannot detect that slab_free_freelist_hook() can be
> > + * removed if slab_free_hook() evaluates to nothing.  Thus, we need to
> > + * catch all relevant config debug options here.
> > + */
> 
> Is it actually generating nothing but a pointer walking loop or is there 
> a bit of code cruft that is being evaluated inside the loop?

If any of the defines are activated, then slab_free_hook(s, object)
will generate some code.

In the case of single object free, then the compiler see that it can
remove the loop, and also notice if slab_free_hook() eval to nothing.

The compiler is not smart enough to remove the loop for multiobject
case, even-though it can see that slab_free_hook() eval to nothing
(in that case it does a pointer walk without any code eval).  Thus, I
need this construct.

> > +#if defined(CONFIG_KMEMCHECK) ||		\
> > +	defined(CONFIG_LOCKDEP)	||		\
> > +	defined(CONFIG_DEBUG_KMEMLEAK) ||	\
> > +	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
> > +	defined(CONFIG_KASAN)
> > +static inline void slab_free_freelist_hook(struct kmem_cache *s,
> > +					   void *head, void *tail)
> > +{
> > +	void *object = head;
> > +	void *tail_obj = tail ? : head;
> > +
> > +	do {
> > +		slab_free_hook(s, object);
> > +	} while ((object != tail_obj) &&
> > +		 (object = get_freepointer(s, object)));
> > +}
> > +#else
> > +static inline void slab_free_freelist_hook(struct kmem_cache *s, void *obj_tail,
> > +					   void *freelist_head) {}
> > +#endif
> > +
> 
> Instead of messing around with an #else you might just wrap the contents 
> of slab_free_freelist_hook in the #if/#endif instead of the entire 
> function declaration.

I had it that way in an earlier version of the patch, but I liked
better this way.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
