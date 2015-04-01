From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 11:34:12 -0700
Message-ID: <CA+55aFxVVoZTGwibiNE9AtjPZ41ODQcNBKkQEepV5fiG=QsKfg@mail.gmail.com>
References: <20141208164650.GB29028@node.dhcp.inet.fi>
	<20141208175805.GB22149@ZenIV.linux.org.uk>
	<20141208180824.GC22149@ZenIV.linux.org.uk>
	<CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
	<20141208182012.GE22149@ZenIV.linux.org.uk>
	<CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
	<20141208184632.GG22149@ZenIV.linux.org.uk>
	<CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
	<20150401023311.GL29656@ZenIV.linux.org.uk>
	<CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
	<20150401180801.GA889@ZenIV.linux.org.uk>
	<CA+55aFyOZ5LD-mAOb_OafJe-VMy0hxrgOCB5hJ=GXJAFP7e8dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyOZ5LD-mAOb_OafJe-VMy0hxrgOCB5hJ=GXJAFP7e8dQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 1, 2015 at 11:26 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> IOW, it's fine to do IO on 'struct page', but it should be
> *controlled* and you damn well need to _own_ that struct page and its
> lifetime, no just "look up random struct page from some kernel
> address".

.. and finally, the reason I feel so strongly about this is that we
*already* had a bug exactly here where you tried to make kvec's "more
generic" and it was just wrong, wrong, wrong.  It's just dangerous to
randomly allow these things.

When we map things into user space, such mappings have some rules
about them (ie they have to be full pages, they haev to actually be
special or refcounted etc etc). Kernel mappings simply don't have
those rules. Not even vmalloc, exactly because we sometimes play games
with kernel mappings. But vmalloc space is at least better than random
"just kernel addresses" which is even worse, since they could be stack
pages or SLAB pages or whatever.

And slab allocations, for example, do *not* honor the page count, even
though such pages do have page counts. The slab allocations can be
reused for other things freely, completely regardless of whether
somebody incremented the page count or not.

And yes, people do things like "kernel_read()" on just normal
kmalloc() allocations. So no, I do *not* think that it's ok to "just
make zero-copy kernel_read() work on kernel addresses by turning them
into 'struct page' and then do whop-the-hell-knows-what random things
with such a 'struct page').

                       Linus
