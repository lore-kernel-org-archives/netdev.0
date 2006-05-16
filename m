From: Mark A Smith <mark1smi@us.ibm.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Mon, 15 May 2006 18:50:36 -0700
Message-ID: <OF4D94549F.7BBB070C-ON85257170.0009219D-88257170.000A05E8@us.ibm.com>
References: <4469201F.4030207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:23497 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751016AbWEPBux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 21:50:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4G1oqlP005873
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 21:50:52 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4G1oqPe253592
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 21:50:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k4G1oqqs004649
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 21:50:52 -0400
Received: from d01ml604.pok.ibm.com (d01ml604.pok.ibm.com [9.56.227.90])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id k4G1oqNZ004641
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 21:50:52 -0400
In-Reply-To: <4469201F.4030207@hp.com>
To: Rick Jones <rick.jones2@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I cannot think of another possible definition for thread-safe in the
context of these functions. Certainly they should not cause a "crash" when
called from multiple threads, but that's a requirement independent of
thread-safety. The POSIX specification doesn't mention atomicity with
respect to these functions. In the context of read(), it defines atomicity
as follows: "Atomic means that all the bytes from a single operation that
started out together end up together, without interleaving from other I/O
operations." This seems to be the semantics I'm expecting from a
"thread-safe" sendmsg(). What else could thread-safe mean for send(),
sendmsg()?

As for fork() vs. pthreads, my original post indicated that this occurs
with or without pthreads, the same problem occurs if you use pthreads. I
tried to indicate that I was using the term "thread" to be independent of
whether the address space was shared or not.

If you do not see any "send() sent 10 bytes" messages in your server
output, it means that the problem occured the very first time the 10-byte
send was attempted. If you watch the data going over the wire, you'll see
those 10 bytes of 1's.

That write() document is excellent, and reads exactly like the POSIX
specification.

As for limits, I modified my test to use very small buffers, below any
reasonable limit. By removing the printf's, which slow the server
considerably, I can still get the problem to produce.

I think the question really boils down to: "What does thread-safe mean with
respect to send()?" It might be more easily answered by asking, "How would
a non-thread-safe send() behave?" I think it would behave the way we're
seeing it behave.

-Mark



That's excellent documentation, and reads exactly to the write()
specification in POSIX.



|---------+---------------------------->
|         |           Rick Jones       |
|         |           <rick.jones2@hp.c|
|         |           om>              |
|         |                            |
|         |           05/15/2006 05:43 |
|         |           PM               |
|---------+---------------------------->
  >-----------------------------------------------------------------------------------------------------------------|
  |                                                                                                                 |
  |       To:       Mark A Smith/Almaden/IBM@IBMUS                                                                  |
  |       cc:       shemminger@osdl.org, Linux Network Development list <netdev@vger.kernel.org>                    |
  |       Subject:  Re: send(), sendmsg(), sendto() not thread-safe                                                 |
  >-----------------------------------------------------------------------------------------------------------------|




Mark A Smith wrote:
> Hi Rick, Stephen,
>
> The thread-safe claim is at:
>
>
http://devrsrc1.external.hp.com/STKS/cgi-bin/man2html?manpage=/usr/share/man/man2.Z/send.2

>
> Specifically,
>
> "
> MULTITHREAD USAGE
>       The send(), sendmsg(), and sendto() system calls are thread-safe.
>       They each have a cancellation point; and they are async-cancel
safe,
>       async-signal safe, and fork-safe.
> "

That looks to be the 11iv1 manpage (aka 11.11).    I wonder if perhaps
there is a distinction made between "thread-safety" and an atomicity
semantic?

Also, _strictly_ speaking, since your test is calling fork() rather than
pthread_create(), it isn't really testing "thread safty" but multiple
process atomicity right?

> I noticed that you were thinking that the problem may be with my test and
> that the send call is returning partial status.

Either the test, or the stack.

> Actually, that's exactly
> the issue. On the systems I tested on, and I assume HP-UX, send is _not_
> returning partial status, it is returning that the entire buffer has been
> written, and yet is interleaving data from packets in the other thread.

Ostensibly, I should see some ten byte send messages in the output of
sendmsgserver yes?  I just ran a test where it was all 32768's, no 10's
but the client still reported an error.  Is that supposed to be possible?

# sendmsgserver > sendmsgserver.log
# wc sendmsgserver.log
165888 663552 3981312 sendmsgserver.log
# grep -v 32768 sendmsgserver.log
#

# ./sendmsgclient localhost
ERROR! We should have all 0! We don't!
buff[16384]=1
buff[16385]=1
buff[16386]=1
buff[16387]=1
buff[16388]=1
buff[16389]=1
buff[16390]=1
buff[16391]=1
buff[16392]=1
buff[16393]=1
That's 10/32768 bad bytes

I've also seen it fail at 12288 rather than 16384.  I wonder if perhaps
there are unstated limits to the size of the write that can be atomic?

Looking at the 11.11 manpage for write(2) in the discussion of writes to
a pipe or FIFO it says:

+  Write requests of {PIPE_BUF} bytes or less will not be
    interleaved with data from other processes doing writes on the
    same pipe.  Writes of greater than {PIPE_BUF} bytes may have
    data interleaved, on arbitrary boundaries, with writes by
    other processes, whether or not the O_NONBLOCK flag of the
    file status flags is set.

from limits.h:

#  define _POSIX_PIPE_BUF       512     /* The number of bytes that can
                                            be written atomically when
                                            writing to a pipe. */


later

#    define PIPE_BUF    8192    /* max number bytes that is guaranteed
                                    to be atomic when writing to a pipe */

Under various #ifdef checks and such.  It would not surprise me if there
was a limit to the size of a buffer in a send/sendto/sendmsg call
similar to that for write against a pipe.

I wonder if similar limits exist for the other stacks in the "yes" column.

rick jones


