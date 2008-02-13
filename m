From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Wed, 13 Feb 2008 07:29:08 +0000
Message-ID: <20080213072908.GA2542@ff.dom.local>
References: <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080212.220003.108906105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:61275 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757129AbYBMHV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 02:21:56 -0500
Received: by fg-out-1718.google.com with SMTP id e21so4310488fga.17
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 23:21:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080212.220003.108906105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2008 at 10:00:03PM -0800, David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Tue, 12 Feb 2008 10:58:21 +0000
> 
> > Here is a trace from when we had _bh locks.
> 
> The problem is that the pppol2tp code calls sk_dst_get() in software
> interrupt context and that is not allowed.

Actually, this lockdep report probably warns of something else:
sk_dst_lock which is seen in process context with softirqs enabled
implicitly endangers some other (ppp_generic) locks, which depend
on ppp_generic pch->upl read_lock, which is taken in softirq context.

I can't see on this report any hardirqs dependancies, so it seems even
blocking hard interrupts, just like in this patch, shouldn't solve
this problem: if BHs were really disabled in exactly the same places,
then it seems this warning should trigger in both variants.

I studied long ago some similar problem with pppoe, and it looked like
ppp_generic needed some fix, but now I've to recall or re-learn almost
all and it needs more time... Anyway, there is a possibility, this
warning isn't so dangerous.

> sk_dst_get() grabs sk->sk_dst_lock without any BH enabling or
> disabling.
> 
> It can do that because the usage is to make all the lock
> taking calls in user context, and in the packet processing
> paths use __sk_dst_get().

BTW, does it mean that ip4_datagram_connect() can be used only in user
context?

> Probably what the pppol2tp code should do is use __sk_dst_check()
> instead of sk_dst_get().  You then have to be able to handle
> NULL returns, just like UDP sendmsg() does, which means you'll
> need to cook up a routing lookup if __sk_dst_check() gives you
> NULL because the route became obsolete.

I think that without changing ppp_generic or changing ip_queue_xmit()
to something else in pppol2tp this would be really hard to avoid such
a warning (and maybe not very necessary).

Regards,
Jarek P.
