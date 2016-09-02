From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock'
Date: Fri, 2 Sep 2016 11:17:18 -0700
Message-ID: <CA+55aFyFEhaOaDN9kuphgRV8sDKpV_2xB9X-kpWqMLUtX9JBtQ@mail.gmail.com>
References: <alpine.LFD.2.20.1609021109340.4072@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Dumazet <edumazet@google.com>, willy tarreau <w@1wt.eu>,
        Network Development <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35458 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754676AbcIBSRU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:17:20 -0400
Received: by mail-oi0-f67.google.com with SMTP id 2so4996732oif.2
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 11:17:19 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1609021109340.4072@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 11:13 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 1 Sep 2016 14:43:53 -0700
> Subject: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock'
>
> Right now we use the 'readlock' both for protecting some of the af_unix
> IO path and for making the bind be single-threaded.
>
> The two are independent, but using the same lock makes for a nasty
> deadlock due to ordering with regards to filesystem locking.  The bind
> locking would want to nest outside the VSF pathname locking, but the IO
> locking wants to nest inside some of those same locks.
>
> We tried to fix this earlier with commit c845acb324aa ("af_unix: Fix
> splice-bind deadlock") which moved the readlock inside the vfs locks,
> but that caused problems with overlayfs that will then call back into
> filesystem routines that take the lock in the wrong order anyway.
>
> Splitting the locks means that we can go back to having the bind lock be
> the outermost lock, and we don't have any deadlocks with lock ordering.
>
> Acked-by: Rainer Weikusat <rweikusat@cyberadapt.com>
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Oh, this was missing a

  Reported-and-tested-by: CAI Qian <caiqian@redhat.com>

who found the new deadlock.

There's now *another* lockdep deadlock report by him, but that one has
nothing to do with networking.

(And neither of these deadlocks will actually deadlock the machine in
practice, but you can trigger the lockdep reports with some odd splice
patterns and overlayfs use)

                 Linus
