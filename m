From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 3 Aug 2006 13:17:31 -0400
Message-ID: <20060803171731.GE20603@thunk.org>
References: <20060803075704.GC27835@thunk.org> <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au> <20060803163204.GB20603@thunk.org> <1154623598.19547.52.camel@c-67-188-28-158.hsd1.ca.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:6047 "EHLO thunker.thunk.org")
	by vger.kernel.org with ESMTP id S932585AbWHCRRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 13:17:43 -0400
To: Daniel Walker <dwalker@mvista.com>
Content-Disposition: inline
In-Reply-To: <1154623598.19547.52.camel@c-67-188-28-158.hsd1.ca.comcast.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 09:46:37AM -0700, Daniel Walker wrote:
> There is some form of priority inheritance on the timer softirq. It said
> in the patch header that the right fix was for the timer softirq to
> change priorities. Which Real Time patch are you using? Or is the
> current system not sufficient ?

We're using a someone older version of the CONFIG_PREEMPT_RT patches
(2.6.16-rt22, with various bug fixes pulled up to what we are
running.)

There is priority inheritance on the hrtimers, but not on normal
timers, and conversations with Thomas and Stephen at OLS indicated
this is on the wishlist, but it has not happened yet.  As I mentioned
in the patch comments, I looked at hacking hrtimers into the tg3
driver code, but (a) the hrtimers code assume that the priority
inheritance happens when a process is associated with the hrtimer and
the process is a high priority process, and (b) the hrtimers code
aren't exported for use by modules.  So I went with a very quick hack,
since we have a hard code freeze for a customer deliverable.

In the long term, we're going to need something a bit more
sophisticated than what we have in the hrtimers code, since not all
code which requests timers are necessarily associated with a process.
The tg3_timer() code, for example, is trigger by the device driver but
isn't associated with a process for boosting purposes, and creating a
process just so that tg3_timer() can be boosted seems like the Wrong
Thing.    

In addition, the timer wheel code has a *large* number of timers that
get added and then removed without ever getting expired by the TCP
networking code, and I'm not at all convinced that the technique used
for doing prio boosting for the hrtimers will scale to what is needed
for normal timers.

						- Ted




