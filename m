From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] fix BUG: scheduling while atomic in netlink broadcast
Date: Fri, 19 May 2017 13:58:10 -0700
Message-ID: <CAM_iQpWN36px=Kjbde-y93LboFMVxMVLPcFi9Hx=5fkvpo8ndA@mail.gmail.com>
References: <CAN-7y0oY=LyeLTxhC5L+Vjy-NivmRJSBpqPP9+NYT7a=NFV0_A@mail.gmail.com>
 <CAM_iQpXraspjEvh9Wy5jOscFz7zKS4Z3XsigxCJFJ5_RuCOnyw@mail.gmail.com> <CAN-7y0rZV-coOpOAzVGZoZB=Mzo4LP7Jpxx3wk+PX_jNMr_=iA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Akshay Narayan <akshayn@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34132 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932415AbdESU6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:58:36 -0400
Received: by mail-wm0-f47.google.com with SMTP id 123so2740900wmg.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 13:58:36 -0700 (PDT)
In-Reply-To: <CAN-7y0rZV-coOpOAzVGZoZB=Mzo4LP7Jpxx3wk+PX_jNMr_=iA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 11:47 AM, Akshay Narayan <akshayn@mit.edu> wrote:
>> I don't want to defend the use of yield() but it looks like there is other
>> problem.
>
> I believe this use of yield() should be replaced with cond_resched()
> even if it turns out there is an unrelated problem.

Yeah, it is a different problem, because cond_resched() itself could
sleep too so it doesn't fix the schedule-in-atomic problem, not to
mention the kmalloc() would sleep.

>
>> Does this module call netlink_broadcast() with __GFP_DIRECT_RECLAIM
>> in IRQ context? If so you should adjust the gfp flags.
>
> The module only calls netlink_broadcast() from a pluggable TCP
> function; from my understanding this is not in the IRQ context. Full
> trace, perhaps more clear, attached below.

It is process context but with a spinlock (bh_lock_sock) held, so
you still can't sleep. IOW, you have to pass a proper gfp flag to
reflect this.
