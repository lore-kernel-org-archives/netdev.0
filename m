From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: wrong smp_mb__after_atomic() in tcp_check_space() ?
Date: Mon, 23 Jan 2017 18:18:28 +0100
Message-ID: <20170123171828.GA2476@redhat.com>
References: <20170123143025.GA31676@redhat.com>
 <f5f9c542-2b23-9df9-098c-ad4007bf7e78@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert.xu@redhat.com>,
        Yauheni Kaliuta <yauheni.kaliuta@redhat.com>,
        netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35662 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750756AbdAWRSa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 12:18:30 -0500
Content-Disposition: inline
In-Reply-To: <f5f9c542-2b23-9df9-098c-ad4007bf7e78@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23, Jason Baron wrote:
>
> >It was added by 3c7151275c0c9a "tcp: add memory barriers to write space paths"
> >and the patch looks correct in that we need the barriers in tcp_check_space()
> >and tcp_poll() in theory, so it seems tcp_check_space() needs smp_mb() ?
> >
>
> Yes, I think it should be upgraded to an smp_mb() there. If you agree with
> this analysis, I will send a patch to upgrade it.

I think this makes sense, if nothing else to remove the obviously wrong
smp_mb__after_atomic() ;)

> Note, I did not actually
> run into this race in practice.

Yes, I am not sure it is actually necessary in practice, and even if
tcp_check_space() races with tcp_poll() and misses SOCK_NOSPACE it should
be probably called again later, but I know nothing about networking code.

We noticed this by accident, we have a bug report which really looks as a
missed wakeup in epoll, but this kernel is old and in particular it lacks
the commit 128dd1759 "epoll: prevent missed events on EPOLL_CTL_MOD" which
looks more promising. But we are not sure it can fully explain the problem
we can't reproduce, so we are looking for anything else which may contribute
to the problem.

Oleg.
