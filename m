From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock'
Date: Fri, 2 Sep 2016 13:00:27 -0700
Message-ID: <CA+55aFzMGD0vfWL_QA-bdQTbUvgS1on_jLExMo7jsps3uu3Tkg@mail.gmail.com>
References: <alpine.LFD.2.20.1609021109340.4072@i7> <CA+55aFyFEhaOaDN9kuphgRV8sDKpV_2xB9X-kpWqMLUtX9JBtQ@mail.gmail.com>
 <20160902.121534.1390430589343316053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Dumazet <edumazet@google.com>, Willy Tarreau <w@1wt.eu>,
        Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33187 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932403AbcIBUA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:00:28 -0400
Received: by mail-oi0-f51.google.com with SMTP id c15so176846348oig.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 13:00:28 -0700 (PDT)
In-Reply-To: <20160902.121534.1390430589343316053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 12:15 PM, David Miller <davem@davemloft.net> wrote:
>
> The main thing I was concerned about was an I/O path that really
> expects the socket's hash not to change for whatever reason, but even
> all of the unix_find_other() calls are done outside of the mutex
> already.

That's my read of it too. I did actually go through the effort on
trying to follow all the locking in there yesterday, so while I would
want an AF_UNIX person to double-check me, I think it's fine.

The real locking seem to be the u->lock spinlock (taken by
unix_state_lock() and friends).

The bindlock is only about serializing the binders, which do things
that can sleep (notably the mknod of the unix socket node in the
filesystem).

The one thing I looked at and wasn't sure about was
unix_stream_connect(), which creates a *new* unix domain socket and
binds it to the old one without holding the bindlock. Note that it
never did hold the lock, so that's not a new thing, but it worries me
a bit.

I *think* it's ok, because I think this all happens before that new
socket is actually reachable, so it cannot race against somebody else
doing a bind. And my patch doesn't actually change anything in this
area, so I'm not making it worse. But it was the one thing I reacted
to when going through the locking there.

(Well, not the "one thing". The other thing I reacted to was the
overall reaction that none of this is documented, and the locking was
clearly not very clear).

                 Linus
