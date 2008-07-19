From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Sat, 19 Jul 2008 14:18:36 +0300
Message-ID: <200807191418.37053.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807182143.38624.opurdila@ixiacom.com> <20080719085110.GA25052@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3560 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752539AbYGSLUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 07:20:45 -0400
In-Reply-To: <20080719085110.GA25052@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 July 2008, Evgeniy Polyakov wrote:

>
> Hmm, than how does it concerns SPLICE_F_NONBLOCK feature change? Your
> patch does not touch this behaviour.
>

My patch makes SPLICE_F_NONBLOCK work only on the pipe, it stops 
SPLICE_F_NONBLOCK giving non-blocking semantics to the socket. It thus allows 
the application to control the "blockiness" of pipe and socket operations 
_independently_:
- you want blocking operations on the socket: you use O_NONBLOCK.
- you want blocking operations on the pipe: you use SPLICE_F_NONBLOCK

It has a limitation though: you are not able to control the "blockiness" of 
the socket operation during the splice call. Thats why I propose using two 
flags: one for the pipe and one for the socket.

> Anyway, in case of not having SPLICE_F_NONBLOCK it does not deadlock,
> but waits until someone reads from the other side of the pipe. It blocks
> and expects reader to unblock it.
>

Correct. 

> It looks like you have two unexpected independent issues with splice:
> ability to perform non-blocking reading from the socket into the pipe
> when SPLICE_F_NONBLOCK is set,
> and blocking waiting for reader to get data from the pipe when
> SPLICE_F_NONBLOCK is not set. Is it correct?
>

What I would like is to have the ability to do blocking operations on the 
socket and non-blocking operations on the pipe.

> If so, the former is a feature, which allows to have some progress when
> receiving queue is empty: one can start getting data from the pipe,
> i.e. splice data out of the pipe to the different file descriptor.

> So, this flag means both non-blocking pipe operations _and_ non-blocking
> receiving from the socket.
>

Correct. 

> For the blocking in pipe_wait() when pipe is full and SPLICE_F_NONBLOCK
> is not set, then it is just a pipe behaviour, which is used as a
> temporal storage for the requested data. It is not some buffer, which is
> returned to the userspace when it is full (or indication of it), but a
> pipe, where you put page pointers, so when pipe is full and opened in
> blocking mode, writer sleeps waiting or reader to get some data out of it
> and thus awake writer. 

Correct.


> It is not a deadlock, but very expected behaviour 
> of the pipe: to block when pipe is full waiting for reader to get data.
>

But in the larger picture it means that: 

(a) a simple single threaded program that copies data from a socket to a file 
with splice, using  blocking operations on the socket and file, will not work 
as it can block in the 1st splice if we specify a non tiny buffer. So, we 
will either:

(b) need to use threads to read from the pipe and unblock it, or 

(c) need to use full non-blocking operations with the whole poll/epoll/select 
bits implemented

If you agree with the above statement, and you think that it is ok to be 
forced to use (b) or (c) instead of (a), than I'll be happy to stop the 
discussion here since its getting into a matter of personal interpretation of 
what a good API is :)

> Hope this will clarify this discussion a bit, so it would not look like
> talk of blind and deaf :)

Indeed :) 

My bad, I probably should have explained this in more details from the 
beginning. Thanks for taking the time to debate this, despite of my poor 
explanations.

Thanks,
tavi
