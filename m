From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: Crash with SO_REUSEPORT and ef456144da8ef507c8cf504284b6042e9201a05c
Date: Tue, 19 Jan 2016 12:04:10 -0400
Message-ID: <CAB9dFdswyri4-pDZ+uoAk00isP8Lba7-uqYPXnT=PnLataJeHg@mail.gmail.com>
References: <CAB9dFdugvFvdQLGAU83CQHYbwaWCMHrAm5Xk746iwMG5g94PqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet@google.com
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34522 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbcASQEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 11:04:11 -0500
In-Reply-To: <CAB9dFdugvFvdQLGAU83CQHYbwaWCMHrAm5Xk746iwMG5g94PqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resent with correct address for Eric.

On Tue, Jan 19, 2016 at 11:57 AM, Marc Dionne <marc.c.dionne@gmail.com> wrote:
> I shared this one with Craig but I thought I'd put it out to a wider audience.
>
> Trying to run the current kernel mainline on a test system I found
> that any attempt to run many of our executables would crash the
> system.  The networking code in all of these opens and listens on
> multiple UDP sockets set with SO_REUSEPORT.  We also like to bind the
> first socket before setting SO_REUSEPORT so we can catch some cases
> where the port is actually in use by someone else (for instance a
> previous incarnation of the same service).
>
> This is easily reproduced with this sequence:
> - create 2 sockets A and B
> - bind socket A to an address
> - set SO_REUSEPORT on socket A
> - set SO_REUSEPORT on socket B
> - bind socket B to the same address as A
>
> The sk_reuseport_cb structure is only allocated at bind time if
> SO_REUSEPORT is already set, so A doesn't have one.  When we bind B, A
> is found as a match that has SO_REUSEPORT and reuseport_add_sock will
> try to use the NULL sk_reuseport_cb structure from A, causing a crash.
>
> Not sure what the best fix is, but seems like the structure could be
> either allocated (if not already done) when setting SO_REUSEPORT, or
> when we find it to be NULL in reuseport_add_sock (but locking may be
> an issue there).  I was able to test that allocating sk_reuseport_cb
> when setting SO_REUSEPORT makes things behave normally again; see
> attached patch.  That's surely not a correct/complete fix as B (in the
> scenario above) will have an unnecessary sk_reuseport_cb which will
> trigger a warning and should be dealt with.
>
> Thanks,
> Marc
