From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Thu, 24 Jul 2008 16:23:32 +0300
Message-ID: <1216905812.5897.6.camel@penberg-laptop>
References: <20080724060448.GA10203@elte.hu>
	 <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
	 <20080724.022259.113079007.davem@davemloft.net>
	 <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>
	 <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net>
	 <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com>
	 <48887A71.5010209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45528 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbYGXNXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 09:23:38 -0400
In-Reply-To: <48887A71.5010209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-07-24 at 14:49 +0200, Patrick McHardy wrote:
> Pekka Enberg wrote:
> > On Thu, Jul 24, 2008 at 3:03 PM, Patrick McHardy <kaber@trash.net> wrote:
> >> Ingo Molnar wrote:
> >>> * Ingo Molnar <mingo@elte.hu> wrote:
> >>>
> >>>> here's a new type of crash a -tip testbox triggered today:
> >>>>
> >>>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> >>>> IP: [<0000000000000000>] 0x0
> >>>> ...
> >>>> Call Trace:
> >>>>  [<ffffffff80777f25>] ? ipv4_confirm+0x8d/0x122
> >>>>  [<ffffffff80733107>] nf_iterate+0x43/0xa5
> >> Does reverting 31d8519c fix this?
> > 
> > Hmm, why do you think it's related? It looks like elem->hook() is a
> > NULL pointer but my patch shouldn't make any difference here...
> 
> No, its already in ipv4_confirm, so its most likely helper->help()
> thats NULL, which is contained in an extension.
> 
> The reason why I think its this patch is (quoting from an old
> email that I never got a response to):

Oh, I'm really sorry about that.

> ---
> Your patch introduced a use-after-free and double-free.
> krealloc() frees the old pointer, but it is still used
> for the ->move operations, then freed again.
> 
> To fix this I think we need a __krealloc() that doesn't
> free the old memory, especially since it must not be
> freed immediately because it may still be used in a RCU
> read side (see the last part in the patch attached to
> this mail (based on a kernel without your patch)).

Agreed. Something like this, perhaps?

[PATCH] netfilter: fix double-free and use-after free

As suggested by Patrick McHardy, introduce a __krealloc() that doesn't
free the original buffer to fix a double-free and use-after-free bug
introduced by me in netfilter that uses RCU.

Reported-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9aa90a6..be6f1d4 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -96,6 +96,7 @@ int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 /*
  * Common kmalloc functions provided by all allocators
  */
+void * __must_check __krealloc(const void *, size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 size_t ksize(const void *);
diff --git a/mm/util.c b/mm/util.c
index 8f18683..6ef9e99 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -68,25 +68,22 @@ void *kmemdup(const void *src, size_t len, gfp_t gfp)
 EXPORT_SYMBOL(kmemdup);
 
 /**
- * krealloc - reallocate memory. The contents will remain unchanged.
+ * __krealloc - like krealloc() but don't free @p.
  * @p: object to reallocate memory for.
  * @new_size: how many bytes of memory are required.
  * @flags: the type of memory to allocate.
  *
- * The contents of the object pointed to are preserved up to the
- * lesser of the new and old sizes.  If @p is %NULL, krealloc()
- * behaves exactly like kmalloc().  If @size is 0 and @p is not a
- * %NULL pointer, the object pointed to is freed.
+ * This function is like krealloc() except it never frees the originally
+ * allocated buffer. Use this if you don't want to free the buffer immediately
+ * like, for example, with RCU.
  */
-void *krealloc(const void *p, size_t new_size, gfp_t flags)
+void *__krealloc(const void *p, size_t new_size, gfp_t flags)
 {
 	void *ret;
 	size_t ks = 0;
 
-	if (unlikely(!new_size)) {
-		kfree(p);
+	if (unlikely(!new_size))
 		return ZERO_SIZE_PTR;
-	}
 
 	if (p)
 		ks = ksize(p);
@@ -95,10 +92,37 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
 		return (void *)p;
 
 	ret = kmalloc_track_caller(new_size, flags);
-	if (ret && p) {
+	if (ret && p)
 		memcpy(ret, p, ks);
+
+	return ret;
+}
+EXPORT_SYMBOL(__krealloc);
+
+/**
+ * krealloc - reallocate memory. The contents will remain unchanged.
+ * @p: object to reallocate memory for.
+ * @new_size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate.
+ *
+ * The contents of the object pointed to are preserved up to the
+ * lesser of the new and old sizes.  If @p is %NULL, krealloc()
+ * behaves exactly like kmalloc().  If @size is 0 and @p is not a
+ * %NULL pointer, the object pointed to is freed.
+ */
+void *krealloc(const void *p, size_t new_size, gfp_t flags)
+{
+	void *ret;
+
+	if (unlikely(!new_size)) {
 		kfree(p);
+		return ZERO_SIZE_PTR;
 	}
+
+	ret = __krealloc(p, new_size, flags);
+	if (ret && p != ret)
+		kfree(p);
+
 	return ret;
 }
 EXPORT_SYMBOL(krealloc);
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 3469bc7..c956ef7 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -95,7 +95,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 	newlen = newoff + t->len;
 	rcu_read_unlock();
 
-	new = krealloc(ct->ext, newlen, gfp);
+	new = __krealloc(ct->ext, newlen, gfp);
 	if (!new)
 		return NULL;
 



