From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 20 Oct 2015 02:12:01 +0100
Message-ID: <562594E1.8040403@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3> <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:21302 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbJTBMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 21:12:08 -0400
In-Reply-To: <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/10/2015 00:33, Eric Dumazet wrote:

> It looks it is a long standing problem, right ?

Yep, seems so.

> inet_shutdown() has this very specific comment from beginning of git
> tree :
>
>          switch (sk->sk_state) {
> ...
>          /* Remaining two branches are temporary solution for missing
>           * close() in multithreaded environment. It is _not_ a good idea,
>           * but we have no choice until close() is repaired at VFS level.
>           */
>          case TCP_LISTEN:
>                  if (!(how & RCV_SHUTDOWN))
>                          break;
>                  /* Fall through */
>          case TCP_SYN_SENT:
>                  err = sk->sk_prot->disconnect(sk, O_NONBLOCK);
>                  sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
>                  break;
>          }

I think it's probably an intrinsic part of the way *NIX file descriptors 
and their reuse has worked since the dawn of *NIX time - at which time 
threads didn't exist, so this problem didn't either. The advent of 
threads made this this hole possible, which is I believe what the 
comment above is pointing out. The problem people are trying to solve by 
calling shutdown() on an listen()ing socket is the race in MT programs 
between a socket being closed and the same file descriptor being 
recycled by a subsequent open()/socket() etc.

> Claiming Solaris does it differently is kind of moot.
> linux is not Solaris.

Agreed that Linux != Solaris, but the argument I'm being faced with is 
that anything that doesn't behave in the same way as Linux is wrong by 
definition. And the problem with that is that the Linux behaviour of 
shutdown() on a listen()/accept() socket is I believe incorrect anyway 
as my read of POSIX says that shutdown() is only valid on connected 
sockets, and sockets in listen()/accept() aren't connected by 
definition, and Linux allows shutdown() to succeed when it should 
probably return ENOTCONN. Yes, there's a potential race with FDs being 
recycled, but you can get that with vanilla file FDs as well, where 
shutdown() isn't an option.

Another problem is that if I call close() on a Linux socket that's in 
accept() the accept call just sits there until there's an incoming 
connection, which succeeds even though the socket is supposed to be 
closed, but then an immediately following accept() on the same socket 
fails. And yet another problem is that poll() on a socket that's had 
listen() called on it returns immediately even if there's no incoming 
connection on it, which I believe makes multiplexing a set of sockets 
which includes a socket you want to accept() on impossible. The test 
program I attached to the bug allows you to play around with the 
different combinations.

> Unless proven a real problem (and not only by trying to backport from Solaris to linux),
> we'll probably wont change this.

It's a real problem (with Hadoop, which contains C/C++ to do low-level 
I/O) and it's the other way around, I am porting that code from Linux to 
Solaris.

I accept that you probably can't change the behaviour of shutdown() in 
Linux without breaking existing code, for example it seems libmicrohttpd 
also assumes it's OK to call shutdown() on a listen() socket on Linux, 
see https://lists.gnu.org/archive/html/libmicrohttpd/2011-09/msg00024.html

However, even if the shutdown() behaviour can't be changed the Linux 
close()/poll() behaviour on a listen()/accept() sockets seems rather odd.

There *may* be a way around this that's race-free and cross-platform 
involving the use of /dev/null and dup2(), see Listing Five on 
http://www.drdobbs.com/parallel/file-descriptors-and-multithreaded-progr/212001285 
but I haven't confirmed it works yet.

Thanks,

-- 
Alan Burlison
--
