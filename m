From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Thu, 1 Oct 2015 15:10:15 -0700
Message-ID: <20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:43804 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbJAWKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 18:10:17 -0400
In-Reply-To: <20150930114255.13505.2618.stgit@canyon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Sep 2015 13:44:19 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Make it possible to free a freelist with several objects by adjusting
> API of slab_free() and __slab_free() to have head, tail and an objects
> counter (cnt).
> 
> Tail being NULL indicate single object free of head object.  This
> allow compiler inline constant propagation in slab_free() and
> slab_free_freelist_hook() to avoid adding any overhead in case of
> single object free.
> 
> This allows a freelist with several objects (all within the same
> slab-page) to be free'ed using a single locked cmpxchg_double in
> __slab_free() and with an unlocked cmpxchg_double in slab_free().
> 
> Object debugging on the free path is also extended to handle these
> freelists.  When CONFIG_SLUB_DEBUG is enabled it will also detect if
> objects don't belong to the same slab-page.
> 
> These changes are needed for the next patch to bulk free the detached
> freelists it introduces and constructs.
> 
> Micro benchmarking showed no performance reduction due to this change,
> when debugging is turned off (compiled with CONFIG_SLUB_DEBUG).
> 

checkpatch says

WARNING: Avoid crashing the kernel - try using WARN_ON & recovery code rather than BUG() or BUG_ON()
#205: FILE: mm/slub.c:2888:
+       BUG_ON(!size);


Linus will get mad at you if he finds out, and we wouldn't want that.

--- a/mm/slub.c~slub-optimize-bulk-slowpath-free-by-detached-freelist-fix
+++ a/mm/slub.c
@@ -2885,7 +2885,8 @@ static int build_detached_freelist(struc
 /* Note that interrupts must be enabled when calling this function. */
 void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
-	BUG_ON(!size);
+	if (WARN_ON(!size))
+		return;
 
 	do {
 		struct detached_freelist df;
_
