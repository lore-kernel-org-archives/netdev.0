From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Netpoll triggers soft lockup
Date: Thu, 11 Apr 2013 10:08:10 -0400
Message-ID: <20130411140809.GC8986@neilslaptop.think-freely.org>
References: <5166BDAA.3000603@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53935 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513Ab3DKOIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:08:21 -0400
Content-Disposition: inline
In-Reply-To: <5166BDAA.3000603@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 03:42:02PM +0200, Bart Van Assche wrote:
> Hi,
> 
> While testing a driver against kernel 3.9-rc6 I ran into a soft
> lockup triggered by sending lots of kernel messages to a remote
> system via netconsole. This behavior was probably introduced by
> commit ca99ca14c ("netpoll: protect napi_poll and poll_controller
> during dev_[open|close]"). That commit introduced a mutex in
> netpoll_poll_dev(), which can be called from interrupt context. Is
> there anyone who can tell me whether this is a bug in commit
> ca99ca14c or in netconsole ?
> 
Thanks for the report Bart, thats interesting.  You're right, the problem was
introduced by ca99ca14c, but it seems like a false positive to me.  The warning
is comming from DEBUG_LOCKS_WARN_ON in spin_lock_mutex.  It appears that the
intent here is to catch users of spin_lock_mutex (which is the mutex api), from
trying to use mutex locking in interrupt context as that results in a panic.  In
this case however, we're using the mutex_trylock call, which is guaranteed not
to sleep (which is the nature of the panic condition).  So we really don't need
to warn here.  I think the right thing to do in this case is to add a flag to
spin_lock_mutex that skips the warning if we're doing a trylock operation.  I'll
work up a patch shortly.

Thanks again!
Neil
