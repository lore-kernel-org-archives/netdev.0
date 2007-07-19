From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: kmap_atomic() oopses in current mainline
Date: Thu, 19 Jul 2007 14:01:33 +0400
Message-ID: <20070719100132.GC15839@2ka.mipt.ru>
References: <20070719013304.3c060c99.akpm@linux-foundation.org> <20070719092856.GA15839@2ka.mipt.ru> <20070719023831.400f7905.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel-announce@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35936 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085AbXGSKCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 06:02:34 -0400
Content-Disposition: inline
In-Reply-To: <20070719023831.400f7905.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 02:38:31AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > > is very wrong if both ASYNC_TX_KMAP_DST and ASYNC_TX_KMAP_SRC can ever be
> > > set.  We'll end up using the same kmap slot for both src add dest and we
> > > get either corrupted data or a BUG.
> > 
> > So far it can not since the only user is raid code, which only allows to
> > perform either reading from bio or writing into one, which requires only
> > one mapping.
> 
> hm, so we got lucky?

I would say it was intentionally, current code can perform only one
operation in a time. Of course changing KM_USER from 0 to 1 in second
kmap_atomic will not force oceans to run out of coasts.

Kind of:

diff --git a/crypto/async_tx/async_memcpy.c b/crypto/async_tx/async_memcpy.c
index a973f4e..a48c7f3 100644
--- a/crypto/async_tx/async_memcpy.c
+++ b/crypto/async_tx/async_memcpy.c
@@ -94,7 +94,7 @@ async_memcpy(struct page *dest, struct page *src, unsigned int dest_offset,
 			dest_buf = page_address(dest) + dest_offset;
 
 		if (flags & ASYNC_TX_KMAP_SRC)
-			src_buf = kmap_atomic(src, KM_USER0) + src_offset;
+			src_buf = kmap_atomic(src, KM_USER1) + src_offset;
 		else
 			src_buf = page_address(src) + src_offset;
 
@@ -104,7 +104,7 @@ async_memcpy(struct page *dest, struct page *src, unsigned int dest_offset,
 			kunmap_atomic(dest_buf, KM_USER0);
 
 		if (flags & ASYNC_TX_KMAP_SRC)
-			kunmap_atomic(src_buf, KM_USER0);
+			kunmap_atomic(src_buf, KM_USER1);
 
 		async_tx_sync_epilog(flags, depend_tx, cb_fn, cb_param);
 	}

> > Btw, shouldn't it always be kmap_atomic() even if flag is not set.
> > That pages are usual one returned by alloc_page().
> 
> The code would work OK if the kmap_atomic()s were unconditional, but it
> would be a bit more expensive if the page is in highmem and we don't
> actually intend to access it with the CPU.
> 
> kmap_atomic() against a non-highmem page is basically free: just an
> additional test_bit().

As far as I recall there was an intention to do async memory copy to
userspace, so likely kmapping is a good idea.

-- 
	Evgeniy Polyakov
