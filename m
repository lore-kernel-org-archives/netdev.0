From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mm: memcontrol: MEMCG no longer works with SLOB
Date: Wed, 09 Dec 2015 22:03:06 +0100
Message-ID: <1555665.xW941mUeCs@wuerfel>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org> <1558902.EBTjGmY9S2@wuerfel> <20151209200107.GA17409@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@virtuozzo.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151209200107.GA17409@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 December 2015 15:01:07 Johannes Weiner wrote:
> On Wed, Dec 09, 2015 at 05:32:39PM +0100, Arnd Bergmann wrote:
> > The change to move the kmem accounting into the normal memcg
> > code means we can no longer use memcg with slob, which lacks
> > the memcg_params member in its struct kmem_cache:
> > 
> > ../mm/slab.h: In function 'is_root_cache':
> > ../mm/slab.h:187:10: error: 'struct kmem_cache' has no member named 'memcg_params'
> > 
> > This enforces the new dependency in Kconfig. Alternatively,
> > we could change the slob code to allow using MEMCG.
> 
> I'm curious, was this a random config or do you actually use
> CONFIG_SLOB && CONFIG_MEMCG?

Just a randconfig build, I do a lot of those to check for ARM specific
regressions.
> index 5adec08..0b3ec4b 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -25,6 +25,9 @@ struct kmem_cache {
>         int refcount;           /* Use counter */
>         void (*ctor)(void *);   /* Called on object slot creation */
>         struct list_head list;  /* List of all slab caches on the system */
> +#ifdef CONFIG_MEMCG
> +       struct memcg_cache_params memcg_params;
> +#endif
>  };
>  
>  #endif /* CONFIG_SLOB */

This was my first approach to the problem, and it solves the build issues,
I just wasn't sure if it works as expected.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
