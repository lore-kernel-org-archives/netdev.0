From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Mon, 21 Aug 2006 01:17:03 -0700 (PDT)
Message-ID: <20060821.011703.78716718.davem@davemloft.net>
References: <20060817093615.GA25553@ms2.inr.ac.ru>
	<20060821081642.GA2637@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56288
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030378AbWHUIQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:16:51 -0400
To: jarkao2@o2.pl
In-Reply-To: <20060821081642.GA2637@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Mon, 21 Aug 2006 10:16:43 +0200

> On 17-08-2006 11:36, Alexey Kuznetsov wrote:
> > Hello!
> >
> > [IPV4]: severe locking bug in fib_semantics.c
> >
> > The patch is for net-2.6.19, but the bug is present in all the kernels
> > since yore.
> >
> > Found in 2.4 by Yixin Pan <yxpan@hotmail.com>. Why do we need lockdep,
> > when sharp-sighted eyes are available? :-)
> >
> >> When I read fib_semantics.c of Linux-2.4.32, write_lock(&fib_info_lock) =
> >> is used in fib_release_info() instead of write_lock_bh(&fib_info_lock).  =
> >> Is the following case possible: a BH interrupts fib_release_info() while =
> >> holding the write lock, and calls ip_check_fib_default() which calls =
> >> read_lock(&fib_info_lock), and spin forever.
> 
> But I hope the real reason for this patch isn't exactly like that.
> Could fib_release_info() be interrupted by BH really?

Absolutely, yes it can.  What makes you think it can't?

All of the call sites I have checked cause it to run with
BH's enabled, and that allows ip_fib_check_default() to
potentially run.  All we need is one such case to cause
the deadlock.

I was skeptical of this case too, until I checked how
fib_release_info() was called.
