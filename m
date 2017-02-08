From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: use-after-free in tw_timer_handler
Date: Wed, 08 Feb 2017 09:58:36 -0800
Message-ID: <1486576716.7793.84.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+a2t=Ev1-Mp6+aHzRkNPhWaY-dSYRdMeL2Hp7b37bnbUg@mail.gmail.com>
         <CACT4Y+ba65AD9qpjjJqM=_Pn333iWTm86BNmy2A5_EqHTY_kWA@mail.gmail.com>
         <1485268138.16328.297.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+b=-XJCwofbCRo6BnKJRU=amd7pxYpNrGdPEFT0bAtJaQ@mail.gmail.com>
         <CANn89iK=5uPEDLpM6=JAKzJ=1GuSSiXw5b_8BrkVUvhYRi_9mw@mail.gmail.com>
         <CACT4Y+bRP9ffnXDJeOD5VkqFw+-cDHh4hEVzcnv3vnHh+vdqBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34635 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdBHSan (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:30:43 -0500
In-Reply-To: <CACT4Y+bRP9ffnXDJeOD5VkqFw+-cDHh4hEVzcnv3vnHh+vdqBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-08 at 18:36 +0100, Dmitry Vyukov wrote:
> On Tue, Jan 24, 2017 at 4:52 PM, Eric Dumazet <edumazet@google.com> wrote:
> > On Tue, Jan 24, 2017 at 7:06 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> >>>
> >>> This code was changed a long time ago :
> >>>
> >>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ed2e923945892a8372ab70d2f61d364b0b6d9054
> >>>
> >>> So I suspect a recent patch broke the logic.
> >>>
> >>> You might start a bisection :
> >>>
> >>> I would check if 4.7 and 4.8 trigger the issue you noticed.
> >>
> >>
> >> It happens with too low rate for bisecting (few times per day). I
> >> could add some additional checks into code, but I don't know what
> >> checks could be useful.
> >
> > If you can not tell if 4.7 and/or 4.8 have the problem, I am not sure
> > we are able to help.
> 
> 
> There are also chances that the problem is older.
> 
> Looking at the code, this part of inet_twsk_purge looks fishy:
> 
> 285                         if (unlikely((tw->tw_family != family) ||
> 286                                      atomic_read(&twsk_net(tw)->count))) {
> 
> It uses net->count == 0 check to find the right sockets. But what if
> there are several nets with count == 0 in flight, can't there be
> several inet_twsk_purge calls running concurrently freeing each other
> sockets? If so it looks like inet_twsk_purge can call
> inet_twsk_deschedule_put twice for a socket. Namely, two calls for
> different nets discover the socket, check that net->count==0 and both
> call inet_twsk_deschedule_put. Shouldn't we just give inet_twsk_purge
> net that it needs to purge?

Yes, atomic_read() is not a proper sync point.

> The second issue that I noticed is that tw_refcnt is set to 4 _after_
> we schedule the timer. The timer will probably won't fire before we
> set tw_refcnt, but if it somehow does it will corrupt the ref count. I
> don't think that it's what I am seeing, though. More likely it's the
> first issues (if it's real).
> 

Timer is pinned, it cannot fire under us on this cpu.
