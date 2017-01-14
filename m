From: Chas Williams <3chas3@gmail.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Sat, 14 Jan 2017 06:34:35 -0500
Message-ID: <1484393675.28370.1.camel@gmail.com>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170113000700.GA1482@electric-eye.fr.zoreil.com>
         <20170113.121001.2197905484527884236.davem@davemloft.net>
         <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
         <1484351674.1643.16.camel@gmail.com>
         <CAM_iQpW+gg5OmBA+xFDVBh7uWcMmPkyQ6D5NCO1Om=YtMiAsNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35045 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbdANLeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 06:34:37 -0500
Received: by mail-qk0-f194.google.com with SMTP id u25so10426035qki.2
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 03:34:37 -0800 (PST)
In-Reply-To: <CAM_iQpW+gg5OmBA+xFDVBh7uWcMmPkyQ6D5NCO1Om=YtMiAsNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 16:30 -0800, Cong Wang wrote:
> On Fri, Jan 13, 2017 at 3:54 PM, Chas Williams <3chas3@gmail.com> wrote:
> > On Fri, 2017-01-13 at 10:20 -0800, Cong Wang wrote:
> >> On Fri, Jan 13, 2017 at 9:10 AM, David Miller <davem@davemloft.net> wrote:
> >> > From: Francois Romieu <romieu@fr.zoreil.com>
> >> > Date: Fri, 13 Jan 2017 01:07:00 +0100
> >> >
> >> >> Were alloc_skb moved one level up in the call stack, there would be
> >> >> no need to use the new wait api in the subsequent page, thus easing
> >> >> pre 3.19 longterm kernel maintenance (at least those on korg page).
> >> >>
> >> >> But it tastes a tad bit too masochistic.
> >> >
> >> > Lack of error handling of allocation failure is always a huge red
> >> > flag.  We even long ago tried to do something like this for TCP FIN
> >> > handling.
> >> >
> >> > It's dumb, it doesn't work.
> >> >
> >> > Therefore I agree that the correct fix is to move the SKB allocation
> >> > up one level to vcc_sendmsg() and make it handle errors properly.
> >>
> >> If you can justify API is not broken by doing that, I am more than happy
> >> to do it, as I already stated in the latter patch:
> >
> > The man page for sendmsg() allows for ENOMEM.  See below.
> >
> 
> Errno is just one part, you miss the behavior behind the logic.
> 
> >>
> >> "Of course, the logic itself is suspicious, other sendmsg()
> >> could handle skb allocation failure very well, not sure
> >> why ATM has to wait for a successful one here. But probably
> >> it is too late to change since the errno and behavior is
> >> visible to user-space. So just leave the logic as it is."
> >>
> >> For some reason, no one reads that patch. :-/
> >
> > I read it and I agree.  I think it should be moved up/conflated with
> > vcc_sendmsg().  vcc_sendmsg() can already return an errno for other
> > conditions so if so has written something where they are explicitly
> > not expecting a ENOMEM, we really can't help them.
> 
> Nope, the reason is never ENOMEM is expected or not. The current
> _behavior_ behind this logic might be relied on by user-space.
> The behavior here is, when allocation fails, kernel will retry under
> certain circumstances, for example, if any fatal signal pending,
> returns ERESTARTSYS, etc.. This is what I worry, not just ENOMEM
> or not, which is too obvious.

Yes, and that behavior is certainly wrong.  Proving that nothing relies
on it would be very difficult since this is a negative supposition.

It's not clear to me that it is a good idea to ignore the pending signal
and just send the data.  At best, this seems like the signal is getting
ignored when the program might actaully want to do something about it.
The way the vcc sockets work, you are almost always waiting for "space
available to send".  Since vcc_sendmsg() has always been able to return
ERESTARTSYS for this condition, this isn't exactly new behavior, it
could just happen (very) slightly more often.

The loop in alloc_tx() also ignores the MSG_DONTWAIT flag.  The user
might end up waiting after all.  So that seems broken as well.  If
someone is expecting to wait with MSG_DONTWAIT when memory pressure
is present, I can't help them.  They are insane.

> Of course, I could be too conservative, I'd rather not to break things
> for -stable at least.
> 
> Thanks.
