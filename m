From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Sat, 19 Jul 2008 12:51:10 +0400
Message-ID: <20080719085110.GA25052@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com> <200807182116.43451.opurdila@ixiacom.com> <20080718183549.GA23263@2ka.mipt.ru> <200807182143.38624.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:35617 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642AbYGSIvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jul 2008 04:51:19 -0400
Content-Disposition: inline
In-Reply-To: <200807182143.38624.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Octavian.

On Fri, Jul 18, 2008 at 09:43:38PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> The flag gets propagated to splice_to_pipe (so there is no need to propagate 
> the check in skb_splice_bits) but we don't have SPLICE_F_NONBLOCK set, we are 
> on the blocking usecase.

Hmm, than how does it concerns SPLICE_F_NONBLOCK feature change? Your
patch does not touch this behaviour.

Anyway, in case of not having SPLICE_F_NONBLOCK it does not deadlock,
but waits until someone reads from the other side of the pipe. It blocks
and expects reader to unblock it.

It looks like you have two unexpected independent issues with splice:
ability to perform non-blocking reading from the socket into the pipe
when SPLICE_F_NONBLOCK is set,
and blocking waiting for reader to get data from the pipe when
SPLICE_F_NONBLOCK is not set. Is it correct?

If so, the former is a feature, which allows to have some progress when
receiving queue is empty: one can start getting data from the pipe,
i.e. splice data out of the pipe to the different file descriptor.
So, this flag means both non-blocking pipe operations _and_ non-blocking
receiving from the socket.

For the blocking in pipe_wait() when pipe is full and SPLICE_F_NONBLOCK
is not set, then it is just a pipe behaviour, which is used as a
temporal storage for the requested data. It is not some buffer, which is
returned to the userspace when it is full (or indication of it), but a
pipe, where you put page pointers, so when pipe is full and opened in
blocking mode, writer sleeps waiting or reader to get some data out of it
and thus awake writer. It is not a deadlock, but very expected behaviour
of the pipe: to block when pipe is full waiting for reader to get data.

Hope this will clarify this discussion a bit, so it would not look like
talk of blind and deaf :)

-- 
	Evgeniy Polyakov
