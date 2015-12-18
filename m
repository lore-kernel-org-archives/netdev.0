From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: splice-bind deadlock (was: [PATCH] af_unix: Revert 'lock_interruptible' in stream receive code)
Date: Fri, 18 Dec 2015 16:04:09 +0000
Message-ID: <87si2zbv5y.fsf_-_@doppelsaurus.mobileactivedefense.com>
References: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
	<56727EE9.5020805@stressinduktion.org>
	<871takk674.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871takk674.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Thu, 17 Dec 2015 23:26:23 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>
> [...]
>
>> There is still a deadlock lingering around
>
> [...]
>
>> http://lists.openwall.net/netdev/2015/11/10/4

[...]

> 	(a while ago) A: socketpair()
>         
> 	B: splice() from a pipe to /mnt/regular_file
>  	   does sb_start_write() on /mnt
>            
> 	C: try to freeze /mnt
> 	   wait for B to finish with /mnt
>            
> 	A: bind() try to bind our socket to /mnt/new_socket_name
> 	   lock our socket, see it not bound yet
> 	   decide that it needs to create something in /mnt
> 	   try to do sb_start_write() on /mnt, block (it's
> 	   waiting for C).
>            
> 	D: splice() from the same pipe to our socket
> 	   lock the pipe, see that socket is connected
> 	   try to lock the socket, block waiting for A
>            
> 	B: get around to actually feeding a chunk from
> 	   pipe to file, try to lock the pipe.
	[from the page]

[...]

> Given
> 	a/b	- acquire a block b (eg, get read lock on superblock
>                   rwsem)
>
> 	b/a	- acquire b block a
>
>         c	- u->readlock
>
>         d	- pipe lock
>
> 	[*y]   - blocks waiting for y
>
>         
> B	a/b
>
> C	b/a[*B]
>
> A	c
> A	a/b[*C]
>
> D	d
> D	c[*A]
>
> B	d[*D]

Some more explanations on this: There two groups of three in the above
(X <- Y supposed to mean 'Y waits for X'), B <- C <- A and A <- D <-
B. 'B blocking C blocking A' is really the same as if B was holding an
abstract mutex m0 A wants. Likewise, A <- D <- B is equivalent to A
holding an abstract mutex m1 B wants. Conceptually, there are two
threads and two locks here,

B: acquires m0 then m1
A: acquires m1 then m0

and because of the conflicting  locking orders, the whole
shoggoth deadlocks sooner or later (Fhtagn!).

The obvious idea to fix this is to reverse either A or B. I think A
should be reversed because that's probably easier (unless there's some
technical problem with that I don't yet know of) and because this avoids
a situation where some other thread which wants the readlock mutex has to
wait until some completeld unrelated filesystem operations have
completed.

But theory only gets one so far and it would be good if someone capable
of reproducing the problem tested this.
