From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and
 'bindlock'
Date: Fri, 2 Sep 2016 22:25:44 +0200
Message-ID: <44e949ee-1a53-3f6f-6c6e-78d3e8072dbc@stressinduktion.org>
References: <alpine.LFD.2.20.1609021109340.4072@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Dumazet <edumazet@google.com>, willy tarreau <w@1wt.eu>,
        netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:47954 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751691AbcIBUZw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:25:52 -0400
In-Reply-To: <alpine.LFD.2.20.1609021109340.4072@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.09.2016 20:13, Linus Torvalds wrote:
> 
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 1 Sep 2016 14:43:53 -0700
> Subject: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock'
> 
> Right now we use the 'readlock' both for protecting some of the af_unix
> IO path and for making the bind be single-threaded.
> 
> The two are independent, but using the same lock makes for a nasty
> deadlock due to ordering with regards to filesystem locking.  The bind
> locking would want to nest outside the VSF pathname locking, but the IO
> locking wants to nest inside some of those same locks.
> 
> We tried to fix this earlier with commit c845acb324aa ("af_unix: Fix
> splice-bind deadlock") which moved the readlock inside the vfs locks,
> but that caused problems with overlayfs that will then call back into
> filesystem routines that take the lock in the wrong order anyway.
> 
> Splitting the locks means that we can go back to having the bind lock be
> the outermost lock, and we don't have any deadlocks with lock ordering.
> 
> Acked-by: Rainer Weikusat <rweikusat@cyberadapt.com>
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
> 
> This patch is really trivial, and I've tried to be careful and look at the 
> locking, but somebody who really knows the AF_UNIX code should definitely 
> take a second look.
> 
> Note that I did the revert (that re-introduces the original splice 
> deadlock) first, because that made the whole series much easier to 
> explain. Doing it in the other order made the revert nastier because this 
> patch obviously touches the same code that the revert in 1/2 does.
> 
> So this way the series ends up being "go back to the original code with 
> the original deadlock, and then fix that original deadlock by splitting 
> the bind lock".

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
