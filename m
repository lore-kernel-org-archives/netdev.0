From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 18:35:42 +0000
Message-ID: <20141208183539.GF22149@ZenIV.linux.org.uk>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <CA+55aFz6izpVGxkziynRXg7zbHzteQyPJH1Kg91ZO3fzqn3LaQ@mail.gmail.com>
 <20141208181401.GD22149@ZenIV.linux.org.uk>
 <CA+55aFzKGsYKh1HALoeFGYQ46uMHww0WdLf5N-9duNTgMSSFxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFzKGsYKh1HALoeFGYQ46uMHww0WdLf5N-9duNTgMSSFxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 10:23:26AM -0800, Linus Torvalds wrote:

> Did this actually use to work? Or is it an issue of "the new iov_iter
> is so generic that something that used to just return an error now
> 'works' and triggers the problem"?

Looks like it failed with EINVAL.  Which might very well be the sane
reaction - if we run into a vmalloc/module address, act as if we failed
to get that page and exit the loop.

> > What's the sane way to grab struct page * for a vmalloc'ed address?
> 
> So "vmalloc_to_page()" should work.
> 
> However, it's actually fundamentally racy unless you can guarantee
> that the vmalloc()'ed area in question is stable (so you had better
> have done that allocation yourself, and be in control of the freeing,
> rather than "we look up random vmalloc'ed addresses).

If vfree(buffer) races with kernel_read() into buffer, we are so badly
fucked that stability of pointers to pages is the least of our concerns...

> In general, it's really a horrible thing to use, and tends to be a big
> red sign that "somebody misdesigned this badly"

More like "nobody has thought of that case", at a guess, but then I hadn't
been involved in finit_module() design - I don't even remember the discussions
around it.  That would be what, something circa 3.7?
