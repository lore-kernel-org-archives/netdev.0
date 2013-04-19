From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Fri, 19 Apr 2013 10:38:02 +0200
Message-ID: <20130419083802.GA27023@gmail.com>
References: <5166BDAA.3000603@acm.org>
 <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
 <5166F35B.1040200@acm.org>
 <20130411191409.GA9790@hmsreliant.think-freely.org>
 <5167A953.1020900@acm.org>
 <20130412113232.GA19966@hmsreliant.think-freely.org>
 <516813A0.1040300@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:60141 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757672Ab3DSIiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 04:38:07 -0400
Received: by mail-ee0-f42.google.com with SMTP id e49so948602eek.15
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 01:38:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <516813A0.1040300@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Bart Van Assche <bvanassche@acm.org> wrote:

> WARNING: at kernel/mutex.c:313 __mutex_unlock_slowpath+0x157/0x160()
> Pid: 181, comm: kworker/0:1H Tainted: G           O 3.9.0-rc6-debug+ #1
> Call Trace:
> <IRQ>  [<ffffffff8103c3ef>] warn_slowpath_common+0x7f/0xc0
> [<ffffffff8103c44a>] warn_slowpath_null+0x1a/0x20
> [<ffffffff81432047>] __mutex_unlock_slowpath+0x157/0x160
> [<ffffffff8143205e>] mutex_unlock+0xe/0x10
> [<ffffffff8136d031>] netpoll_poll_dev+0x111/0x9a0
> [<ffffffff81345f32>] ? __alloc_skb+0x82/0x2a0
> [<ffffffff8136dac5>] netpoll_send_skb_on_dev+0x205/0x3b0
> [<ffffffff8136e00a>] netpoll_send_udp+0x28a/0x3a0
> [<ffffffffa0524843>] ? write_msg+0x53/0x110 [netconsole]
> [<ffffffffa05248bf>] write_msg+0xcf/0x110 [netconsole]
> [<ffffffff8103d7f1>] call_console_drivers.constprop.16+0xa1/0x120
> [<ffffffff8103e848>] console_unlock+0x3f8/0x450
> [<ffffffff8103ecce>] vprintk_emit+0x1ee/0x510
> [<ffffffff812d1f2c>] dev_vprintk_emit+0x5c/0x70
> [<ffffffff810ff047>] ? mempool_free_slab+0x17/0x20

I *really* think that using a mutex from a low level debug interface like netpoll 
is a mistake. We want such interfaces to be as atomic and as self-contained as 
possible: using spinlocks, which could possibly be converted to raw spinlocks, 
etc.

mutexes should be used when there's an expectation of possibly long blocking time. 
That's not really the case for netpoll, we either are able to generate the skb 
right then and send it off, or we are in trouble, right?

Thanks,

	Ingo
