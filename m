From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] mm: memcontrol: MEMCG no longer works with SLOB
Date: Wed, 9 Dec 2015 15:01:07 -0500
Message-ID: <20151209200107.GA17409@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
 <2564892.qO1q7YJ6Nb@wuerfel>
 <1558902.EBTjGmY9S2@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1558902.EBTjGmY9S2@wuerfel>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 09, 2015 at 05:32:39PM +0100, Arnd Bergmann wrote:
> The change to move the kmem accounting into the normal memcg
> code means we can no longer use memcg with slob, which lacks
> the memcg_params member in its struct kmem_cache:
> 
> ../mm/slab.h: In function 'is_root_cache':
> ../mm/slab.h:187:10: error: 'struct kmem_cache' has no member named 'memcg_params'
> 
> This enforces the new dependency in Kconfig. Alternatively,
> we could change the slob code to allow using MEMCG.

I'm curious, was this a random config or do you actually use
CONFIG_SLOB && CONFIG_MEMCG?

Excluding CONFIG_MEMCG completely for slob seems harsh, but I would
prefer not littering the source with

#if defined(CONFIG_MEMCG) && (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))

or

#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)

for such a special case. The #ifdefs are already out of hand in there.

Vladimir, what would you think of simply doing this?

diff --git a/mm/slab.h b/mm/slab.h
index 5adec08..0b3ec4b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -25,6 +25,9 @@ struct kmem_cache {
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
 	struct list_head list;	/* List of all slab caches on the system */
+#ifdef CONFIG_MEMCG
+	struct memcg_cache_params memcg_params;
+#endif
 };
 
 #endif /* CONFIG_SLOB */
