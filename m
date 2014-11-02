From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Connection with Smart Z hangs
Date: Sun, 2 Nov 2014 10:20:22 -0800
Message-ID: <CA+55aFzB+d8+pjvuPo-n5G7X9MK9vh9ER5zYLCXZBzjMD4bseA@mail.gmail.com>
References: <544782AF.2060406@gmx.de>
	<544D4DBB.9050103@libdivecomputer.org>
	<54566950.5080206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: devel <devel@libdivecomputer.org>,
	Network Development <netdev@vger.kernel.org>
To: Martin Lang <mlg.hessigheim@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:45553 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbaKBSUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 13:20:23 -0500
Received: by mail-vc0-f176.google.com with SMTP id hq12so1564633vcb.21
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2014 10:20:22 -0800 (PST)
In-Reply-To: <54566950.5080206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 2, 2014 at 9:26 AM, Martin Lang <mlg.hessigheim@gmail.com> wrote:
>
> I debugged a little bit and got the impression that the problem is with the
> IRDA driver and not libdivecomputer.

Looks that way.

> [  767.319321] BUG: unable to handle kernel NULL pointer dereference at (null)
> [  767.320541] CPU: 0 PID: 3093 Comm: smart Not tainted 3.13.0-37-generic #64-Ubuntu

Ugh. 3.13. I guess you can't get anything newer through Ubuntu without
going through some big upgrade of everything.

Not that I see any likely fixes since 3.13. Irda is basically dead
technology, the only user we ever see any more are a very few dive
computers. So nobody maintains it any more.

In fact, we had this very bug reported last *year*, and I debugged it,
and sent my

> [  767.322008]  [<ffffffffa02c75c6>] ? irda_connect+0x156/0x480 [irda]
> [  767.322540] Code:  Bad RIP value.

Ok, it's a call to a NULL pointer, which is bad. The only such call is the

    sk->sk_prot->disconnect()

call, and the "disconnect" function for irda is NULL, always has been
and probably always will be. And nobody has ever fixed this. There was
a thread in late december last year (and early January this year about
this particular oops and another one) where I reported this, and
people agreed that it was all bogus. There was a separate locking
issue too, which wasn't as simple.

David, I'm just going to remove that whole bogus disconnect call. It
won't make things *work* for Martin (because this is all in the
"connect failed" path), but that call as-is is just wrong, wrong,
wrong. And apparently nobody cares about irda any more.

If anybody is at all interested in helping maintain irda code, holler
to David and to the netdev mailing list. The position is up for grabs.

                          Linus
