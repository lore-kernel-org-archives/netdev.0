From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 09:45:27 -0700
Message-ID: <CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
	<20141208164650.GB29028@node.dhcp.inet.fi>
	<20141208175805.GB22149@ZenIV.linux.org.uk>
	<20141208180824.GC22149@ZenIV.linux.org.uk>
	<CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
	<20141208182012.GE22149@ZenIV.linux.org.uk>
	<CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
	<20141208184632.GG22149@ZenIV.linux.org.uk>
	<CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
	<20150401023311.GL29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150401023311.GL29656@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2015 at 7:33 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> So the whole "get_page()" thing is broken. Iterating over pages in a
>> KVEC is simply wrong, wrong, wrong. It needs to fail.
>>
>> Iterating over a KVEC to *copy* data is ok. But no page lookup stuff
>> or page reference things.
>
> Hmm...  FWIW, for ITER_KVEC the underlying data would bloody better not
> go away anyway - vmalloc space or not.  Protecting the object from being
> freed under us is caller's responsibility and caller can guarantee that.
> Would a variant that does kmap_to_page()/vmalloc_to_page() _without_
> get_page() for ITER_KVEC work sanely?

No.

It's insane to iterate over 'struct page' pointers, whether you do
get_page or not.

Why?

The *only* thing you can do with those pages is to copy the content.
You must never *ever* do anything else. And if the caller only copies
the content, then the caller is *wrong* to use the page-iterators.

It really is that simple. Either the caller cares about just the
content - in which case it should use the normal "iterate over
addresses" - or the caller somehow cares about 'struct page' itself,
in which case it is *wrong* to do it over vmalloc space or random
kernel mappings.

You cannot have it both ways.

In fact, even _if_ the caller just does a "kmap()" and then looks at
the contents, it is very questionable to allow it for kernel or
vmalloc data. Why? Because we actually do things like mark vmalloc
areas read-only for module code etc, and using kmap() on the pages is
just a way for bad users to more easily overcome things like that by
mistake.

So it's simply wrong in so many ways. There is absolutely *zero*
excuse to look at "struct page" for random kernel data. You had better
get the struct page some valid way - either by explicitly allocating
the page as such, or by looking it up from a *valid* source (ie
looking up a page range from a user mapping).

                       Linus
