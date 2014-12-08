From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 10:23:26 -0800
Message-ID: <CA+55aFzKGsYKh1HALoeFGYQ46uMHww0WdLf5N-9duNTgMSSFxQ@mail.gmail.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
	<20141208164650.GB29028@node.dhcp.inet.fi>
	<CA+55aFz6izpVGxkziynRXg7zbHzteQyPJH1Kg91ZO3fzqn3LaQ@mail.gmail.com>
	<20141208181401.GD22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141208181401.GD22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 8, 2014 at 10:14 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> iov_iter_get_pages() in ITER_KVEC case, trying to avoid get_user_pages_fast()
> and getting it wrong.  FWIW, the reproducer is finit_module(fd, ....)
> where fd has been opened with O_DIRECT.  In that case we get kernel_read()
> on O_DIRECT and the buffer has just been vmalloc'ed.

Ugh. That's horrid. Do we need to even support O_DIRECT in that case?
In general, we should *not* do IO on vmalloc'ed areas, although at
least the non-O_DIRECT case where we just memcpy() it as if it came
from user space is much better.

Did this actually use to work? Or is it an issue of "the new iov_iter
is so generic that something that used to just return an error now
'works' and triggers the problem"?

> What's the sane way to grab struct page * for a vmalloc'ed address?

So "vmalloc_to_page()" should work.

However, it's actually fundamentally racy unless you can guarantee
that the vmalloc()'ed area in question is stable (so you had better
have done that allocation yourself, and be in control of the freeing,
rather than "we look up random vmalloc'ed addresses).

In general, it's really a horrible thing to use, and tends to be a big
red sign that "somebody misdesigned this badly"

                    Linus
