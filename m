From: Chas Williams <3chas3@gmail.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 18:54:34 -0500
Message-ID: <1484351674.1643.16.camel@gmail.com>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170113000700.GA1482@electric-eye.fr.zoreil.com>
         <20170113.121001.2197905484527884236.davem@davemloft.net>
         <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33263 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdAMXyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 18:54:37 -0500
Received: by mail-qk0-f194.google.com with SMTP id 11so9205790qkl.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 15:54:36 -0800 (PST)
In-Reply-To: <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 10:20 -0800, Cong Wang wrote:
> On Fri, Jan 13, 2017 at 9:10 AM, David Miller <davem@davemloft.net> wrote:
> > From: Francois Romieu <romieu@fr.zoreil.com>
> > Date: Fri, 13 Jan 2017 01:07:00 +0100
> >
> >> Were alloc_skb moved one level up in the call stack, there would be
> >> no need to use the new wait api in the subsequent page, thus easing
> >> pre 3.19 longterm kernel maintenance (at least those on korg page).
> >>
> >> But it tastes a tad bit too masochistic.
> >
> > Lack of error handling of allocation failure is always a huge red
> > flag.  We even long ago tried to do something like this for TCP FIN
> > handling.
> >
> > It's dumb, it doesn't work.
> >
> > Therefore I agree that the correct fix is to move the SKB allocation
> > up one level to vcc_sendmsg() and make it handle errors properly.
> 
> If you can justify API is not broken by doing that, I am more than happy
> to do it, as I already stated in the latter patch:

The man page for sendmsg() allows for ENOMEM.  See below.

> 
> "Of course, the logic itself is suspicious, other sendmsg()
> could handle skb allocation failure very well, not sure
> why ATM has to wait for a successful one here. But probably
> it is too late to change since the errno and behavior is
> visible to user-space. So just leave the logic as it is."
> 
> For some reason, no one reads that patch. :-/

I read it and I agree.  I think it should be moved up/conflated with
vcc_sendmsg().  vcc_sendmsg() can already return an errno for other
conditions so if so has written something where they are explicitly
not expecting a ENOMEM, we really can't help them.

I would certainly prefer to not have to resort to an atomic allocation.
That's just going to make matters worse as far as similarity to the
existing API.

So, as Francois has suggested, just wait for the atm socket to
drain, and then do the allocation after the wait is finished.
