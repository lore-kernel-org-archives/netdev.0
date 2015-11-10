From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Deadlock between bind and splice
Date: Tue, 10 Nov 2015 02:31:33 +0000
Message-ID: <20151110023133.GY22011@ZenIV.linux.org.uk>
References: <CACT4Y+brDX=C15jSs33zGaCBt2BDPPzBcgqtKA2dYMdviYjKww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35340 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbbKJCbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 21:31:38 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+brDX=C15jSs33zGaCBt2BDPPzBcgqtKA2dYMdviYjKww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 06, 2015 at 01:58:27PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I am on revision d1e41ff11941784f469f17795a4d9425c2eb4b7a (Nov 5) and
> seeing the following lockdep reports. I don't have exact reproducer
> program as it is caused by several independent programs (state
> accumulated in kernel across invocations); if the report is not enough
> I can try to cook a reproducer.
> 
> Thanks.
> 
> [ INFO: possible circular locking dependency detected ]
> 4.3.0+ #30 Not tainted
> -------------------------------------------------------
> a.out/9972 is trying to acquire lock:
>  (&pipe->mutex/1){+.+.+.}, at: [<     inline     >] pipe_lock_nested
> fs/pipe.c:59
>  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff814d6e46>]
> pipe_lock+0x56/0x70 fs/pipe.c:67
> 
> but task is already holding lock:
>  (sb_writers#5){.+.+.+}, at: [<ffffffff814c77ec>]
> __sb_start_write+0xec/0x130 fs/super.c:1198
> 
> which lock already depends on the new lock.
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #2
[AF_UNIX bind() does sb_start_write() while holding unix_sock locked]

> -> #1
[splice() to AF_UNIX socket is trying to lock unix_sock while holding
the pipe locked]

> -> #0 (&pipe->mutex/1){+.+.+.}:
[splice() to regular file is locking the pipe under sb_start_write()]

Cute...  The first impression is that in #1 you need the socket to
be connected, or it won't even reach that attempt to lock unix_sock,
while bind() on the same sucker ought to bugger off before getting
around to touching the filesystem, so it looks like a false positive,
but... socketpair() yields a connected socket and AFAICS there's
nothing in unix_bind() to bugger off on such.

So the scenario ought to be:
(a while ago) A: socketpair()
B: splice() from a pipe to /mnt/regular_file
	does sb_start_write() on /mnt
C: try to freeze /mnt
	wait for B to finish with /mnt
A: bind() try to bind our socket to /mnt/new_socket_name
	lock our socket, see it not bound yet
	decide that it needs to create something in /mnt
	try to do sb_start_write() on /mnt, block (it's
	waiting for C).
D: splice() from the same pipe to our socket
	lock the pipe, see that socket is connected
	try to lock the socket, block waiting for A
B:	get around to actually feeding a chunk from
	pipe to file, try to lock the pipe.  Deadlock.

Locking the socket is interruptible, though, so killing D will
untangle that mess - it's not quite a hopeless deadlock.

Deadlock or not, should bind() actually work on connected sockets?
AFAICS, socketpair() is the only way for it to happen...
