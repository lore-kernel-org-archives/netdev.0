From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: skb_splice_bits() and large chunks in pipe (was Re:
 xfs_file_splice_read: possible circular locking dependency detected
Date: Sun, 18 Sep 2016 13:12:21 -0700
Message-ID: <CA+55aFx5Y=Rddw3ObnOm-XSUkJezfxzNGuTckD2ChVmJRNsD2g@mail.gmail.com>
References: <CA+55aFxrqCng2Qxasc9pyMrKUGFjo==fEaFT1vkH9Lncte3RgQ@mail.gmail.com>
 <20160909023452.GO2356@ZenIV.linux.org.uk> <CA+55aFwHQMjO4-vtfB9-ytc=o+DRo-HXVGckvXLboUxgpwb7_g@mail.gmail.com>
 <20160909221945.GQ2356@ZenIV.linux.org.uk> <CA+55aFzTOOB6oEVaaGD0N7Uznk-W9+ULPwzsxS_L_oZqGVSeLA@mail.gmail.com>
 <20160914031648.GB2356@ZenIV.linux.org.uk> <CA+55aFznQaOWoSMNphgGJJWZ=8-odrc0DAUMzfGPQe+_N4UgNA@mail.gmail.com>
 <20160914042559.GC2356@ZenIV.linux.org.uk> <20160917082007.GA6489@ZenIV.linux.org.uk>
 <20160917190023.GA8039@ZenIV.linux.org.uk> <20160918193112.GF2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jens Axboe <axboe@kernel.dk>, Nick Piggin <npiggin@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36292 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753428AbcIRUMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 16:12:22 -0400
In-Reply-To: <20160918193112.GF2356@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 12:31 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> FWIW, I'm not sure if skb_splice_bits() can't land us in trouble; fragments
> might come from compound pages and I'm not entirely convinced that we won't
> end up with coalesced fragments putting more than PAGE_SIZE into a single
> pipe_buffer.  And that could badly confuse a bunch of code.

The pipe buffer code is actually *supposed* to handle any size
allocations at all. They should *not* be limited by pages, exactly
because the data can come from huge-pages or just multi-page
allocations. It's definitely possible with networking, and networking
is one of the *primary* targets of splice in many ways.

So if the splice code ends up being confused by "this is not just
inside a single page", then the splice code is buggy, I think.

Why would splice_write() cases be confused anyway? A filesystem needs
to be able to handle the case of "this needs to be split" regardless,
since even if the source buffer were to fit in a page, the offset
might obviously mean that the target won't fit in a page.

Now, if you decide that you want to make the iterator always split
those possibly big cases and never have big iovec entries, I guess
that would potentially be ok. But my initial reaction is that they are
perfectly normal and should be handled normally, and any code that
depends on a splice buffer fitting in one page is just buggy and
should be fixed.

                 Linus
