From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: skb_splice_bits() and large chunks in pipe (was Re:
 xfs_file_splice_read: possible circular locking dependency detected
Date: Sun, 18 Sep 2016 20:31:12 +0100
Message-ID: <20160918193112.GF2356@ZenIV.linux.org.uk>
References: <CA+55aFxrqCng2Qxasc9pyMrKUGFjo==fEaFT1vkH9Lncte3RgQ@mail.gmail.com>
 <20160909023452.GO2356@ZenIV.linux.org.uk>
 <CA+55aFwHQMjO4-vtfB9-ytc=o+DRo-HXVGckvXLboUxgpwb7_g@mail.gmail.com>
 <20160909221945.GQ2356@ZenIV.linux.org.uk>
 <CA+55aFzTOOB6oEVaaGD0N7Uznk-W9+ULPwzsxS_L_oZqGVSeLA@mail.gmail.com>
 <20160914031648.GB2356@ZenIV.linux.org.uk>
 <CA+55aFznQaOWoSMNphgGJJWZ=8-odrc0DAUMzfGPQe+_N4UgNA@mail.gmail.com>
 <20160914042559.GC2356@ZenIV.linux.org.uk>
 <20160917082007.GA6489@ZenIV.linux.org.uk>
 <20160917190023.GA8039@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe@kernel.dk>, Nick Piggin <npiggin@gmail.com>,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:57372 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755785AbcIRTbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 15:31:16 -0400
Content-Disposition: inline
In-Reply-To: <20160917190023.GA8039@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FWIW, I'm not sure if skb_splice_bits() can't land us in trouble; fragments
might come from compound pages and I'm not entirely convinced that we won't
end up with coalesced fragments putting more than PAGE_SIZE into a single
pipe_buffer.  And that could badly confuse a bunch of code.

Can that legitimately happen?  If so, we'll need to audit quite a few
->splice_write()-related codepaths; FUSE, in particular, is very likely
to be unhappy with that kind of stuff, and it's not the only place where
we might count upon never seeing e.g. longer than PAGE_SIZE chunks in
bio_vec.  It shouldn't be all that hard to fix, but if the whole thing
is simply impossible, I would rather avoid that round of RTFS at the moment...

Comments?
