From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 18:46:34 +0000
Message-ID: <20141208184632.GG22149@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
 <20141208180824.GC22149@ZenIV.linux.org.uk>
 <CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
 <20141208182012.GE22149@ZenIV.linux.org.uk>
 <CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 10:37:51AM -0800, Linus Torvalds wrote:

> How about we make "kernel_read()" just clear O_DIRECT? Does that fix
> it to just use copies?

Umm...  clearing O_DIRECT on struct file that might have other references
to it isn't nice, to put it mildly...

Frankly, stopping iov_iter_get_pages() on the first page in vmalloc/module
space looks like the sanest strategy anyway.  We'd get the same behaviour
as we used to, and as for finit_module(2), well... put "fails if given
an O_DIRECT descriptor" and be done with that.

Alternatively, we can really go for
	page = is_vmalloc_or_module_addr(addr) ? vmalloc_to_page(addr)
						: virt_to_page(addr)
	*pages++ = get_page(page);
and have the fucker work.  Stability is up to the caller, of course -
reading into buffer that might get freed (and reused) under you has much
worse problems...
