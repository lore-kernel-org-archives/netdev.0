From: Rick Jones <rick.jones2@hp.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Mon, 15 May 2006 17:43:11 -0700
Message-ID: <4469201F.4030207@hp.com>
References: <OFA7F8723C.2DDF9383-ON85257170.00014BE5-88257170.00019BEA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:63973 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1750896AbWEPAnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 20:43:14 -0400
To: Mark A Smith <mark1smi@us.ibm.com>
In-Reply-To: <OFA7F8723C.2DDF9383-ON85257170.00014BE5-88257170.00019BEA@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark A Smith wrote:
> Hi Rick, Stephen,
> 
> The thread-safe claim is at:
> 
> http://devrsrc1.external.hp.com/STKS/cgi-bin/man2html?manpage=/usr/share/man/man2.Z/send.2
> 
> Specifically,
> 
> "
> MULTITHREAD USAGE
>       The send(), sendmsg(), and sendto() system calls are thread-safe.
>       They each have a cancellation point; and they are async-cancel safe,
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
