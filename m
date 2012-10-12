From: enh <enh@google.com>
Subject: listen(2) backlog changes in or around Linux 3.1?
Date: Fri, 12 Oct 2012 16:40:40 -0700
Message-ID: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33163 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab2JLXlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 19:41:05 -0400
Received: by mail-qc0-f174.google.com with SMTP id d3so2660119qch.19
        for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 16:41:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i used to use the following hack to unit test connect timeouts: i'd
call listen(2) on a socket and then deliberately connect (backlog + 3)
sockets without accept(2)ing any of the connections. (why 3? because
Stevens told me so, and experiment backed him up. see figure 4.10 in
his UNIX Network Programming.)

with "old" kernels, 2.6.35-ish to 3.0-ish, this worked great. my next
connect(2) to the same loopback port would hang indefinitely. i could
even unblock the connect by calling accept(2) in another thread. this
was awesome for testing.

in 3.1 on ARM, 3.2 on x86 (Ubuntu desktop), and 3.4 on ARM, this no
longer works. it doesn't seem to be as simple as "the constant is no
longer 3". my tests are now flaky. sometimes they work like they used
to, and sometimes an extra connect(2) will succeed. (or, if i'm in
non-blocking mode, my poll(2) will return with the non-blocking socket
that's trying to connect now ready.)

i'm guessing if this changed in 3.1 and is still changed in 3.4,
whatever's changed wasn't an accident. but i haven't been able to find
the right search terms to RTFM. i also finally got around to grepping
the kernel for the "+ 3", but wasn't able to find that. (so i'd be
interested to know where the old behavior came from too.)

my least worst workaround at the moment is to use one of RFC5737's
test networks, but that requires that the device have a network
connection, otherwise my connect(2)s fail immediately with
ENETUNREACH, which is no use to me. also, unlike my old trick, i've
got no way to suddenly "unblock" a slow connect(2) (this is useful for
unit testing the code that does the poll(2) part of the usual
connect-with-timeout implementation).
https://android-review.googlesource.com/#/c/44563/

hopefully someone here can shed some light on this? ideally someone
will have a workaround as good as my old trick. i realize i was
relying on undocumented behavior, and i'm happy to have to check
/proc/version and behave appropriately, but i'd really like a way to
keep my unit tests!

thanks,
 elliott
