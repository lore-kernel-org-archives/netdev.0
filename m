From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [NET]: Fix kfree(skb)
Date: Tue, 27 Feb 2007 21:14:25 +0300
Message-ID: <20070227181425.GA26886@2ka.mipt.ru>
References: <45E46518.5070100@trash.net> <200702271235.22671.paul.moore@hp.com> <20070227.100052.59655152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: paul.moore@hp.com, kaber@trash.net, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40874 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbXB0SPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 13:15:33 -0500
Content-Disposition: inline
In-Reply-To: <20070227.100052.59655152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 27, 2007 at 10:00:52AM -0800, David Miller (davem@davemloft.net) wrote:
> It's unfortunately an easy mistake to make since kfree() accepts any
> pointer type without warning.
> 
> What would be really nice is if someone could come up with a way for
> kfree() to disallow being passed objects that are meant to be released
> via some other mechanism.  So that, for example:
> 
> 	kfree(skb);
> 
> would warn or fail to compile, but the kfree_skb() code could go:
> 
> 	kmem_cache_free_I_KNOW_WHAT_I_AM_DOING(skbuff_head_cache, skb);
> 
> :-)

Something like that? (not tested, will do if starting point looks
correct - it checks if requested to be freed size is equal to one of the 
kmalloc() size, and warns if kmalloc cache is not that one where 
we are going to free an object):

diff --git a/mm/slab.c b/mm/slab.c
index c610062..bcb29df 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3757,6 +3757,15 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
+
+	{
+		int size = kmem_cache_size(c);
+		struct cache_sizes *csizep = malloc_sizes;
+		while (size != csizep->cs_size)
+			csizep++;
+		WARN_ON(csizep != c);
+	}
+
 	debug_check_no_locks_freed(objp, obj_size(c));
 	__cache_free(c, (void *)objp);
 	local_irq_restore(flags);

-- 
	Evgeniy Polyakov
