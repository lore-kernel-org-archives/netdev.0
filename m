From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 20 Oct 2015 10:59:46 +0100
Message-ID: <56261092.7080003@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3>	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <562594E1.8040403@oracle.com> <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22099 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbJTJ7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 05:59:49 -0400
In-Reply-To: <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/10/2015 02:45, Eric Dumazet wrote:

> On Tue, 2015-10-20 at 02:12 +0100, Alan Burlison wrote:
>
>> Another problem is that if I call close() on a Linux socket that's in
>> accept() the accept call just sits there until there's an incoming
>> connection, which succeeds even though the socket is supposed to be
>> closed, but then an immediately following accept() on the same socket
>> fails.
>
> This is exactly what the comment I pasted documents.

Yes, and it's caveated with "temporary solution" and "_not_ a good idea" 
and says that the problem is that close() needs repairing. In other 
works, the change in shutdown() behaviour appears to be a workaround for 
an acknowledged bug, and it's one with consequences.

There are two separate things here.

The first is the close/reopen race issue with filehandles. As I said, I 
believe that's an artefact of history, because it wasn't possible for it 
to happen before threads and was possible after them. There appears to 
be no good way to avoid this with the current *NIX filehandle semantics 
when threads are being used. History sucks.

The second is how/if you might work around that. As far as I can tell, 
Linux does so by allowing shutdown() to be called on unconnected sockets 
and uses that as a signal that threads waiting in accept() should return 
from the accept with a failure but without the filehandle being actually 
closed, and therefore not being available for reuse, and therefore not 
subject to potential races.  However by doing so I believe the behaviour 
of shutdown is then not POSIX-conforming. The Linux manpage for 
shutdown(2) says "CONFORMING TO POSIX.1-2001", as far as I can tell it 
isn't. At very least I believe the manpage needs changing.

> On linux, doing close(listener) on one thread does _not_ wakeup other
> threads doing accept(listener)

Allowing an in-progress accept() to continue and to succeed at some 
point in the distant future on a filehandle that's closed seems incorrect.

Also, the behaviour of poll() that I mentioned - that it returns 
immediately for a socket in the listen() state - does seem like an 
out-and-out bug to me, I haven't seen any explanation of why that might 
be correct behaviour.

> So I guess allowing shutdown(listener) was a way to somehow propagate
> some info on the threads stuck in accept()

Yes, I think you are right.

> This is a VFS issue, and a long standing one.

That seems to be what the comment you quoted is saying, yes.

> Think of all cases like dup() and fd passing games, and the close(fd)
> being able to signal out of band info is racy.

Yes, I agree there are potential race conditions, intrinsic to the way 
*NIX FDs work. As I said earlier, there *may* be a portable way around 
this using /dev/null & dup2() but I haven't had chance to investigate 
that yet.

> close() is literally removing one ref count on a file.
> Expecting it doing some kind of magical cleanup of a socket is not
> reasonable/practical.

I'm not sure what that means at an application level - no matter how 
many copies I make of a FD in a process it's still just an integer and 
calling close on it closes it and causes any future IOs to fail - except 
for the case of sockets in accept() it seems, which continue and may 
even eventually succeed. Leaving aside the behaviour of shutdown() on 
listening sockets, the current behaviour of close() on a socket in 
accept() seems incorrect. And then of course there's also the poll() issue.

> On a multi threaded program, each thread doing an accept() increased the
> refcount on the file.

That may be how Linux implements accept(), but I don't see anything 
about refcounting in the POSIX spec for accept().

> Really, I have no idea of how Solaris coped with this, and I do not want
> to know.

The bug goes into quite some detail about how Solaris behaves. The issue 
here is that we have two implementations, Linux and Solaris, both 
claiming to be POSIX-conformant but both showing different behaviour. 
There's a discussion to be had about the whys and wherefores of that 
difference, but saying that you don't want to know how Solaris behaves 
isn't really going to help move the conversation along.

-- 
Alan Burlison
--
