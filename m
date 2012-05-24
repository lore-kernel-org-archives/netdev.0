From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
Date: Thu, 24 May 2012 15:20:09 +0200
Message-ID: <201205241529.37684.hans.schillstrom@ericsson.com>
References: <1337864467.13491.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:48903 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481Ab2EXN3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 09:29:41 -0400
In-Reply-To: <1337864467.13491.15.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper
We are also working with this issue right now,

On Thursday 24 May 2012 15:01:07 Jesper Dangaard Brouer wrote:
> Hi Eric,
> 
> I have been doing some TCP performance measurements with SYN flooding,
> and have found that, we don't handle this case well.
> 
> I have made a patch for fast/early SYN handling in tcp_v4_rcv() in
> net/ipv4/tcp_ipv4.c.  This increases SYN performance from 130 kpps to
> 750 kpps (max of the generator), with idle CPU cycles.
> 
> Current locking:
>  During a SYN flood (against a single port) all CPUs are spinning on
> the same spinlock, namely bh_lock_sock_nested(sk), in tcp_ipv4.c.  The
> lock dates back to a commit by DaveM in May 1999, see historic
> commit[1].  It seem that TCP runs fully locked, per sock.
> 
> I need some help with locking, as the patch seems to work fine, with
> NO-PREEMPT, but with PREEMPT enabled I start to see warnings (in
> reqsk_queue_destroy) and oopses (in inet_csk_reqsk_queue_prune).
> 
> What am I missing?
> 
> [1] Historic commit: http://git.kernel.org/?p=linux/kernel/git/davem/netdev-vger-cvs.git;a=commitdiff;h=5744fad55cefbd6f079410500a507443d92d63ff
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
> 
> [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
> 
> TCP SYN handling is on the slow path via tcp_v4_rcv(), and is
> performed while holding spinlock bh_lock_sock().
> 
> Real-life and testlab experiments show, that the kernel choks
> when reaching 130Kpps SYN floods (powerful Nehalem 16 cores).
> Measuring with perf reveals, that its caused by
> bh_lock_sock_nested() call in tcp_v4_rcv().

I can confirm this too, and it doesn't scale with more cores

> 
> With this patch, the machine can handle 750Kpps (max of the SYN
> flood generator) with cycles to spare.
This looks great.

I'm also working with a solution that not trash conntack
i.e. have conntrack working during a heavy SYN attack

-- 
Regards
Hans Schillstrom 
