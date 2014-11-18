From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Tue, 18 Nov 2014 12:49:13 -0800
Message-ID: <CA+55aFxK0wj2LLp0WmhRsBZch8XfoYbzmbEeJaMpt=SDh5GBvw@mail.gmail.com>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141118084745.GT7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 12:47 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> The minimal implementations would be
>
> __wsum csum_and_copy_from_user(const void __user *src, void *dst, int len,
>                                __wsum sum, int *err_ptr)
> {
>         if (unlikely(copy_from_user(dst, src, len) < 0)) {

No. That "< 0" should be "!= 0". The user copy functions return a
positive value of how many bytes they *failed* to copy.

> Note that we are *not* guaranteed that *err_ptr is touched in case of success
> - not all architectures zero it in that case.  Callers must (and do) zero it
> before the call of csum_and_copy_{from,to}_user().  Furthermore, return value
> in case of error is undefined.

Yeah, easy to misuse.

> IMO the calling conventions are atrocious.

Yeah, not pretty. At the same time, the pain of changing what seems to
work might not be worth it.

And quite frankly, I *detest* your patch 3/5.

"access_ok()" isn't that expensive, and removing them as unnecessary
is fraught with errors. We've had several cases of "oops, we used
__get_user() in a loop, because it generates much better code, but
we'd forgotten to do access_ok(), so now people can read kernel data".

I really think that

 (a) using "__get_user/__put_user/__memcpy_from/to_user" should be
avoided unless there is a clear and present performance issue

 (b) when that performance issue is clear and unmistakable, you should
generally have the "access_ok()" check *locally* to the use of unsafe
ops, so that you can *locally* see that it's safe.

 (c) if there is some upper-level check (ie the normal read/write
paths that make *sure* the addresses are fine), and there is some huge
performance issue that means that the local checks would be a problem,
then we should have a big comment about exactly where the checks are
done.

Your 3/5 violates pretty much all of these, imho.

The rest of the patches I have nothing against. I'm a bit worried that
this is stuff that can easily get stupid thinkos (ie exactly due to
things like the argument order thing), and I wonder how much it buys
us, but at least it seems to generally remove more lines than it adds,
and cleans some stuff up, so I'm not against it.

                    Linus

                 Linus
