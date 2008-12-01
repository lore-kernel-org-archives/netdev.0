From: dann frazier <dannf@hp.com>
Subject: Re: [PATCH] Fix soft lockups/OOM issues w/ unix garbage collector
Date: Mon, 1 Dec 2008 13:17:04 -0700
Message-ID: <20081201201703.GA15884@colo.lackof.org>
References: <20081125231712.GA30297@ldl.fc.hp.com> <20081125.211913.114802735.davem@davemloft.net> <20081126170401.GC30297@ldl.fc.hp.com> <20081126.153243.85669383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eteo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:57950 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbYLAURQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 15:17:16 -0500
Content-Disposition: inline
In-Reply-To: <20081126.153243.85669383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2008 at 03:32:43PM -0800, David Miller wrote:
> From: dann frazier <dannf@dannf.org>
> Date: Wed, 26 Nov 2008 10:04:02 -0700
> 
> > This is an implementation of David Miller's suggested fix in:
> >   https://bugzilla.redhat.com/show_bug.cgi?id=470201
> > 
> > It has been updated to use wait_event() instead of
> > wait_event_interruptible().
> > 
> > Paraphrasing the description from the above report, it makes sendmsg()
> > block while UNIX garbage collection is in progress. This avoids a
> > situation where child processes continue to queue new FDs over a
> > AF_UNIX socket to a parent which is in the exit path and running
> > garbage collection on these FDs. This contention can result in soft
> > lockups and oom-killing of unrelated processes.
> > 
> > Signed-off-by: dann frazier <dannf@hp.com>
> 
> Applied, thanks a lot Dann.

I was asked if this patch may introduce blocking during operations on
non-blocking sockets. Should we update wait_for_unix_gc (and its
callers) to something like this?

int wait_for_unix_gc(bool can_block)
{
    if (!can_block)
        return gc_in_progress ? -EWOULDBLOCK : 0;

    wait_event(unix_gc_wait, gc_in_progress == false);
    return 0;
}

-- 
dann frazier

