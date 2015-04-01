From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 21:15:38 +0100
Message-ID: <20150401201538.GD889@ZenIV.linux.org.uk>
References: <CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
 <20141208182012.GE22149@ZenIV.linux.org.uk>
 <CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
 <20141208184632.GG22149@ZenIV.linux.org.uk>
 <CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
 <20150401023311.GL29656@ZenIV.linux.org.uk>
 <CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
 <20150401180801.GA889@ZenIV.linux.org.uk>
 <CA+55aFyOZ5LD-mAOb_OafJe-VMy0hxrgOCB5hJ=GXJAFP7e8dQ@mail.gmail.com>
 <CA+55aFxVVoZTGwibiNE9AtjPZ41ODQcNBKkQEepV5fiG=QsKfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxVVoZTGwibiNE9AtjPZ41ODQcNBKkQEepV5fiG=QsKfg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 01, 2015 at 11:34:12AM -0700, Linus Torvalds wrote:
> with kernel mappings. But vmalloc space is at least better than random
> "just kernel addresses" which is even worse, since they could be stack
> pages or SLAB pages or whatever.
> 
> And slab allocations, for example, do *not* honor the page count, even
> though such pages do have page counts. The slab allocations can be
> reused for other things freely, completely regardless of whether
> somebody incremented the page count or not.
> 
> And yes, people do things like "kernel_read()" on just normal
> kmalloc() allocations. So no, I do *not* think that it's ok to "just
> make zero-copy kernel_read() work on kernel addresses by turning them
> into 'struct page' and then do whop-the-hell-knows-what random things
> with such a 'struct page').

Umm...  Tangentially related question - do we have any IO codepaths where
a pointer to page might stick around indefinitely?  AFAICS, for AIO it's
enough to wait for request to complete, but that's available to caller.
Do we have anything where one would really have to do e.g. freeing (or
dropping refcount, etc.) in a callback one can't conveniently wait for?
sg_table with pointers to pages of kmalloc'ed objects are really common in
e.g. crypto/*...
