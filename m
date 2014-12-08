From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 11:48:52 -0800
Message-ID: <CA+55aFxSYbDN23MHBRL=neOXJkM4h_GU3qniyYTWwCm_EcGpsQ@mail.gmail.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
	<20141208164650.GB29028@node.dhcp.inet.fi>
	<20141208175805.GB22149@ZenIV.linux.org.uk>
	<20141208180824.GC22149@ZenIV.linux.org.uk>
	<CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
	<20141208182012.GE22149@ZenIV.linux.org.uk>
	<CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
	<20141208184632.GG22149@ZenIV.linux.org.uk>
	<CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
	<20141208192816.GH22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141208192816.GH22149@ZenIV.linux.org.uk>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 8, 2014 at 11:28 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On x86 it does, but I don't see anything obvious in generic version in
> mm/gup.c, so the old code might still have a problem on some architectures.
> What am I missing here?

Hmm. You may be right. The "access_ok()" is supposed to protect
things, but for cases like finit_module() that has explicitly said
"kernel addresses are ok", that check doesn't work.

Maybe  something like this..

    diff --git a/mm/gup.c b/mm/gup.c
    index cd62c8c90d4a..6234b1e6ced9 100644
    --- a/mm/gup.c
    +++ b/mm/gup.c
    @@ -951,6 +951,9 @@ int __get_user_pages_fast(unsigned long start,
int nr_pages, int write,
            len = (unsigned long) nr_pages << PAGE_SHIFT;
            end = start + len;

    +       if (unlikely(segment_eq(get_fs(), KERNEL_DS)))
    +               return 0;
    +
            if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
                                            start, len)))
                    return 0;

Completely untested, obviously. That code isn't even compiled on x86.
Adding linux-arch for more comments.

(Background: the generic non-x86 "get_user_pages_fast()" function
cannot check that the page tables are actually *user* page tables,
so..)

                      Linus
