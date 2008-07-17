From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Thu, 17 Jul 2008 18:21:33 +0400
Message-ID: <20080717142132.GA11702@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:53330 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756579AbYGQOVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 10:21:42 -0400
Content-Disposition: inline
In-Reply-To: <200807171633.49791.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Octavian.

On Thu, Jul 17, 2008 at 04:33:49PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
>     This patch changes tcp_splice_read to the behavior implied by man 2
>     splice:
>     
>          SPLICE_F_NONBLOCK - Do not block on I/O. This makes the splice
>          pipe operations non-blocking, but splice() may nevertheless block
>          because the file descriptors that are spliced to/from may block
>          (unless they have the O_NONBLOCK flag set).
>     
>     This approach also provides a simple solution to the splice
>     transfer size problem. Say we have the following common sequence:
>     
>          splice(socket, pipe);
>          splice(pipe, file);
>     
>     Unless we specify SPLICE_F_NONBLOCK, we can't use arbitrarily large
>     transfer sizes with the 1st splice since otherwise we will deadlock
>     due to pipe being full.  But if we use SPLICE_F_NONBLOCK, the current
>     implementation will make the underlying socket non-blocking and thus
>     will force us use poll or other async I/O notification mechanism.

Existing behaviour was selected to be able to have a progress if socket
does not have enough data to fill the pipe. With your change if socket
is not opened with non-blocking mode reading will block not matter if
SPLICE_F_NONBLOCK is set or not. This is a quite serious break of the
overall idea behind SPLICE_F_NONBLOCK.

Socket will not be marked as non-blocking if SPLICE_F_NONBLOCK is
specified, only splicing will used non-blocking reading, any read via
recv() will use existing socket flags.

-- 
	Evgeniy Polyakov
