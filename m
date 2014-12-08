From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 18:08:27 +0000
Message-ID: <20141208180824.GC22149@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141208175805.GB22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 05:58:05PM +0000, Al Viro wrote:
> It looks like the second VIRTUAL_BUG_ON() in __phys_addr(), most likely
> from __pa(), from virt_to_page(), from
>                 unsigned long addr = (unsigned long)v.iov_base, end;
>                 size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
> 
>                 if (len > maxpages * PAGE_SIZE)
>                         len = maxpages * PAGE_SIZE;
>                 addr &= ~(PAGE_SIZE - 1);
>                 for (end = addr + len; addr < end; addr += PAGE_SIZE)
>                         get_page(*pages++ = virt_to_page(addr));
>                 return len - *start;
> in iov_iter_get_pages().  And that's ITER_KVEC case there...  Further
> call chain looks like dio_refill_pages(), from dio_get_page(), from
> do_direct_io(), eventually from kernel_read() and finit_module(),
> Presumably called on O_DIRECT descriptor...

FWIW, virt_to_page() is probably not OK to call on an address in the
middle of vmalloc'ed area, is it?  Would
		for (end = addr + len; addr < end; addr += PAGE_SIZE) {
			if (is_vmalloc_addr(addr))
				ACCESS_ONCE(*(char *)addr);
			get_page(*pages++ = virt_to_page(addr));
		}
be a safe replacement for the loop in the above?
