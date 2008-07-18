From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 18:50:07 +0300
Message-ID: <200807181850.07393.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807181704.17211.opurdila@ixiacom.com> <20080718143219.GA905@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	axboe@kernel.dk
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2658 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755810AbYGRPwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 11:52:14 -0400
In-Reply-To: <20080718143219.GA905@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Why? There is clearly documented behaviour of the call, it works exactly
> like it is supposed to work - it tries to be non-blocking everywhere
> where it can, but not always, that's why there is a sentence which
> states that even with given flag call may block.

I think that it tries a bit too hard to be non-blocking in the TCP receive 
implementation, and that is causing problems for some usecases. 

And (sorry for saying this again - it will be the last time) to me it looks 
like SPLICE_F_NONBLOCK is intended for the pipe only:

commit 29e350944fdc2dfca102500790d8ad6d6ff4f69d
Author: Linus Torvalds <torvalds@g5.osdl.org>
Date:   Sun Apr 2 12:46:35 2006 -0700

    splice: add SPLICE_F_NONBLOCK flag
    
    It doesn't make the splice itself necessarily nonblocking (because the
    actual file descriptors that are spliced from/to may block unless they
    have the O_NONBLOCK flag set), but it makes the splice pipe operations
    nonblocking.

>
> If there are 20 packets in the queue it will get 16 and put them into
> another end (in the next call in your example). Where will it block?
>

It will take 17 because this is what the user requested. And when trying to 
push the 17th on the pipe, it will block. I base this both on experiments and 
on my understanding of the tcp splice receive implementation. 

>
> I really do not think that there is any kind of problem with current
> behaviour, and thus there is no need to introduce additional flags
> and/or change existing behaviour, but I can understand you that existing
> approach does not met your expectation, so you are trying to change it.
> I've added Jens Axboe to copy list, who is responsible for splice
> design.
>
> Btw, you are also trying to change existing userspace API, which may be
> very much forbidden at this stage.

If people here will be telling me that for splice you must always use 
non-blocking I/O since you can't get the blocking case to work reliably, than 
I will accept that. After all, they know better :) 

Thanks,
tavi
