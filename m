From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] igb: don't reuse pages with pfmemalloc
	flag
Date: Wed, 22 Oct 2014 08:45:37 -0700
Message-ID: <1413992737.9031.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org, sassmann@kpanic.de,
	e1000-devel@lists.sourceforge.net,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, davem@davemloft.net,
	john.ronciak@intel.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org
To: Roman Gushchin <klamm@yandex-team.ru>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-22 at 17:50 +0400, Roman Gushchin wrote:
> Incoming packet is dropped silently by sk_filter(), if the skb was
> allocated from pfmemalloc reserves and the corresponding socket is
> not marked with the SOCK_MEMALLOC flag.
> 
> Igb driver allocates pages for DMA with __skb_alloc_page(), which
> calls alloc_pages_node() with the __GFP_MEMALLOC flag. So, in case
> of OOM condition, igb can get pages with pfmemalloc flag set.
> 
> If an incoming packet hits the pfmemalloc page and is large enough
> (small packets are copying into the memory, allocated with
> netdev_alloc_skb_ip_align(), so they are not affected), it will be
> dropped.
> 
> This behavior is ok under high memory pressure, but the problem is
> that the igb driver reuses these mapped pages. So, packets are still
> dropping even if all memory issues are gone and there is a plenty
> of free memory.
> 
> In my case, some TCP sessions hang on a small percentage (< 0.1%)
> of machines days after OOMs.
> 
> Fix this by avoiding reuse of such pages.
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> ---

Interesting...

It seems we also need to clear skb->pfmemalloc in napi_reuse_skb()




------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
