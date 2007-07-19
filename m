From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kmap_atomic() oopses in current mainline
Date: Thu, 19 Jul 2007 02:38:31 -0700
Message-ID: <20070719023831.400f7905.akpm@linux-foundation.org>
References: <20070719013304.3c060c99.akpm@linux-foundation.org>
	<20070719092856.GA15839@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel-announce@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-announce-owner@vger.kernel.org>
In-Reply-To: <20070719092856.GA15839@2ka.mipt.ru>
Sender: linux-kernel-announce-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 13:28:56 +0400 Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Hi.
> 
> On Thu, Jul 19, 2007 at 01:33:04AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > I don't think the 2-year-old Vaio has offload engine support ;) Dan, this:
> > 
> > +		if (flags & ASYNC_TX_KMAP_DST)
> > +			dest_buf = kmap_atomic(dest, KM_USER0) + dest_offset;
> > +		else
> > +			dest_buf = page_address(dest) + dest_offset;
> > +
> > +		if (flags & ASYNC_TX_KMAP_SRC)
> > +			src_buf = kmap_atomic(src, KM_USER0) + src_offset;
> > +		else
> > +			src_buf = page_address(src) + src_offset;
> > +
> > +		memcpy(dest_buf, src_buf, len);
> > +
> > +		if (flags & ASYNC_TX_KMAP_DST)
> > +			kunmap_atomic(dest_buf, KM_USER0);
> > +
> > +		if (flags & ASYNC_TX_KMAP_SRC)
> > +			kunmap_atomic(src_buf, KM_USER0);
> > +
> > 
> > is very wrong if both ASYNC_TX_KMAP_DST and ASYNC_TX_KMAP_SRC can ever be
> > set.  We'll end up using the same kmap slot for both src add dest and we
> > get either corrupted data or a BUG.
> 
> So far it can not since the only user is raid code, which only allows to
> perform either reading from bio or writing into one, which requires only
> one mapping.

hm, so we got lucky?

> Btw, shouldn't it always be kmap_atomic() even if flag is not set.
> That pages are usual one returned by alloc_page().

The code would work OK if the kmap_atomic()s were unconditional, but it
would be a bit more expensive if the page is in highmem and we don't
actually intend to access it with the CPU.

kmap_atomic() against a non-highmem page is basically free: just an
additional test_bit().
