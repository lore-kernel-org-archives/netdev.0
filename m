From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 19:08:01 +0100
Message-ID: <20150401180801.GA889@ZenIV.linux.org.uk>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 01, 2015 at 09:45:27AM -0700, Linus Torvalds wrote:

> The *only* thing you can do with those pages is to copy the content.
> You must never *ever* do anything else. And if the caller only copies
> the content, then the caller is *wrong* to use the page-iterators.
> 
> It really is that simple. Either the caller cares about just the
> content - in which case it should use the normal "iterate over
> addresses" - or the caller somehow cares about 'struct page' itself,
> in which case it is *wrong* to do it over vmalloc space or random
> kernel mappings.

... or the caller wants sg_table.  When net/9p p9_client_write() is called
with virtio for underlying transport (and the amount of data is large enough)
it allocates two buffers (for request header and response resp.), builds
header in the first buffer and proceeds to populate two scatterlists - one
with header + data being sent (sg_set_buf() on the header + sg_set_page() on
each page in payload) and another covering the buffer for response.  Then it
passes the sucker to virtio, which does the actual transfer.

Non-zerocopy variant of the same allocates a buffer for request + data,
a buffer for response, builds header _and_ copies data, then proceeds the
same way as zerocopy path.

In both cases we end up doing sg_set_buf() on some of that - in fact,
in non-zerocopy path that's all we do.  And sg_set_buf() is just
	sg_set_page(sg, virt_to_page(buf), buflen, offset_in_page(buf));

What's more, on the sg_set_page() side it has to deal with several cases:
	1) normal write(); pages are obtained by get_user_pages_fast().
	2) writepage().  Page should've been really passed by caller
via ITER_BVEC iov_iter and picked from there, but p9_client_write() isn't
iov_iter-aware, so the caller does kmap() and passes the kernel address
as payload.  And then this sucker proceeds to do kmap_to_page() instead
of get_user_pages_fast() - virt_to_page() won't do.  That one should be
killed off - there's really no reason to play with kmap() at all.
	3) setxattr().  The data being written comes from the kernel
buffer, _hopefully_ not vmalloc'ed one.  Same path as in (2) once we
get inside p9_client_write(); I'd prefer to pass ITER_KVEC there.

Similar thing happens in p9_client_read(), only there we definitely can
get vmalloc'ed destination - finit_module(2) will trigger read into
vmalloc'ed buffer.  Zerocopy logics in net/9p is actually shared for
read and write (except that we have fixed header for request and header
+ payload for response).  Getting the pages to feed into sg_set_page()
is done in net/9p/trans_virtio.c:p9_get_mapped_pages(); basically, it's
get_user_pages_fast() for userland payloads and this
        } else {
                /* kernel buffer, no need to pin pages */
                int s, index = 0;
                int count = nr_pages;
                while (nr_pages) {
                        s = rest_of_page(data);
                        if (is_vmalloc_addr(data))
                                pages[index++] = vmalloc_to_page(data);
                        else
                                pages[index++] = kmap_to_page(data);
                        data += s;
                        nr_pages--;
                }
                nr_pages = count;
        }
for the kernel ones.  kmap_to_page() probably ought to be virt_to_page()
(it's an artefact of calling conventions - readpage and writepage shouldn't
have to pass the page as kmapped address), but vmalloc_to_page() is
for absolutely real use case - finit_module() reading a file from 9p fs
into vmalloc'ed buffer.

AFAICS, your objections seem to apply to that code.  A lot of clumsiness
in there (and in fs/9p) would be killed if we switched p9_client_{read,write}
to passing iov_iter, but it's not a matter of adding functionality to those;
they already do the same thing, only with bloody inconvenient calling
conventions.  It's already there.

How about a primitive that would feed iov_iter into scatterlist, and fill
an array with struct page pointers to drop afterwards?  With ITER_IOVEC
dumping the get_user_pages_fast() results into that array and ITER_KVEC
just putting NULLs there.

IOW, do you have a problem with obtaining a pointer to kernel page and
immediately shoving it into scatterlist?  
